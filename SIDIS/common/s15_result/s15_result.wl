<|"Masters" -> <|CutIntegral["R01", {1, 1, 0, 0}] -> 
    <|"Class" -> "cut_volume", "PrefactorSoftPower" -> -eps, 
     "Prefactor" -> (2^(-2 + 2*eps)*Pi^((2 - 2*eps)/2))/
       (w^eps*Gamma[(2 - 2*eps)/2]), "ParameterLimits" -> <||>, 
     "DivergentParameters" -> {}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> -1, "CoefficientSoftMinimum" -> -1, 
     "OrdinarySeriesOrder" -> 1|>, CutIntegral["R01", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_massless", "PrefactorSoftPower" -> -1 - eps, 
     "Prefactor" -> (Pi^(1 - eps)*w^(-1 - eps)*(-t + w)*Gamma[-eps])/
       (2*(t - w)*(Q2 + s + t - w)*Gamma[-2*eps]), "ParameterLimits" -> 
      <|zp -> Infinity|>, "DivergentParameters" -> {zp}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> 0, "CoefficientSoftMinimum" -> 0, 
     "OrdinarySeriesOrder" -> 0|>, CutIntegral["R02", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_massless", "PrefactorSoftPower" -> -eps, 
     "Prefactor" -> -1/2*(Pi^(1 - eps)*(-t + w)*Gamma[-eps])/
        ((t - w)*w^eps*(s*t + Q2*w)*Gamma[-2*eps]), 
     "ParameterLimits" -> <|zp -> 1|>, "DivergentParameters" -> {}, 
     "TaylorDepth" -> 0, "CoefficientEpsilonMinimum" -> 0, 
     "CoefficientSoftMinimum" -> -1, "OrdinarySeriesOrder" -> 0|>, 
   CutIntegral["R03", {1, 1, 0, 1}] -> <|"Class" -> "cut_single_massive", 
     "PrefactorSoftPower" -> -eps, "Prefactor" -> 
      (2^(-1 + 2*eps)*Pi^((2 - 2*eps)/2))/((-2*Q2 - s - t)*w^eps*
        Gamma[(2 - 2*eps)/2]), "ParameterLimits" -> 
      <|zz -> -1 + (2*(2*Q2 + s + t))/(2*Q2 + s + t + Abs[s + t])|>, 
     "DivergentParameters" -> {}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> 0, "CoefficientSoftMinimum" -> -1, 
     "OrdinarySeriesOrder" -> 0|>, CutIntegral["R03", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_one_massive", "PrefactorSoftPower" -> -eps, 
     "Prefactor" -> (Pi^(1 - eps)*(2*Q2 + s + t)*Gamma[-eps])/
       (2*(-2*Q2 - s - t)*w^eps*(Q2*t - 2*Q2*w - s*w)*Gamma[-2*eps]), 
     "ParameterLimits" -> <|zm -> Piecewise[{{1, s + t >= 0}}, 
         (Q2 + s + t)/Q2], zp -> (2*Q2 + s + t + Abs[s + t])/(2*Q2)|>, 
     "DivergentParameters" -> {}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> 0, "CoefficientSoftMinimum" -> 0, 
     "OrdinarySeriesOrder" -> 0|>, CutIntegral["R04", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_one_massive", "PrefactorSoftPower" -> -eps, 
     "Prefactor" -> (Pi^(1 - eps)*(2*Q2 + s + t)*Gamma[-eps])/
       (2*(-2*Q2 - s - t)*t*(Q2 + s + t - w)*w^eps*Gamma[-2*eps]), 
     "ParameterLimits" -> <|zm -> Piecewise[{{1, s + t < 0}}, 
         Q2/(Q2 + s + t)], zp -> Piecewise[{{1, s + t >= 0}}, 
         Q2/(Q2 + s + t)]|>, "DivergentParameters" -> {}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> 0, "CoefficientSoftMinimum" -> -1, 
     "OrdinarySeriesOrder" -> 0|>, CutIntegral["R09", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_one_massive", "PrefactorSoftPower" -> -eps, 
     "Prefactor" -> (Pi^(1 - eps)*(2*Q2 + s + t)*Gamma[-eps])/
       (2*(-2*Q2 - s - t)*w^eps*(Q2*s - 2*Q2*w - t*w)*Gamma[-2*eps]), 
     "ParameterLimits" -> <|zm -> Piecewise[{{1, s + t >= 0}}, 
         (Q2 + s + t)/Q2], zp -> (2*Q2 + s + t + Abs[s + t])/(2*Q2)|>, 
     "DivergentParameters" -> {}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> 0, "CoefficientSoftMinimum" -> 0, 
     "OrdinarySeriesOrder" -> 0|>, CutIntegral["R10", {1, 1, 1, 1}] -> 
    <|"Class" -> "cut_pair_one_massive", "PrefactorSoftPower" -> -eps, 
     "Prefactor" -> (Pi^(1 - eps)*(2*Q2 + s + t)*Gamma[-eps])/
       (2*s*(-2*Q2 - s - t)*(Q2 + s + t - w)*w^eps*Gamma[-2*eps]), 
     "ParameterLimits" -> <|zm -> Piecewise[{{1, s + t < 0}}, 
         Q2/(Q2 + s + t)], zp -> Piecewise[{{1, s + t >= 0}}, 
         Q2/(Q2 + s + t)]|>, "DivergentParameters" -> {}, "TaylorDepth" -> 0, 
     "CoefficientEpsilonMinimum" -> 0, "CoefficientSoftMinimum" -> -1, 
     "OrdinarySeriesOrder" -> 0|>|>, "OrdinaryMasters" -> 
  <|CutIntegral["R01", {1, 1, 0, 0}] -> SeriesData[eps, 0, 
     {Pi/2, (2*Pi - EulerGamma*Pi - Pi*Log[Pi] - Pi*Log[w])/2}, 0, 2, 1], 
   CutIntegral["R01", {1, 1, 1, 1}] -> SeriesData[eps, 0, 
     {-(Pi/(w*(-Q2 - s - t + w))), (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
        Pi*Log[((s - w)*(-t + w))/((Q2 + s + t - w)*w)])/
       (w*(-Q2 - s - t + w))}, -1, 1, 1], CutIntegral["R02", {1, 1, 1, 1}] -> 
    SeriesData[eps, 0, {-(Pi/(s*t + Q2*w)), 
      (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
        Pi*Log[-(((s - w)*(-t + w))/(s*t + Q2*w))])/(s*t + Q2*w)}, -1, 1, 1], 
   CutIntegral["R03", {1, 1, 0, 1}] -> SeriesData[eps, 0, 
     {(Pi*Log[(1 - Sqrt[1 - (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2])/
          (1 + Sqrt[1 - (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2])])/
       (2*(2*Q2 + s + t)*Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
          (2*Q2 + s + t)^2])}, 0, 1, 1], CutIntegral["R03", {1, 1, 1, 1}] -> 
    SeriesData[eps, 0, {Pi/(2*(Q2*t - 2*Q2*w - s*w)), 
      (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
        Pi*Log[((2*Q2 + s + t)^2*(t - w)^2*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 
                4*Q2*w)/(2*Q2 + s + t)^2])*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 
                4*Q2*w)/(2*Q2 + s + t)^2]))/(4*(Q2*t - 2*Q2*w - s*w)^2)])/
       (2*(Q2*t - 2*Q2*w - s*w))}, -1, 1, 1], 
   CutIntegral["R04", {1, 1, 1, 1}] -> SeriesData[eps, 0, 
     {Pi/(2*t*(Q2 + s + t - w)), (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
        Pi*Log[((2*Q2 + s + t)^2*(t - w)^2*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 
                4*Q2*w)/(2*Q2 + s + t)^2])*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 
                4*Q2*w)/(2*Q2 + s + t)^2]))/(4*t^2*(Q2 + s + t - w)^2)])/
       (2*t*(Q2 + s + t - w))}, -1, 1, 1], 
   CutIntegral["R09", {1, 1, 1, 1}] -> SeriesData[eps, 0, 
     {Pi/(2*(Q2*s - 2*Q2*w - t*w)), (-(EulerGamma*Pi) - Pi*Log[Pi] - 
        Pi*Log[w] + Pi*Log[((2*Q2 + s + t)^2*(s - w)^2*
            (1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2])*
            (1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2]))/
           (4*(Q2*s - 2*Q2*w - t*w)^2)])/(2*(Q2*s - 2*Q2*w - t*w))}, -1, 1, 
     1], CutIntegral["R10", {1, 1, 1, 1}] -> SeriesData[eps, 0, 
     {Pi/(2*s*(Q2 + s + t - w)), (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
        Pi*Log[((2*Q2 + s + t)^2*(s - w)^2*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 
                4*Q2*w)/(2*Q2 + s + t)^2])*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 
                4*Q2*w)/(2*Q2 + s + t)^2]))/(4*s^2*(Q2 + s + t - w)^2)])/
       (2*s*(Q2 + s + t - w))}, -1, 1, 1]|>, 
 "RegionMasterMap" -> <|CutIntegral["R01", {1, 1, 1, 1}] -> 
    <|"ParameterDefinition" -> zp -> SubTropica`\[Lambda]^(-1), 
     "Regions" -> {{-1, -1}, {0, -1}}, "TaylorDepth" -> 0, 
     "Entries" -> {<|"Region" -> {0, -1}, "LambdaPower" -> -SubTropica`eps, 
        "IntegralID" -> "region_2de21a1690a6990f1b36b15c94f2c80c82fab018d3b87\
7cb1317f18cbaae2cf"|>}|>|>, "RegionValues" -> 
  <|
   "region_2de21a1690a6990f1b36b15c94f2c80c82fab018d3b877cb1317f18cbaae2cf" \
-> <|"Series" -> SeriesData[eps, 0, {-1, 0, -1/6*Pi^2}, -1, 2, 1], 
     "Tuple" -> {1, u^SubTropica`eps/(1 + u), {u}, {}}, "Order" -> 1, 
     "InputHash" -> 901193505881348576049694978159866770697612244231112366204\
66841344800923730373, "RawOutputFile" -> "/u/scratch/r/rushil/AI_Assisted_SID\
IS/SIDIS_20260907/common/s15_cut_soft/c73dbeaef9834085bcd47eacb55215f77b5d70d\
59ad410d0dde3243a2c3641c5/region_2de21a1690a6990f1b36b15c94f2c80c82fab018d3b8\
77cb1317f18cbaae2cf/s15_raw.wl", "AlgebraicLetterDefinitions" -> {}, 
     "Accepted" -> True|>|>, "InputHashes" -> 
  <|"s08_result.wl" -> 537005998558187005691005291732605032463386266422894682\
70548961267074622879573, "s10_result.wl" -> 
    9935675245460889407651453754557767720022143570864083265512395883964836188\
2195, "s11_result.wl" -> 
    8108728831168752611831698127268415791715859613867654342478311131209804481\
7653|>, "SourceHash" -> 
  976658659809151608916903546309755133263206944448432326026688597697888242083\
8, "InputHash" -> 
  901193505881348576049694978159866770697612244231112366204668413448009237303\
73, "WorkDirectory" -> "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/\
common/s15_cut_soft/c73dbeaef9834085bcd47eacb55215f77b5d70d59ad410d0dde3243a2\
c3641c5", "PhysicalConditions" -> Q2 > 0 && s > w > 0 && 
   -Q2 - s + w < t < -((Q2*w)/s), "SoftPhysicalConditions" -> 
  Q2 > 0 && s > 0 && t < 0 && Q2 + s + t > 0, "AcceptedCutMasterRegions" -> 
  True, "EndpointDistributionsAssembled" -> False|>
