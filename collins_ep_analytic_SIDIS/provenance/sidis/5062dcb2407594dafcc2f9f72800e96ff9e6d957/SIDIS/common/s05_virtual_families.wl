Get[FileNameJoin[{DirectoryName[$InputFileName],"..","common","s22_paths.wl"}]];
(* Scalarize the unchanged virtual interferences for a new Kira reduction. *)
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
root=sidisRoot;
gate[name_, condition_] := If[!TrueQ[condition], Print["FAIL: ", name];
  If[$KernelID > 0, Throw[$Failed, "S05Failure"], CloseKernels[]; Quit[1]]];
zero[expression_] := Factor[Together[expression]] === 0;
put[value_, file_] := (Put[value, file <> ".tmp"];
  RenameFile[file <> ".tmp", file, OverwriteTarget -> True]);
SetAttributes[bounded, HoldFirst];
bounded[expression_, name_] := MemoryConstrained[TimeConstrained[expression, 1800,
  gate["time limit " <> ToString[name, InputForm], False]], 2*1024^3,
  gate["memory limit " <> ToString[name, InputForm], False]];
setKinematics[rows_] := (FCClearScalarProducts[];
  Scan[Function[row, With[{v = row[[1]], u = row[[2]], value = row[[3]]},
    SPD[v, u] = value; SP[v, u] = value]], rows]);
externalDenominators[expression_] := expression /.
  FeynAmpDenominator[lines__] :> Times @@
    (If[FreeQ[#, ell], FeynAmpDenominatorExplicit[FeynAmpDenominator[#]],
      FeynAmpDenominator[#]] & /@ {lines});
contract[amplitude_, mode_] := Module[{a = amplitude, b = bornAmplitude, value},
  If[mode === "Ppp", a = a /. Polarization[q, ___] -> p;
    b = b /. Polarization[q, ___] -> p];
  value = FermionSpinSum[a ComplexConjugate[b], ExtraFactor -> initialAverage];
  value = SUNSimplify[value, Explicit -> True, SUNNToCACF -> False];
  If[mode === "Pg", value = -DoPolarizationSums[value, q, 0, VirtualBoson -> True]];
  value = DoPolarizationSums[value, gluonMomentum, gluonReference];
  value = Contract[DiracSimplify[value, DiracTraceEvaluate -> True]];
  value = FCReplaceMomenta[value, {k2 -> p + q - k1}];
  ExpandScalarProduct[externalDenominators[value]]/chargeSquared];

(* GLI products here represent multiplication of factors in one integrand.
   They are combined before GLIs are interpreted as integrated quantities. *)
combineGLI[expression_] := FixedPoint[Function[value, Expand[value] /.
  {Power[GLI[id_, indices_List], power_Integer] :> GLI[id, power indices],
   GLI[id_, left_List] GLI[id_, right_List] :> GLI[id, left + right]}], expression];
mapIntegrand[expression_, id_] := Module[
  {lines, topology, numeratorRules, mapped, reconstructed, integrals, coefficients,
   denominator, position, length, scalarProducts, prepared, difference,
   loopProducts, candidates, rank, nextRank, matrix},
  If[expression === 0, Return[<|"Coefficients" -> <||>, "Topology" -> Missing["ZeroDiagram"],
    "Targets" -> {}, "ReconstructionPassed" -> True|>]];
  prepared = ToSFAD[expression];
  gate[id <> " standard-propagator conversion preserves the integrand", zero[
    ExpandScalarProduct[FeynAmpDenominatorExplicit[prepared - expression]]]];
  lines = DeleteDuplicates[Flatten[Cases[prepared,
    FeynAmpDenominator[propagators__] :> (FeynAmpDenominator /@ {propagators}), Infinity]]];
  gate[id <> " loop propagators present", Length[lines] > 0];
  loopProducts = FCI[SPD[ell, #]] & /@ {ell, p, q, k1};
  candidates = ToSFAD[ChangeDimension[FCI[#], D]] & /@
    {FAD[ell], FAD[ell + p], FAD[ell + q], FAD[ell + k1]};
  matrix[propagators_] := Table[Coefficient[
    ExpandScalarProduct[1/FeynAmpDenominatorExplicit[propagator]], product],
    {propagator, propagators}, {product, loopProducts}];
  rank = MatrixRank[matrix[lines]];
  gate[id <> " independent original propagators", rank === Length[lines]];
  Scan[Function[candidate,
    nextRank = MatrixRank[matrix[Append[lines, candidate]]];
    If[nextRank > rank, AppendTo[lines, candidate]; rank = nextRank]], candidates];
  gate[id <> " complete denominator and numerator basis", rank === Length[loopProducts]];
  topology = FCTopology[id, lines, {ell}, {p, q, k1}, {}, {}];
  gate[id <> " valid complete topology", FCLoopValidTopologyQ[topology] &&
    !FCLoopBasisIncompleteQ[topology] && !FCLoopBasisOverdeterminedQ[topology]];
  numeratorRules = FCLoopCreateRulesToGLI[topology];
  length = Length[topology[[2]]];
  mapped = prepared /. FeynAmpDenominator[propagators__] :>
    Times @@ Map[Function[propagator,
      denominator = FeynAmpDenominator[propagator];
      position = FirstPosition[topology[[2]], denominator, Missing["UnmappedPropagator"]];
      gate[id <> " denominator position", !MissingQ[position]];
      GLI[id, UnitVector[length, First[position]]]], {propagators}];
  mapped = combineGLI[mapped /. numeratorRules];
  If[!FreeQ[mapped, ell | _Pair],
    put[<|"InputHash" -> inputHash, "PreparedIntegrand" -> prepared,
      "Topology" -> topology, "NumeratorRules" -> numeratorRules,
      "MappedExpression" -> mapped, "RemainingPairs" -> DeleteDuplicates[Cases[mapped, _Pair, Infinity]],
      "Accepted" -> False|>, sidisPath[{cache, id <> "_incomplete.wl"}]]];
  gate[id <> " scalarization removes every loop scalar product", FreeQ[mapped,
    ell | _FeynAmpDenominator | _Pair | _Spinor | _DiracTrace | _DiracGamma | _SUNTF |
    _SUNTrace | _Polarization | $Failed | $Aborted]];
  integrals = Sort[DeleteDuplicates[Cases[mapped, _GLI, Infinity]]];
  coefficients = AssociationMap[Factor[Coefficient[mapped, #]] &, integrals];
  gate[id <> " expression is linear in scalar integrals", zero[mapped -
    Total[KeyValueMap[Times, coefficients]]]];
  (* Reconstruct the algebraic integrand before integration. FCLoopFromGLI
     drops an all-zero-index integral as scaleless; that is deferred to Kira. *)
  reconstructed = mapped /. GLI[name_, indices_List] :>
    Times @@ MapThread[Power, {FeynAmpDenominatorExplicit /@ topology[[2]], indices}];
  difference = Factor[Together[ExpandScalarProduct[
    reconstructed - FeynAmpDenominatorExplicit[expression]]]];
  If[difference =!= 0, put[<|"InputHash" -> inputHash,
    "OriginalExpression" -> expression, "PreparedExpression" -> prepared,
    "Topology" -> topology, "NumeratorRules" -> numeratorRules,
    "MappedExpression" -> mapped, "ReconstructedExpression" -> reconstructed,
    "Difference" -> difference, "Accepted" -> False|>,
    sidisPath[{cache, id <> "_reconstruction_failure.wl"}]]];
  gate[id <> " exact original-integrand reconstruction", difference === 0];
  scalarProducts = DeleteDuplicates[Cases[1/(FeynAmpDenominatorExplicit[#]) & /@ topology[[2]],
    _Pair, Infinity]];
  <|"Coefficients" -> coefficients, "Topology" -> topology, "Targets" -> integrals,
    "NumeratorRules" -> numeratorRules, "ScalarProducts" -> scalarProducts,
    "ReconstructionPassed" -> True|>];

task[mode_, index_] := Catch[Module[{file, saved, value, result, id},
  id = prefix <> mode <> IntegerString[index, 10, 2];
  file = sidisPath[{cache, id <> ".wl"}];
  If[FileExistsQ[file], saved = sidisGet[file];
    If[AssociationQ[saved] && saved["InputHash"] === inputHash &&
      TrueQ[saved["ReconstructionPassed"]], Return[saved]]];
  Print["VIRTUAL ", channel, " ", mode, " diagram ", index, " kernel ", $KernelID];
  value = bounded[contract[virtualAmplitudes[[index]], mode], id <> " contraction"];
  gate[id <> " closed spin/color trace", FreeQ[value,
    _Spinor | _DiracTrace | _DiracGamma | _SUNTF | _SUNTrace | _Polarization]];
  result = bounded[mapIntegrand[value, id], id <> " scalarization"];
  result = Join[result, <|"InputHash" -> inputHash, "Mode" -> mode,
    "Diagram" -> index, "ContractedIntegrand" -> value|>];
  put[result, file]; ClearSystemCache[]; result], "S05Failure"];

sourceHash = sidisHash[$InputFileName, "SHA256"];
geometry = sidisGet[sidisPath[{root, "s02_result.wl"}]];
gate["accepted common definitions", TrueQ[geometry["Accepted"]]];
slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1];
CloseKernels[];
If[slots > 1, LaunchKernels[KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[4, slots],
  "TimeConstraint" -> 60]]];
workers = Length[Kernels[]];
If[workers > 0, ParallelEvaluate[$HistoryLength = 0; Global`$FeynCalcStartupMessages = False;
  Get["FeynCalc`"]];
  runtime = ParallelEvaluate[{$MachineName, $Version}];
  gate["workers share the compute node", And @@ (First[#] === $MachineName & /@ runtime)], runtime = {}];
Print["VIRTUAL_WORKERS ", workers];
$DistributedContexts = None;
channelResults = <||>; allTopologies = {}; allTargets = {};
Do[
  inputDirectory = sidisPath[{root, channel, "s01_inputs"}];
  born = sidisGet[sidisPath[{inputDirectory, "s02_result.wl"}]];
  generatedFile = sidisPath[{inputDirectory, If[channel === "Hqg", "s04_result.wl", "s01_result.wl"]}];
  generated = sidisGet[generatedFile];
  If[channel === "Hqg",
    real = sidisGet[sidisPath[{inputDirectory, "s05_result.wl"}]];
    chargeSquared = real["ModelChargeSquared"];
    bornScalarProducts = real["BornScalarProducts"];
    quarkStateInput = sidisGet[sidisPath[{root, "Hqq", "s01_inputs", "s02_result.wl"}]];
    initialAverage = 1/(quarkStateInput["QuarkSpinCount"] quarkStateInput["FundamentalDimension"]),
    chargeSquared = born["ModelChargeSquared"];
    bornScalarProducts = born["BornScalarProducts"];
    initialAverage = born["InitialAverages"][channel]];
  {gluonMomentum, gluonReference} = Switch[channel, "Hqq", {k2, p}, "Hqg", {k1, p}, "Hgq", {p, k1}];
  setKinematics[bornScalarProducts];
  bornAmplitude = Total[generated["Born"]] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
  virtualAmplitudes = generated["Virtual"] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
  genericQuarkMasses = DeleteDuplicates[Cases[virtualAmplitudes,
    value_ /; MatchQ[Head[value], _Symbol] &&
      MemberQ[{"MQU", "MQD"}, SymbolName[Head[value]]] :> value, Infinity]];
  masslessRules = Thread[genericQuarkMasses -> 0];
  virtualAmplitudes = virtualAmplitudes /. masslessRules;
  Do[gate[channel <> " inherited Born normalization " <> mode,
    bounded[zero[contract[bornAmplitude, mode] - born["Born" <> mode]], channel <> " Born"]],
    {mode, {"Pg", "Ppp"}}];
  Print["BORN_NORMALIZATION_ACCEPTED ", channel, " virtual diagrams ", Length[virtualAmplitudes]];
  inputHash = Hash[{sourceHash, sidisHash[generatedFile, "SHA256"],
    sidisHash[sidisPath[{inputDirectory, "s02_result.wl"}], "SHA256"],
    bornScalarProducts, initialAverage, chargeSquared, masslessRules, $Version, $FeynCalcVersion}, "SHA256"];
  cache = sidisPath[{root, channel, "s05_cache", IntegerString[inputHash, 16]}];
  If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];
  prefix = "V" <> channel;
  If[workers > 0, DistributeDefinitions[gate, zero, put, bounded, setKinematics,
    externalDenominators, contract, combineGLI, mapIntegrand, task, channel, prefix,
    bornAmplitude, virtualAmplitudes, initialAverage, chargeSquared, gluonMomentum,
    gluonReference, bornScalarProducts, inputHash, cache];
    ParallelEvaluate[setKinematics[bornScalarProducts]]];
  tasks = Flatten[Table[{mode, index}, {mode, {"Pg", "Ppp"}}, {index, Length[virtualAmplitudes]}], 1];
  results = If[workers > 0, ParallelMap[task @@ # &, tasks, Method -> "FinestGrained"], task @@ # & /@ tasks];
  gate[channel <> " all virtual integrands mapped", FreeQ[results, $Failed | $Aborted]];
  topologies = DeleteCases[Lookup[results, "Topology"], _Missing];
  targets = Sort[DeleteDuplicates[Flatten[Lookup[results, "Targets"]]]];
  put[<|"Channel" -> channel, "DiagramMaps" -> results, "Topologies" -> topologies,
    "Targets" -> targets, "BornScalarProducts" -> bornScalarProducts,
    "InitialAverage" -> initialAverage, "ModelChargeSquared" -> chargeSquared,
    "MasslessQuarkSpecialization" -> masslessRules,
    "InterferenceConvention" -> "Before adding the Hermitian conjugate",
    "Measure" -> mu^(2 Epsilon)/(2 Pi)^(4 - 2 Epsilon),
    "CouplingsRemoved" -> "eq^2 gs^4", "SourceHash" -> sourceHash,
    "InputHash" -> inputHash, "BornNormalizationAccepted" -> True,
    "Accepted" -> True, "IntegralEvaluationPerformed" -> False|>,
    sidisPath[{root, channel, "s05_result.wl"}]];
  AssociateTo[channelResults, channel -> <|"File" -> channel <> "/s05_result.wl",
    "Hash" -> sidisHash[sidisPath[{root, channel, "s05_result.wl"}], "SHA256"],
    "DiagramCount" -> Length[virtualAmplitudes], "TargetCount" -> Length[targets]|>];
  allTopologies = Join[allTopologies, topologies]; allTargets = Union[allTargets, targets];
  Print["VIRTUAL_CHANNEL_MAPPED ", channel, " targets ", Length[targets]];
  Clear[results, generated, born, virtualAmplitudes]; ClearSystemCache[], {channel, {"Hqq", "Hqg", "Hgq"}}];
CloseKernels[];
put[<|"Channels" -> channelResults, "Topologies" -> allTopologies,
  "Targets" -> allTargets, "SourceHash" -> sourceHash, "ParallelRuntime" -> runtime,
  "Accepted" -> True, "IntegralEvaluationPerformed" -> False|>, sidisPath[{root, "s05_result.wl"}]];
Print["S05_SUCCESS: ", Length[allTargets], " virtual scalar-integral targets."];
Quit[0];
