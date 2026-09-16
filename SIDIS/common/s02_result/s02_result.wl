<|"ExternalMomenta" -> {p, q, k1}, "LoopMomenta" -> {r}, 
 "CommonGram" -> {{0, (Q2 + s)/2, (Q2 + s + t - w)/2, (-a + z1)/2}, 
   {(Q2 + s)/2, -Q2, (-Q2 - t)/2, (a + b + w - z1 - z2)/2}, 
   {(Q2 + s + t - w)/2, (-Q2 - t)/2, 0, (b - z1)/2}, 
   {(-a + z1)/2, (a + b + w - z1 - z2)/2, (b - z1)/2, z1}}, 
 "BasisMomenta" -> {p, q, k1, r}, "DefiningEquations" -> 
  {scalar[1, 1] == 0, scalar[2, 2] == -Q2, scalar[3, 3] == 0, 
   scalar[1, 1] + 2*scalar[1, 2] + scalar[2, 2] == s, 
   scalar[2, 2] - 2*scalar[2, 3] + scalar[3, 3] == t, 
   scalar[1, 1] + 2*scalar[1, 2] - 2*scalar[1, 3] + scalar[2, 2] - 
     2*scalar[2, 3] + scalar[3, 3] == w, scalar[4, 4] == z1, 
   scalar[1, 1] + 2*scalar[1, 2] - 2*scalar[1, 3] - 2*scalar[1, 4] + 
     scalar[2, 2] - 2*scalar[2, 3] - 2*scalar[2, 4] + scalar[3, 3] + 
     2*scalar[3, 4] + scalar[4, 4] == z2, 
   scalar[1, 1] - 2*scalar[1, 4] + scalar[4, 4] == a, 
   scalar[3, 3] + 2*scalar[3, 4] + scalar[4, 4] == b}, 
 "DefiningSolution" -> {scalar[1, 1] -> 0, scalar[1, 2] -> (Q2 + s)/2, 
   scalar[1, 3] -> (Q2 + s + t - w)/2, scalar[1, 4] -> (-a + z1)/2, 
   scalar[2, 2] -> -Q2, scalar[2, 3] -> (-Q2 - t)/2, 
   scalar[2, 4] -> (a + b + w - z1 - z2)/2, scalar[3, 3] -> 0, 
   scalar[3, 4] -> (b - z1)/2, scalar[4, 4] -> z1}, 
 "RecoilMomentum" -> -k1 + p + q, "CutMomenta" -> {r, -k1 + p + q - r}, 
 "CutRules" -> {z1 -> 0, z2 -> 0}, "CutEnergyConditions" -> 
  {energy[r] > 0, energy[-k1 + p + q - r] > 0}, 
 "UncutMomenta" -> {p - r, k1 - q + r, k1 + r, p + q - r, q - r, k1 - p + r}, 
 "UncutPropagators" -> {a, -a + t - w + z1 + z2, b, -b + s - w + z1 + z2, 
   -a - b - Q2 - w + 2*z1 + z2, a + b - Q2 - s - t + w - z1}, 
 "OnCutUncutPropagators" -> {a, -a + t - w, b, -b + s - w, -a - b - Q2 - w, 
   a + b - Q2 - s - t + w}, "UncutDirections" -> 
  {{1, 0}, {-1, 0}, {0, 1}, {0, -1}, {-1, -1}, {1, 1}}, 
 "Families" -> <|"R01" -> <|"UncutIndices" -> {1, 3}, "LoopMomenta" -> {r}, 
     "PropagatorMomenta" -> {r, -k1 + p + q - r, p - r, k1 + r}, 
     "PropagatorMassesSquared" -> {0, 0, 0, 0}, "Propagators" -> 
      {z1, z2, a, b}, "CutPositions" -> {1, 2}, "OnCutUncutPropagators" -> 
      {a, b}, "UncutCoordinateRules" -> {a -> v3, b -> v4}, 
     "BasisDeterminant" -> 1|>, "R02" -> <|"UncutIndices" -> {1, 4}, 
     "LoopMomenta" -> {r}, "PropagatorMomenta" -> {r, -k1 + p + q - r, p - r, 
       p + q - r}, "PropagatorMassesSquared" -> {0, 0, 0, 0}, 
     "Propagators" -> {z1, z2, a, -b + s - w + z1 + z2}, 
     "CutPositions" -> {1, 2}, "OnCutUncutPropagators" -> {a, -b + s - w}, 
     "UncutCoordinateRules" -> {a -> v3, b -> s - v4 - w}, 
     "BasisDeterminant" -> -1|>, "R03" -> <|"UncutIndices" -> {1, 5}, 
     "LoopMomenta" -> {r}, "PropagatorMomenta" -> {r, -k1 + p + q - r, p - r, 
       q - r}, "PropagatorMassesSquared" -> {0, 0, 0, 0}, 
     "Propagators" -> {z1, z2, a, -a - b - Q2 - w + 2*z1 + z2}, 
     "CutPositions" -> {1, 2}, "OnCutUncutPropagators" -> 
      {a, -a - b - Q2 - w}, "UncutCoordinateRules" -> 
      {a -> v3, b -> -Q2 - v3 - v4 - w}, "BasisDeterminant" -> -1|>, 
   "R04" -> <|"UncutIndices" -> {1, 6}, "LoopMomenta" -> {r}, 
     "PropagatorMomenta" -> {r, -k1 + p + q - r, p - r, k1 - p + r}, 
     "PropagatorMassesSquared" -> {0, 0, 0, 0}, "Propagators" -> 
      {z1, z2, a, a + b - Q2 - s - t + w - z1}, "CutPositions" -> {1, 2}, 
     "OnCutUncutPropagators" -> {a, a + b - Q2 - s - t + w}, 
     "UncutCoordinateRules" -> {a -> v3, b -> Q2 + s + t - v3 + v4 - w}, 
     "BasisDeterminant" -> 1|>, "R05" -> <|"UncutIndices" -> {2, 3}, 
     "LoopMomenta" -> {r}, "PropagatorMomenta" -> {r, -k1 + p + q - r, 
       k1 - q + r, k1 + r}, "PropagatorMassesSquared" -> {0, 0, 0, 0}, 
     "Propagators" -> {z1, z2, -a + t - w + z1 + z2, b}, 
     "CutPositions" -> {1, 2}, "OnCutUncutPropagators" -> {-a + t - w, b}, 
     "UncutCoordinateRules" -> {a -> t - v3 - w, b -> v4}, 
     "BasisDeterminant" -> -1|>, "R06" -> <|"UncutIndices" -> {2, 4}, 
     "LoopMomenta" -> {r}, "PropagatorMomenta" -> {r, -k1 + p + q - r, 
       k1 - q + r, p + q - r}, "PropagatorMassesSquared" -> {0, 0, 0, 0}, 
     "Propagators" -> {z1, z2, -a + t - w + z1 + z2, -b + s - w + z1 + z2}, 
     "CutPositions" -> {1, 2}, "OnCutUncutPropagators" -> 
      {-a + t - w, -b + s - w}, "UncutCoordinateRules" -> 
      {a -> t - v3 - w, b -> s - v4 - w}, "BasisDeterminant" -> 1|>, 
   "R07" -> <|"UncutIndices" -> {2, 5}, "LoopMomenta" -> {r}, 
     "PropagatorMomenta" -> {r, -k1 + p + q - r, k1 - q + r, q - r}, 
     "PropagatorMassesSquared" -> {0, 0, 0, 0}, "Propagators" -> 
      {z1, z2, -a + t - w + z1 + z2, -a - b - Q2 - w + 2*z1 + z2}, 
     "CutPositions" -> {1, 2}, "OnCutUncutPropagators" -> 
      {-a + t - w, -a - b - Q2 - w}, "UncutCoordinateRules" -> 
      {a -> t - v3 - w, b -> -Q2 - t + v3 - v4}, "BasisDeterminant" -> 1|>, 
   "R08" -> <|"UncutIndices" -> {2, 6}, "LoopMomenta" -> {r}, 
     "PropagatorMomenta" -> {r, -k1 + p + q - r, k1 - q + r, k1 - p + r}, 
     "PropagatorMassesSquared" -> {0, 0, 0, 0}, "Propagators" -> 
      {z1, z2, -a + t - w + z1 + z2, a + b - Q2 - s - t + w - z1}, 
     "CutPositions" -> {1, 2}, "OnCutUncutPropagators" -> 
      {-a + t - w, a + b - Q2 - s - t + w}, "UncutCoordinateRules" -> 
      {a -> t - v3 - w, b -> Q2 + s + v3 + v4}, "BasisDeterminant" -> -1|>, 
   "R09" -> <|"UncutIndices" -> {3, 5}, "LoopMomenta" -> {r}, 
     "PropagatorMomenta" -> {r, -k1 + p + q - r, k1 + r, q - r}, 
     "PropagatorMassesSquared" -> {0, 0, 0, 0}, "Propagators" -> 
      {z1, z2, b, -a - b - Q2 - w + 2*z1 + z2}, "CutPositions" -> {1, 2}, 
     "OnCutUncutPropagators" -> {b, -a - b - Q2 - w}, 
     "UncutCoordinateRules" -> {a -> -Q2 - v3 - v4 - w, b -> v3}, 
     "BasisDeterminant" -> 1|>, "R10" -> <|"UncutIndices" -> {3, 6}, 
     "LoopMomenta" -> {r}, "PropagatorMomenta" -> {r, -k1 + p + q - r, 
       k1 + r, k1 - p + r}, "PropagatorMassesSquared" -> {0, 0, 0, 0}, 
     "Propagators" -> {z1, z2, b, a + b - Q2 - s - t + w - z1}, 
     "CutPositions" -> {1, 2}, "OnCutUncutPropagators" -> 
      {b, a + b - Q2 - s - t + w}, "UncutCoordinateRules" -> 
      {a -> Q2 + s + t - v3 + v4 - w, b -> v3}, "BasisDeterminant" -> -1|>, 
   "R11" -> <|"UncutIndices" -> {4, 5}, "LoopMomenta" -> {r}, 
     "PropagatorMomenta" -> {r, -k1 + p + q - r, p + q - r, q - r}, 
     "PropagatorMassesSquared" -> {0, 0, 0, 0}, "Propagators" -> 
      {z1, z2, -b + s - w + z1 + z2, -a - b - Q2 - w + 2*z1 + z2}, 
     "CutPositions" -> {1, 2}, "OnCutUncutPropagators" -> 
      {-b + s - w, -a - b - Q2 - w}, "UncutCoordinateRules" -> 
      {a -> -Q2 - s + v3 - v4, b -> s - v3 - w}, "BasisDeterminant" -> -1|>, 
   "R12" -> <|"UncutIndices" -> {4, 6}, "LoopMomenta" -> {r}, 
     "PropagatorMomenta" -> {r, -k1 + p + q - r, p + q - r, k1 - p + r}, 
     "PropagatorMassesSquared" -> {0, 0, 0, 0}, "Propagators" -> 
      {z1, z2, -b + s - w + z1 + z2, a + b - Q2 - s - t + w - z1}, 
     "CutPositions" -> {1, 2}, "OnCutUncutPropagators" -> 
      {-b + s - w, a + b - Q2 - s - t + w}, "UncutCoordinateRules" -> 
      {a -> Q2 + t + v3 + v4, b -> s - v3 - w}, "BasisDeterminant" -> 1|>|>, 
 "Channels" -> <|"Hqq" -> <|"File" -> "Hqq/s02_result.wl", 
     "SHA256" -> 243688983981755320004535715482544804065267440472165801391000\
78788222671789231, "TensorKeys" -> {"RealQGG_Charge0__Pg", 
       "RealQGG_Charge0__Ppp", "RealSame_Charge0__Pg", 
       "RealSame_Charge0__Ppp", "RealDistinct_Charge0__Pg", 
       "RealDistinct_Charge1__Pg", "RealDistinct_Charge2__Pg", 
       "RealDistinct_Charge0__Ppp", "RealDistinct_Charge1__Ppp", 
       "RealDistinct_Charge2__Ppp"}, "CoordinateRules" -> 
      {a12 -> b, Q2 -> Q2, s -> s, s23 -> w, t -> t, u3 -> -a + t - w}|>, 
   "Hqg" -> <|"File" -> "Hqg/s02_result.wl", "SHA256" -> 95353918389308226585\
616836192228826818599937811615510514711723185863758258962, 
     "TensorKeys" -> {"Pg", "Ppp"}, "CoordinateRules" -> 
      {a12 -> b, Q2 -> Q2, s -> s, s23 -> w, t -> t, u3 -> -a + t - w}|>, 
   "Hgq" -> <|"File" -> "Hgq/s02_result.wl", "SHA256" -> 75543057607174814661\
914021665046523419391438343888032215459097606829859340823, 
     "TensorKeys" -> {"Pg", "Ppp"}, "CoordinateRules" -> 
      {a12 -> b, Q2 -> Q2, s -> s, s23 -> w, t -> t, u3 -> -a + t - w}|>, 
   "Hgg" -> <|"File" -> "Hgg/s02_result.wl", "SHA256" -> 16592067342651061670\
374153959365486991961695314011025256305760883660467185684, 
     "TensorKeys" -> {"g", "pp"}, "CoordinateRules" -> 
      {a -> a, b -> b, Q2 -> Q2, s -> s, t -> t, w -> w}|>, 
   "Hqqbar" -> <|"File" -> "Hqqbar/s02_result.wl", "SHA256" -> 55900523747192\
937740959084032605252675055277374789959838970089580890342703973, 
     "TensorKeys" -> {"g", "pp"}, "CoordinateRules" -> 
      {a -> a, b -> b, Q2 -> Q2, s -> s, t -> t, w -> w}|>, 
   "Hqqprime" -> <|"File" -> "Hqqprime/s02_result.wl", 
     "SHA256" -> 974885046222946369896706377778392701449050844021800597854477\
70158819767545507, "TensorKeys" -> {"g", "pp"}, "CoordinateRules" -> 
      {a -> a, b -> b, Q2 -> Q2, s -> s, t -> t, w -> w}|>|>, 
 "Dimension" -> D, "SourceHash" -> 261584077823719627197191033606187661144661\
93319089865663060229356742058991341, "IntegralEvaluationPerformed" -> False, 
 "Accepted" -> True|>
