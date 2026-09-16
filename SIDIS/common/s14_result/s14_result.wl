<|"CouplingResidue" -> -1/96*(-2*Nf + 11*SUNN)/Pi^2, 
 "ChannelCouplingResidues" -> <|"Hqq" -> -1/96*(-2*Nf + 11*SUNN)/Pi^2, 
   "Hqg" -> -1/96*(-2*Nf + 11*SUNN)/Pi^2, 
   "Hgq" -> -1/96*(-2*Nf + 11*SUNN)/Pi^2|>, 
 "FieldUVResidues" -> 
  <|"quark" -> -1/32*((-1 + SUNN)*(1 + SUNN))/(Pi^2*SUNN), 
   "gluon" -> -1/24*Nf/Pi^2 + (5*SUNN)/(48*Pi^2)|>, 
 "SelfUVResidues" -> <|"quark" -> -1/32*((-1 + SUNN)*(1 + SUNN))/(Pi^2*SUNN), 
   "gauge" -> (5*SUNN)/(48*Pi^2), "one_flavor" -> -1/24*1/Pi^2|>, 
 "VirtualUVResidues" -> 
  <|"Hqq" -> <|"Pg" -> ((-1 + SUNN)*(1 + SUNN)*(-1 + 3*SUNN^2)*
        (2*Q2^2 + 2*Q2*Global`s + Global`s^2 + 2*Q2*Global`t + Global`t^2))/
       (16*Pi^2*Global`s*SUNN^2*Global`t), 
     "Ppp" -> ((-1 + SUNN)*(1 + SUNN)*(-1 + 3*SUNN^2)*(Q2 + Global`s + 
         Global`t))/(32*Pi^2*SUNN^2)|>, 
   "Hqg" -> <|"Pg" -> -1/16*((-1 + SUNN)*(1 + SUNN)*(-1 + 3*SUNN^2)*
         (Q2^2 + 2*Q2*Global`s + 2*Global`s^2 + 2*Global`s*Global`t + 
          Global`t^2))/(Pi^2*Global`s*SUNN^2*(Q2 + Global`s + Global`t)), 
     "Ppp" -> -1/32*((-1 + SUNN)*(1 + SUNN)*(-1 + 3*SUNN^2)*Global`t)/
        (Pi^2*SUNN^2)|>, "Hgq" -> 
    <|"Pg" -> ((-1 + 3*SUNN^2)*(Q2^2 + Global`s^2 + 2*Q2*Global`t + 
         2*Global`s*Global`t + 2*Global`t^2))/(16*Pi^2*SUNN*Global`t*
        (Q2 + Global`s + Global`t)), "Ppp" -> (Global`s*(-1 + 3*SUNN^2))/
       (16*Pi^2*SUNN)|>|>, "FieldBookkeeping" -> 
  <|"Hqq" -> <|"FieldCounts" -> <|"quark" -> 2, "gluon" -> 1|>, 
     "Spinors" -> {Spinor[Momentum[k1, D], 0, 1], Spinor[Momentum[p, D], 0, 
        1]}, "GluonMomenta" -> {k2}, "BornStrongPower" -> 1, 
     "CouplingWeight" -> 2, "ExternalUVResidue" -> (3 - 2*Nf*SUNN + 2*SUNN^2)/
       (48*Pi^2*SUNN), "BareOnShellResidue" -> 0|>, 
   "Hqg" -> <|"FieldCounts" -> <|"quark" -> 2, "gluon" -> 1|>, 
     "Spinors" -> {Spinor[Momentum[k2, D], 0, 1], Spinor[Momentum[p, D], 0, 
        1]}, "GluonMomenta" -> {k1}, "BornStrongPower" -> 1, 
     "CouplingWeight" -> 2, "ExternalUVResidue" -> (3 - 2*Nf*SUNN + 2*SUNN^2)/
       (48*Pi^2*SUNN), "BareOnShellResidue" -> 0|>, 
   "Hgq" -> <|"FieldCounts" -> <|"quark" -> 2, "gluon" -> 1|>, 
     "Spinors" -> {Spinor[Momentum[k1, D], 0, 1], Spinor[-Momentum[k2, D], 0, 
        1]}, "GluonMomenta" -> {p}, "BornStrongPower" -> 1, 
     "CouplingWeight" -> 2, "ExternalUVResidue" -> (3 - 2*Nf*SUNN + 2*SUNN^2)/
       (48*Pi^2*SUNN), "BareOnShellResidue" -> 0|>|>, 
 "Measure" -> mu^(2*Global`eps)*(2*Pi)^(-4 + 2*Global`eps), 
 "Scheme" -> "MSbar", "MSPole" -> Global`eps^(-1) - EulerGamma + Log[4*Pi], 
 "Regulator" -> Global`eps, "InputHash" -> 1130417025206381812140875489995174\
19919128663472691539714806274492787227778748, "SourceHash" -> 100195265902543\
766866281603105383417972009523408684637318047840923974715340525, 
 "WorkDirectory" -> "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/com\
mon/s14_uv/f9eb5616bcbefd6accab4ec75527419aa38b96d3d6af67aeaa877a4076365ebc", 
 "KiraReductionFile" -> "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907\
/common/s14_uv/f9eb5616bcbefd6accab4ec75527419aa38b96d3d6af67aeaa877a4076365e\
bc/s14_reduction.wl", "MasterValuesFile" -> "/u/scratch/r/rushil/AI_Assisted_\
SIDIS/SIDIS_20260907/common/s14_uv/f9eb5616bcbefd6accab4ec75527419aa38b96d3d6\
af67aeaa877a4076365ebc/s14_master_values.wl", "Accepted" -> True|>
