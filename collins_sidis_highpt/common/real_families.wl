(* Algebraic partial-fraction/Laurent mapper adapted from SIDIS/common/s03_real_families.wl.
   Original SHA256: af23fd0f16f04dde4897cf92b77a9f6826bfee3442a29f26b9450663c78c0675.
   This helper loads no unpolarized contractions and performs no integration. *)
HSCutFamilySetup[input_Association]:=(geometry=input;denominators=geometry["OnCutUncutPropagators"];directions=geometry["UncutDirections"];families=geometry["Families"];familyNames=Keys[families]);
gate[name_,condition_]:=If[!TrueQ[condition],Print["CUT_MAP_FAILED ",name];Exit[2]];
zero[x_]:=Factor[Together[x]]===0;
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

