<|"VirtualMasterParents" -> <|GLI["V01", {0, 1, 0, 1}] -> 
    <|"ParentID" -> "P2_0110", "ActiveIndices" -> {2, 4}, 
     "RoutingSigns" -> {1, 1}, "OriginalShifts" -> {-p - q, 0}, 
     "Permutation" -> {1, 2}, "PhysicalSubstitutions" -> {c12 -> -s}, 
     "OriginalChordMatrix" -> {{0, s}, {s, 0}}, "RequiredOrder" -> 1, 
     "IntegralEvaluationPerformed" -> False|>, GLI["V02", {1, 1, 0, 0}] -> 
    <|"ParentID" -> "P2_0110", "ActiveIndices" -> {1, 2}, 
     "RoutingSigns" -> {1, 1}, "OriginalShifts" -> {k1 - p - 2*q, -p - q}, 
     "Permutation" -> {1, 2}, "PhysicalSubstitutions" -> {c12 -> -t}, 
     "OriginalChordMatrix" -> {{0, t}, {t, 0}}, "RequiredOrder" -> 1, 
     "IntegralEvaluationPerformed" -> False|>, GLI["V03", {0, 1, 1, 0}] -> 
    <|"ParentID" -> "P2_0110", "ActiveIndices" -> {2, 3}, 
     "RoutingSigns" -> {1, 1}, "OriginalShifts" -> {-p - q, -p}, 
     "Permutation" -> {1, 2}, "PhysicalSubstitutions" -> {c12 -> Q2}, 
     "OriginalChordMatrix" -> {{0, -Q2}, {-Q2, 0}}, "RequiredOrder" -> 1, 
     "IntegralEvaluationPerformed" -> False|>, GLI["V03", {1, 1, 0, 0}] -> 
    <|"ParentID" -> "P2_0110", "ActiveIndices" -> {1, 2}, 
     "RoutingSigns" -> {1, 1}, "OriginalShifts" -> {k1 - 2*p - q, -p - q}, 
     "Permutation" -> {1, 2}, "PhysicalSubstitutions" -> {c12 -> Q2 + s + t}, 
     "OriginalChordMatrix" -> {{0, -Q2 - s - t}, {-Q2 - s - t, 0}}, 
     "RequiredOrder" -> 1, "IntegralEvaluationPerformed" -> False|>, 
   GLI["V06", {1, 1, 1, 1}] -> <|"ParentID" -> "P4_0001001001011010", 
     "ActiveIndices" -> {1, 2, 3, 4}, "RoutingSigns" -> {1, 1, 1, 1}, 
     "OriginalShifts" -> {-p - q, k1 - p - q, -p, 0}, 
     "Permutation" -> {2, 4, 1, 3}, "PhysicalSubstitutions" -> 
      {c14 -> -t, c23 -> -s, c34 -> Q2}, "OriginalChordMatrix" -> 
      {{0, 0, -Q2, s}, {0, 0, t, 0}, {-Q2, t, 0, 0}, {s, 0, 0, 0}}, 
     "RequiredOrder" -> 0, "IntegralEvaluationPerformed" -> False|>, 
   GLI["V07", {1, 1, 1, 1}] -> <|"ParentID" -> "P4_0001001001011010", 
     "ActiveIndices" -> {1, 2, 3, 4}, "RoutingSigns" -> {1, 1, 1, 1}, 
     "OriginalShifts" -> {-p - q, k1 - p - q, -q, 0}, 
     "Permutation" -> {1, 2, 3, 4}, "PhysicalSubstitutions" -> 
      {c14 -> -s, c23 -> Q2 + s + t, c34 -> Q2}, "OriginalChordMatrix" -> 
      {{0, 0, 0, s}, {0, 0, -Q2 - s - t, 0}, {0, -Q2 - s - t, 0, -Q2}, 
       {s, 0, -Q2, 0}}, "RequiredOrder" -> 0, 
     "IntegralEvaluationPerformed" -> False|>, GLI["V08", {1, 1, 1, 1}] -> 
    <|"ParentID" -> "P4_0001001001011010", "ActiveIndices" -> {1, 2, 3, 4}, 
     "RoutingSigns" -> {1, 1, 1, 1}, "OriginalShifts" -> 
      {k1 - p - q, -p, k1 - p, 0}, "Permutation" -> {2, 4, 3, 1}, 
     "PhysicalSubstitutions" -> {c14 -> -t, c23 -> Q2 + s + t, c34 -> Q2}, 
     "OriginalChordMatrix" -> {{0, t, -Q2, 0}, {t, 0, 0, 0}, 
       {-Q2, 0, 0, -Q2 - s - t}, {0, 0, -Q2 - s - t, 0}}, 
     "RequiredOrder" -> 0, "IntegralEvaluationPerformed" -> False|>|>, 
 "ParentInputs" -> <|"P2_0110" -> <|"ParentID" -> "P2_0110", 
     "Propagators" -> {SFAD[r], SFAD[pv2 + r]}, "ParentGram" -> {{-c12}}, 
     "ZeroPattern" -> {{0, 1}, {1, 0}}, "Representation" -> 
      {(x[1] + x[2])^(-2 + 2*eps)/(c12*x[1]*x[2])^eps, 
       I*Pi^(2 - eps)*Gamma[eps], {x[1], x[2]}, {x[1] + x[2], c12*x[1]*x[2], 
        {{x[1], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[r, D], 0, 0, {1, 1}]], 1}, 
         {x[2], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[pv2 + r, D], 0, 0, {1, 1}]], 1}}, {{x[1] + x[2]}}, 
        {-(Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv2, D]]*x[2])}, 
        -(c12*x[2]), 1, 0}}, "Gauge" -> x[2] -> 1, "SubTropicaInput" -> 
      {I*Pi^(2 - eps)*Gamma[eps], (1 + x[1])^(-2 + 2*eps)/(c12*x[1])^eps, 
       {x[1]}, {c12}}, "EuclideanConditions" -> c12 > 0, 
     "MeasureConvention" -> 
      "Unnormalized Minkowski d^D r; FCFeynmanParametrize Unity", 
     "ParameterMeasure" -> 
      "Product d x_i after the recorded projective gauge", "Order" -> 1, 
     "SourceHash" -> 38193046509750891643973548721179030189165367704044544304\
77404164398193558133, "IntegralEvaluationPerformed" -> False, 
     "Accepted" -> True|>, "P4_0001001001011010" -> 
    <|"ParentID" -> "P4_0001001001011010", "Propagators" -> 
      {SFAD[r], SFAD[pv2 + r], SFAD[pv3 + r], SFAD[pv4 + r]}, 
     "ParentGram" -> {{0, c23/2, -1/2*c14}, {c23/2, 0, (-c14 + c34)/2}, 
       {-1/2*c14, (-c14 + c34)/2, -c14}}, "ZeroPattern" -> 
      {{0, 0, 0, 1}, {0, 0, 1, 0}, {0, 1, 0, 1}, {1, 0, 1, 0}}, 
     "Representation" -> {(x[1] + x[2] + x[3] + x[4])^(2*eps)*
        (c23*x[2]*x[3] + c14*x[1]*x[4] + c34*x[3]*x[4])^(-2 - eps), 
       I*Pi^(2 - eps)*Gamma[2 + eps], {x[1], x[2], x[3], x[4]}, 
       {x[1] + x[2] + x[3] + x[4], c23*x[2]*x[3] + c14*x[1]*x[4] + 
         c34*x[3]*x[4], {{x[1], FeynAmpDenominator[
           StandardPropagatorDenominator[Momentum[r, D], 0, 0, {1, 1}]], 1}, 
         {x[2], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[pv2 + r, D], 0, 0, {1, 1}]], 1}, 
         {x[3], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[pv3 + r, D], 0, 0, {1, 1}]], 1}, 
         {x[4], FeynAmpDenominator[StandardPropagatorDenominator[
            Momentum[pv4 + r, D], 0, 0, {1, 1}]], 1}}, 
        {{x[1] + x[2] + x[3] + x[4]}}, 
        {-(Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv2, D]]*x[2]) - 
          Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv3, D]]*x[3] - 
          Pair[LorentzIndex[FCGV["mu"], D], Momentum[pv4, D]]*x[4]}, 
        -(c14*x[4]), 1, 0}}, "Gauge" -> x[4] -> 1, "SubTropicaInput" -> 
      {I*Pi^(2 - eps)*Gamma[2 + eps], (1 + x[1] + x[2] + x[3])^(2*eps)*
        (c14*x[1] + c34*x[3] + c23*x[2]*x[3])^(-2 - eps), {x[1], x[2], x[3]}, 
       {c14, c23, c34}}, "EuclideanConditions" -> c14 > 0 && c23 > 0 && 
       c34 > 0, "MeasureConvention" -> 
      "Unnormalized Minkowski d^D r; FCFeynmanParametrize Unity", 
     "ParameterMeasure" -> 
      "Product d x_i after the recorded projective gauge", "Order" -> 0, 
     "SourceHash" -> 38193046509750891643973548721179030189165367704044544304\
77404164398193558133, "IntegralEvaluationPerformed" -> False, 
     "Accepted" -> True|>|>, "SourceHash" -> 38193046509750891643973548721179\
03018916536770404454430477404164398193558133, 
 "ReductionHash" -> 
  549063646323255713609128328993011891321204726074831823095760421892906916481\
5, "Accepted" -> True, "IntegralEvaluationPerformed" -> False, 
 "PhysicalContinuationPerformed" -> False|>
