Get[FileNameJoin[{DirectoryName[$InputFileName],"..","common","s22_paths.wl"}]];
(* Physical continuation and renormalization using only newly evaluated masters. *)
$HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
root=sidisRoot;
gate[name_,test_] := If[!TrueQ[test],Print["FAIL: ",name];
  If[$KernelID>0,Throw[$Failed,"S19Failure"],CloseKernels[];Quit[1]]];
gate["complete source syntax",SyntaxQ[sidisImport[$InputFileName,"Text"]]];
put[value_,file_] := (Block[{$ContextPath={"System`","Global`"}},Put[value,file<>".tmp"]];
  RenameFile[file<>".tmp",file,OverwriteTarget->True]);
SetAttributes[bounded,HoldFirst];
bounded[value_,label_] := MemoryConstrained[TimeConstrained[value,1200,
  gate[label<>" time limit",False]],2*1024^3,gate[label<>" memory limit",False]];
parents=sidisGet[sidisPath[{root,"s12_result.wl"}]];
evaluations=sidisGet[sidisPath[{root,"s13_result.wl"}]];
uv=sidisGet[sidisPath[{root,"s14_result.wl"}]];
manifest=sidisGet[sidisPath[{root,"s18_result.wl"}]];
gate["accepted fresh virtual evaluation inputs",TrueQ[parents["Accepted"]]&&
  TrueQ[evaluations["AcceptedEuclideanParents"]]&&TrueQ[uv["Accepted"]]&&TrueQ[manifest["Accepted"]]];
gate["virtual parent input identity",evaluations["InputFileHash"]===sidisHash[sidisPath[{root,"s12_result.wl"}],"SHA256"]];
sourceHash=sidisHash[$InputFileName,"SHA256"];
inputHashes=Association@Table[name->sidisHash[sidisPath[{root,name}],"SHA256"],
  {name,{"s12_result.wl","s13_result.wl","s14_result.wl","s18_result.wl"}}];
inputHash=Hash[{sourceHash,inputHashes},"SHA256"];
work=sidisPath[{root,"common","s19_virtual",IntegerString[inputHash,16]}];
If[!DirectoryQ[work],CreateDirectory[work,CreateIntermediateDirectories->True]];
physical=Q2>0&&s>0&&t<0&&Q2+s+t>0&&mu>0&&SUNN>1;
reduce[value_] := Module[{refined,functions},
  refined=Refine[value,physical];
  functions=DeleteDuplicates[Cases[refined,_Log|_PolyLog|_Re|_Im,Infinity]];
  Collect[Expand[refined],functions,Factor]];
continueMaster[master_,data_] := Catch[Module[
  {file,saved,parent,series,coefficients,polynomials,polynomial,signs,sign,shift,
   imaginary,functions,limits,rules,value,rawCoefficients,continued,result},
  file=sidisPath[{work,"s19_master_"<>IntegerString[Hash[master,"SHA256"],16]<>".wl"}];
  If[FileExistsQ[file],saved=sidisGet[file];If[saved["InputHash"]===inputHash&&TrueQ[saved["Accepted"]],Return[saved]]];
  Print["VIRTUAL_CONTINUATION ",InputForm[master]," kernel ",$KernelID];
  parent=parents["ParentInputs"][data["ParentID"]];
  series=evaluations["Parents"][data["ParentID"]]["Series"]/.SubTropica`eps->eps;
  gate["virtual master has all required epsilon coefficients",MatchQ[series,_SeriesData]&&
    series[[5]]>manifest["RequiredOrders"][master]&&Length[series[[3]]]>0];
  coefficients=parent["SubTropicaInput"][[4]];
  polynomials=DeleteDuplicates[Cases[parent["Representation"][[1]],
    Power[base_,exponent_]/;!FreeQ[exponent,eps]&&AnyTrue[coefficients,!FreeQ[base,#]&]:>base,Infinity]];
  gate["one explicit kinematic Feynman polynomial",Length[polynomials]===1];
  polynomial=First[polynomials];
  signs=DeleteDuplicates[Cases[parent["Representation"][[4,3]],StandardPropagatorDenominator[_,_,_,{_,i0_}]:>i0,Infinity]];
  gate["one inherited Feynman pole prescription",Length[signs]===1&&MemberQ[{-1,1},First[signs]]];
  sign=First[signs];shift=(First[#]->Last[#]-I sign eta)& /@data["PhysicalSubstitutions"];
  imaginary=ComplexExpand[Im[polynomial/.shift]];
  gate["physical deformation stays on the inherited Feynman sheet",bounded[
    FullSimplify[sign imaginary<0,physical&&eta>0&&And@@(#>0& /@parent["Representation"][[3]])],
    "Feynman polynomial imaginary sign"]];
  functions=DeleteDuplicates[Cases[Normal[series],_Log|_PolyLog,Infinity]];
  limits=Table[
    value=bounded[FullSimplify[Limit[function/.shift,eta->0,Direction->"FromAbove",
      Assumptions->physical],physical],"physical logarithm or dilogarithm boundary"];
    gate["physical special-function boundary is evaluated",FreeQ[value,eta|_Limit|_ConditionalExpression|_Real|Indeterminate|ComplexInfinity]];
    function->value,{function,functions}];
  rawCoefficients=series[[3]];
  continued=Map[bounded[reduce[(#/.limits)/.data["PhysicalSubstitutions"]],"continued master coefficient"]&,rawCoefficients];
  value=Apply[SeriesData,ReplacePart[List@@series,3->continued]];
  gate["continued master has no Euclidean parameters",FreeQ[value,Alternatives@@coefficients]];
  result=<|"Master"->master,"Series"->value,"FunctionLimits"->limits,"FeynmanDeformation"->shift,
    "FeynmanPolynomial"->polynomial,"ImaginaryPart"->imaginary,"Conditions"->physical,
    "InputHash"->inputHash,"SourceHash"->sourceHash,"Accepted"->True|>;
  put[result,file];ClearSystemCache[];Print["VIRTUAL_MASTER_CONTINUED ",InputForm[master]];result],"S19Failure"];
slots=Quiet[Check[ToExpression[Environment["NSLOTS"]],1]];
If[!IntegerQ[slots]||slots<1,slots=1];CloseKernels[];
If[slots>1,LaunchKernels[KernelConfiguration["localhost","KernelCommand"->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel","KernelCount"->Min[4,slots],"TimeConstraint"->60]]];
workers=Length[Kernels[]];
If[workers>0,ParallelEvaluate[$HistoryLength=0];DistributeDefinitions[gate,put,bounded,
  continueMaster,reduce,parents,evaluations,manifest,inputHash,sourceHash,work,physical]];
$DistributedContexts=None;
tasks=KeyValueMap[List,parents["VirtualMasterParents"]];
values=If[workers>0,ParallelMap[continueMaster@@#&,tasks,Method->"FinestGrained"],continueMaster@@#& /@tasks];
CloseKernels[];
gate["all new masters continued",FreeQ[values,$Failed|$Aborted]&&And@@Lookup[values,"Accepted"]];
masterValues=AssociationThread[Keys[parents["VirtualMasterParents"]],Lookup[values,"Series"]];
put[<|"Masters"->masterValues,"ContinuationRecords"->values,"InputHash"->inputHash|>,sidisPath[{work,"s19_masters.wl"}]];
fieldSplits=Association@KeyValueMap[Function[{field,residue},Module[{solution},
  solution=Solve[(residue/epsUV+ir/eps/.epsUV->eps)==0,ir];
  gate["bare field has a unique IR residue consistent with the scaleless integral",Length[solution]===1];
  field->(residue/epsUV+(ir/.First[solution])/eps)]],uv["FieldUVResidues"]];
channelResults=<||>;
Do[
  file=sidisPath[{root,channel,"s18_result.wl"}];data=sidisGet[file];
  gate[channel<>" virtual coefficient identity",TrueQ[data["Accepted"]]&&sidisHash[file,"SHA256"]===manifest["Channels"][channel]["Hash"]];
  born=sidisGet[sidisPath[{root,channel,"s01_inputs","s02_result.wl"}]];
  book=uv["FieldBookkeeping"][channel];
  gate[channel<>" Kira establishes the vanishing bare on-shell residue",book["BareOnShellResidue"]===0];
  fields=Flatten[KeyValueMap[ConstantArray[#1,#2]&,book["FieldCounts"]]];
  fieldFactor=Times@@(Sqrt[1+ord fieldSplits[#]]& /@fields);
  externalInterference=Coefficient[Normal[Series[fieldFactor^2,{ord,0,1}]],ord];
  gate[channel<>" external UV bookkeeping agrees with fresh residues",
    Factor[Coefficient[Expand[externalInterference],epsUV,-1]-book["ExternalUVResidue"]]===0];
  gate[channel<>" bare external contribution vanishes in the common regulator",
    Factor[externalInterference/.epsUV->eps]===0];
  pre=<||>;renormalized=<||>;uvResiduals=<||>;
  Do[
    Print["VIRTUAL_RENORMALIZE ",channel," ",mode];
    terms=KeyValueMap[Function[{master,coefficient},Module[{value},
      value=bounded[Series[(data["Measure"]/.Epsilon->eps)(coefficient/.D->4-2eps)masterValues[master],
        {eps,0,0}],"virtual loop measure and master multiplication"];
      gate["virtual product has the required regulator depth",value===0||(MatchQ[value,_SeriesData]&&value[[5]]>0)];
      Normal[value]]],data["Components"][mode]["Coefficients"]];
    interference=Total[terms];AssociateTo[pre,mode->interference];
    put[<|"Channel"->channel,"Mode"->mode,"PreHermitian"->interference,"InputHash"->inputHash|>,
      sidisPath[{work,"s19_pre_"<>channel<>"_"<>mode<>".wl"}]];
    Print["VIRTUAL_HERMITIAN ",channel," ",mode];
    hermitian=bounded[reduce[ComplexExpand[interference+Conjugate[interference],
      TargetFunctions->{Re,Im}]],"Hermitian interference"];
    fullUV=Factor[ComplexExpand[uv["VirtualUVResidues"][channel][mode]+
      Conjugate[uv["VirtualUVResidues"][channel][mode]]]];
    separated=hermitian+fullUV(1/epsUV-1/eps);
    gate["UV separation preserves the common-regulator tensor",Expand[(separated/.epsUV->eps)-hermitian]===0];
    bornD=born["Born"<>mode]/.D->4-2eps;
    counterterm=book["CouplingWeight"]uv["CouplingResidue"](uv["MSPole"]/.eps->epsUV)bornD;
    complete=separated+externalInterference bornD+counterterm;
    residual=Factor[Coefficient[Expand[complete],epsUV,-1]/.eps->0];
    AssociateTo[uvResiduals,mode->residual];
    gate[channel<>mode<>" complete UV cancellation",residual===0];
    value=bounded[Normal[Series[complete/.epsUV->eps,{eps,0,0}]],"renormalized virtual Laurent series"];
    gate["renormalized tensor has no unresolved integral or boundary",FreeQ[value,
      _GLI|_PaVe|_Integrate|_Limit|_Series|_SeriesData|_Real|$Failed|$Aborted|epsUV|Indeterminate|ComplexInfinity]];
    AssociateTo[renormalized,mode->value],{mode,Keys[data["Components"]]}];
  result=<|"Channel"->channel,"RenormalizedVirtual"->renormalized,"PreHermitian"->pre,
    "UVResiduals"->uvResiduals,"ExternalInterference"->externalInterference,"FieldSplits"->fieldSplits,
    "CouplingResidue"->uv["CouplingResidue"],"CouplingWeight"->book["CouplingWeight"],
    "FieldCounts"->book["FieldCounts"],"Regulator"->eps,"MSPole"->uv["MSPole"],
    "Measure"->data["Measure"],"CouplingsRemoved"->data["CouplingsRemoved"],
    "PhysicalConditions"->physical,"InputHashes"->inputHashes,"SourceHash"->sourceHash,
    "MasterFile"->sidisPath[{work,"s19_masters.wl"}],"Accepted"->True|>;
  file=sidisPath[{root,channel,"s19_result.wl"}];put[result,file];
  AssociateTo[channelResults,channel-><|"File"->channel<>"/s19_result.wl","Hash"->sidisHash[file,"SHA256"]|>],
  {channel,{"Hqq","Hqg","Hgq"}}];
put[<|"Channels"->channelResults,"InputHashes"->inputHashes,"SourceHash"->sourceHash,"Accepted"->True|>,
  sidisPath[{root,"s19_result.wl"}]];
Print["S19_SUCCESS: new physical virtual tensors and fresh MSbar counterterms assembled."];
Quit[0];
