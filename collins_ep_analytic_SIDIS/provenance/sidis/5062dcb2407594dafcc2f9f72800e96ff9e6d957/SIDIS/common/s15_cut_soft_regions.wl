Get[FileNameJoin[{DirectoryName[$InputFileName],"..","common","s22_paths.wl"}]];
(* Regulated soft regions of the freshly evaluated reverse-unitarity masters. *)
$HistoryLength=0;
root=sidisRoot;
gate[name_,test_] := If[!TrueQ[test],Print["FAIL: ",name];
  If[$KernelID>0,Throw[$Failed,"S15Failure"],CloseKernels[];Quit[1]]];
put[value_,file_] := (Block[{$ContextPath={"System`","Global`"}},Put[value,file<>".tmp"]];RenameFile[file<>".tmp",file,OverwriteTarget->True]);
SetAttributes[bounded,HoldFirst];
bounded[value_,label_] := MemoryConstrained[TimeConstrained[value,1200,
  gate[label<>" time limit",False]],2*1024^3,gate[label<>" memory limit",False]];
inputs=sidisGet[sidisPath[{root,"s08_result.wl"}]];
evaluations=sidisGet[sidisPath[{root,"s10_result.wl"}]];
coeffManifest=sidisGet[sidisPath[{root,"s11_result.wl"}]];
gate["accepted normalized cut masters and coefficient maps",
  TrueQ[inputs["AcceptedRepresentations"]]&&TrueQ[evaluations["CutNormalizationAccepted"]]&&
  TrueQ[coeffManifest["Accepted"]]&&evaluations["InputFileHash"]===sidisHash[sidisPath[{root,"s08_result.wl"}],"SHA256"]];
sourceHash=sidisHash[$InputFileName,"SHA256"];
inputHashes=Association@Table[name->sidisHash[sidisPath[{root,name}],"SHA256"],
  {name,{"s08_result.wl","s10_result.wl","s11_result.wl"}}];
inputHash=Hash[{sourceHash,inputHashes},"SHA256"];
work=sidisPath[{root,"common","s15_cut_soft",IntegerString[inputHash,16]}];
If[!DirectoryQ[work],CreateDirectory[work,CreateIntermediateDirectories->True]];
components={};
KeyValueMap[Function[{channel,metadata},Module[{file,data},
  file=sidisPath[{root,channel,"s11_result.wl"}];data=sidisGet[file];
  gate[channel<>" coefficient input identity",TrueQ[data["Accepted"]]&&sidisHash[file,"SHA256"]===metadata["Hash"]];
  components=Join[components,Values[data["Components"]]]]],coeffManifest["Channels"]];
(* Inherited interior of the physical SIDIS region, before the recoil endpoint. *)
physical=Q2>0&&s>w>0&&w-Q2-s<t<-Q2 w/s;
softPhysical=Q2>0&&s>0&&t<0&&Q2+s+t>0;
masterMetadata=<||>;ordinaryMasters=<||>;
Do[
  data=inputs["Masters"][master];prefactor=data["RegulatedPrefactor"];
  exponent=bounded[FullSimplify[Limit[w D[prefactor,w]/prefactor,w->0,
    Direction->"FromAbove",Assumptions->softPhysical&&Element[Global`eps,Reals]],
    softPhysical&&Element[Global`eps,Reals]],"master prefactor soft power"];
  gate["prefactor has a linear regulator-dependent recoil power",
    PolynomialQ[exponent,Global`eps]&&Exponent[exponent,Global`eps]<=1&&FreeQ[exponent,w|_Limit]];
  softValuations=DeleteCases[#["SoftValuations"][master]& /@components,Infinity];
  epsilonValuations=DeleteCases[#["EpsilonValuations"][master]& /@components,Infinity];
  depth=Max[0,-1-Min[softValuations]-(exponent /. Global`eps->0)];
  gate["finite measured soft Taylor depth",IntegerQ[depth]&&depth>=0];
  limits=Association@Table[First[rule]->bounded[FullSimplify[Limit[Last[rule],w->0,
    Direction->"FromAbove",Assumptions->softPhysical],softPhysical],"Euler parameter limit"],
    {rule,data["PhysicalSubstitutions"]}];
  divergent=Keys[Select[limits,MatchQ[#,_DirectedInfinity]&]];
  finiteOrder=Max[0,-Min[epsilonValuations]];
  value=(evaluations["Classes"][data["Class"]]["Series"] /. SubTropica`eps->Global`eps) /.
    data["PhysicalSubstitutions"];
  value=bounded[Series[prefactor value,{Global`eps,0,finiteOrder}],"ordinary cut master series"];
  gate["cut master reaches the coefficient-required regulator depth",MatchQ[value,_SeriesData]&&value[[5]]>finiteOrder];
  AssociateTo[ordinaryMasters,master->value];
  AssociateTo[masterMetadata,master-><|"Class"->data["Class"],"PrefactorSoftPower"->exponent,
    "Prefactor"->prefactor,"ParameterLimits"->limits,"DivergentParameters"->divergent,
    "TaylorDepth"->depth,"CoefficientEpsilonMinimum"->Min[epsilonValuations],
    "CoefficientSoftMinimum"->Min[softValuations],"OrdinarySeriesOrder"->finiteOrder|>];
  Print["SOFT_MASTER ",InputForm[master]," depth ",depth," parameters ",InputForm[limits]],
  {master,Keys[inputs["Masters"]]}];
put[<|"Masters"->masterMetadata,"OrdinaryMasters"->ordinaryMasters,"InputHash"->inputHash|>,
  sidisPath[{work,"s15_master_metadata.wl"}]];
packageRoot=sidisPath[{root,"software","SubTropica-1.2.10"}];
polymake=sidisPath[{root,"software","s01_polymake"}];
sidisGet[sidisPath[{packageRoot,"Kernel","init.m"}]];
SubTropica`$PolymakeCommand=polymake;
moduleProbe=RunProcess[{polymake,"use application \"ideal\"; print \"SIDIS_POLYMAKE_MODULE_OK\\n\";"}];
gate["Polymake ideal module loads",moduleProbe["ExitCode"]===0&&
  StringContainsQ[moduleProbe["StandardOutput"],"SIDIS_POLYMAKE_MODULE_OK"]&&
  !StringContainsQ[moduleProbe["StandardError"],"ERROR"]];
regionInputs=<||>;regionMasterMap=<||>;
Do[
  metadata=masterMetadata[master];
  If[metadata["DivergentParameters"]==={},Continue[]];
  gate["divergent parameter belongs to the two-null Euler class",
    metadata["Class"]==="cut_pair_massless"&&metadata["DivergentParameters"]==={zp}];
  tuple=inputs["Classes"][metadata["Class"]]["SubTropicaInput"] /. Global`eps->SubTropica`eps;
  vars=tuple[[3]];limit={zp->1/SubTropica`\[Lambda]};
  dlog=Times@@vars tuple[[2]];
  rays=bounded[SubTropica`STGetRegionVectors[dlog,vars,{},limit],"soft region vectors"];
  gate["region engine returns nonempty exact rays",MatchQ[rays,{{__Integer}..}|{{__Rational}..}|{{(_Integer|_Rational)..}..}]];
  rays=Sort[DeleteDuplicates[#/Abs[Last[#]]& /@rays]];
  regionalSource=dlog /. limit /. SubTropica`\[Lambda]->regionScale;
  entries={};
  Do[
    puiseux=bounded[SubTropica`STPuiseux[regionalSource,Join[vars,{regionScale}],ray,metadata["TaylorDepth"]],"regulated region expansion"];
    gate["regulated region contains an explicit coefficient series",MatchQ[puiseux,{_,_SeriesData}]];
    pref=puiseux[[1]];
    prefPower=FullSimplify[SubTropica`\[Lambda] D[pref,SubTropica`\[Lambda]]/pref,
      And@@Join[#>0& /@Join[vars,{regionScale,SubTropica`\[Lambda]}],{Element[SubTropica`eps,Reals]}]];
    regionalPref=FullSimplify[pref/SubTropica`\[Lambda]^prefPower,
      And@@Join[#>0& /@Join[vars,{regionScale,SubTropica`\[Lambda]}],{Element[SubTropica`eps,Reals]}]];
    gate["region prefactor recoil power is factored",FreeQ[regionalPref,SubTropica`\[Lambda]]];
    series=puiseux[[2]];
    Do[
      coefficient=series[[3,i]];If[ListQ[coefficient],coefficient=Total[coefficient]];
      density=FullSimplify[(regionalPref coefficient /. regionScale->1)/(Times@@vars),
        And@@Join[#>0& /@vars,{Element[SubTropica`eps,Reals]}]];
      If[density===0,Continue[]];
      power=Expand[prefPower+(series[[4]]+i-1)/series[[6]]];
      If[(power /. SubTropica`eps->0)>metadata["TaylorDepth"],Continue[]];
      id="region_"<>IntegerString[Hash[{density,vars},"SHA256"],16];
      AssociateTo[regionInputs,id-><|"Tuple"->{1,density,vars,{}},
        "Order"->inputs["Classes"][metadata["Class"]]["Order"]|>];
      AppendTo[entries,<|"Region"->ray,"LambdaPower"->power,"IntegralID"->id|>],
      {i,Length[series[[3]]]}],{ray,rays}];
  AssociateTo[regionMasterMap,master-><|"ParameterDefinition"->First[limit],"Regions"->rays,
    "TaylorDepth"->metadata["TaylorDepth"],"Entries"->entries|>],{master,Keys[masterMetadata]}];
put[<|"RegionInputs"->regionInputs,"MasterMap"->regionMasterMap,"InputHash"->inputHash|>,
  sidisPath[{work,"s15_region_inputs.wl"}]];
evaluateRegion[id_,data_] := Catch[Module[{directory,file,tuple,raw,rules,value,saved,oldDirectory},
  directory=sidisPath[{work,id}];If[!DirectoryQ[directory],CreateDirectory[directory]];
  file=sidisPath[{directory,"s15_result.wl"}];
  If[FileExistsQ[file],saved=sidisGet[file];If[saved["InputHash"]===inputHash&&TrueQ[saved["Accepted"]],Return[saved]]];
  oldDirectory=Directory[];SetDirectory[directory];
  If[!MemberQ[$Packages,"SubTropica`"],sidisGet[sidisPath[{packageRoot,"Kernel","init.m"}]]];
  SubTropica`$PolymakeCommand=polymake;
  SetOptions[HyperIntica`HyperInt,"EvaluatePeriodsQ"->True];
  tuple=data["Tuple"];
  $Assumptions=And@@Join[#>0& /@Join[tuple[[3]],tuple[[4]]],{Element[SubTropica`eps,Reals]}];
  put[data,sidisPath[{directory,"s15_input.wl"}]];
  Print["SUBTROPICA_SOFT_REGION ",id," kernel ",$KernelID];
  raw=bounded[SubTropica`STIntegrate[tuple,"Order"->data["Order"],"Integrator"->"HyperIntica",
    "LROrderBackend"->"HyperIntica","KernelsAvailable"->1,"SimplifyOutput"->Identity,
    "Verbose"->False,"ShowTimings"->True,"ScanGauges"->False,"SetProblemID"->id,
    "SaveAllIntegrands"->"s15_integrands.wl","ReuseExistingResults"->False,
    "ClearCachesPerIntegrand"->True],"soft region integration"];
  rules=HyperIntica`GetAlgebraicBackSubRules[];
  put[<|"Tuple"->tuple,"RawOutput"->raw,"AlgebraicLetterDefinitions"->rules,"InputHash"->inputHash|>,
    sidisPath[{directory,"s15_raw.wl"}]];
  gate[id<>" complete evaluated region",raw===0||(MatchQ[raw,_SeriesData]&&raw[[5]]>data["Order"]&&Length[raw[[3]]]>0)];
  value=(raw /. rules) /. HyperIntica`Hlog[arg_,word_List]:>HyperIntica`HlogAsMpl[arg,word];
  value=FixedPoint[(# /. {HyperIntica`mzv[n_Integer]:>Zeta[n],
    HyperIntica`Mpl[{n_Integer},{arg_}]:>PolyLog[n,arg]})&,value] /. SubTropica`eps->Global`eps;
  gate[id<>" portable exact region series",FreeQ[value,_HyperIntica`Wm|_HyperIntica`Wp|_Real|$Failed|$Aborted]];
  saved=<|"Series"->value,"Tuple"->tuple,"Order"->data["Order"],"InputHash"->inputHash,
    "RawOutputFile"->sidisPath[{directory,"s15_raw.wl"}],"AlgebraicLetterDefinitions"->rules,"Accepted"->True|>;
  put[saved,file];SetDirectory[oldDirectory];ClearSystemCache[];saved],"S15Failure"];
slots=Quiet[Check[ToExpression[Environment["NSLOTS"]],1]];
If[!IntegerQ[slots]||slots<1,slots=1];CloseKernels[];
If[slots>1,LaunchKernels[KernelConfiguration["localhost","KernelCommand"->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel","KernelCount"->Min[4,slots],"TimeConstraint"->60]]];
workers=Length[Kernels[]];
If[workers>0,ParallelEvaluate[$HistoryLength=0];DistributeDefinitions[gate,put,bounded,
  evaluateRegion,work,inputHash,packageRoot,polymake]];
$DistributedContexts=None;
tasks=KeyValueMap[List,regionInputs];
values=If[workers>0,ParallelMap[evaluateRegion@@#&,tasks,Method->"FinestGrained"],evaluateRegion@@#& /@tasks];
CloseKernels[];
gate["every regulated region evaluated",FreeQ[values,$Failed|$Aborted]&&And@@Lookup[values,"Accepted"]];
result=<|"Masters"->masterMetadata,"OrdinaryMasters"->ordinaryMasters,"RegionMasterMap"->regionMasterMap,
  "RegionValues"->AssociationThread[Keys[regionInputs],values],"InputHashes"->inputHashes,
  "SourceHash"->sourceHash,"InputHash"->inputHash,"WorkDirectory"->work,
  "PhysicalConditions"->physical,"SoftPhysicalConditions"->softPhysical,
  "AcceptedCutMasterRegions"->True,"EndpointDistributionsAssembled"->False|>;
put[result,sidisPath[{root,"s15_result.wl"}]];
gate["saved regions preserve exact symbol contexts",Block[{$ContextPath={"System`","Global`"}},sidisGet[sidisPath[{root,"s15_result.wl"}]]]===result];
Print["S15_SUCCESS: regulated cut-master regions and fixed-recoil master series evaluated."];
Quit[0];
