Get[FileNameJoin[{DirectoryName[$InputFileName],"..","common","s22_paths.wl"}]];
(* Assemble the new real cut integrals in the inherited distribution convention. *)
$HistoryLength=0;
root=sidisRoot;
gate[name_,test_] := If[!TrueQ[test],Print["FAIL: ",name];
  If[$KernelID>0,Throw[$Failed,"S17Failure"],CloseKernels[];Quit[1]]];
put[value_,file_] := (Put[value,file<>".tmp"];RenameFile[file<>".tmp",file,OverwriteTarget->True]);
SetAttributes[bounded,HoldFirst];
bounded[value_,label_] := MemoryConstrained[TimeConstrained[value,1200,
  gate[label<>" time limit",False]],2*1024^3,gate[label<>" memory limit",False]];
inputs=sidisGet[sidisPath[{root,"s08_result.wl"}]];
evaluations=sidisGet[sidisPath[{root,"s10_result.wl"}]];
manifest=sidisGet[sidisPath[{root,"s11_result.wl"}]];
regions=sidisGet[sidisPath[{root,"s15_result.wl"}]];
gate["accepted new cut evaluations and regions",TrueQ[inputs["AcceptedRepresentations"]]&&
  TrueQ[evaluations["CutNormalizationAccepted"]]&&TrueQ[manifest["Accepted"]]&&
  TrueQ[regions["AcceptedCutMasterRegions"]]];
sourceHash=sidisHash[$InputFileName,"SHA256"];
inputHashes=Association@Table[name->sidisHash[sidisPath[{root,name}],"SHA256"],
  {name,{"s08_result.wl","s10_result.wl","s11_result.wl","s15_result.wl"}}];
gate["region inputs match the current cut evaluations",KeyTake[inputHashes,Keys[regions["InputHashes"]]]===regions["InputHashes"]];
inputHash=Hash[{sourceHash,inputHashes},"SHA256"];
branchAssumptions[sign_] := Q2>0&&s>0&&omega>0&&B>0&&
  -Q2-s<sign omega-s<0&&SUNN>1&&Nc>1;
reduce[value_,assumptions_] := Module[{refined,functions},
  refined=Refine[value,assumptions];
  functions=DeleteDuplicates[Cases[refined,_Log|_PolyLog|_ArcTan|_Re|_Im,Infinity]];
  Collect[Expand[refined],functions,Factor]];
epsilonSeries[value_,order_,label_] := Module[{series},
  series=bounded[Series[value,{eps,0,order}],label];
  gate[label<>" regulator coverage",FreeQ[series,eps|_SeriesData|_Series]||(MatchQ[series,_SeriesData]&&series[[5]]>order)];
  Normal[series]];
endpointIntegral=Integrate[rr^(-1-kap ep),{rr,0,B},
  Assumptions->kap>0&&ep<0&&B>0,GenerateConditions->False];
gate["regulated endpoint integral evaluated",FreeQ[endpointIntegral,_Integrate|_ConditionalExpression]];
logKernel=Normal[Series[Exp[-kap ep ellLog],{ep,0,2}]];
laurentProduct[laurent_,kernel_,order_] := Module[{polynomial=Expand[laurent],first,last},
  If[polynomial===0,Return[0]];
  first=Exponent[polynomial,eps,Min];last=Exponent[polynomial,eps];
  Total@Table[eps^n Coefficient[polynomial,eps,n] Normal[Series[kernel,{eps,0,order-n}]],{n,first,last}]];

softPieces[master_,sign_] := softPieces[master,sign]=Module[
  {data,metadata,assumptions,replacement,power,prefactor,value,pieces={},entry,
   definition,parameterRules,lambdaForm,lambdaPower,lambdaRegular,totalPower,regular},
  data=inputs["Masters"][master];metadata=regions["Masters"][master];
  assumptions=branchAssumptions[sign]&&w>0;
  replacement=t->sign omega-s;
  power=metadata["PrefactorSoftPower"];
  prefactor=bounded[FullSimplify[(data["RegulatedPrefactor"]/w^power)/.replacement,
    assumptions&&Element[eps,Reals]],"remove regulated cut recoil power"];
  If[metadata["DivergentParameters"]==={},
    value=(evaluations["Classes"][data["Class"]]["Series"]/.SubTropica`eps->eps)/.
      data["PhysicalSubstitutions"]/.replacement;
    Return[{<|"Power"->power,"Regular"->prefactor value|>}]];
  definition=regions["RegionMasterMap"][master]["ParameterDefinition"];
  parameterRules=Solve[First[definition]==Last[definition],SubTropica`\[Lambda]];
  gate["unique physical soft-region parameter",Length[parameterRules]===1];
  lambdaForm=Factor[SubTropica`\[Lambda]/.First[parameterRules]/.data["PhysicalSubstitutions"]/.replacement];
  lambdaPower=bounded[FullSimplify[Limit[w D[lambdaForm,w]/lambdaForm,w->0,
    Direction->"FromAbove",Assumptions->branchAssumptions[sign]],branchAssumptions[sign]],"region recoil valuation"];
  gate["region recoil valuation is a positive integer",IntegerQ[lambdaPower]&&lambdaPower>0];
  lambdaRegular=Factor[lambdaForm/w^lambdaPower];
  gate["region expansion remains on its positive physical side",
    FullSimplify[Limit[lambdaRegular,w->0,Direction->"FromAbove",Assumptions->branchAssumptions[sign]]>0,
      branchAssumptions[sign]]];
  Do[
    value=regions["RegionValues"][entry["IntegralID"]]["Series"];
    If[value===0,Continue[]];
    totalPower=Expand[power+lambdaPower(entry["LambdaPower"]/.SubTropica`eps->eps)];
    regular=prefactor lambdaRegular^(entry["LambdaPower"]/.SubTropica`eps->eps) value;
    AppendTo[pieces,<|"Power"->totalPower,"Regular"->regular,"Region"->entry["Region"]|>],
    {entry,regions["RegionMasterMap"][master]["Entries"]}];pieces];

pieceEndpoint[piece_,sign_] := pieceEndpoint[piece,sign]=bounded[
  FullSimplify[Limit[piece["Regular"],w->0,Direction->"FromAbove",
    Assumptions->branchAssumptions[sign]&&Element[eps,Reals]],
    branchAssumptions[sign]&&Element[eps,Reals]],"regular master endpoint"];
softRows[coefficient_,piece_,sign_] := Module[
  {power=piece["Power"],integerPower,kappa,rational,valuation,firstPower,leading,value},
  integerPower=power/.eps->0;kappa=-Coefficient[power,eps];
  gate["regulated soft power is affine with integer recoil degree",
    IntegerQ[integerPower]&&PolynomialQ[power,eps]&&Exponent[power,eps]<=1];
  rational=Cancel[coefficient/.t->sign omega-s];
  valuation=Exponent[Numerator[rational],w,Min]-Exponent[Denominator[rational],w,Min];
  firstPower=valuation+integerPower;
  If[firstPower>=0,Return[{}]];
  gate["measured recoil degree needs only a leading endpoint coefficient",firstPower===-1];
  leading=Factor[Cancel[w^(-valuation)rational]/.w->0];
  gate["rational endpoint coefficient is finite",FreeQ[leading,w|Indeterminate|ComplexInfinity|_DirectedInfinity]];
  value=epsilonSeries[(leading/.D->4-2eps)pieceEndpoint[piece,sign],1,"leading soft epsilon coefficient"];
  value=bounded[reduce[value,branchAssumptions[sign]],"leading endpoint collection"];
  gate["endpoint coefficients are fully evaluated",FreeQ[value,w|_Limit|_Derivative|_Series|_SeriesData|Indeterminate|ComplexInfinity]];
  If[value===0,{},{{kappa,firstPower,value}}]];

assemble[channel_,key_,component_,channelHash_] := Catch[Module[
  {hash,directory,file,saved,coefficients,ordinary,terms,branches,sign,rows,groups,combined,
   assumptions,endpoints,delta,plus,regular,value,result,master},
  hash=Hash[{inputHash,channelHash,key},"SHA256"];
  directory=sidisPath[{root,channel,"s17_cache",IntegerString[hash,16]}];
  If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
  file=sidisPath[{directory,"s17_result.wl"}];
  If[FileExistsQ[file],saved=sidisGet[file];If[saved["InputHash"]===hash&&TrueQ[saved["Accepted"]],Return[saved]]];
  Print["REAL_ASSEMBLY ",channel," ",key," kernel ",$KernelID];
  coefficients=Select[component["Coefficients"],#=!=0&];
  terms=KeyValueMap[Function[{m,c},epsilonSeries[(c/.D->4-2eps)regions["OrdinaryMasters"][m],0,
    "ordinary cut coefficient"]],coefficients];
  ordinary=Total[terms];
  gate["ordinary cut contraction is symbolic and evaluated",FreeQ[ordinary,_CutIntegral|_SeriesData|_Series|_Integrate|_Real|$Failed|$Aborted]];
  branches=Association@Table[
    Print["REAL_ENDPOINT ",channel," ",key," branch ",sign];
    assumptions=branchAssumptions[sign];rows={};
    Do[rows=Join[rows,Flatten[softRows[coefficients[master],#,sign]& /@softPieces[master,sign],1]],
      {master,Keys[coefficients]}];
    groups=GatherBy[rows,Take[#,2]&];
    combined=Table[{group[[1,1]],group[[1,2]],bounded[reduce[Total[group[[All,3]]],assumptions],
      "combine recoil coefficients"]},{group,groups}];
    put[<|"Rows"->rows,"Combined"->combined,"InputHash"->hash|>,
      sidisPath[{directory,"s17_soft_"<>ToString[sign]<>".wl"}]];
    Do[If[row[[2]]<-1,gate["stronger recoil singularities cancel",
      bounded[FullSimplify[row[[3]],assumptions],"stronger recoil cancellation"]===0]],{row,combined}];
    endpoints=Select[combined,#[[2]]===-1&&Last[#]=!=0&];
    gate["endpoint regulator has the defining convergence orientation",And@@(TrueQ[#[[1]]>0]& /@endpoints)];
    delta=bounded[reduce[Total[laurentProduct[#[[3]],endpointIntegral/.{kap->#[[1]],ep->eps},0]& /@endpoints],
      assumptions],"delta coefficient"];
    plus=Table[bounded[reduce[Total[laurentProduct[#[[3]],B^(-#[[1]]eps)
      (Coefficient[logKernel,ellLog,n]/.{kap->#[[1]],ep->eps}),0]& /@endpoints],assumptions],
      "plus coefficient"],{n,0,2}];
    gate["no higher logarithmic plus distribution survives",Factor[plus[[3]]]===0];
    regular=(ordinary/.t->sign omega-s)-Total[laurentProduct[#[[3]],w^(-1-#[[1]]eps),0]& /@endpoints];
    value=<|"Delta"->delta,"L0"->plus[[1]],"L1"->plus[[2]],"Regular"->regular,
      "SoftCoefficients"->endpoints,"Assumptions"->assumptions|>;
    put[value,sidisPath[{directory,"s17_branch_"<>ToString[sign]<>".wl"}]];
    sign->value,{sign,{1,-1}}];
  result=<|"Channel"->channel,"TensorKey"->key,"Ordinary"->ordinary,"Branches"->branches,
    "InputHash"->hash,"CoefficientHash"->channelHash,"SourceHash"->sourceHash,"Accepted"->True|>;
  put[result,file];ClearSystemCache[];Print["REAL_ASSEMBLY_ACCEPTED ",channel," ",key];result],"S17Failure"];
slots=Quiet[Check[ToExpression[Environment["NSLOTS"]],1]];
If[!IntegerQ[slots]||slots<1,slots=1];CloseKernels[];
If[slots>1,LaunchKernels[KernelConfiguration["localhost","KernelCommand"->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel","KernelCount"->Min[4,slots],"TimeConstraint"->60]]];
workers=Length[Kernels[]];
If[workers>0,ParallelEvaluate[$HistoryLength=0];DistributeDefinitions[gate,put,bounded,
  branchAssumptions,reduce,epsilonSeries,laurentProduct,softPieces,pieceEndpoint,softRows,assemble,
  root,inputHash,sourceHash,inputs,evaluations,regions,endpointIntegral,logKernel]];
$DistributedContexts=None;outputs=<||>;
Do[
  file=sidisPath[{root,channel,"s11_result.wl"}];data=sidisGet[file];
  hash=sidisHash[file,"SHA256"];
  gate[channel<>" coefficient identity",TrueQ[data["Accepted"]]&&hash===manifest["Channels"][channel]["Hash"]];
  tasks=KeyValueMap[{channel,#1,#2,hash}&,data["Components"]];
  values=If[workers>0,ParallelMap[assemble@@#&,tasks,Method->"FinestGrained"],assemble@@#& /@tasks];
  gate[channel<>" all real components assembled",FreeQ[values,$Failed|$Aborted]&&And@@Lookup[values,"Accepted"]];
  result=<|"Channel"->channel,"Real"->AssociationThread[Keys[data["Components"]],values],
    "Measure"->inputs["MasterMeasure"],"PhaseAndWeightsApplied"->False,
    "PlusDefinition"->"Ln=[Log[w/B]^n/w]_+ on [0,B]","BranchMap"->(t->sign omega-s),
    "Regulator"->eps,"SourceHash"->sourceHash,"InputHashes"->inputHashes,"Accepted"->True|>;
  file=sidisPath[{root,channel,"s17_result.wl"}];put[result,file];
  AssociateTo[outputs,channel-><|"File"->channel<>"/s17_result.wl","Hash"->sidisHash[file,"SHA256"]|>];
  Clear[data,tasks,values,result];ClearSystemCache[],{channel,Keys[manifest["Channels"]]}];
CloseKernels[];
put[<|"Channels"->outputs,"InputHashes"->inputHashes,"SourceHash"->sourceHash,
  "AcceptedCutDistributions"->True,"FinalHatsAssembled"->False|>,sidisPath[{root,"s17_result.wl"}]];
Print["S17_SUCCESS: new cut-measure real distributions assembled for all six channels."];
Quit[0];
