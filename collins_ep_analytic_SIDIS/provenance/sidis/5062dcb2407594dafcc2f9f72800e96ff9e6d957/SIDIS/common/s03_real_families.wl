Get[FileNameJoin[{DirectoryName[$InputFileName],"..","common","s22_paths.wl"}]];
(* Exact real-interference coefficients of two-cut loop integrals. *)
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
root=sidisRoot;
gate[name_, condition_] := If[!TrueQ[condition], Print["FAIL: ", name];
  If[$KernelID > 0, Throw[$Failed, "S03Failure"], CloseKernels[]; Quit[1]]];
zero[expression_] := Factor[Together[expression]] === 0;
put[value_, path_] := (Put[value, path <> ".tmp"];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
SetAttributes[bounded, HoldFirst];
bounded[expression_, label_] := MemoryConstrained[TimeConstrained[expression, 1800,
  gate["time limit " <> ToString[label, InputForm], False]], 2*1024^3,
  gate["memory limit " <> ToString[label, InputForm], False]];
geometry = sidisGet[sidisPath[{root, "s02_result.wl"}]];
gate["S02 acceptance/source", TrueQ[geometry["Accepted"]] &&
  geometry["SourceHash"] === sidisHash[sidisPath[{root, "s02_definitions.wl"}], "SHA256"]];
denominators = geometry["OnCutUncutPropagators"];
directions = geometry["UncutDirections"];
families = geometry["Families"];
familyNames = Keys[families];
sourceHash = sidisHash[$InputFileName, "SHA256"];
geometryHash = sidisHash[sidisPath[{root, "s02_result.wl"}], "SHA256"];

merge[pieces_List] := If[pieces === {}, <||>,
  Select[Merge[pieces, Factor[Together[Total[#]]] &], # =!= 0 &]];

(* All partial-fraction coefficients are solved from the actual affine
   propagators. No angular integral or phase-space formula is used. *)
decompose[powers_List] := decompose[powers] = Module[
  {support, relations, relation, constant, pieces, lowered},
  support = Flatten[Position[powers, _?(# > 0 &)]];
  If[support === {}, Return[<|powerKey @@ powers -> 1|>]];
  If[Length[support] <= 2 && MatrixRank[directions[[support]]] === Length[support],
    Return[<|powerKey @@ powers -> 1|>]];
  relations = NullSpace[Transpose[directions[[support]]]];
  relation = SelectFirst[relations, !zero[#.denominators[[support]]] &, $Failed];
  gate["nonzero affine relation for dependent propagators", relation =!= $Failed];
  constant = Factor[relation.denominators[[support]]];
  gate["relation constant is independent of loop coordinates", FreeQ[constant, a | b]];
  pieces = MapThread[Function[{position, coefficient},
    If[coefficient === 0, <||>,
      lowered = ReplacePart[powers, position -> powers[[position]] - 1];
      Map[Factor[coefficient #/constant] &, decompose[lowered]]]], {support, relation}];
  merge[pieces]];

extractAtoms[expression_] := Module[{rational, factors, powers, found, ratio, prefactor},
  rational = Together[expression];
  factors = Rest[FactorList[Denominator[rational]]];
  powers = ConstantArray[0, Length[denominators]];
  Do[If[!FreeQ[factor[[1]], a | b],
    found = SelectFirst[Range[Length[denominators]],
      Function[index, ratio = Cancel[factor[[1]]/denominators[[index]]];
        ratio =!= 0 && FreeQ[ratio, a | b]], Missing["UnknownPropagator"]];
    If[MissingQ[found], Print["UNKNOWN_PROPAGATOR ", InputForm[factor[[1]]]]];
    gate["every loop-dependent factor is a generated propagator", !MissingQ[found]];
    powers[[found]] += factor[[2]]], {factor, factors}];
  prefactor = Cancel[rational Times @@ MapThread[Power, {denominators, powers}]];
  gate["atom extraction leaves a polynomial numerator",
    FreeQ[Denominator[Together[prefactor]], a | b]];
  {powers, prefactor}];

familyRows[expression_, family_] := Module[
  {spec, transformed, numerator, denominator, denominatorPowers, denominatorCoefficient,
   polynomial, rows, reconstruction},
  spec = families[family];
  transformed = Together[expression /. spec["UncutCoordinateRules"]];
  numerator = Expand[Numerator[transformed]];
  denominator = Factor[Denominator[transformed]];
  gate["family numerator is polynomial", PolynomialQ[numerator, {v3, v4}]];
  denominatorPowers = Exponent[denominator, #] & /@ {v3, v4};
  denominatorCoefficient = Cancel[denominator/(Times @@ MapThread[Power,
    {{v3, v4}, denominatorPowers}])];
  gate["family denominator is a Laurent monomial", FreeQ[denominatorCoefficient, v3 | v4]];
  polynomial = CoefficientRules[numerator, {v3, v4}];
  rows = Association[Map[Function[entry,
    CutIntegral[family, Join[ConstantArray[1, Length[geometry["CutMomenta"]]],
      denominatorPowers - First[entry]]] -> Factor[Last[entry]/denominatorCoefficient]], polynomial]];
  reconstruction = Total[KeyValueMap[Function[{integral, coefficient},
    coefficient Times @@ MapThread[Power, {{v3, v4}, -Drop[integral[[2]], 2]}]], rows]];
  gate["family Laurent coefficients reconstruct", zero[reconstruction - transformed]];
  rows];

mapExpression[expression_] := Module[{powers, prefactor, decomposition, pieces, rows, reconstruction},
  If[expression === 0, Return[<||>]];
  {powers, prefactor} = extractAtoms[expression];
  decomposition = decompose[powers];
  pieces = KeyValueMap[Function[{key, coefficient},
    Module[{indices = List @@ key, support, family, value},
      support = Flatten[Position[indices, _?(# > 0 &)]];
      family = SelectFirst[familyNames,
        Complement[support, families[#]["UncutIndices"]] === {} &, Missing["NoFamily"]];
      gate["every independent denominator set has a family", !MissingQ[family]];
      value = Cancel[prefactor coefficient/(Times @@ MapThread[Power, {denominators, indices}])];
      familyRows[value, family]]], decomposition];
  rows = merge[pieces];
  reconstruction = Total[KeyValueMap[Function[{integral, coefficient},
    coefficient Times @@ MapThread[Power,
      {families[integral[[1]]]["OnCutUncutPropagators"], -Drop[integral[[2]], 2]}]], rows]];
  gate["complete cut-family map reconstructs the input tensor", zero[reconstruction - expression]];
  gate["both physical cuts remain to unit power in every target",
    And @@ (Take[#[[2]], 2] === ConstantArray[1, Length[geometry["CutMomenta"]]] & /@ Keys[rows])];
  rows];

mapTask[task_] := Catch[Module[{file, saved, value, rows},
  file = task["CacheFile"];
  If[FileExistsQ[file], saved = sidisGet[file];
    If[AssociationQ[saved] && saved["InputHash"] === task["InputHash"] &&
        TrueQ[saved["ReconstructionPassed"]], Return[saved]]];
  Print["MAP ", task["Channel"], " ", task["TensorKey"], " ", task["Label"],
    " kernel ", $KernelID];
  gate["pair file remains unchanged", sidisHash[task["InputFile"], "SHA256"] === task["FileHash"]];
  value = sidisGet[task["InputFile"]][task["Selector"]] /. task["CoordinateRules"];
  rows = bounded[mapExpression[value], {task["Channel"], task["Label"], task["TensorKey"]}];
  saved = <|"TensorKey" -> task["TensorKey"], "Label" -> task["Label"],
    "Coefficients" -> rows, "InputHash" -> task["InputHash"],
    "InputFileHash" -> task["FileHash"], "ReconstructionPassed" -> True|>;
  put[saved, file]; saved], "S03Failure"];

slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1];
CloseKernels[];
configuration = KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots],
  "TimeConstraint" -> 60];
TimeConstrained[LaunchKernels[configuration], 60, Null];
workers = Length[Kernels[]];
If[workers > 0,
  ParallelEvaluate[$HistoryLength = 0; Global`$FeynCalcStartupMessages = False; Get["FeynCalc`"]];
  runtime = ParallelEvaluate[{$MachineName, $Version}];
  gate["workers share the allocated compute node", And @@ (First[#] === $MachineName & /@ runtime)];
  DistributeDefinitions[gate, zero, put, bounded, merge, decompose, extractAtoms,
    familyRows, mapExpression, mapTask, root, geometry, denominators, directions, families, familyNames],
  runtime = {}];
$DistributedContexts = None;
allTargets = {}; channelResults = <||>;

Do[
  channelDirectory = sidisPath[{root, channel}];
  inputDirectory = sidisPath[{channelDirectory, "s01_inputs"}];
  channelFile = sidisPath[{channelDirectory, "s02_result.wl"}];
  gate[channel <> " S02 identity", sidisHash[channelFile, "SHA256"] ===
    geometry["Channels"][channel]["SHA256"]];
  data = sidisGet[channelFile]; keys = Keys[data["Contractions"]];
  coordinates = data["CoordinateRules"];
  importManifest = sidisImport[sidisPath[{channelDirectory, "s01_result.json"}], "RawJSON"];
  importedHashes = Association[(#["path"] -> FromDigits[#["sha256"], 16]) & /@ importManifest["files"]];
  inputHash = Hash[{sourceHash, geometryHash, sidisHash[channelFile, "SHA256"]}, "SHA256"];
  cacheDirectory = sidisPath[{channelDirectory, "s03_cache", IntegerString[inputHash, 16]}];
  If[!DirectoryQ[cacheDirectory], CreateDirectory[cacheDirectory, CreateIntermediateDirectories -> True]];
  tasks = {}; pairSums = AssociationThread[keys, ConstantArray[{}, Length[keys]]];
  If[MemberQ[{"Hqq", "Hqg", "Hgq"}, channel],
    cacheStage = If[channel === "Hqg", "s05_cache", "s03_cache"];
    files = Sort[FileNames[If[channel === "Hqq", {"*_Pg_*.wl", "*_Ppp_*.wl"},
      {"Pg_*.wl", "Ppp_*.wl"}], sidisPath[{inputDirectory, cacheStage}], Infinity]],
    files = Select[Sort[FileNames["real_*.wl", sidisPath[{inputDirectory, "s02_result"}]]],
      StringMatchQ[FileBaseName[#], RegularExpression["real_[0-9]+"]] &]];
  gate[channel <> " unintegrated pair files exist", Length[files] > 0];
  Do[
    relativeFile = StringTrim[StringDrop[file, StringLength[root]], "/"];
    fileHash = sidisHash[file, "SHA256"];
    gate[channel <> " imported pair identity", fileHash === importedHashes[relativeFile]];
    entry = sidisGet[file];
    If[MemberQ[{"Hqq", "Hgq"}, channel] &&
      entry["InputHash"] =!= data["Bookkeeping"]["InputHash"], Continue[]];
    selectors = If[MemberQ[{"Hqq", "Hqg", "Hgq"}, channel], {"Value"}, {"g", "pp"}];
    Do[
      mode = If[selector === "Value",
        If[StringContainsQ["_" <> FileBaseName[file] <> "_", "_Ppp_"], "Ppp", "Pg"], selector];
      key = If[channel === "Hqq", entry["Component"] <> "__" <> mode, mode];
      gate[channel <> " pair tensor key is inherited", MemberQ[keys, key]];
      AppendTo[pairSums[key], entry[selector] /. coordinates];
      label = FileBaseName[file] <> "_" <> selector;
      AppendTo[tasks, <|"Channel" -> channel, "TensorKey" -> key, "Label" -> label,
        "InputFile" -> file, "FileHash" -> fileHash, "Selector" -> selector,
        "CoordinateRules" -> coordinates,
        "InputHash" -> Hash[{inputHash, fileHash, selector, key}, "SHA256"],
        "CacheFile" -> sidisPath[{cacheDirectory, label <> ".wl"}]|>], {selector, selectors}],
    {file, files}];
  Do[gate[channel <> " exact source-pair sum " <> key,
    bounded[zero[Total[pairSums[key]] - data["Contractions"][key]], channel <> " pair sum"]], {key, keys}];
  Clear[pairSums, entry]; ClearSystemCache[];
  Print["PAIR_SUMS_ACCEPTED ", channel, " mapping tasks ", Length[tasks]];
  mapped = If[workers > 0, ParallelMap[mapTask, tasks, Method -> "FinestGrained"], mapTask /@ tasks];
  gate[channel <> " all pair maps accepted", FreeQ[mapped, $Failed | $Aborted]];
  coefficients = AssociationMap[Function[key, bounded[
    merge[Lookup[Select[mapped, #["TensorKey"] === key &], "Coefficients"]], channel <> " coefficient sum"]], keys];
  targets = Sort[DeleteDuplicates[Flatten[Keys /@ Values[coefficients]]]];
  put[<|"Channel" -> channel, "Coefficients" -> coefficients, "Targets" -> targets,
    "CoordinateRules" -> coordinates, "InputHash" -> inputHash,
    "SourceHash" -> sourceHash, "GeometryHash" -> geometryHash,
    "PairCount" -> Length[tasks], "PairSumsAccepted" -> True,
    "ReconstructionPassed" -> True, "IntegralEvaluationPerformed" -> False|>,
    sidisPath[{channelDirectory, "s03_result.wl"}]];
  AssociateTo[channelResults, channel -> <|"File" -> channel <> "/s03_result.wl",
    "SHA256" -> sidisHash[sidisPath[{channelDirectory, "s03_result.wl"}], "SHA256"],
    "TargetCount" -> Length[targets], "PairCount" -> Length[tasks]|>];
  allTargets = Union[allTargets, targets];
  Print["CHANNEL_MAPPED ", channel, " targets ", Length[targets]];
  Clear[data, mapped, tasks, coefficients]; ClearSystemCache[],
  {channel, Keys[geometry["Channels"]]}];
CloseKernels[];
targetText[integral_] := integral[[1]] <> "[" <>
  StringRiffle[ToString /@ integral[[2]], ","] <> "]";
Export[sidisPath[{root, "s03_targets"}], StringRiffle[targetText /@ allTargets, "\n"] <> "\n", "Text"];
put[<|"Channels" -> channelResults, "Targets" -> allTargets,
  "GeometryHash" -> geometryHash, "SourceHash" -> sourceHash,
  "ParallelRuntime" -> runtime, "Accepted" -> True|>, sidisPath[{root, "s03_result.wl"}]];
Print["S03_SUCCESS: ", Length[allTargets], " unique real Kira targets."];
Quit[0];
