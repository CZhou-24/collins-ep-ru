Get[FileNameJoin[{DirectoryName[$InputFileName],"..","common","s22_paths.wl"}]];
(* Assemble the six channels from the new integral evaluations. *)
$HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
root=sidisRoot;
gate[name_,test_] := If[!TrueQ[test],Print["FAIL: ",name];
  If[$KernelID>0,Throw[$Failed,"S20Failure"],CloseKernels[];Quit[1]]];
gate["complete source syntax",SyntaxQ[sidisImport[$InputFileName,"Text"]]];
put[value_,file_] := (Block[{$ContextPath={"System`","Global`"}},Put[value,file<>".tmp"]];
  RenameFile[file<>".tmp",file,OverwriteTarget->True]);
SetAttributes[bounded,HoldFirst];
bounded[value_,label_] := MemoryConstrained[TimeConstrained[value,1200,
  gate[label<>" time limit",False]],2*1024^3,gate[label<>" memory limit",False]];
realManifest=sidisGet[sidisPath[{root,"s17_result.wl"}]];
virtualManifest=sidisGet[sidisPath[{root,"s19_result.wl"}]];
gate["accepted new real and virtual tensors",TrueQ[realManifest["AcceptedCutDistributions"]]&&TrueQ[virtualManifest["Accepted"]]];
geometry=sidisGet[sidisPath[{root,"s02_result.wl"}]];
cutGeometry=sidisGet[sidisPath[{root,"s08_result.wl"}]];
sourceHash=sidisHash[$InputFileName,"SHA256"];
physical=Q2>0&&s>w>0&&w-Q2-s<t<-Q2 w/s&&mu>0&&mu2>0&&B>0&&SUNN>1&&Nc>1;
softPhysical=Q2>0&&s>0&&t<0&&Q2+s+t>0&&mu>0&&mu2>0&&B>0&&SUNN>1&&Nc>1;
dimension=4-2eps;
stateNormalization=(2Pi)^D Times@@Table[(2Pi)^(-(D-1)),{momentum,geometry["CutMomenta"]}];
stateNormalization=FullSimplify[stateNormalization/.D->dimension];
angularJacobian=FullSimplify[cutGeometry["RadialPrefactor"]
  (cutGeometry["SphereAreaDefinition"]/.nn->D-1-Length[{theta,phi}]/.D->dimension)];
hardNormalization=(2Pi)^(-Limit[dimension,eps->0]);
couplingSquare=Factor[gs^2/.First[Solve[gs^2==4Pi alphaS,gs]]];
reduce[value_,assumptions_] := Module[{expression,functions},
  expression=Refine[value,assumptions];
  expression=PowerExpand[expression/.Log[arg_]:>Log[Factor[arg]],Assumptions->assumptions];
  functions=DeleteDuplicates[Cases[expression,_Log|_PolyLog|_ArcTan|_ArcTanh|_Re|_Im,Infinity]];
  Collect[Expand[expression],functions,Factor]];
zero[value_,assumptions_] := Module[{expression=reduce[value,assumptions]},
  expression===0||FullSimplify[expression,assumptions]===0];
epsSeries[value_] := Normal[Series[value,{eps,0,0}]];
finitePart[parts_,label_,assumptions_,directory_,hash_] := Module[
  {file,saved,combined,powers,residues,value},
  file=sidisPath[{directory,"s20_"<>label<>".wl"}];
  If[FileExistsQ[file],saved=sidisGet[file];If[saved["InputHash"]===hash&&TrueQ[saved["Accepted"]],Return[saved["Finite"]]]];
  Print["POLE_ASSEMBLY ",label];
  gate[label<>" finite symbolic input parts",
    FreeQ[parts,_Integrate|_Series|_SeriesData|_Limit|_Real|$Failed|$Aborted|Indeterminate|_DirectedInfinity]];
  combined=Expand[Total[parts],eps];
  powers=Range[Min[Append[Cases[combined,Power[eps,n_Integer]/;n<0:>n,Infinity],0]],-1];
  gate[label<>" is an evaluated Laurent polynomial",PolynomialQ[Expand[eps^(-Min[Append[powers,0]])combined],eps]];
  residues=Association@Table[n->bounded[reduce[Coefficient[combined,eps,n],assumptions],label<>" pole simplification"],{n,powers}];
  put[<|"PoleResiduals"->residues,"InputParts"->parts,"InputHash"->hash,"Accepted"->False|>,file];
  Do[gate[label<>" pole "<>ToString[n],bounded[zero[residues[n],assumptions],label<>" exact pole cancellation"]],{n,powers}];
  value=Coefficient[combined,eps,0];
  gate[label<>" finite evaluated tensor",FreeQ[value,eps|_Integrate|_Series|_SeriesData|_Limit|_Real|$Failed|$Aborted|Indeterminate|ComplexInfinity]];
  put[<|"PoleResiduals"->Map[Factor,residues],"Finite"->value,"InputHash"->hash,"Accepted"->True|>,file];value];
boundary[value_,assumptions_] := bounded[reduce[Limit[value,omega->0,
  Direction->"FromAbove",Assumptions->assumptions],assumptions],"common branch boundary"];

coreChannel[channel_] := Catch[Module[
  {channelRoot,real,virtual,born,subtraction,bookkeeping,hashes,hash,directory,sourcePhase,phase,
   tensorKeys,weights,flavorDomain=True,ranges,range,originalCount,canonicalCount,modeKeys,weighted,
   branches,finite,branch,assumptions,parts,result,projectors,leading,hats,middle,limits,commonReal,
   ordinary,virtualPart,virtualBoundary,subtractionPart,mode,sign,distribution,coefficient},
  channelRoot=sidisPath[{root,channel}];
  real=sidisGet[sidisPath[{channelRoot,"s17_result.wl"}]];
  virtual=sidisGet[sidisPath[{channelRoot,"s19_result.wl"}]];
  born=sidisGet[sidisPath[{channelRoot,"s01_inputs","s02_result.wl"}]];
  subtraction=sidisGet[sidisPath[{channelRoot,"s01_inputs",If[channel==="Hqg","s10_result.wl","s08_result.wl"]}]];
  bookkeeping=sidisGet[sidisPath[{channelRoot,"s02_result.wl"}]]["Bookkeeping"];
  gate[channel<>" consistent color and flavor symbol contexts",
    FreeQ[{real,virtual,born,subtraction,bookkeeping},Global`SUNN|Global`Nf]];
  gate[channel<>" new tensor identities",TrueQ[real["Accepted"]]&&TrueQ[virtual["Accepted"]]&&
    sidisHash[sidisPath[{channelRoot,"s17_result.wl"}],"SHA256"]===realManifest["Channels"][channel]["Hash"]&&
    sidisHash[sidisPath[{channelRoot,"s19_result.wl"}],"SHA256"]===virtualManifest["Channels"][channel]["Hash"]];
  hashes=Association@Table[name->sidisHash[sidisPath[{channelRoot,name}],"SHA256"],
    {name,{"s17_result.wl","s19_result.wl","s20_phase_input.json","s02_result.wl","s01_inputs/s02_result.wl",
      If[channel==="Hqg","s01_inputs/s10_result.wl","s01_inputs/s08_result.wl"]}}];
  hash=Hash[{sourceHash,hashes},"SHA256"];
  directory=sidisPath[{channelRoot,"s20_cache",IntegerString[hash,16]}];
  If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
  sourcePhase=ToExpression[sidisImport[sidisPath[{channelRoot,"s20_phase_input.json"}],"RawJSON"]["DefinitionExpression"]];
  phase=mu^(2eps)stateNormalization;
  gate[channel<>" phase normalization matches its source definition",bounded[FullSimplify[
    FunctionExpand[phase angularJacobian-sourcePhase w^-eps],physical&&Element[eps,Reals]],"cut-to-phase normalization"]===0];
  tensorKeys=Keys[real["Real"]];
  If[channel==="Hqq",
    ranges=DeleteDuplicates[#[[2]]& /@Values[bookkeeping["OtherChargeMomentDefinitions"]]];
    gate["one inherited flavor range",Length[ranges]===1];range=First[ranges];
    flavorDomain=Reduce[Element[range[[3]],Integers]&&range[[2]]<=bookkeeping["ObservedFlavor"]<=range[[3]],range[[3]],Integers];
    originalCount=bookkeeping["DistinctFlavorMultiplicity"];
    canonicalCount=If[Head[originalCount]===Piecewise,originalCount[[1,1,1]],originalCount];
    gate["inherited flavor count on its complete domain",Reduce[flavorDomain&&originalCount!=canonicalCount,range[[3]],Integers]===False];
    weights=Map[FullSimplify[#["FlavorWeight"]/.originalCount->canonicalCount,flavorDomain]&,bookkeeping["Components"]]];
  weighted[mode_,sign_,distribution_] := If[channel==="Hqq",
    Total[weights[First[StringSplit[#,"__"]]]real["Real"][#]["Branches"][sign][distribution]& /@
      Select[tensorKeys,Last[StringSplit[#,"__"]]===mode&]],
    real["Real"][mode]["Branches"][sign][distribution]];
  ordinary[mode_] := If[channel==="Hqq",Total[
    weights[First[StringSplit[#,"__"]]]real["Real"][#]["Ordinary"]& /@
      Select[tensorKeys,Last[StringSplit[#,"__"]]===mode&]],real["Real"][mode]["Ordinary"]];
  finite=Association@Table[mode->Association@Table[sign->Association@Table[
    assumptions=(If[distribution==="Regular",physical,softPhysical]/.t->sign omega-s)&&omega>0&&flavorDomain;
    virtualPart=If[distribution==="Delta",2Pi virtual["RenormalizedVirtual"][mode],0]/.virtual["Regulator"]->eps;
    subtractionPart=If[distribution==="L1",0,subtraction["Counterterms"][mode][distribution]]/.
      subtraction["Regulator"]->eps/.s23->w;
    parts={bounded[epsSeries[phase weighted[mode,sign,distribution]],"real phase multiplication"],
      virtualPart/.t->sign omega-s,subtractionPart/.t->sign omega-s};
    distribution->finitePart[parts,StringRiffle[{channel,mode,ToString[sign],distribution},"_"],assumptions,directory,hash],
    {distribution,{"L1","L0","Regular","Delta"}}],{sign,{1,-1}}],{mode,{"Pg","Ppp"}}];
  middle=<||>;
  Do[
    Print["VIRTUAL_BOUNDARY ",channel," ",mode];
    virtualBoundary=boundary[2Pi virtual["RenormalizedVirtual"][mode]/.
      virtual["Regulator"]->eps/.t->omega-s,(softPhysical/.t->-s)&&flavorDomain&&Element[eps,Reals]&&eps!=0];
    gate[channel<>" "<>mode<>" evaluated virtual boundary",
      FreeQ[virtualBoundary,omega|_Limit|_Series|_SeriesData|Indeterminate|_DirectedInfinity]];
    limits=Association@Table[distribution->Table[boundary[weighted[mode,sign,distribution],
      (softPhysical/.t->-s)&&flavorDomain],{sign,{1,-1}}],{distribution,{"Delta","L0","L1"}}];
    KeyValueMap[gate["real endpoint branches share a common boundary",zero[Subtract@@#2,(softPhysical/.t->-s)&&flavorDomain]]&,limits];
    commonReal=Map[First,limits];
    AssociateTo[commonReal,"Regular"->((ordinary[mode]/.t->-s)-commonReal["L0"]/w-commonReal["L1"]Log[w/B]/w)];
    AssociateTo[middle,mode->Association@Table[
      assumptions=(If[distribution==="Regular",physical,softPhysical]/.t->-s)&&flavorDomain;
      virtualPart=If[distribution==="Delta",virtualBoundary,0];
      subtractionPart=If[distribution==="L1",0,subtraction["Counterterms"][mode][distribution]]/.
        subtraction["Regulator"]->eps/.s23->w/.t->-s;
      distribution->finitePart[{epsSeries[phase commonReal[distribution]],virtualPart,subtractionPart},
        StringRiffle[{channel,mode,"0",distribution},"_"],assumptions,directory,hash],
      {distribution,{"Delta","L0","L1","Regular"}}]],{mode,{"Pg","Ppp"}}];
  Do[AssociateTo[finite,mode->Join[finite[mode],<|0->middle[mode]|>]],{mode,{"Pg","Ppp"}}];
  projectors=born["ProjectorsEpsilon"]/.eps->0/.born["BornKinematics"];
  leading=Association@Table[item[[1]]->Factor[eq^2 couplingSquare 2Pi hardNormalization
    (item[[2]]/.projectors/.{hg->born["BornPg"],hpp->born["BornPpp"]}/.D->4)],{item,{{"F1",f1},{"F2",f2}}}];
  hats=Association@Table[item[[1]]-><|"LODelta"->leading[item[[1]]],"NLO"->Association@Table[
    sign->Association@Table[distribution->eq^2 couplingSquare^2 hardNormalization
      (item[[2]]/.projectors/.{hg->finite["Pg"][sign][distribution],hpp->finite["Ppp"][sign][distribution]}),
      {distribution,{"Delta","L0","L1","Regular"}}],{sign,{1,-1,0}}]|>,{item,{{"F1",f1},{"F2",f2}}}];
  result=<|"Channel"->channel,"Fhats"->hats,"FiniteContractions"->finite,
    "BranchConvention"->"sign=+1/-1 with t=sign omega-s, omega>0; sign=0 means t=-s",
    "PlusDefinition"->real["PlusDefinition"],"PhysicalConditions"->physical,"FlavorDomain"->flavorDomain,
    "Bookkeeping"->KeyTake[bookkeeping,{"Components","OtherChargeMomentDefinitions","TagWeights","ObservedFlavor"}],
    "RealPhase"->phase,"HardNormalization"->hardNormalization,"InputHashes"->hashes,
    "SourceHash"->sourceHash,"PoleCache"->directory,"Accepted"->True|>;
  put[result,sidisPath[{channelRoot,"s20_result.wl"}]];
  KeyValueMap[put[#2,sidisPath[{channelRoot,"s20_"<>#1<>"_hat.wl"}]]&,hats];
  Print["FINAL_HATS_ACCEPTED ",channel];<|"Channel"->channel,"Hash"->sidisHash[sidisPath[{channelRoot,"s20_result.wl"}],"SHA256"],"Accepted"->True|>],"S20Failure"];

simpleChannel[channel_] := Catch[Module[
  {channelRoot,real,subtraction,generated,fields,options,observed,spectators,weight,
   sourcePhase,phase,hashes,hash,directory,finite,parts,ordinary,poles,projectors,hard,hats,result},
  channelRoot=sidisPath[{root,channel}];real=sidisGet[sidisPath[{channelRoot,"s17_result.wl"}]];
  subtraction=sidisGet[sidisPath[{channelRoot,"s16_result.wl"}]];
  generated=sidisGet[sidisPath[{channelRoot,"s01_inputs","s01_result","real.wl"}]];
  gate[channel<>" consistent color and flavor symbol contexts",
    FreeQ[{real,subtraction,generated},Global`SUNN|Global`Nf]];
  gate[channel<>" accepted new tensors and subtraction",TrueQ[real["Accepted"]]&&TrueQ[subtraction["AcceptedSubtractionInputs"]]&&
    sidisHash[sidisPath[{channelRoot,"s17_result.wl"}],"SHA256"]===realManifest["Channels"][channel]["Hash"]];
  hashes=Association@Table[name->sidisHash[sidisPath[{channelRoot,name}],"SHA256"],
    {name,{"s17_result.wl","s16_result.wl","s20_phase_input.json","s01_inputs/s01_result/real.wl"}}];
  hash=Hash[{sourceHash,hashes},"SHA256"];
  directory=sidisPath[{channelRoot,"s20_cache",IntegerString[hash,16]}];
  If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
  fields=Lookup[generated,"outgoing_fields",Missing["ReadGeneratedProcess"]];
  If[MissingQ[fields],options=List@@Head[generated["graphs"]];
    fields=FirstCase[options,HoldPattern[Rule[key_Symbol,process_Rule]]/;SymbolName[key]==="Process":>Last[process],Missing["ProcessFields"]]];
  gate["generated outgoing fields match their momenta",ListQ[fields]&&Length[fields]===Length[generated["outgoing"]]];
  observed=Position[generated["outgoing"],k1];gate["one tagged outgoing momentum",Length[observed]===1];
  spectators=Delete[fields,observed];weight=1/(Times@@(Factorial /@Values[Counts[spectators]]));
  If[KeyExistsQ[generated,"symmetry_weight"],gate["measured spectator weight matches this channel's generated record",weight===generated["symmetry_weight"]]];
  sourcePhase=ToExpression[sidisImport[sidisPath[{channelRoot,"s20_phase_input.json"}],"RawJSON"]["DefinitionExpression"]]/.
    Global`symmetryWeight->weight;
  phase=weight mu2^(2eps) hardNormalization stateNormalization;
  gate[channel<>" phase normalization matches its source definition",bounded[FullSimplify[
    FunctionExpand[phase angularJacobian-sourcePhase/Pi],physical&&Element[eps,Reals]],"real-only phase normalization"]===0];
  Do[Do[gate[channel<>" no endpoint distribution "<>dist,
    bounded[zero[real["Real"][mode]["Branches"][sign][dist],(softPhysical/.t->sign omega-s)&&omega>0],"real-only endpoint cancellation"]],
    {mode,Keys[real["Real"]]},{sign,{1,-1}}],{dist,{"Delta","L0","L1"}}];
  finite=Association@Table[
    ordinary=real["Real"][mode]["Ordinary"];
    parts={bounded[epsSeries[phase ordinary],"real-only phase multiplication"],
      bounded[epsSeries[subtraction["PhaseCT"](subtraction["Convolutions"][mode]/.D->dimension)],"collinear subtraction multiplication"]};
    mode->finitePart[parts,channel<>"_"<>mode<>"_Regular",physical,directory,hash],{mode,Keys[real["Real"]]}];
  hard=finite/.gs->Sqrt[couplingSquare];
  If[channel==="Hgg",hard=hard/.eq^2->chargeSum];
  If[channel==="Hqqbar",hard=hard/.eq^2->eq2];
  projectors=subtraction["Projectors"];
  hats=AssociationThread[{"F1","F2"},({f1,f2}/.projectors/.
    {D->4,xh->Q2/(s+Q2),Hg->hard["g"],Hpp->hard["pp"]})];
  gate[channel<>" finite exact F hats",FreeQ[hats,eps|gs|_GLI|_PaVe|_Integrate|_Series|_Limit|_Real|Indeterminate|ComplexInfinity]];
  result=<|"Channel"->channel,"Fhats"->hats,"FiniteContractions"->hard,
    "Delta"->Map[Function[value,0],hats],"L0"->Map[Function[value,0],hats],"L1"->Map[Function[value,0],hats],
    "PhysicalConditions"->physical,"SpectatorFields"->spectators,"SpectatorWeight"->weight,
    "RealPhase"->phase,"InputHashes"->hashes,"SourceHash"->sourceHash,"PoleCache"->directory,"Accepted"->True|>;
  put[result,sidisPath[{channelRoot,"s20_result.wl"}]];
  KeyValueMap[put[#2,sidisPath[{channelRoot,"s20_"<>#1<>"_hat.wl"}]]&,hats];
  Print["FINAL_HATS_ACCEPTED ",channel];<|"Channel"->channel,"Hash"->sidisHash[sidisPath[{channelRoot,"s20_result.wl"}],"SHA256"],"Accepted"->True|>],"S20Failure"];

slots=Quiet[Check[ToExpression[Environment["NSLOTS"]],1]];
If[!IntegerQ[slots]||slots<1,slots=1];CloseKernels[];
If[slots>1,LaunchKernels[KernelConfiguration["localhost","KernelCommand"->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel","KernelCount"->Min[4,slots],"TimeConstraint"->60]]];
workers=Length[Kernels[]];
If[workers>0,ParallelEvaluate[$HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"]];DistributeDefinitions[gate,put,bounded,
  reduce,zero,epsSeries,finitePart,boundary,coreChannel,simpleChannel,root,sourceHash,
  realManifest,virtualManifest,physical,softPhysical,dimension,stateNormalization,
  angularJacobian,hardNormalization,couplingSquare]];
$DistributedContexts=None;
channels={"Hgg","Hqqbar","Hqqprime","Hqq","Hqg","Hgq"};
channelTask[channel_] := If[MemberQ[{"Hgg","Hqqbar","Hqqprime"},channel],simpleChannel[channel],coreChannel[channel]];
If[workers>0,DistributeDefinitions[channelTask]];
values=If[workers>0,ParallelMap[channelTask,channels,Method->"FinestGrained"],channelTask /@channels];
CloseKernels[];
gate["all six channel F hats accepted",FreeQ[values,$Failed|$Aborted]&&And@@Lookup[values,"Accepted"]];
put[<|"Channels"->AssociationThread[channels,values],"SourceHash"->sourceHash,
  "Method"->"Reverse unitarity, Kira IBP, SubTropica masters; no Package-X loop values",
  "Accepted"->True|>,sidisPath[{root,"s20_result.wl"}]];
Print["S20_SUCCESS: all six channels' symbolic F hats passed their pole gates."];
Quit[0];
