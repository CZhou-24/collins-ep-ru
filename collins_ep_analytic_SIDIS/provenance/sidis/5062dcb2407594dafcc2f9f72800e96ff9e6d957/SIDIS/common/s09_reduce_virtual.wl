Get[FileNameJoin[{DirectoryName[$InputFileName],"..","common","s22_paths.wl"}]];
(* Kira reduction of the new, exactly reconstructed virtual scalar integrands. *)
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
root=sidisRoot;
gate[name_, condition_] := If[TrueQ[condition], Print["PASS: ", name],
  Print["FAIL: ", name]; Quit[1]];
put[value_, file_] := (Put[value, file <> ".tmp"];
  RenameFile[file <> ".tmp", file, OverwriteTarget -> True]);
geometry = sidisGet[sidisPath[{root, "s02_result.wl"}]];
mapping = sidisGet[sidisPath[{root, "s05_result.wl"}]];
gate["accepted virtual scalar maps", TrueQ[mapping["Accepted"]] &&
  mapping["SourceHash"] === sidisHash[sidisPath[{root, "s05_virtual_families.wl"}], "SHA256"]];
external = geometry["ExternalMomenta"];
externalGram = Take[geometry["CommonGram"], {1, Length[external]}, {1, Length[external]}] /. w -> 0;
FCClearScalarProducts[];
Do[With[{left = external[[i]], right = external[[j]], value = externalGram[[i,j]]},
  SPD[left,right] = value], {i,Length[external]}, {j,i,Length[external]}];
zero[value_] := Factor[Together[ExpandScalarProduct[value]]] === 0;
coordinates[value_] := Coefficient[Expand[value], #] & /@ external;
familyKeys = <||>; families = <||>; changes = <||>;
Do[
  gate["massless unit standard virtual propagators", MatchQ[topology[[2]],
    {FeynAmpDenominator[StandardPropagatorDenominator[Momentum[_,D],0,0,{1,1}]]..}]];
  momenta = #[[1,1,1]] & /@ topology[[2]];
  signs = Coefficient[#,ell] & /@ momenta;
  gate["unit virtual loop routing", And @@ (MemberQ[{-1,1},#] & /@ signs)];
  shifts = MapThread[Expand[#1/#2-ell] &, {momenta,signs}];
  candidates = Flatten[Table[
    shifted = Expand[orientation (#-anchor)] & /@ shifts;
    permutation = Ordering[coordinates /@ shifted];
    <|"Shifts" -> shifted[[permutation]], "Permutation" -> permutation,
      "Orientation" -> orientation, "Anchor" -> anchor|>,
    {anchor,shifts}, {orientation,{-1,1}}],1];
  canonical = First[SortBy[candidates, Flatten[coordinates /@ #["Shifts"]] &]];
  key = canonical["Shifts"];
  If[!KeyExistsQ[familyKeys,key],
    name = "V" <> IntegerString[Length[familyKeys]+1,10,2];
    AssociateTo[familyKeys,key -> name];
    AssociateTo[families,name -> <|"LoopMomenta" -> {ell},
      "PropagatorMomenta" -> (ell+# & /@ key),
      "PropagatorMassesSquared" -> ConstantArray[0,Length[key]]|>]];
  name = familyKeys[key];
  Do[
    old = momenta[[canonical["Permutation"][[i]]]] /. ell -> canonical["Orientation"] ell-canonical["Anchor"];
    new = families[name]["PropagatorMomenta"][[i]];
    gate["canonical routing reconstructs " <> topology[[1]], zero[FCI[SPD[old,old]-SPD[new,new]]]],
    {i,Length[key]}];
  AssociateTo[changes,topology[[1]] -> Join[canonical,<|"Family" -> name|>]],
  {topology,mapping["Topologies"]}];
canonicalize[GLI[id_String,indices_List]] := GLI[changes[id]["Family"],indices[[changes[id]["Permutation"]]]];
canonicalRules = (# -> canonicalize[#] & /@ mapping["Targets"]);
targets = Union[Last /@ canonicalRules];
names = Sort[Keys[families]];
Print["CANONICAL_VIRTUAL_FAMILIES ",Length[names]," targets ",Length[targets]];
kira = sidisPath[{root, "software", "kira-3.1"}];
fermat = sidisPath[{root, "software", "fermat", "Ferl7", "fer64"}];
gate["dedicated Kira and Fermat binaries exist", FileExistsQ[kira] && FileExistsQ[fermat]];
SetEnvironment["FERMATPATH" -> fermat];
sourceHash = sidisHash[$InputFileName, "SHA256"];
inputHash = Hash[{sourceHash, sidisHash[sidisPath[{root, "s05_result.wl"}], "SHA256"],
  sidisHash[sidisPath[{root, "s02_result.wl"}], "SHA256"], sidisHash[kira, "SHA256"], sidisHash[fermat, "SHA256"]}, "SHA256"];
work = sidisPath[{root, "common", "s09_kira_virtual", IntegerString[inputHash, 16]}];
config = sidisPath[{work, "config"}];
If[!DirectoryQ[config], CreateDirectory[config, CreateIntermediateDirectories -> True]];
text[expression_] := StringReplace[ToString[InputForm[expression]], Whitespace -> ""];
csv[list_] := "[" <> StringRiffle[text /@ list, ","] <> "]";
integralText[integral_] := integral[[1]] <> csv[integral[[2]]];
invariants = Sort[DeleteDuplicates[Cases[externalGram,
  symbol_Symbol /; Context[symbol] === "Global`", Infinity]]];
(* Fermat requires lower-case variable names. This is a name change only. *)
exportRules = {Q2 -> q2};
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
    MapThread["      - [\"" <> text[#1] <> "\", " <> text[#2] <> "]" &,
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
  "Canonicalization" -> changes, "CanonicalizationRules" -> canonicalRules|>, sidisPath[{work, "s09_configuration.wl"}]];
Print["KIRA_START ", work, " target count ", Length[targets], " bounds ", InputForm[bounds]];
run = RunProcess[{kira, "--parallel=2", "jobs.yaml"}, All, ProcessDirectory -> work];
Export[sidisPath[{work, "s09_kira_stdout.log"}], run["StandardOutput"], "Text"];
Export[sidisPath[{work, "s09_kira_stderr.log"}], run["StandardError"], "Text"];
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
  RegularExpression["V[0-9]+\\[[0-9, -]+\\]"]]];
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
  Export[sidisPath[{work,"s09_"<>closureName<>".log"}],closureRun["StandardOutput"]<>closureRun["StandardError"],"Text"];
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
  "MissingFromInventory" -> Complement[masters,declaredMasters]|>,sidisPath[{work,"s09_master_inventory.wl"}]];
gate["every rule ends in Kira's final master inventory",
  Complement[masters, declaredMasters] === {}];
gate["final virtual basis consists of scalar unit-index masters",
  And @@ (Complement[#[[2]],{0,1}] === {} & /@ masters)];
gate["rule coefficients are rational in symbolic dimension and invariants",
  FreeQ[rules, _Real | $Failed | $Aborted]];
resultFile = sidisPath[{root, "s09_result.wl"}];
put[<|"Rules" -> rules, "Masters" -> masters, "Targets" -> targets,
  "Bounds" -> bounds, "Families" -> families, "SourceHash" -> sourceHash,
  "InputHash" -> inputHash, "MappingHash" -> sidisHash[sidisPath[{root, "s05_result.wl"}], "SHA256"],
  "KiraHash" -> sidisHash[kira, "SHA256"], "FermatHash" -> sidisHash[fermat, "SHA256"],
  "RuleFiles" -> ruleFiles, "ClosureRuleFiles" -> closureFiles, "WorkDirectory" -> work, "Accepted" -> True,
  "Canonicalization" -> changes, "CanonicalizationRules" -> canonicalRules,
  "MasterEvaluationPerformed" -> False|>, resultFile];
Do[put[<|"Channel" -> channel,
  "VirtualMappingHash" -> mapping["Channels"][channel]["Hash"],
  "SharedReduction" -> "../s09_result.wl", "SharedReductionHash" -> sidisHash[resultFile,"SHA256"],
  "Accepted" -> True, "MasterEvaluationPerformed" -> False|>,
  sidisPath[{root,channel,"s09_result.wl"}]], {channel,Keys[mapping["Channels"]]}];
Print["S09_SUCCESS: ", Length[targets], " targets reduced to ", Length[masters], " virtual masters."];
Print["MASTERS ",InputForm[masters]];
Quit[0];
