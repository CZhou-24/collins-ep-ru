Get[FileNameJoin[{DirectoryName[$InputFileName],"..","common","s22_paths.wl"}]];
(* Full SubTropica evaluation of the freshly derived Euclidean parents. *)
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
root=sidisRoot;
gate[name_, condition_] := If[!TrueQ[condition], Print["FAIL: ", name];
  If[$KernelID > 0, Throw[$Failed, "S13Failure"], CloseKernels[]; Quit[1]]];
put[value_, path_] := (Put[value, path <> ".tmp"];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
inputs = sidisGet[sidisPath[{root, "s12_result.wl"}]];
gate["accepted corrected parent inputs", TrueQ[inputs["Accepted"]] &&
  inputs["SourceHash"] === sidisHash[sidisPath[{root, "s12_virtual_master_inputs.wl"}], "SHA256"]];
software = sidisImport[sidisPath[{root, "software", "s01_result.json"}], "RawJSON"];
gate["accepted dedicated integration tools", TrueQ[software["accepted"]]];
sourceHash = sidisHash[$InputFileName, "SHA256"];
inputFileHash = sidisHash[sidisPath[{root, "s12_result.wl"}], "SHA256"];

packageRoot = sidisPath[{root, "software", "SubTropica-1.2.10"}];
packageHash = sidisHash[sidisPath[{root, "software", "SubTropica-1.2.10.tar.gz"}], "SHA256"];
polymake = sidisPath[{root, "software", "s01_polymake"}];
workRoot = sidisPath[{root, "common", "s13_subtropica_virtual"}];
If[!DirectoryQ[workRoot], CreateDirectory[workRoot, CreateIntermediateDirectories -> True]];
evaluateParent[id_, data_] := Catch[Module[
  {inputHash, work, resultFile, saved, tuple, rename, raw, normalized, result, originalDirectory, moduleProbe, algebraicRules, order = data["Order"]},
  inputHash = Hash[{sourceHash, data["SubTropicaInput"], order, packageHash,
    sidisHash[polymake, "SHA256"], $Version}, "SHA256"];
  work = sidisPath[{workRoot, id, IntegerString[inputHash, 16]}];
  If[!DirectoryQ[work], CreateDirectory[work, CreateIntermediateDirectories -> True]];
  resultFile = sidisPath[{work, "s13_result.wl"}];
  If[FileExistsQ[resultFile], saved = sidisGet[resultFile];
    If[AssociationQ[saved] && saved["InputHash"] === inputHash &&
      TrueQ[saved["AcceptedEuclideanParent"]], Return[saved]]];
  originalDirectory = Directory[]; SetDirectory[work];
  If[!MemberQ[$Packages, "SubTropica`"],
    sidisGet[sidisPath[{packageRoot, "Kernel", "init.m"}]]];
  SubTropica`$PolymakeCommand = polymake;
  SubTropica`STCheckDependencies[];
  gate[id <> " polymake available in this compute worker",
    Lookup[SubTropica`$STDependencies["polymake"], "status", ""] === "ok"];
  moduleProbe=RunProcess[{polymake,"use application \"ideal\"; print \"SIDIS_POLYMAKE_MODULE_OK\\n\";"}];
  gate[id<>" Polymake ideal module loads",moduleProbe["ExitCode"]===0 &&
    StringContainsQ[moduleProbe["StandardOutput"],"SIDIS_POLYMAKE_MODULE_OK"] &&
    !StringContainsQ[moduleProbe["StandardError"],"ERROR"]];
  SetOptions[HyperIntica`HyperInt, "EvaluatePeriodsQ" -> True];
  tuple = data["SubTropicaInput"];
  rename = Thread[tuple[[3]] -> Table[Symbol["Global`xx" <> ToString[i]], {i, Length[tuple[[3]]]}]];
  tuple = tuple /. rename /. Global`eps -> SubTropica`eps;
  $Assumptions = And @@ Join[# > 0 & /@ tuple[[4]], {Element[SubTropica`eps, Reals]}];
  put[<|"InputHash" -> inputHash, "Input" -> tuple, "Order" -> order,
    "ParameterRename" -> rename, "PackageHash" -> packageHash,
    "SourceHash" -> sourceHash, "MeasureConvention" -> data["MeasureConvention"]|>,
    sidisPath[{work, "s13_input.wl"}]];
  Print["SUBTROPICA_START ", id, " order ", order, " kernel ", $KernelID];
  raw = MemoryConstrained[TimeConstrained[SubTropica`STIntegrate[tuple,
    "Order" -> order, "Integrator" -> "HyperIntica", "LROrderBackend" -> "HyperIntica",
    "KernelsAvailable" -> 1, "SimplifyOutput" -> Identity,
    "Verbose" -> False, "ShowTimings" -> True, "ScanGauges" -> False,
    "SetProblemID" -> id, "SaveAllIntegrands" -> "s13_all_integrands.wl",
    "ReuseExistingResults" -> False, "ClearCachesPerIntegrand" -> True],
    3600, gate[id <> " integration time limit", False]], 3*1024^3,
    gate[id <> " integration memory limit", False]];
  algebraicRules = HyperIntica`GetAlgebraicBackSubRules[];
  put[<|"InputHash" -> inputHash, "Input" -> tuple, "RawOutput" -> raw,
    "AlgebraicLetterDefinitions" -> algebraicRules,
    "PackageVersion" -> SubTropica`$SubTropicaVersion|>, sidisPath[{work, "s13_raw.wl"}]];
  gate[id <> " genuine complete SubTropica series", MatchQ[raw, _SeriesData] && Length[raw[[3]]] > 0 &&
    FreeQ[raw, $Failed | $Aborted | _SubTropica`STIntegrate] && raw[[5]] > order];
  normalized = (raw /. algebraicRules) /. HyperIntica`Hlog[arg_, word_List] :> HyperIntica`HlogAsMpl[arg, word];
  normalized = FixedPoint[(# /. {HyperIntica`mzv[n_Integer] :> Zeta[n],
    HyperIntica`Mpl[{n_Integer}, {arg_}] :> PolyLog[n, arg]}) &, normalized];
  gate[id <> " algebraic letters have explicit saved definitions",
    FreeQ[normalized, _HyperIntica`Wm | _HyperIntica`Wp]];
  result = <|"ParentID" -> id, "InputHash" -> inputHash, "Order" -> order,
    "RawOutputFile" -> sidisPath[{work, "s13_raw.wl"}],
    "RawOutputHash" -> sidisHash[sidisPath[{work, "s13_raw.wl"}], "SHA256"],
    "Series" -> normalized, "AlgebraicLetterDefinitions" -> algebraicRules, "EuclideanConditions" -> data["EuclideanConditions"],
    "MeasureConvention" -> data["MeasureConvention"], "WorkDirectory" -> work,
    "SubTropicaVersion" -> SubTropica`$SubTropicaVersion,
    "AcceptedEuclideanParent" -> True, "PhysicalContinuationPerformed" -> False|>;
  put[result, resultFile]; SetDirectory[originalDirectory]; ClearSystemCache[];
  Print["SUBTROPICA_PARENT_ACCEPTED ", id]; result], "S13Failure"];
slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1];
CloseKernels[];
If[slots > 1, LaunchKernels[KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[4, slots],
  "TimeConstraint" -> 60]]];
workers = Length[Kernels[]];
If[workers > 0, ParallelEvaluate[$HistoryLength = 0];
  DistributeDefinitions[gate, put, evaluateParent, sourceHash, packageRoot,
    packageHash, polymake, workRoot];
  runtime = ParallelEvaluate[{$MachineName, $Version}];
  gate["SubTropica workers share the allocated node", And @@ (First[#] === $MachineName & /@ runtime)], runtime = {}];
$DistributedContexts = None;
tasks = KeyValueMap[List, inputs["ParentInputs"]];
results = If[workers > 0, ParallelMap[evaluateParent @@ # &, tasks, Method -> "FinestGrained"],
  evaluateParent @@ # & /@ tasks];
CloseKernels[];
gate["every parent evaluated", FreeQ[results, $Failed | $Aborted] &&
  And @@ Lookup[results, "AcceptedEuclideanParent"]];
put[<|"Parents" -> AssociationThread[Keys[inputs["ParentInputs"]], results],
  "SourceHash" -> sourceHash, "InputFileHash" -> inputFileHash,
  "PackageHash" -> packageHash, "ParallelRuntime" -> runtime,
  "AcceptedEuclideanParents" -> True, "PhysicalContinuationPerformed" -> False|>,
  sidisPath[{root, "s13_result.wl"}]];
Print["S13_SUCCESS: ", Length[results], " virtual master parent integrals evaluated by SubTropica."];
Quit[0];
