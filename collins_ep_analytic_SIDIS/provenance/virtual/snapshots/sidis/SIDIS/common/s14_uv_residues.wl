Get[FileNameJoin[{DirectoryName[$InputFileName],"..","common","s22_paths.wl"}]];
(* Fresh UV residues through auxiliary-mass rearrangement, Kira and SubTropica. *)
$HistoryLength=0;$FeynCalcStartupMessages=False;$LoadAddOns={"FeynArts"};
Get["FeynCalc`"];$FAVerbose=0;
root=sidisRoot;
gate[name_,test_] := If[TrueQ[test],Print["PASS: ",name],Print["FAIL: ",name];Quit[1]];
put[value_,file_] := (Put[value,file<>".tmp"];RenameFile[file<>".tmp",file,OverwriteTarget->True]);
SetAttributes[bounded,HoldFirst];
bounded[value_,label_] := MemoryConstrained[TimeConstrained[value,1200,
  gate[label<>" time limit",False]],2*1024^3,gate[label<>" memory limit",False]];
zero[value_] := Factor[Together[value]]===0;
geometry=sidisGet[sidisPath[{root,"s02_result.wl"}]];
virtualManifest=sidisGet[sidisPath[{root,"s05_result.wl"}]];
gate["accepted unintegrated virtual maps",TrueQ[virtualManifest["Accepted"]]];
sourceHash=sidisHash[$InputFileName,"SHA256"];
inputHash=Hash[{sourceHash,sidisHash[sidisPath[{root,"s05_result.wl"}],"SHA256"],
  sidisHash[sidisPath[{root,"s02_result.wl"}],"SHA256"]},"SHA256"];
work=sidisPath[{root,"common","s14_uv",IntegerString[inputHash,16]}];
If[!DirectoryQ[work],CreateDirectory[work,CreateIntermediateDirectories->True]];
external={p,q,k1};externalGram=geometry["CommonGram"][[1;;3,1;;3]] /. w->0;
setKinematics[] := (FCClearScalarProducts[];
  Do[With[{left=external[[i]],right=external[[j]],value=externalGram[[i,j]]},
    SPD[left,right]=value],{i,Length[external]},{j,i,Length[external]}]);
setKinematics[];
loopProducts=FCI[SPD[ell,#]]& /@ Prepend[external,ell];
loopVariables=Array[uvx,Length[loopProducts]];
scalarRules=Thread[loopProducts->loopVariables];
coordinateVariables=Array[uvz,Length[loopProducts]];
families=<|
  "OS"-><|"Momenta"->{ell,ell+p,ell+q,ell+k1},"Masses"->{0,0,0,0}|>,
  "SE"-><|"Momenta"->{ell,ell+q,ell+p,ell+k1},"Masses"->{0,0,0,0}|>,
  "UV"-><|"Momenta"->{ell,ell+p,ell+q,ell+k1},"Masses"->{M2,M2,M2,M2}|>|>;
familyMaps=Association@KeyValueMap[Function[{id,data},Module[{polynomials,solution},
  polynomials=MapThread[ExpandScalarProduct[FCI[SPD[#1,#1]]]-#2 &,
    {data["Momenta"],data["Masses"]}] /. scalarRules;
  solution=Solve[Thread[polynomials==coordinateVariables],loopVariables];
  gate[id<>" unique loop scalar coordinate map",Length[solution]===1];
  id-><|"Polynomials"->polynomials,"Rules"->First[solution]|>]],families];
mapScalar[expression_,id_] := Module[{mapped,terms,coefficient,powers,values,reconstructed},
  If[expression===0,Return[<||>]];
  mapped=Expand[Cancel[expression /. familyMaps[id]["Rules"]]];
  terms=If[Head[mapped]===Plus,List@@mapped,{mapped}];
  values=Map[Function[term,
    powers=Table[Exponent[Numerator[Together[term]],z]-Exponent[Denominator[Together[term]],z],
      {z,coordinateVariables}];
    coefficient=Factor[term/(Times@@(coordinateVariables^powers))];
    gate[id<>" scalar coefficient has no loop coordinates",FreeQ[coefficient,Alternatives@@coordinateVariables]];
    GLI[id,-powers]->coefficient],terms];
  values=Map[Factor[Together[#]]&,Merge[Association /@ values,Total]];
  reconstructed=Total[KeyValueMap[#2 Times@@(familyMaps[id]["Polynomials"]^(-#1[[2]]))&,values]];
  gate[id<>" exact scalar-integrand reconstruction",zero[reconstructed-expression]];values];
toScalars[value_] := Factor[Together[ExpandScalarProduct[FeynAmpDenominatorExplicit[value]] /. scalarRules]];
uvExpansion[value_,label_] := Module[{rational,scaling,series,firstPower,pieces,regularized},
  rational=toScalars[value];If[rational===0,Return[<||>]];
  gate[label<>" closed scalar loop integrand",FreeQ[rational,_Pair|_FeynAmpDenominator|ell]];
  scaling=Thread[loopVariables->MapIndexed[#1 lam^(-If[First[#2]===1,2,1])&,loopVariables]];
  series=bounded[Normal[Series[rational /. scaling,{lam,0,4}]],label<>" UV expansion"];
  If[series===0,Return[<||>]];
  firstPower=Exponent[series,lam,Min];
  pieces=Association@Table[power->Factor[Coefficient[series,lam,power]],{power,firstPower,4}];
  regularized=Map[Function[piece,Expand[piece] /.
    Power[uvx[1],n_Integer /; n<0] :> (uvx[1]-M2)^n],pieces];
  gate[label<>" auxiliary mass leaves logarithmic asymptotics unchanged",
    zero[Coefficient[Normal[Series[(regularized[4]-pieces[4]) /. scaling,{lam,0,4}]],lam,4]]];
  Association@KeyValueMap[#1->mapScalar[#2,"UV"]&,regularized]];

(* Generate the two-point functions from the massless QCD model. *)
gate["complete source syntax",SyntaxQ[sidisImport[$InputFileName,"Text"]]];
massRules=Thread[(SMP /@ {"m_u","m_d","m_s","m_c","m_b","m_t"})->0];
electroweak={S[_],V[1|2|3|4],U[1|2|3|4],F[1|2]};
strongPower=ng /. First[Solve[{3(v3+ve)+4v4==2ni+ne,
  nl==ni-v3-v4-ve+1,ng==v3+2v4,ve==nPhoton},{ng,ni,v3,ve}]];
generateSelf[field_,exclusions_,label_] := Module[{topologies,diagrams,raw,amplitudes,fields,masses,assignedFields},
  topologies=CreateTopologies[1,1->1,ExcludeTopologies->{Tadpoles}];
  diagrams=InsertFields[topologies,{field}->{field},Model->"SMQCD",InsertionLevel->{Particles},ExcludeParticles->exclusions];
  If[label==="one_flavor",assignedFields=Cases[diagrams,HoldPattern[Rule[Field[_],value_]]:>value,Infinity];
    fields=DeleteDuplicates[Cases[assignedFields,F[3,{i_Integer,___}]:>i,Infinity]];
    put[<|"Diagrams"->diagrams,"MeasuredFlavors"->fields|>,sidisPath[{work,"s14_flavor_labels.wl"}]];
    gate["one generated massless closed flavor",fields==={1} && FreeQ[assignedFields,F[4,___]]]];
  raw=CreateFeynAmp[diagrams,Truncated->True,PreFactor->1];
  amplitudes=FCFAConvert[raw,IncomingMomenta->{v},OutgoingMomenta->{v},LoopMomenta->{ell},
    UndoChiralSplittings->True,ChangeDimension->D,List->True,SMP->True,Contract->False,
    DropSumOver->True,FinalSubstitutions->massRules]//DotSimplify//(DiracSimplify[#,DiracTraceEvaluate->True]&);
  gate[label<>" generated QCD coupling degree",Length[amplitudes]>0 &&
    And@@(Exponent[#,SMP["g_s"]]==(strongPower /. {ne->Length[{field,field}],nl->1,nPhoton->0})&&FreeQ[#,SMP["e"]]& /@ amplitudes)];
  masses=DeleteDuplicates[Cases[amplitudes,x_ /; MatchQ[Head[x],_Symbol]&&MemberQ[{"MQU","MQD"},SymbolName[Head[x]]]:>x,Infinity]];
  <|"Diagrams"->diagrams,"Amplitudes"->(amplitudes /. SMP["g_s"]->1 /. Thread[masses->0]),
    "MassSpecialization"->Thread[masses->0]|>];
colorCoefficient[value_] := Module[{expression,identities},
  expression=SUNSimplify[Contract[value],Explicit->True,SUNNToCACF->False];
  identities=DeleteDuplicates[Cases[expression,_SUNDelta|_SUNFDelta,Infinity]];
  gate["self-energy color identity",Length[identities]===1 && FreeQ[expression,_SUNTF|_SUNTrace|_SUNF]];
  expression/First[identities]];
selfProjection[data_,type_] := Module[{amplitude,free,insertion,denominator,indices,projector,ratio,longitudinal=0,routes,candidates,valid,routing,coordinateDenominator,originalRatio},
  FCClearScalarProducts[];SPD[v,v]=rho;
  amplitude=colorCoefficient[Total[data["Amplitudes"]]];
  If[type==="quark",
    free=I GSD[v]/rho;
    insertion=DiracTrace[GSD[v].free.amplitude.free];denominator=DiracTrace[GSD[v].free];
    ratio=DiracSimplify[insertion,DiracTraceEvaluate->True]/DiracSimplify[denominator,DiracTraceEvaluate->True],
    indices=DeleteDuplicates[Cases[amplitude,_LorentzIndex,Infinity]];
    gate["two vector self-energy indices",Length[indices]===2];
    amplitude=amplitude /. Thread[indices->{LorentzIndex[muSE,D],LorentzIndex[nuSE,D]}];
    longitudinal=Contract[FVD[v,muSE] FVD[v,nuSE] amplitude]/rho^2;
    projector=MTD[muSE,nuSE]-FVD[v,muSE]FVD[v,nuSE]/rho;
    free=-I MTD[muSE,nuSE]/rho;
    insertion=projector(-I MTD[muSE,aaSE]/rho)(amplitude /. {muSE->aaSE,nuSE->bbSE})(-I MTD[bbSE,nuSE]/rho);
    ratio=Contract[insertion]/Contract[projector free]];
  ratio=ExpandScalarProduct[Contract[ratio]];longitudinal=ExpandScalarProduct[longitudinal];
  setKinematics[];
  ratio=FCReplaceMomenta[ratio,{v->q}] /. rho->-Q2;
  longitudinal=FCReplaceMomenta[longitudinal,{v->q}] /. rho->-Q2;
  originalRatio=ratio;
  routes=(ell-># ell)& /@(sign /. Solve[sign^2==1,sign]);
  candidates=Association@Table[ToString[route,InputForm]->
    toScalars[FCReplaceMomenta[ratio,{route}]],{route,routes}];
  valid=Select[routes,Function[route,
    coordinateDenominator=Denominator[Cancel[candidates[ToString[route,InputForm]] /. familyMaps["SE"]["Rules"]]];
    PolynomialQ[coordinateDenominator,coordinateVariables]&&
      Length[CoefficientRules[coordinateDenominator,coordinateVariables]]===1]];
  put[<|"Original"->originalRatio,"RoutingCandidates"->candidates,"ValidRoutings"->valid|>,
    sidisPath[{work,"s14_routing_"<>IntegerString[Hash[originalRatio,"SHA256"],16]<>".wl"}]];
  gate[type<>" self energy has a scalar-family loop routing",Length[valid]>0];
  routing=First[valid];
  gate["self-energy loop reversal has unit measure Jacobian",Abs[D[Last[routing],ell]]===1];
  ratio=FCReplaceMomenta[ratio,{routing}];longitudinal=FCReplaceMomenta[longitudinal,{routing}];
  <|"OriginalIntegrand"->originalRatio,"LoopRouting"->routing,
    "Full"->mapScalar[toScalars[ratio],"SE"],"UVPowers"->uvExpansion[ratio,type<>" self energy"],
    "Longitudinal"->mapScalar[toScalars[longitudinal],"SE"]|>];
selfGenerated=<|
  "quark"->bounded[generateSelf[F[3,{1}],electroweak,"quark"],"quark generation"],
  "gauge"->bounded[generateSelf[V[5],Join[electroweak,{F[_]}],"gauge"],"gauge generation"],
  "one_flavor"->bounded[generateSelf[V[5],{S[_],V[_],U[_],F[1|2|4],F[3,{2}],F[3,{3}]},"one_flavor"],"flavor generation"]|>;

previousSourceFile=sidisPath[{root,"s14_previous_14692901","s14_uv_residues.wl"}];
previousText=sidisImport[previousSourceFile,"Text"];currentText=sidisImport[$InputFileName,"Text"];
previousPrefix=StringTrim[StringTake[previousText,First[First[StringPosition[previousText,"uvDiagrams=<||>"]]]-1]];
currentPrefix=StringTrim[StringTake[currentText,First[First[StringPosition[currentText,"(* Generate the two-point functions"]]]-1]];
gate["reused UV maps have byte-identical defining algebra",previousPrefix===currentPrefix];
previousHash=Hash[{sidisHash[previousSourceFile,"SHA256"],sidisHash[sidisPath[{root,"s05_result.wl"}],"SHA256"],
  sidisHash[sidisPath[{root,"s02_result.wl"}],"SHA256"]},"SHA256"];
previousWork=sidisPath[{root,"common","s14_uv",IntegerString[previousHash,16]}];
uvDiagrams=<||>;bornInputs=<||>;
Do[
  data=sidisGet[sidisPath[{root,channel,"s05_result.wl"}]];
  gate[channel<>" virtual input identity",sidisHash[sidisPath[{root,channel,"s05_result.wl"}],"SHA256"]===
    virtualManifest["Channels"][channel]["Hash"]];
  AssociateTo[bornInputs,channel->sidisGet[sidisPath[{root,channel,"s01_inputs","s02_result.wl"}]]];
  Do[
    label=channel<>"_"<>diagram["Mode"]<>"_"<>ToString[diagram["Diagram"]];
    file=sidisPath[{work,"s14_"<>label<>".wl"}];
    Print["UV_DIAGRAM ",label];
    previousFile=sidisPath[{previousWork,"s14_"<>label<>".wl"}];
    saved=If[FileExistsQ[file],sidisGet[file],If[FileExistsQ[previousFile],
      inherited=sidisGet[previousFile];gate[label<>" inherited UV map identity",inherited["InputHash"]===previousHash];
      inherited=Join[inherited,<|"InputHash"->inputHash,"OriginalInputHash"->previousHash,
        "UnchangedMapSource"->previousSourceFile,"OriginalFile"->previousFile|>];
      put[inherited,file];inherited,<||>]];
    packet=If[Lookup[saved,"InputHash",None]===inputHash,saved,
      packet=<|"InputHash"->inputHash,"Channel"->channel,"Mode"->diagram["Mode"],
        "Diagram"->diagram["Diagram"],"UVPowers"->uvExpansion[diagram["ContractedIntegrand"],label]|>;
      put[packet,file];packet];
    AssociateTo[uvDiagrams,label->packet],{diagram,data["DiagramMaps"]}];
  Clear[data];ClearSystemCache[],{channel,{"Hqq","Hqg","Hgq"}}];

selfMaps=Association@KeyValueMap[#1->selfProjection[#2,If[#1==="quark","quark","gluon"]]&,selfGenerated];
put[<|"Generated"->selfGenerated,"Maps"->selfMaps,"InputHash"->inputHash|>,sidisPath[{work,"s14_self_energies.wl"}]];
scalarCoefficientMaps=Join[Flatten[Values[#["UVPowers"]]& /@ Values[uvDiagrams],1],
  Flatten[Join[Values[#["UVPowers"]],{#["Full"],#["Longitudinal"]}]& /@Values[selfMaps],1]];
gate["all scalar coefficients are explicit maps",And@@(AssociationQ /@ scalarCoefficientMaps)];
targets=Union[Flatten[Keys /@ scalarCoefficientMaps,1],{GLI["OS",{1,1,0,0}]}];
gate["all Kira targets are scalar integrals",MatchQ[targets,{__GLI}]];
gate["Kira target export covers every coefficient map",And@@(Complement[Keys[#],targets]==={}& /@ scalarCoefficientMaps)];
gate["generated self-energy and UV targets are present",And@@(MemberQ[targets,GLI[#,_]]& /@ {"SE","UV"})];
put[<|"UVVirtualDiagrams"->uvDiagrams,"SelfMaps"->selfMaps,"Families"->families,
  "Targets"->targets,"InputHash"->inputHash,"SourceHash"->sourceHash,
  "AcceptedScalarMaps"->True|>,sidisPath[{work,"s14_scalar_maps.wl"}]];

mapWork=work;work=sidisPath[{mapWork,"s14_kira"}];
families=Map[Join[#,<|"LoopMomenta"->{ell},"PropagatorMomenta"->#["Momenta"],
  "PropagatorMassesSquared"->#["Masses"]|>]&,families];
names=Sort[Keys[families]];
kira = sidisPath[{root, "software", "kira-3.1"}];
fermat = sidisPath[{root, "software", "fermat", "Ferl7", "fer64"}];
gate["dedicated Kira and Fermat binaries exist", FileExistsQ[kira] && FileExistsQ[fermat]];
SetEnvironment["FERMATPATH" -> fermat];
config = sidisPath[{work, "config"}];
If[!DirectoryQ[config], CreateDirectory[config, CreateIntermediateDirectories -> True]];
text[expression_] := StringReplace[ToString[InputForm[expression]], Whitespace -> ""];
csv[list_] := "[" <> StringRiffle[text /@ list, ","] <> "]";
integralText[integral_] := integral[[1]] <> csv[integral[[2]]];
invariants = Union[{M2},Sort[DeleteDuplicates[Cases[externalGram,
  symbol_Symbol /; Context[symbol] === "Global`", Infinity]]]];
(* Fermat requires lower-case variable names. This is a name change only. *)
exportRules = {Q2 -> q2,M2->m2};
importRules = Reverse /@ exportRules;
gate["invariant rename is invertible", (invariants /. exportRules /. importRules) === invariants];
kinematics = {"kinematics:", "  incoming_momenta: " <> csv[external],
  "  outgoing_momenta: []", "  kinematic_invariants:"};
kinematics = Join[kinematics, ("    - [" <> text[# /. exportRules] <> ", 2]" & /@ invariants),
  {"  scalarproduct_rules:"}, Flatten[Table[
    "    - [[" <> text[external[[i]]] <> "," <> text[external[[j]]] <> "], " <>
      text[externalGram[[i, j]] /. exportRules] <> "]",
    {i, Length[external]}, {j, i, Length[external]}]]];
Export[sidisPath[{config, "kinematics.yaml"}], StringRiffle[kinematics, "\n"] <> "\n", "Text"];
familyLines = {"integralfamilies:"};
reductions = {};
preferred = {};
bounds = <||>;
globalR = Max[Total[Select[#, #>0 &]] & /@ targets[[All,2]]] + Length[First[Values[families]]["LoopMomenta"]];
globalS = Max[-Total[Select[#, #<0 &]] & /@ targets[[All,2]]] + Length[First[Values[families]]["LoopMomenta"]];
Do[
  spec = families[name];
  actual = Select[targets, #[[1]] === name &][[All, 2]];
  positiveSums = Total[Select[#, # > 0 &]] & /@ actual;
  negativeSums = -Total[Select[#, # < 0 &]] & /@ actual;
  sectors = Sort[DeleteDuplicates[Total[MapIndexed[
    If[#1 > 0, 2^(First[#2] - 1), 0] &, #]] & /@ actual]];
  topSectors = Select[sectors, Function[sector, !AnyTrue[DeleteCases[sectors, sector],
    BitAnd[sector, #] === sector &]]];
  rBound = globalR;
  sBound = globalS;
  AssociateTo[bounds, name -> <|"r" -> rBound, "s" -> sBound,
    "Sectors" -> sectors, "TopSectors" -> topSectors, "TargetCount" -> Length[actual]|>];
  familyLines = Join[familyLines, {"  - name: " <> name,
    "    loop_momenta: " <> csv[spec["LoopMomenta"]],
    "    top_level_sectors: " <> csv[topSectors], "    propagators:"},
    MapThread["      - [\"" <> text[#1] <> "\", " <> text[#2 /. exportRules] <> "]" &,
      {spec["PropagatorMomenta"], spec["PropagatorMassesSquared"]}],
    {}];
  AppendTo[reductions, "        - {topologies: [" <> name <> "], sectors: " <>
    csv[topSectors] <> ", r: " <> text[rBound] <> ", s: " <> text[sBound] <> "}"];
  preferred = Join[preferred, Table[GLI[name,
    Table[If[MemberQ[support, i], 1, 0], {i,Length[spec["PropagatorMomenta"]]}]],
    {support, Subsets[Range[Length[spec["PropagatorMomenta"]]]]}]],
  {name, names}];
Export[sidisPath[{config, "integralfamilies.yaml"}], StringRiffle[familyLines, "\n"] <> "\n", "Text"];
Export[sidisPath[{work, "targets"}], StringRiffle[integralText /@ targets, "\n"] <> "\n", "Text"];
Export[sidisPath[{work, "preferred"}], StringRiffle[integralText /@ preferred, "\n"] <> "\n", "Text"];
jobs = Join[{"jobs:", "  - reduce_sectors:", "      reduce:"}, reductions,
  {"      select_integrals:", "        select_mandatory_list:", "          - [targets]",
   "      preferred_masters: preferred", "      run_initiate: true",
   "      run_triangular: true", "      run_back_substitution: true",
   "  - kira2math:", "      target:", "        - [targets]"}];
Export[sidisPath[{work, "jobs.yaml"}], StringRiffle[jobs, "\n"] <> "\n", "Text"];
put[<|"InputHash" -> inputHash, "SourceHash" -> sourceHash, "Bounds" -> bounds,
  "Families" -> families, "Targets" -> targets, "PreferredCandidates" -> preferred,
  "ExportRules" -> exportRules, "ImportRules" -> importRules,
  "ScalarMapFile" -> "../s14_scalar_maps.wl"|>, sidisPath[{work, "s14_configuration.wl"}]];
Print["KIRA_START ", work, " target count ", Length[targets], " bounds ", InputForm[bounds]];
run = RunProcess[{kira, "--parallel=2", "jobs.yaml"}, All, ProcessDirectory -> work];
Export[sidisPath[{work, "s14_kira_stdout.log"}], run["StandardOutput"], "Text"];
Export[sidisPath[{work, "s14_kira_stderr.log"}], run["StandardError"], "Text"];
Print[StringTake[run["StandardOutput"], -Min[12000, StringLength[run["StandardOutput"]]]]];
If[run["StandardError"] =!= "", Print[run["StandardError"]]];
gate["Kira completed", run["ExitCode"] === 0];
ruleFiles = Sort[FileNames["kira_*.m", sidisPath[{work, "results"}], Infinity]];
gate["Kira exported symbolic rules", Length[ruleFiles] > 0];
rules = DeleteDuplicates[Flatten[Get /@ ruleFiles]];
gate["Kira output consists of rules", MatchQ[rules, {__Rule}]];
heads = Symbol /@ names;
toIntegral[expression_] := expression /. (HoldPattern[h_[indices__Integer]] /; MemberQ[heads, h]) :>
  GLI[SymbolName[h], {indices}];
masterFile = sidisPath[{work, "tmp", Last[names], "masters"}];
gate["final Kira master inventory exists", FileExistsQ[masterFile]];
declaredMasters = toIntegral[ToExpression /@ StringCases[sidisImport[masterFile, "Text"],
  RegularExpression["[A-Z]+\\[[0-9, -]+\\]"]]];
gate["nonempty final Kira master inventory", MatchQ[declaredMasters, {__GLI}]];
rules = toIntegral[rules] /. importRules /. d -> D;
missingTargets = Complement[targets, First /@ rules];
gate["targets without explicit rules are declared masters",
  Complement[missingTargets, declaredMasters] === {}];
rules = Join[rules, (# -> # & /@ missingTargets)];
gate["each target has a reduction rule", Complement[targets, First /@ rules] === {}];
gate["rules have unique targets", DuplicateFreeQ[First /@ rules]];
masters = Sort[DeleteDuplicates[Cases[Last /@ rules, _GLI, Infinity]]];
closureFiles={};closurePass=0;
missingMasters=Complement[masters,declaredMasters];
While[missingMasters=!={} && closurePass<5,
  closurePass++;
  closureName="closure_"<>ToString[closurePass];
  Export[sidisPath[{work,closureName}],StringRiffle[integralText /@ missingMasters,"\n"]<>"\n","Text"];
  Export[sidisPath[{work,closureName<>".yaml"}],
    "jobs:\n  - kira2math:\n      target:\n        - ["<>closureName<>"]\n","Text"];
  Print["KIRA_EXPORT_CLOSURE ",InputForm[missingMasters]];
  closureRun=RunProcess[{kira,closureName<>".yaml"},All,ProcessDirectory->work];
  Export[sidisPath[{work,"s14_"<>closureName<>".log"}],closureRun["StandardOutput"]<>closureRun["StandardError"],"Text"];
  gate["Kira intermediate-integral export completed",closureRun["ExitCode"]===0];
  files=FileNames["kira_"<>closureName<>".m",sidisPath[{work,"results"}],Infinity];
  gate["Kira exported the needed intermediate rules",Length[files]>0];
  closureRules=toIntegral[DeleteDuplicates[Flatten[Get /@ files]]] /. importRules /. d->D;
  gate["every intermediate has a non-identity Kira rule",Complement[missingMasters,First /@ closureRules]==={} &&
    And@@(First[#]=!=Last[#]& /@ closureRules)];
  rules=(First[#]->Expand[Last[#] /. closureRules]& /@ rules);
  closureFiles=Join[closureFiles,files];
  masters=Sort[DeleteDuplicates[Cases[Last /@ rules,_GLI,Infinity]]];
  missingMasters=Complement[masters,declaredMasters]];
put[<|"ExportedMasters" -> masters,"FinalInventory" -> declaredMasters,
  "MissingFromInventory" -> Complement[masters,declaredMasters]|>,sidisPath[{work,"s14_master_inventory.wl"}]];
gate["every rule ends in Kira's final master inventory",
  Complement[masters, declaredMasters] === {}];
gate["final virtual basis consists of scalar unit-index masters",
  And @@ (Complement[#[[2]],{0,1}] === {} & /@ masters)];
gate["rule coefficients are rational in symbolic dimension and invariants",
  FreeQ[rules, _Real | $Failed | $Aborted]];

reduction=<|"Rules"->rules,"Masters"->masters,"Targets"->targets,"Families"->families,
  "RuleFiles"->ruleFiles,"ClosureRuleFiles"->closureFiles,"InputHash"->inputHash,"SourceHash"->sourceHash,
  "Accepted"->True|>;
put[reduction,sidisPath[{mapWork,"s14_reduction.wl"}]];
ruleMap=Association[rules];
reduceMap[coefficients_] := Factor[Together[Total[KeyValueMap[#2 ruleMap[#1]&,coefficients]]]];
gate["on-shell massless two-point integral is scaleless in Kira",ruleMap[GLI["OS",{1,1,0,0}]]===0];
KeyValueMap[gate[#1<>" self energy is transverse",reduceMap[#2["Longitudinal"]]===0]&,KeyDrop[selfMaps,{"quark"}]];
selfFull=Map[reduceMap[#["Full"]]&,selfMaps];
selfBasis=Union[Cases[Values[selfFull],_GLI,Infinity]];
gate["full generated self energies use one common massless off-shell bubble",Length[selfBasis]===1];
selfMaster=First[selfBasis];selfDefinition=families[selfMaster[[1]]];
selfActive=Flatten[Position[selfMaster[[2]],1]];
gate["self-energy master is the massless external two-point integral",Length[selfActive]===2 &&
  selfDefinition["Masses"][[selfActive]]==={0,0} &&
  zero[ExpandScalarProduct[FCI[SPD[Subtract@@selfDefinition["Momenta"][[selfActive]]]]]+Q2]];
selfFactors=Map[Factor[#/selfMaster]&,selfFull];
gate["self-energy coefficients have a finite on-shell limit",And@@Map[
  FreeQ[Limit[#,Q2->0],Indeterminate|ComplexInfinity|_DirectedInfinity|_Limit]&,
  Values[selfFactors]]];
put[<|"ReducedSelfEnergies"->selfFull,"ScalarBubble"->selfMaster,"Coefficients"->selfFactors,
  "OnShellBubble"->GLI["OS",{1,1,0,0}],"KiraOnShellValue"->ruleMap[GLI["OS",{1,1,0,0}]],
  "AcceptedOnShellBoundary"->True|>,sidisPath[{mapWork,"s14_onshell_boundary.wl"}]];
scalarCoefficientMaps=Join[Flatten[Values[#["UVPowers"]]& /@ Values[uvDiagrams],1],
  Flatten[Join[Values[#["UVPowers"]],{#["Full"],#["Longitudinal"]}]& /@Values[selfMaps],1]];
reducedForms=reduceMap /@ scalarCoefficientMaps;
masterOrders=Association@Table[master->Module[{coefficients,valuations},
  coefficients=DeleteCases[Factor[Coefficient[Expand[#],master]]& /@reducedForms,0];
  valuations=Map[Function[value,With[{rational=Cancel[value /. D->4-2 Global`eps]},
    Exponent[Numerator[rational],Global`eps,Min]-Exponent[Denominator[rational],Global`eps,Min]]],coefficients];
  Max[0,-1-Min[valuations]]],{master,masters}];
put[masterOrders,sidisPath[{mapWork,"s14_master_orders.wl"}]];
work=mapWork;
setKinematics[];
cutGeometry=sidisGet[sidisPath[{root,"s08_result.wl"}]];
sphereArea=cutGeometry["SphereAreaDefinition"];
packageRoot=sidisPath[{root,"software","SubTropica-1.2.10"}];
polymake=sidisPath[{root,"software","s01_polymake"}];
parameterInputs=<||>;
Do[
  definition=families[master[[1]]];active=Flatten[Position[master[[2]],1]];
  propagators=Table[FeynAmpDenominator[StandardPropagatorDenominator[
    Momentum[definition["Momenta"][[i]],D],0,-definition["Masses"][[i]],{master[[2,i]],1}]],{i,active}];
  denominatorResiduals=Table[
    ExpandScalarProduct[1/FeynAmpDenominatorExplicit[propagators[[j]]]]-
      ExpandScalarProduct[FCI[SPD[definition["Momenta"][[active[[j]]]],definition["Momenta"][[active[[j]]]]]]]+
      definition["Masses"][[active[[j]]]],{j,Length[active]}];
  gate["UV master denominator convention",And@@(zero /@ denominatorResiduals)];
  representation=bounded[FCFeynmanParametrize[Times@@propagators,{ell},Names->x,
    FCReplaceD->{D->4-2 Global`eps},FeynmanIntegralPrefactor->"Unity"],"UV master parameters"];
  gate["UV master parameter tuple",MatchQ[representation,{_,_,_List}]];
  If[Length[active]===1,
    mass=definition["Masses"][[First[active]]];power=master[[2,First[active]]];
    (* Radial Euclidean representation, with the Minkowski Wick factor explicit. *)
    tuple={I (-1)^power (sphereArea /. nn->4-2 Global`eps)/2,
      yy^((4-2 Global`eps)/2-1)/(yy+mass)^power,{yy},{mass}};
    gammaNormalization=representation[[2]] (representation[[1]] /. Thread[representation[[3]]->1]),
    tuple={representation[[2]],representation[[1]] /. (Last[representation[[3]]]->1),
      Most[representation[[3]]],{Q2}};gammaNormalization=Missing["NotRadialTadpole"]];
  AssociateTo[parameterInputs,master-><|"Tuple"->tuple,"FeynmanRepresentation"->representation,
    "RadialNormalization"->gammaNormalization|>],{master,masters}];
put[parameterInputs,sidisPath[{work,"s14_master_inputs.wl"}]];
sidisGet[sidisPath[{packageRoot,"Kernel","init.m"}]];
SubTropica`$PolymakeCommand=polymake;SubTropica`STCheckDependencies[];
gate["SubTropica dependencies available",Lookup[SubTropica`$STDependencies["polymake"],"status",""]==="ok"];
moduleProbe=RunProcess[{polymake,"use application \"ideal\"; print \"SIDIS_POLYMAKE_MODULE_OK\\n\";"}];
gate["Polymake ideal module loads",moduleProbe["ExitCode"]===0 &&
  StringContainsQ[moduleProbe["StandardOutput"],"SIDIS_POLYMAKE_MODULE_OK"] &&
  !StringContainsQ[moduleProbe["StandardError"],"ERROR"]];
SetOptions[HyperIntica`HyperInt,"EvaluatePeriodsQ"->True];
masterValues=<||>;
Do[
  directory=sidisPath[{work,"s14_master_"<>IntegerString[Hash[master,"SHA256"],16]}];
  If[!DirectoryQ[directory],CreateDirectory[directory]];SetDirectory[directory];
  order=masterOrders[master];
  tuple=parameterInputs[master]["Tuple"];
  tuple=tuple /. Thread[tuple[[3]]->Table[Symbol["Global`xx"<>ToString[i]],{i,Length[tuple[[3]]]}]];
  tuple=tuple /. Global`eps->SubTropica`eps;
  $Assumptions=And@@Join[#>0& /@tuple[[4]],{Element[SubTropica`eps,Reals]}];
  Print["UV_SUBTROPICA ",InputForm[master]];
  raw=bounded[SubTropica`STIntegrate[tuple,"Order"->order,"Integrator"->"HyperIntica",
    "LROrderBackend"->"HyperIntica","KernelsAvailable"->1,"SimplifyOutput"->Identity,
    "Verbose"->False,"ShowTimings"->True,"ScanGauges"->False,
    "SetProblemID"->"uv_master","SaveAllIntegrands"->"s14_integrands.wl",
    "ReuseExistingResults"->False,"ClearCachesPerIntegrand"->True],"UV SubTropica master"];
  letterRules=HyperIntica`GetAlgebraicBackSubRules[];
  put[<|"Master"->master,"Tuple"->tuple,"RawOutput"->raw,"AlgebraicLetterDefinitions"->letterRules,
    "InputHash"->inputHash|>,sidisPath[{directory,"s14_raw.wl"}]];
  gate["UV master genuinely evaluated",MatchQ[raw,_SeriesData]&&Length[raw[[3]]]>0&&raw[[5]]>order&&FreeQ[raw,$Failed|$Aborted|_SubTropica`STIntegrate]];
  normalized=(raw /. letterRules) /. HyperIntica`Hlog[arg_,word_List]:>HyperIntica`HlogAsMpl[arg,word];
  normalized=FixedPoint[(# /. {HyperIntica`mzv[n_Integer]:>Zeta[n],
    HyperIntica`Mpl[{n_Integer},{arg_}]:>PolyLog[n,arg]})&,normalized] /. SubTropica`eps->Global`eps;
  gate["UV master portable symbolic series",FreeQ[normalized,_HyperIntica`Wm|_HyperIntica`Wp|_Real]];
  If[!MissingQ[parameterInputs[master]["RadialNormalization"]],
    gate["radial Wick normalization agrees with the Gaussian parameter representation",
      FullSimplify[Normal[normalized-Series[parameterInputs[master]["RadialNormalization"],
        {Global`eps,0,order}]],M2>0]===0]];
  AssociateTo[masterValues,master->normalized],{master,masters}];
SetDirectory[work];
put[masterValues,sidisPath[{work,"s14_master_values.wl"}]];
measure=mu^(2 Global`eps)/(2 Pi)^(4-2 Global`eps);
uvPole[coefficients_] := Module[{integrated},
  integrated=reduceMap[coefficients] /. D->4-2 Global`eps /. Normal[masterValues];
  Factor[Coefficient[Normal[Series[measure integrated,{Global`eps,0,0}]],Global`eps,-1]]];
uvFromPowers[powers_,label_] := Module[{residues,physicalResidues},
  If[Length[powers]===0,Return[0]];
  residues=Map[uvPole,powers];
  physicalResidues=Map[FullSimplify[Limit[#,M2->0,Direction->"FromAbove"],Q2>0&&mu>0]&,residues];
  KeyValueMap[If[#1<4,gate[label<>" power-divergent auxiliary terms vanish in massless QCD",#2===0]]&,physicalResidues];
  gate[label<>" logarithmic residue is auxiliary-mass independent",FreeQ[Lookup[residues,4,0],M2]];
  Factor[Total[Values[physicalResidues]]]];
selfUV=Association@KeyValueMap[#1->uvFromPowers[#2["UVPowers"],#1]&,selfMaps];
gate["quark residue is real and has the same Dirac-adjoint residue",
  zero[ComplexExpand[selfUV["quark"]-Conjugate[selfUV["quark"]]]]];
fieldUV=<|"quark"->selfUV["quark"],"gluon"->selfUV["gauge"]+Nf selfUV["one_flavor"]|>;
virtualUV=<||>;counterterms=<||>;fieldBookkeeping=<||>;
Do[
  generated=sidisGet[sidisPath[{root,channel,"s01_inputs",If[channel==="Hqg","s04_result.wl","s01_result.wl"]}]];
  spinors=DeleteDuplicates[Cases[generated["Born"],_Spinor,Infinity]];
  gluonMomenta=DeleteDuplicates[Cases[generated["Born"],Polarization[momentum_,___]/;momentum=!=q:>momentum,Infinity]];
  fields=Join[ConstantArray["quark",Length[spinors]],ConstantArray["gluon",Length[gluonMomenta]]];
  gate[channel<>" generated external colored states present",Length[spinors]>0&&Length[gluonMomenta]>0];
  strongPowers=DeleteDuplicates[Exponent[#,SMP["g_s"]]& /@ generated["Born"]];
  gate[channel<>" unique generated Born coupling degree",Length[strongPowers]===1];
  couplingWeight=Coefficient[Normal[Series[(1+ord zg)^(2 First[strongPowers]),{ord,0,1}]],ord]/zg;
  fieldFactor=Times@@(Sqrt[1+ord fieldUV[#]]& /@ fields);
  externalUV=Coefficient[Normal[Series[fieldFactor^2,{ord,0,1}]],ord];
  AssociateTo[fieldBookkeeping,channel-><|"FieldCounts"->Counts[fields],"Spinors"->spinors,
    "GluonMomenta"->gluonMomenta,"BornStrongPower"->First[strongPowers],"CouplingWeight"->couplingWeight,
    "ExternalUVResidue"->externalUV,"BareOnShellResidue"->ruleMap[GLI["OS",{1,1,0,0}]]|>];
  channelUV=Association@Table[mode->Factor[Total[uvFromPowers[#["UVPowers"],channel<>mode]& /@
    Select[Values[uvDiagrams],#["Channel"]===channel&&#["Mode"]===mode&]]],{mode,{"Pg","Ppp"}}];
  AssociateTo[virtualUV,channel->channelUV];
  values=Association@Table[
    completeUV=ComplexExpand[channelUV[mode]+Conjugate[channelUV[mode]]];
    bornFour=bornInputs[channel]["Born"<>mode] /. D->4;
    solution=Solve[completeUV+bornFour(externalUV+couplingWeight zg)==0,zg];
    gate[channel<>mode<>" unique coupling UV counterterm",Length[solution]===1];
    mode->Factor[zg /. First[solution]],{mode,{"Pg","Ppp"}}];
  gate[channel<>" both projectors give the same coupling counterterm",zero[Subtract@@Values[values]]];
  AssociateTo[counterterms,channel->First[Values[values]]],{channel,{"Hqq","Hqg","Hgq"}}];
gate["all three channels give the same coupling UV counterterm",And@@(zero[#-First[Values[counterterms]]]& /@Values[counterterms])];
couplingResidue=First[Values[counterterms]];
gate["coupling counterterm is local and real",FreeQ[couplingResidue,s|t|Q2|M2|mu|Global`eps] &&
  zero[ComplexExpand[couplingResidue-Conjugate[couplingResidue]]]];
result=<|"CouplingResidue"->couplingResidue,"ChannelCouplingResidues"->counterterms,
  "FieldUVResidues"->fieldUV,"SelfUVResidues"->selfUV,"VirtualUVResidues"->virtualUV,
  "FieldBookkeeping"->fieldBookkeeping,"Measure"->measure,
  "Scheme"->"MSbar", "MSPole"->1/Global`eps-EulerGamma+Log[4 Pi],"Regulator"->Global`eps,
  "InputHash"->inputHash,"SourceHash"->sourceHash,"WorkDirectory"->work,
  "KiraReductionFile"->sidisPath[{work,"s14_reduction.wl"}],
  "MasterValuesFile"->sidisPath[{work,"s14_master_values.wl"}],
  "Accepted"->True|>;
put[result,sidisPath[{root,"s14_result.wl"}]];
Print["S14_SUCCESS: fresh Kira/SubTropica UV residues and common coupling counterterm accepted."];
Print["COUPLING_RESIDUE ",InputForm[couplingResidue]];
Quit[0];
