Get[FileNameJoin[{DirectoryName[$InputFileName],"..","common","s22_paths.wl"}]];
(* Existing virtual numerators multiplied by the new Kira reduction. *)
$HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
root=sidisRoot;
gate[name_,test_] := If[!TrueQ[test],Print["FAIL: ",name];
  If[$KernelID>0,Throw[$Failed,"S18Failure"],CloseKernels[];Quit[1]]];
put[value_,file_] := (Put[value,file<>".tmp"];RenameFile[file<>".tmp",file,OverwriteTarget->True]);
SetAttributes[bounded,HoldFirst];
bounded[value_,label_] := MemoryConstrained[TimeConstrained[value,1200,
  gate[label<>" time limit",False]],2*1024^3,gate[label<>" memory limit",False]];
manifest=sidisGet[sidisPath[{root,"s05_result.wl"}]];
reduction=sidisGet[sidisPath[{root,"s09_result.wl"}]];
parents=sidisGet[sidisPath[{root,"s12_result.wl"}]];
gate["accepted virtual maps and reduction",And@@(TrueQ[#["Accepted"]]& /@{manifest,reduction,parents})];
canonical=Association[reduction["CanonicalizationRules"]];rules=Association[reduction["Rules"]];
masters=reduction["Masters"];
sourceHash=sidisHash[$InputFileName,"SHA256"];
inputHashes=Association@Table[name->sidisHash[sidisPath[{root,name}],"SHA256"],
  {name,{"s05_result.wl","s09_result.wl","s12_result.wl"}}];
inputHash=Hash[{sourceHash,inputHashes},"SHA256"];
valuation[expression_] := If[expression===0,Infinity,With[{rational=Together[expression/.D->4-2eps]},
  Exponent[Numerator[rational],eps,Min]-Exponent[Denominator[rational],eps,Min]]];
collect[channel_,mode_,diagrams_,channelHash_] := Catch[Module[
  {hash,directory,file,saved,values,terms,orders,packet,diagram,master},
  hash=Hash[{inputHash,channelHash,mode},"SHA256"];
  directory=sidisPath[{root,channel,"s18_cache",IntegerString[hash,16]}];
  If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
  file=sidisPath[{directory,"s18_result.wl"}];
  If[FileExistsQ[file],saved=sidisGet[file];If[saved["InputHash"]===hash&&TrueQ[saved["Accepted"]],Return[saved]]];
  Print["VIRTUAL_COEFFICIENTS ",channel," ",mode," kernel ",$KernelID];
  Do[gate["all diagram targets have canonical Kira rules",
    Complement[Keys[diagram["Coefficients"]],Keys[canonical]]==={}&&
    Complement[canonical/@Keys[diagram["Coefficients"]],Keys[rules]]==={}],{diagram,diagrams}];
  values=Association@Table[
    terms=Table[bounded[Factor[Together[Total[KeyValueMap[
      #2 Coefficient[rules[canonical[#1]],master]&,diagram["Coefficients"]]]]],
      "diagram coefficient reduction"],{diagram,diagrams}];
    master->bounded[Factor[Together[Total[terms]]],"virtual master coefficient sum"],{master,masters}];
  gate["virtual coefficients are scalar rational functions",FreeQ[values,_GLI|_Real|_PaVe|_Integrate|$Failed|$Aborted]];
  orders=Map[If[#===Infinity,0,Max[0,-#]]&,Map[valuation,values]];
  packet=<|"Channel"->channel,"Mode"->mode,"Coefficients"->values,"RequiredOrders"->orders,
    "InputHash"->hash,"ChannelHash"->channelHash,"SourceHash"->sourceHash,"Accepted"->True|>;
  put[packet,file];ClearSystemCache[];Print["VIRTUAL_COEFFICIENTS_ACCEPTED ",channel," ",mode];packet],"S18Failure"];
slots=Quiet[Check[ToExpression[Environment["NSLOTS"]],1]];
If[!IntegerQ[slots]||slots<1,slots=1];CloseKernels[];
If[slots>1,LaunchKernels[KernelConfiguration["localhost","KernelCommand"->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel","KernelCount"->Min[4,slots],"TimeConstraint"->60]]];
workers=Length[Kernels[]];
If[workers>0,ParallelEvaluate[$HistoryLength=0];DistributeDefinitions[gate,put,bounded,valuation,
  collect,root,sourceHash,inputHash,canonical,rules,masters]];
$DistributedContexts=None;outputs=<||>;allOrders={};
Do[
  file=sidisPath[{root,channel,"s05_result.wl"}];data=sidisGet[file];hash=sidisHash[file,"SHA256"];
  gate[channel<>" virtual input identity",TrueQ[data["Accepted"]]&&hash===manifest["Channels"][channel]["Hash"]];
  modes=DeleteDuplicates[Lookup[data["DiagramMaps"],"Mode"]];
  tasks=Table[{channel,mode,Select[data["DiagramMaps"],#["Mode"]===mode&],hash},{mode,modes}];
  values=If[workers>0,ParallelMap[collect@@#&,tasks,Method->"FinestGrained"],collect@@#& /@tasks];
  gate[channel<>" all projector coefficients collected",FreeQ[values,$Failed|$Aborted]&&And@@Lookup[values,"Accepted"]];
  allOrders=Join[allOrders,Lookup[values,"RequiredOrders"]];
  result=Join[KeyTake[data,{"Channel","InitialAverage","ModelChargeSquared","BornScalarProducts",
    "Measure","CouplingsRemoved","InterferenceConvention"}],
    <|"Components"->AssociationThread[modes,values],"Masters"->masters,"SourceHash"->sourceHash,
      "InputHashes"->inputHashes,"Accepted"->True,"MasterEvaluationPerformed"->False|>];
  file=sidisPath[{root,channel,"s18_result.wl"}];put[result,file];
  AssociateTo[outputs,channel-><|"File"->channel<>"/s18_result.wl","Hash"->sidisHash[file,"SHA256"]|>];
  Clear[data,tasks,values,result];ClearSystemCache[],{channel,{"Hqq","Hqg","Hgq"}}];
CloseKernels[];
requiredOrders=Merge[allOrders,Max];
put[<|"ActualCoefficientOrders"->requiredOrders,"PlannedOrders"->Map[#["RequiredOrder"]&,parents["VirtualMasterParents"]]|>,
  sidisPath[{root,"s18_required_orders.wl"}]];
gate["parent evaluations cover the full coefficient-required epsilon orders",And@@KeyValueMap[
  parents["VirtualMasterParents"][#1]["RequiredOrder"]>=#2&,requiredOrders]];
put[<|"Channels"->outputs,"RequiredOrders"->requiredOrders,"SourceHash"->sourceHash,
  "InputHashes"->inputHashes,"Accepted"->True|>,sidisPath[{root,"s18_result.wl"}]];
Print["S18_SUCCESS: all virtual coefficients collected in the new Kira master basis."];
Quit[0];
