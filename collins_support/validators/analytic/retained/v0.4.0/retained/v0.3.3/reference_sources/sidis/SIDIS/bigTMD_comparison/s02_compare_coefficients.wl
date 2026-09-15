(* Reuse the established BigTMD conversion and compare the new SIDIS outputs. *)
$HistoryLength=0;$MaxExtraPrecision=2000;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
root=DirectoryName[$InputFileName];source=$InputFileName;
gate[name_,test_]:=If[!TrueQ[test],Throw[<|"Gate"->name,"Value"->test|>,"stage"]];
SetAttributes[bounded,HoldFirst];
bounded[value_,name_]:=TimeConstrained[MemoryConstrained[value,2*1024^3,
  Throw[<|"Gate"->name,"Reason"->"memory limit"|>,"stage"]],900,
  Throw[<|"Gate"->name,"Reason"->"time limit"|>,"stage"]];
put[value_,file_]:=(Block[{$ContextPath={"System`","Global`"}},Put[value,file<>".tmp"]];
  RenameFile[file<>".tmp",file,OverwriteTarget->True]);
sha[file_]:=FileHash[file,"SHA256","HexString"];
log[value_]:=Print[DateString[Now,"ISODateTime"]," ",value];
setup=Catch[
 gate["source syntax",SyntaxQ[Import[source,"Text"]]];
 imported=Import[FileNameJoin[{root,"s01_result.json"}],"RawJSON"];
 gate["accepted frozen inputs",TrueQ[imported["Accepted"]]];
 Do[
  base=FileNameJoin[{root,ch,"s01_result"}];
  manifest=Import[FileNameJoin[{base,"manifest.json"}],"RawJSON"];
  KeyValueMap[Function[{name,entry},
   path=Which[name==="production.wl"||name==="born.wl"||name==="subtraction.wl",FileNameJoin[{base,name}],
    StringStartsQ[name,"reference/"],FileNameJoin[{base,name}],True,FileNameJoin[{base,"reference",name}]];
   gate[ch<>" frozen input "<>name,sha[path]===entry["SHA256"]]],manifest],{ch,Keys[imported["Channels"]]}];
 helperSource=Import[FileNameJoin[{root,"reference","s05_compare_distributions.wl"}],"Text"];
 helperCode=StringTake[helperSource,{First[First[StringPosition[helperSource,"unitDilogarithm["]]],
   First[First[StringPosition[helperSource,"splitChains["]]]-1}];
 helperGate="And @@ MapThread[SameQ, {Times @@@ rows, terms}]";
 gate["same previously accepted normalizer reconstruction gate",StringCount[helperCode,helperGate]===1];
 helperCode=StringReplace[helperCode,helperGate->
   "And @@ MapThread[(SameQ[#1,#2] || Together[#1-#2] === 0)&, {Times @@@ rows, terms}]"];
 ToExpression[helperCode];
 dilogarithms=Get[FileNameJoin[{root,"reference","s13_dilogarithms.wl"}]];
 gate["accepted identity library",TrueQ[dilogarithms["Complete"]]&&
   dilogarithms["SourceHash"]===FileHash[FileNameJoin[{root,"reference","s13_dilogarithm_identities.wl"}],"SHA256"]];
 common={Q2->Q^2,SUNN->3,Nf->nf,Nc->3,w->s23,mu2->mu^2};
 couplingSquare=Factor[gs^2/.First[Solve[gs^2==4Pi alphaS,gs]]];
 definitions=<||>;productionHashes=<||>;
 Do[
  base=FileNameJoin[{root,ch,"s01_result"}];referenceRoot=FileNameJoin[{base,"reference"}];
  production=Get[FileNameJoin[{base,"production.wl"}]];
  gate[ch<>" accepted new production",TrueQ[production["Accepted"]]];
  AssociateTo[productionHashes,ch->sha[FileNameJoin[{base,"production.wl"}]]];
  physical=(production["PhysicalConditions"]/.common)&&Q>0&&alphaS>0&&Element[nf,Integers]&&nf>=1&&
    Element[{eq,eqp,eq2,chargeSum,otherChargeMoment[1],otherChargeMoment[2]},Reals];
  If[MemberQ[{"Hqq","Hqg","Hgq"},ch],
   born=Get[FileNameJoin[{base,"born.wl"}]];
   projectors=born["ProjectorsEpsilon"]/.eps->0/.born["BornKinematics"];
   ownNorm=eq^2 couplingSquare^2 production["HardNormalization"];
   gate[ch<>" exact replay of exported final projections",And@@Flatten@Table[
    production["Fhats"][item[[1]]]["NLO"][sign][kind]===ownNorm
     (item[[2]]/.projectors/.{hg->production["FiniteContractions"]["Pg"][sign][kind],
       hpp->production["FiniteContractions"]["Ppp"][sign][kind]}),
    {item,{{"F1",f1},{"F2",f2}}},{sign,{1,-1}},{kind,{"Delta","L0","L1","Regular"}}]];
   If[ch==="Hqg",
    packets=FileNames["F*.wl",referenceRoot];
    Do[
     label=FileBaseName[packet];definition=Get[packet]["Definition"];pieces=StringSplit[label,"_"];
     left=If[Last[pieces]==="Born",production["Fhats"][First[pieces]]["LODelta"],
       production["Fhats"][First[pieces]]["NLO"][ToExpression[pieces[[2]]]][Last[pieces]]]/.common;
     AssociateTo[definitions,ch<>"__"<>label-><|"Channel"->ch,"Label"->label,"Left"->left,
       "Right"->definition["Right"],"Assumptions"->definition["Assumptions"],
       "Kind"->Last[pieces],"ReferenceFile"->packet|>],{packet,packets}],
    canonical=Association@Table[mode->Association@Table[sign->Get[FileNameJoin[{referenceRoot,
      "s02_"<>mode<>"_"<>ToString[sign]<>"_canonical.wl"}]],{sign,{1,-1}}],{mode,{"Pg","Ppp"}}];
    matrix=canonical["Pg"][1]["ProjectorMatrix"];
    ownMatrix=Table[Coefficient[(symbol/.projectors),tensor],{symbol,{f1,f2}},{tensor,{hg,hpp}}]/.common;
    gate[ch<>" unchanged reference projectors",(Together/@Flatten[ownMatrix-matrix])==={0,0,0,0}];
    driver=Get[FileNameJoin[{referenceRoot,"s01_driver.wl"}]];
    bornReference=Get[FileNameJoin[{referenceRoot,"s02_born_reference.wl"}]];
    gsSquare=First[driver["gs2"]]/.sourceAlphaS[_]->alphaS;
    bornTransport=Cancel[(First[driver["factor0"]]/lum0)/(z jac0/(xi zeta0^2))/.zh0->z/zeta0]/.gs2->gsSquare;
    bornFactor=Cancel[bornReference["DriverAddition"]/(rawBorn factor0)];
    bornTensors=Values[bornReference["Born"]]/.born["BornKinematics"]/.common;
    referenceBorn=eq^2 bornTransport bornFactor matrix.bornTensors;
    Do[name=item[[1]];index=item[[2]];label=name<>"_Born";
     AssociateTo[definitions,ch<>"__"<>label-><|"Channel"->ch,"Label"->label,
      "Left"->(production["Fhats"][name]["LODelta"]/.common),"Right"->referenceBorn[[index]],
      "Assumptions"->(canonical["Pg"][1]["SoftDomain"]/.omega->s+t),"Kind"->"Born"|>],
      {item,{{"F1",1},{"F2",2}}}];
    Do[
     label=mode<>"_"<>ToString[sign]<>"_"<>kind;conversion=canonical[mode][sign];
     AssociateTo[definitions,ch<>"__"<>label-><|"Channel"->ch,"Label"->label,
      "Left"->(ownNorm production["FiniteContractions"][mode][sign][kind]/.common),
      "Right"->conversion["ReferenceNormalization"]conversion["CanonicalReference"][kind],
      "Assumptions"->conversion[If[kind==="Regular","PhysicalDomain","SoftDomain"]],"Kind"->kind|>],
      {mode,{"Pg","Ppp"}},{sign,{1,-1}},{kind,{"Delta","L0","L1","Regular"}}]];
   ,
   subtraction=Get[FileNameJoin[{base,"subtraction.wl"}]];projectors=subtraction["Projectors"];
   driver=Get[FileNameJoin[{referenceRoot,"s01_driver.wl"}]];
   reference=Get[FileNameJoin[{referenceRoot,"s01_reconstructed.wl"}]]/.w->s23;
   norm=Cancel[(Last[driver["factor"]]/lum)/(z jac/(xi zeta^2))/.zh->z/zeta]/.
     gs2->(First[driver["gs2"]]/.sourceAlphaS[_]->alphaS);
   matrix=Table[Coefficient[({f1,f2}/.projectors/.D->4)[[index]],tensor],
     {index,2},{tensor,{Hg,Hpp}}]/.{xh->Q2/(s+Q2)}/.common;
   weights=Switch[ch,"Hgg",<|"A"->chargeSum|>,"Hqqbar",<|"A"->eq2|>,
     "Hqqprime",<|"A"->eq^2,"B"->eq eqp,"C"->eqp^2|>];
   referenceTensors=Table[norm Total[Table[weights[chargeCase]
     (reference[mode][chargeCase]["regular"]+reference[mode][chargeCase]["plus1B"]/s23+
      reference[mode][chargeCase]["plus2B"]Log[s23]/s23),{chargeCase,Keys[weights]}]],{mode,{"Pg","Ppp"}}];
   referenceHats=matrix.referenceTensors;
   Do[name=item[[1]];index=item[[2]];label=name<>"_Regular";
    AssociateTo[definitions,ch<>"__"<>label-><|"Channel"->ch,"Label"->label,
      "Left"->(production["Fhats"][name]/.common),"Right"->referenceHats[[index]],
      "Assumptions"->physical,"Kind"->"Regular"|>],{item,{{"F1",1},{"F2",2}}}]];
  ,{ch,Keys[imported["Channels"]]}];
 hash=Hash[{FileHash[source,"SHA256"],FileHash[FileNameJoin[{root,"s01_result.json"}],"SHA256"],helperCode},"SHA256"];
 put[<|"Definitions"->definitions,"InputHash"->hash,"ProductionHashes"->productionHashes|>,FileNameJoin[{root,"s02_inputs.wl"}]];
 True,"stage"];
If[setup=!=True,put[setup,FileNameJoin[{root,"s02_failure.wl"}]];Print["FAIL: setup ",InputForm[setup]];Quit[1]];

comparisonTask[key_]:=Module[{definition,channel,label,directory,file,saved,assumptions,difference,
  radicals,map={},domain,reduced,result,points,checks,point,numericalPoint,values,numericDifference},
 definition=definitions[key];channel=definition["Channel"];label=definition["Label"];
 directory=FileNameJoin[{root,channel,"s02_result",IntegerString[hash,16],label}];
 If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
 file=FileNameJoin[{directory,"s02_result.wl"}];
 If[FileExistsQ[file],saved=Get[file];If[saved["InputHash"]===hash&&TrueQ[saved["Completed"]],Return[saved]]];
 result=Block[{cache=directory,inputHash=hash,acceptedInputHashes={hash}},Catch[
  log[{"COMPARE",key}];assumptions=definition["Assumptions"];
  difference=definition["Left"]-definition["Right"];
  points=Table[{Q->qvalue,s->10,t->-9,omega->1,mu->3,B->2,nf->4,alphaS->1/5,
    eq->2/3,eqp->-1/3,eq2->(2/3)^2,chargeSum->1,otherChargeMoment[1]->0,
    otherChargeMoment[2]->2/9,s23->1/7},{qvalue,{2,5/2}}];
  checks=Table[
   gate["physical comparison point",TrueQ[assumptions/.point]];
   numericalPoint=Map[Function[rule,First[rule]->N[Last[rule],90]],point];
   values=bounded[Quiet[N[{definition["Left"],definition["Right"]}/.numericalPoint,90],{N::meprec}],"original coefficient values"];
   gate["finite numeric coefficients",And@@(NumericQ/@values)];
   numericDifference=Subtract@@values;
   <|"Point"->point,"Values"->values,"Difference"->numericDifference,
    "Equal"->TrueQ[Abs[numericDifference]<10^-60 Max[1,Max[Abs[values]]]]|>,{point,points}];
  put[<|"Definition"->definition,"Difference"->difference,"NumericalChecks"->checks,"InputHash"->hash|>,
   FileNameJoin[{directory,"s02_input.wl"}]];
  domain=assumptions;
  If[definition["Kind"]==="Regular",
   radicals=DeleteDuplicates[Cases[difference,Power[rad_,power_Rational]/;
    Denominator[power]===2&&!FreeQ[rad,s23]&&PolynomialQ[rad,s23]&&Exponent[rad,s23]===1:>rad,Infinity]];
   If[radicals=!={},radical=First[SortBy[radicals,LeafCount]];
    gate["positive recoil radical",bounded[FullSimplify[radical>0,domain],"radical domain"]===True];
    map=First[Solve[radius^2==radical,s23]];
    gate["invertible recoil coordinate",Together[(radical/.map)-radius^2]===0];domain=(domain/.map)&&radius>0]];
  reduced=bounded[normalize[Refine[difference/.map,domain],domain],"fresh exact comparison"];
  <|"Completed"->True,"Channel"->channel,"Label"->label,"InputHash"->hash,
   "Difference"->reduced,"Equal"->TrueQ[reduced===0],"NumericalChecks"->checks,
   "Assumptions"->domain,"AlgebraicMap"->map,"FreshDifferenceHash"->Hash[difference,"SHA256"]|>,"stage"]];
 If[!AssociationQ[result]||!TrueQ[result["Completed"]],result=<|"Completed"->False,"Channel"->channel,
  "Label"->label,"InputHash"->hash,"Failure"->result|>];
 put[result,file];log[{"COMPARISON_FINISHED",key,result["Completed"],result["Equal"]}];result];
slots=Quiet[Check[ToExpression[Environment["NSLOTS"]],1]];If[!IntegerQ[slots]||slots<1,slots=1];
LaunchKernels[KernelConfiguration["localhost","KernelCommand"->
 "/u/local/apps/mathematica/13.1/Executables/WolframKernel","KernelCount"->Min[4,slots],"TimeConstraint"->60]];
gate["cluster workers available",Length[Kernels[]]>0];
ParallelEvaluate[$HistoryLength=0;$MaxExtraPrecision=2000;$FeynCalcStartupMessages=False;Get["FeynCalc`"]];
DistributeDefinitions[root,hash,definitions,gate,bounded,put,log,dilogarithms,unitDilogarithm,
 reduceDilogarithm,reduceFunction,reduceAlgebraic,expandCoth,normalize,comparisonTask];
$DistributedContexts=None;
results=ParallelMap[comparisonTask,Keys[definitions],Method->"FinestGrained"];CloseKernels[];
channels=Keys[imported["Channels"]];
byChannel=Association@Table[ch->With[{rows=Select[results,#["Channel"]===ch&]},
 <|"Completed"->AllTrue[rows,TrueQ[#["Completed"]]&],"AllEqual"->AllTrue[rows,TrueQ[#["Equal"]]&],
 "Results"->rows,"ProductionSHA256"->productionHashes[ch]|>],{ch,channels}];
KeyValueMap[put[#2,FileNameJoin[{root,#1,"s02_result.wl"}]]&,byChannel];
out=<|"Channels"->byChannel,"Completed"->AllTrue[results,TrueQ[#["Completed"]]&],
 "AllEqual"->AllTrue[results,TrueQ[#["Equal"]]&],"InputHash"->hash,"SourceSHA256"->sha[source],
 "Direction"->"new SIDIS minus reconstructed BigTMD","ReferenceInterpretation"->imported["ReferenceInterpretation"]|>;
put[out,FileNameJoin[{root,"s02_result.wl"}]];
Export[FileNameJoin[{root,"s02_result.json"}],<|"Completed"->out["Completed"],"AllEqual"->out["AllEqual"],
 "Channels"->Map[KeyTake[#,{"Completed","AllEqual","ProductionSHA256"}]&,byChannel],"ResultSHA256"->sha[FileNameJoin[{root,"s02_result.wl"}]]|>,"RawJSON"];
If[TrueQ[out["Completed"]],Print["S02_SUCCESS: six-channel comparison evaluated; AllEqual=",out["AllEqual"]];Quit[0],
 Print["FAIL: unfinished comparison component"];Quit[1]];
