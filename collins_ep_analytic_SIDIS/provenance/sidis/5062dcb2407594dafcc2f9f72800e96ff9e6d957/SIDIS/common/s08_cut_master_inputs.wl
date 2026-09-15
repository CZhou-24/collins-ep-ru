Get[FileNameJoin[{DirectoryName[$InputFileName],"..","common","s22_paths.wl"}]];
(* Positive-energy Euler representations of the actual Kira cut masters. *)
$HistoryLength = 0;
root=sidisRoot;
gate[name_, condition_] := If[TrueQ[condition], Print["PASS: ", name],
  Print["FAIL: ", name]; Quit[1]];
put[value_, path_] := (Put[value, path <> ".tmp"];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
zero[value_] := Factor[Together[value]] === 0;
SetAttributes[bounded, HoldFirst];
bounded[value_, label_] := MemoryConstrained[TimeConstrained[value, 900,
  gate[label <> " time limit", False]], 2*1024^3, gate[label <> " memory limit", False]];
geometry = sidisGet[sidisPath[{root, "s02_result.wl"}]];
reduction = sidisGet[sidisPath[{root, "s04_result.wl"}]];
gate["accepted real reduction", TrueQ[reduction["Accepted"]]];
sourceHash = sidisHash[$InputFileName, "SHA256"];
basis = geometry["BasisMomenta"]; gram = geometry["CommonGram"];
vector[momentum_] := Coefficient[Expand[momentum], #] & /@ basis;
dot[left_, right_] := Factor[vector[left].gram.vector[right]];
cut[value_] := Factor[value /. geometry["CutRules"]];
recoil = geometry["RecoilMomentum"];
dimension = 4 - 2 eps;

(* Geometry only: the Gaussian definition fixes the continued sphere area. *)
gaussian = Integrate[Exp[-xx^2], {xx, -Infinity, Infinity}];
radialGaussian = Integrate[Exp[-rr^2] rr^(nn - 1), {rr, 0, Infinity},
  Assumptions -> nn > 0];
sphereArea[n_] := (gaussian^nn/radialGaussian) /. nn -> n;
cutEquations = {en^2 - rad^2 == 0, (Sqrt[w] - en)^2 - rad^2 == 0};
cutSolutions = Solve[cutEquations, {en, rad}];
positiveSolutions = Select[cutSolutions,
  TrueQ[FullSimplify[en > 0 && Sqrt[w] - en > 0 && rad > 0 /. #, w > 0]] &];
gate["unique positive-energy cut solution", Length[positiveSolutions] === 1];
cutSolution = First[positiveSolutions];
cutPolynomials = Subtract @@@ cutEquations;
cutJacobian = Det[Table[D[polynomial, variable],
  {polynomial, cutPolynomials}, {variable, {en, rad}}]] /. cutSolution;
radialPrefactor = FullSimplify[(rad^(dimension - 2) /. cutSolution)/Abs[cutJacobian],
  w > 0 && Element[eps, Reals]];
gate["both defining cuts vanish", And @@ (TrueQ[Simplify[# /. cutSolution, w > 0]] & /@ cutEquations)];

(* These changes of variables produce densities; only SubTropica evaluates them. *)
cosine = (1 - u)/(1 + u);
cosineJacobian = FullSimplify[Abs[D[cosine, u]], u > 0];
cosineDensity = FullSimplify[(1 - cosine^2)^((dimension - 4)/2) cosineJacobian,
  u > 0 && Element[eps, Reals]];
bubbleTuple = {1, cosineDensity, {u}, {}};
betaParameter = (1 - zz)/(1 + zz);
triangleDensity = FullSimplify[cosineDensity/(1 - betaParameter cosine),
  u > 0 && zz > 0 && Element[eps, Reals]];
triangleTuple = {1, triangleDensity, {u}, {zz}};

(* Eq. (56) and its unevaluated Appell Euler definition, arXiv:1101.3557.
   j refers to the possibly massive direction; k to the null direction. *)
omegaPrefactor = 2^(2 - jj - kk - 2 eps) Pi^(1 - eps)*
  Gamma[1 - kk - eps]/Gamma[2 - kk - 2 eps];
appellParameters = {aa -> jj, bb -> 1 - kk - eps, cc -> 2 - kk - 2 eps};
eulerPrefactor = Gamma[cc]/(Gamma[aa] Gamma[cc - aa]) /. appellParameters;
eulerDensity = (tau^(aa - 1) (1 - tau)^(cc - aa - 1)
  (1 - (1 - zm) tau)^(-bb) (1 - (1 - zp) tau)^(-bb)) /. appellParameters;
eulerMap = tau -> u/(1 + u);
pairDensity = FullSimplify[(eulerDensity /. eulerMap) D[u/(1 + u), u],
  u > 0 && zm > 0 && zp > 0 && Element[{eps, jj, kk}, Reals]];
pairPrefactor = Cancel[omegaPrefactor eulerPrefactor];
normalizationInputs = <|
  "normalization_direct_null" -> <|"SubTropicaInput" -> {1,
    FullSimplify[cosineDensity/(1-cosine),u>0 && Element[eps,Reals]], {u},{}},
    "Order" -> 1, "RegulatedPrefactor" -> ((radialPrefactor sphereArea[dimension-2]) /. w->1)|>,
  "normalization_pair_rest" -> <|"SubTropicaInput" -> {1,
    FullSimplify[pairDensity /. {jj->1,kk->1,zm->1,zp->1},u>0 && Element[eps,Reals]], {u},{}},
    "Order" -> 1, "RegulatedPrefactor" -> ((radialPrefactor pairPrefactor (1/2)^(-jj)) /. {jj->1,kk->1,w->1})|>|>;

(* Bound the needed series using actual rational reduction coefficients. *)
valuation[expression_] := Module[{value = Together[expression /. D -> dimension]},
  If[zero[value], Infinity, Exponent[Numerator[value], eps, Min] -
    Exponent[Denominator[value], eps, Min]]];
masters = reduction["Masters"];
ruleValues = Expand[Last /@ reduction["Rules"]];
orders = Association@Table[master -> (1 - Min[0,
  Min[valuation /@ DeleteCases[Coefficient[#, master] & /@ ruleValues, 0]]]), {master, masters}];
gate["finite nonnegative requested regulator orders", And @@ (IntegerQ[#] && # >= 0 & /@ Values[orders])];

entries = <||>; tuples = <||>;
Do[
  family = reduction["Families"][master[[1]]];
  gate["unit cut master indices", Complement[master[[2]], {0, 1}] === {}];
  active = Select[Complement[Range[Length[master[[2]]]], family["CutPositions"]], master[[2, #]] > 0 &];
  effective = Table[
    momentum = family["PropagatorMomenta"][[i]];
    sign = Coefficient[momentum, r];
    shift = Expand[momentum/sign - r];
    alpha = alpha /. First[Solve[cut[dot[momentum, momentum] - 2 dot[r, shift + alpha recoil]] == 0, alpha]];
    effectiveVector = Expand[shift + alpha recoil]; Clear[alpha];
    gate["effective vector reconstructs " <> ToString[master, InputForm],
      zero[cut[dot[momentum, momentum] - 2 dot[r, effectiveVector]]]];
    scale = dot[effectiveVector, recoil];
    <|"Position" -> i, "Vector" -> effectiveVector, "Scale" -> scale,
      "NormalizedMassSquared" -> Factor[w dot[effectiveVector, effectiveVector]/scale^2],
      "Power" -> master[[2, i]]|>, {i, active}];
  Switch[Length[effective],
    0,
      id = "cut_volume"; tuple = bubbleTuple;
      prefactor = radialPrefactor sphereArea[dimension - 2]; physicalRules = {},
    1,
      id = "cut_single_massive"; tuple = triangleTuple;
      velocity = Sqrt[1 - effective[[1]]["NormalizedMassSquared"]];
      physicalRules = {zz -> (1 - velocity)/(1 + velocity)};
      prefactor = radialPrefactor sphereArea[dimension - 2]/effective[[1]]["Scale"],
    2,
      nullPositions = Select[Range[Length[effective]], zero[effective[[#]]["NormalizedMassSquared"]] &];
      gate["pair has a null direction", Length[nullPositions] > 0];
      nullPosition = Last[nullPositions]; otherPosition = First[Complement[Range[Length[effective]], {nullPosition}]];
      {first, second} = effective[[{otherPosition, nullPosition}]];
      pairInvariant = Factor[w dot[first["Vector"], second["Vector"]]/
        (2 first["Scale"] second["Scale"])];
      betaSquared = Factor[1 - first["NormalizedMassSquared"]];
      rootRules = {zm -> (1 - Sqrt[betaSquared])/(2 pairInvariant),
        zp -> (1 + Sqrt[betaSquared])/(2 pairInvariant)};
      exponentRules = {jj -> first["Power"], kk -> second["Power"]};
      If[Length[nullPositions] === 2,
        id = "cut_pair_massless";
        tuple = {1, FullSimplify[(pairDensity /. exponentRules) /. zm -> 0,
          u > 0 && zp > 0 && Element[eps, Reals]], {u}, {zp}};
        physicalRules = DeleteCases[rootRules, HoldPattern[zm -> _]],
        id = "cut_pair_one_massive";
        tuple = {1, pairDensity /. exponentRules, {u}, {zm, zp}};
        physicalRules = rootRules];
      prefactor = radialPrefactor (pairPrefactor /. exponentRules)/
        (first["Scale"]^first["Power"] second["Scale"]^second["Power"] pairInvariant^first["Power"]),
    _, gate["supported scalar cut-master class", False]];
  If[KeyExistsQ[tuples, id], gate["shared class has the same defining tuple", tuples[id]["SubTropicaInput"] === tuple]];
  previousOrder = If[KeyExistsQ[tuples, id], tuples[id]["Order"], 0];
  AssociateTo[tuples, id -> <|"SubTropicaInput" -> tuple,
    "Order" -> Max[previousOrder, orders[master]], "SourceHash" -> sourceHash|>];
  AssociateTo[entries, master -> <|"Class" -> id, "EffectiveVectors" -> effective,
    "RegulatedPrefactor" -> prefactor, "PhysicalSubstitutions" -> physicalRules,
    "RequiredOrder" -> orders[master], "CutEnergyConditions" -> geometry["CutEnergyConditions"],
    "ParameterConditions" -> And @@ (# >= 0 & /@ (tuple[[4]] /. physicalRules)),
    "AcceptedRepresentation" -> True, "IntegralEvaluationPerformed" -> False|>];
  Print["CUT_INPUT ", InputForm[master], " class ", id, " order ", orders[master]], {master, masters}];
directory = sidisPath[{root, "common", "s08_cut_inputs"}];
If[!DirectoryQ[directory], CreateDirectory[directory, CreateIntermediateDirectories -> True]];
KeyValueMap[put[#2, sidisPath[{directory, #1 <> ".wl"}]] &, tuples];
put[<|"Masters" -> entries, "Classes" -> tuples, "NormalizationInputs" -> normalizationInputs, "PositiveCutSolution" -> cutSolution,
  "CutJacobian" -> cutJacobian, "RadialPrefactor" -> radialPrefactor,
  "SphereAreaDefinition" -> sphereArea[nn], "CosineMap" -> cosine,
  "AppellEulerDefinition" -> {omegaPrefactor, eulerPrefactor, eulerDensity},
  "MasterMeasure" -> "d^D r delta_plus(r^2) delta_plus((P-r)^2); no 2 pi factors",
  "RepresentationReference" -> "https://arxiv.org/abs/1101.3557 Eqs (7),(56), Appendix B",
  "SourceHash" -> sourceHash,
  "ReductionHash" -> sidisHash[sidisPath[{root, "s04_result.wl"}], "SHA256"],
  "AcceptedRepresentations" -> True, "IntegralEvaluationPerformed" -> False|>, sidisPath[{root, "s08_result.wl"}]];
Print["S08_SUCCESS: ", Length[masters], " positive-energy cut masters mapped to ", Length[tuples], " Euler classes."];
Quit[0];
