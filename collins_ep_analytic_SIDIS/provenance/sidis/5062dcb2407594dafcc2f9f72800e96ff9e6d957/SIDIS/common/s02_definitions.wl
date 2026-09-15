Get[FileNameJoin[{DirectoryName[$InputFileName],"..","common","s22_paths.wl"}]];
(* Common SIDIS invariant definitions and the two physical cut propagators. *)
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
root=sidisRoot;
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name],
  Print["FAIL: ", name]; Quit[1]];
zero[expression_] := Factor[Together[expression]] === 0;
put[value_, path_] := (Put[value, path <> ".tmp"];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
SetAttributes[bounded, HoldFirst];
bounded[expression_, label_] := MemoryConstrained[TimeConstrained[expression, 900,
  gate["time limit: " <> label, False]], 2*1024^3,
  gate["memory limit: " <> label, False]];
channels = {"Hqq", "Hqg", "Hgq", "Hgg", "Hqqbar", "Hqqprime"};
sourceHash = sidisHash[$InputFileName, "SHA256"];

(* These are defining on-shell and Mandelstam equations, not stored solutions. *)
basis = {p, q, k1, r};
gram = Table[scalar[Min[i, j], Max[i, j]], {i, Length[basis]}, {j, Length[basis]}];
unknowns = DeleteDuplicates[Flatten[gram]];
vector[v_] := Coefficient[Expand[v], #] & /@ basis;
dot[v_, u_] := Expand[vector[v].gram.vector[u]];
recoil = p + q - k1;
definitions = {dot[p, p] == 0, dot[q, q] == -Q2, dot[k1, k1] == 0,
  dot[p + q, p + q] == s, dot[q - k1, q - k1] == t,
  dot[recoil, recoil] == w, dot[r, r] == z1,
  dot[recoil - r, recoil - r] == z2, dot[p - r, p - r] == a,
  dot[k1 + r, k1 + r] == b};
solutions = Solve[definitions, unknowns];
gate["unique common invariant solution", Length[solutions] === 1];
solution = First[solutions];
gate["all defining equations reconstruct", And @@ (TrueQ[Simplify[# /. solution]] & /@ definitions)];
gram = Map[Factor, gram /. solution, {2}];
cutRules = {z1 -> 0, z2 -> 0};
cutMomenta = {r, recoil - r};
gate["cut propagators have their declared coordinates",
  And @@ MapThread[zero[#1 - #2] &, {dot[#, #] & /@ cutMomenta, {z1, z2}}]];

(* Candidate uncut lines are taken from the tree-propagator routings. S03
   must match every actual nonconstant denominator to this catalog. *)
uncutMomenta = {p - r, p - (recoil - r), k1 + r, k1 + (recoil - r),
  q - r, q - (recoil - r)};
uncutFull = Factor[dot[#, #]] & /@ uncutMomenta;
uncutOnCuts = Factor[# /. cutRules] & /@ uncutFull;
directions = ({Coefficient[#, a], Coefficient[#, b]} & /@ uncutOnCuts);
gate["uncut propagators are affine on both cuts",
  And @@ (PolynomialQ[#, {a, b}] && Exponent[#, a] <= 1 &&
      Exponent[#, b] <= 1 && zero[Coefficient[#, a b]] & /@ uncutOnCuts)];
independentPairs = Select[Subsets[Range[Length[uncutMomenta]], {2}],
  !zero[Det[directions[[#]]]] &];
gate["independent cut families exist", Length[independentPairs] > 0];
families = Association@Table[With[{pair = independentPairs[[i]],
    id = "R" <> IntegerString[i, 10, 2]},
  id -> Module[{momenta, forms, determinant, coordinateMap},
    momenta = Join[cutMomenta, uncutMomenta[[pair]]];
    forms = Factor[dot[#, #]] & /@ momenta;
    determinant = Factor[Det[Table[D[forms[[j]], variable],
      {j, Length[forms]}, {variable, {z1, z2, a, b}}]]];
    gate[id <> " independent full loop basis", determinant =!= 0];
    coordinateMap = Solve[Thread[uncutOnCuts[[pair]] == {v3, v4}], {a, b}];
    gate[id <> " unique uncut coordinate map", Length[coordinateMap] === 1];
    <|"UncutIndices" -> pair, "LoopMomenta" -> {r},
      "PropagatorMomenta" -> momenta, "PropagatorMassesSquared" -> ConstantArray[0, Length[momenta]],
      "Propagators" -> forms, "CutPositions" -> Range[Length[cutMomenta]],
      "OnCutUncutPropagators" -> uncutOnCuts[[pair]],
      "UncutCoordinateRules" -> First[coordinateMap],
      "BasisDeterminant" -> determinant|>]], {i, Length[independentPairs]}];

oldToCommon[rows_List] := Module[{values, oldVariables, temporaryVariables,
    renamed, target, equations, answers, rules},
  values = rows[[All, 3]];
  oldVariables = Sort[DeleteDuplicates[Cases[values,
    symbol_Symbol /; Context[symbol] === "Global`", Infinity]]];
  temporaryVariables = Table[Unique["oldInvariant"], {Length[oldVariables]}];
  renamed = values /. Thread[oldVariables -> temporaryVariables];
  target = Map[Function[row, Factor[dot[
      row[[1]] /. {k2 -> r, k3 -> recoil - r},
      row[[2]] /. {k2 -> r, k3 -> recoil - r}] /. cutRules]], rows];
  equations = Thread[renamed == target];
  answers = Solve[equations, temporaryVariables];
  gate["unique source-to-common invariant map", Length[answers] === 1];
  rules = Thread[oldVariables -> (temporaryVariables /. First[answers])];
  gate["every inherited scalar product reconstructs in common coordinates",
    And @@ MapThread[zero[#1 - #2] &, {values /. rules, target}]];
  rules];

channelResults = <||>;
Do[
  directory = sidisPath[{root, channel}];
  inputDirectory = sidisPath[{directory, "s01_inputs"}];
  manifest = sidisImport[sidisPath[{directory, "s01_result.json"}], "RawJSON"];
  gate[channel <> " accepted byte-preserved import", TrueQ[manifest["accepted"]]];
  Scan[Function[entry, gate[channel <> " input hash " <> FileNameTake[entry["path"]],
    IntegerString[sidisHash[sidisPath[{root, entry["path"]}], "SHA256"], 16, 64] ===
      entry["sha256"]]], manifest["files"]];
  If[MemberQ[{"Hqq", "Hqg", "Hgq"}, channel],
    sourceResult = If[channel === "Hqg", "s05_result.wl", "s03_result.wl"];
    data = sidisGet[sidisPath[{inputDirectory, sourceResult}]];
    rows = data["RealScalarProducts"];
    contractions = data["Contractions"];
    If[channel === "Hqq",
      wards = data["WardChecks"],
      wards = KeySelect[contractions, StringContainsQ[#, "Ward"] &]];
    contractions = KeySelect[contractions, !StringContainsQ[#, "Ward"] &];
    bookkeeping = KeyDrop[data, {"Contractions", "RealScalarProducts", "WardChecks"}],
    sourceResult = "s02_result/real.wl";
    data = sidisGet[sidisPath[{inputDirectory, sourceResult}]];
    kinematics = sidisGet[sidisPath[{inputDirectory, "s02_result", "kinematics.wl"}]];
    momenta = kinematics["momenta"];
    rows = Flatten[Table[{momenta[[i]], momenta[[j]], kinematics["gram"][[i, j]]},
      {i, Length[momenta]}, {j, i, Length[momenta]}], 1];
    wards = <|"PhotonWard" -> data["qq"]|>;
    contractions = KeyTake[data, {"g", "pp"}];
    bookkeeping = <|"BornQG" -> "s01_inputs/s02_result/born_qg.wl",
      "BornGQ" -> "s01_inputs/s02_result/born_gq.wl",
      "GeneratedReal" -> "s01_inputs/s01_result/real.wl",
      "TensorCouplingsKept" -> True, "SpectatorWeightAppliedToTensor" -> False|>
  ];
  gate[channel <> " inherited Ward checks", Length[wards] > 0 && And @@ (zero /@ Values[wards])];
  coordinateRules = bounded[oldToCommon[rows], channel <> " invariant map"];
  tensors = Map[Function[value, value /. coordinateRules], contractions];
  gate[channel <> " exact unintegrated scalar tensors", FreeQ[tensors,
    _Real | _Integrate | _SeriesData | _FeynAmpDenominator | _PaVe | $Failed | $Aborted]];
  put[<|"Channel" -> channel, "CoordinateRules" -> coordinateRules,
    "Contractions" -> tensors, "OriginalContractionKeys" -> Keys[contractions],
    "Bookkeeping" -> bookkeeping, "WardChecks" -> wards,
    "OriginalRealResult" -> "s01_inputs/" <> sourceResult,
    "SourceHash" -> sourceHash,
    "ImportManifestHash" -> sidisHash[sidisPath[{directory, "s01_result.json"}], "SHA256"]|>,
    sidisPath[{directory, "s02_result.wl"}]];
  AssociateTo[channelResults, channel -> <|"File" -> channel <> "/s02_result.wl",
    "SHA256" -> sidisHash[sidisPath[{directory, "s02_result.wl"}], "SHA256"],
    "TensorKeys" -> Keys[tensors], "CoordinateRules" -> coordinateRules|>];
  Print["CHANNEL_READY ", channel, " tensor keys ", Keys[tensors]];
  Clear[data, tensors, contractions, kinematics, bookkeeping]; ClearSystemCache[],
  {channel, channels}];

put[<|"ExternalMomenta" -> Take[basis, 3], "LoopMomenta" -> {r},
  "CommonGram" -> gram, "BasisMomenta" -> basis,
  "DefiningEquations" -> definitions, "DefiningSolution" -> solution,
  "RecoilMomentum" -> recoil, "CutMomenta" -> cutMomenta,
  "CutRules" -> cutRules, "CutEnergyConditions" -> {energy[r] > 0, energy[recoil - r] > 0},
  "UncutMomenta" -> uncutMomenta, "UncutPropagators" -> uncutFull,
  "OnCutUncutPropagators" -> uncutOnCuts, "UncutDirections" -> directions,
  "Families" -> families, "Channels" -> channelResults,
  "Dimension" -> D, "SourceHash" -> sourceHash,
  "IntegralEvaluationPerformed" -> False, "Accepted" -> True|>,
  sidisPath[{root, "s02_result.wl"}]];
Print["S02_SUCCESS: ", Length[families], " candidate cut families; all channel maps checked."];
Quit[0];
