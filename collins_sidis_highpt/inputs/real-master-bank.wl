<|"values" -> <|"R01_1_1_0_0_ordinary_p0" -> Pi/2, 
   "R01_1_1_0_0_ordinary_p1" -> (2*Pi - EulerGamma*Pi - Pi*Log[Pi] - 
      Pi*Log[w])/2, "R01_1_1_0_0_soft_plus_1_p0" -> Pi/2, 
   "R01_1_1_0_0_soft_plus_1_p1" -> -1/2*(Pi*(-2 + EulerGamma + Log[Pi])), 
   "R01_1_1_0_0_soft_plus_1_p2" -> 
    -1/8*(Pi*(Pi^2 + 8*(-2 + Log[Pi]) - 
       2*(EulerGamma^2 + 2*EulerGamma*(-2 + Log[Pi]) + Log[Pi]^2))), 
   "R01_1_1_0_0_soft_minus_1_p0" -> Pi/2, "R01_1_1_0_0_soft_minus_1_p1" -> 
    -1/2*(Pi*(-2 + EulerGamma + Log[Pi])), "R01_1_1_0_0_soft_minus_1_p2" -> 
    -1/8*(Pi*(Pi^2 + 8*(-2 + Log[Pi]) - 
       2*(EulerGamma^2 + 2*EulerGamma*(-2 + Log[Pi]) + Log[Pi]^2))), 
   "R01_1_1_1_1_ordinary_m1" -> -(Pi/(w*(-Q2 - s - t + w))), 
   "R01_1_1_1_1_ordinary_p0" -> (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
      Pi*Log[((s - w)*(-t + w))/((Q2 + s + t - w)*w)])/(w*(-Q2 - s - t + w)), 
   "R01_1_1_1_1_soft_plus_1_m1" -> Pi/(omega + Q2), 
   "R01_1_1_1_1_soft_plus_1_p0" -> 
    -((Pi*(EulerGamma + Log[Pi] + Log[-((omega + Q2)/(omega*s - s^2))]))/
      (omega + Q2)), "R01_1_1_1_1_soft_plus_1_p1" -> 
    (Pi*(-Pi^2 + 6*(EulerGamma + Log[Pi])^2 + 
       6*Log[-((omega + Q2)/(omega*s - s^2))]*(2*(EulerGamma + Log[Pi]) + 
         Log[-((omega + Q2)/(omega*s - s^2))])))/(12*(omega + Q2)), 
   "R01_1_1_1_1_soft_plus_1_p2" -> 0, "R01_1_1_1_1_soft_minus_1_m1" -> 
    -(Pi/(omega - Q2)), "R01_1_1_1_1_soft_minus_1_p0" -> 
    (Pi*(EulerGamma + Log[Pi] - Log[-((s*(omega + s))/(omega - Q2))]))/
     (omega - Q2), "R01_1_1_1_1_soft_minus_1_p1" -> 
    (Pi*(Pi^2 - 6*(EulerGamma + Log[Pi])^2 - 
       6*Log[-((s*(omega + s))/(omega - Q2))]*(-2*(EulerGamma + Log[Pi]) + 
         Log[-((s*(omega + s))/(omega - Q2))])))/(12*(omega - Q2)), 
   "R01_1_1_1_1_soft_minus_1_p2" -> 0, "R02_1_1_1_1_ordinary_m1" -> 
    -(Pi/(s*t + Q2*w)), "R02_1_1_1_1_ordinary_p0" -> 
    (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
      Pi*Log[-(((s - w)*(-t + w))/(s*t + Q2*w))])/(s*t + Q2*w), 
   "R02_1_1_1_1_soft_plus_1_m1" -> -(Pi/((omega - s)*s)), 
   "R02_1_1_1_1_soft_plus_1_p0" -> (Pi*(EulerGamma + Log[Pi]))/
     ((omega - s)*s), "R02_1_1_1_1_soft_plus_1_p1" -> 
    (Pi*(Pi^2 - 2*(EulerGamma + Log[Pi])^2))/(4*(omega - s)*s), 
   "R02_1_1_1_1_soft_plus_1_p2" -> 0, "R02_1_1_1_1_soft_minus_1_m1" -> 
    Pi/(s*(omega + s)), "R02_1_1_1_1_soft_minus_1_p0" -> 
    -((Pi*(EulerGamma + Log[Pi]))/(s*(omega + s))), 
   "R02_1_1_1_1_soft_minus_1_p1" -> (Pi*(-Pi^2 + 2*(EulerGamma + Log[Pi])^2))/
     (4*s*(omega + s)), "R02_1_1_1_1_soft_minus_1_p2" -> 0, 
   "R03_1_1_0_1_ordinary_p0" -> 
    (Pi*Log[(1 - Sqrt[1 - (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2])/
        (1 + Sqrt[1 - (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2])])/
     (2*(2*Q2 + s + t)*Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2]), 
   "R03_1_1_0_1_soft_plus_1_p0" -> (Pi*Log[Q2/(omega + Q2)])/(2*omega), 
   "R03_1_1_0_1_soft_plus_1_p1" -> 
    (Pi*Log[Q2/(omega + Q2)]*(-2*(EulerGamma + Log[Pi]) + 
        Log[(omega + Q2)/Q2]) - 4*Pi*PolyLog[2, omega/(omega + Q2)])/
     (4*omega), "R03_1_1_0_1_soft_plus_1_p2" -> 0, 
   "R03_1_1_0_1_soft_minus_1_p0" -> (Pi*Log[1 - omega/Q2])/(2*omega), 
   "R03_1_1_0_1_soft_minus_1_p1" -> 
    (-2*Pi*(EulerGamma + Log[1 - omega/Q2]/2 + Log[Pi])*Log[1 - omega/Q2] - 
      4*Pi*PolyLog[2, omega/Q2])/(4*omega), "R03_1_1_0_1_soft_minus_1_p2" -> 
    0, "R03_1_1_1_1_ordinary_m1" -> Pi/(2*(Q2*t - 2*Q2*w - s*w)), 
   "R03_1_1_1_1_ordinary_p0" -> (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((2*Q2 + s + t)^2*(t - w)^2*
          (1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2])*
          (1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2]))/
         (4*(Q2*t - 2*Q2*w - s*w)^2)])/(2*(Q2*t - 2*Q2*w - s*w)), 
   "R03_1_1_1_1_soft_plus_1_m1" -> Pi/(2*Q2*(omega - s)), 
   "R03_1_1_1_1_soft_plus_1_p0" -> 
    -1/2*(Pi*(EulerGamma + Log[(Pi*Q2)/(omega + Q2)]))/(Q2*(omega - s)), 
   "R03_1_1_1_1_soft_plus_1_p1" -> 
    -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 
        4*EulerGamma*Log[(Pi*Q2)/(omega + Q2)] - 2*Log[Q2/(omega + Q2)]*
         Log[(Pi^2*Q2)/(omega + Q2)] - 8*PolyLog[2, omega/(omega + Q2)]))/
      (Q2*(omega - s)), "R03_1_1_1_1_soft_plus_1_p2" -> 0, 
   "R03_1_1_1_1_soft_minus_1_m1" -> -1/2*Pi/(Q2*(omega + s)), 
   "R03_1_1_1_1_soft_minus_1_p0" -> 
    (Pi*(EulerGamma + Log[-((Pi*Q2)/(omega - Q2))]))/(2*Q2*(omega + s)), 
   "R03_1_1_1_1_soft_minus_1_p1" -> 
    (Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 4*EulerGamma*
        Log[-((Pi*Q2)/(omega - Q2))] - 2*Log[-(Q2/(omega - Q2))]*
        Log[-((Pi^2*Q2)/(omega - Q2))] - 8*PolyLog[2, omega/(omega - Q2)]))/
     (8*Q2*(omega + s)), "R03_1_1_1_1_soft_minus_1_p2" -> 0, 
   "R04_1_1_1_1_ordinary_m1" -> Pi/(2*t*(Q2 + s + t - w)), 
   "R04_1_1_1_1_ordinary_p0" -> (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((2*Q2 + s + t)^2*(t - w)^2*
          (1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2])*
          (1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2]))/
         (4*t^2*(Q2 + s + t - w)^2)])/(2*t*(Q2 + s + t - w)), 
   "R04_1_1_1_1_soft_plus_1_m1" -> Pi/(2*(omega + Q2)*(omega - s)), 
   "R04_1_1_1_1_soft_plus_1_p0" -> 
    -1/2*(Pi*(EulerGamma + Log[(Pi*(omega + Q2))/Q2]))/
      ((omega + Q2)*(omega - s)), "R04_1_1_1_1_soft_plus_1_p1" -> 
    -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 
        4*Log[Pi]*Log[(omega + Q2)/Q2] - 2*Log[(omega + Q2)/Q2]^2 - 
        4*EulerGamma*Log[(Pi*(omega + Q2))/Q2] - 8*PolyLog[2, -(omega/Q2)]))/
      ((omega + Q2)*(omega - s)), "R04_1_1_1_1_soft_plus_1_p2" -> 0, 
   "R04_1_1_1_1_soft_minus_1_m1" -> Pi/(2*(omega - Q2)*(omega + s)), 
   "R04_1_1_1_1_soft_minus_1_p0" -> 
    -1/2*(Pi*(EulerGamma + Log[Pi - (omega*Pi)/Q2]))/
      ((omega - Q2)*(omega + s)), "R04_1_1_1_1_soft_minus_1_p1" -> 
    -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 4*EulerGamma*Log[Pi - (omega*Pi)/Q2] - 
        2*Log[Pi - (omega*Pi)/Q2]^2 - 8*PolyLog[2, omega/Q2]))/
      ((omega - Q2)*(omega + s)), "R04_1_1_1_1_soft_minus_1_p2" -> 0, 
   "R09_1_1_1_1_ordinary_m1" -> Pi/(2*(Q2*s - 2*Q2*w - t*w)), 
   "R09_1_1_1_1_ordinary_p0" -> (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((2*Q2 + s + t)^2*(s - w)^2*
          (1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2])*
          (1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2]))/
         (4*(Q2*s - 2*Q2*w - t*w)^2)])/(2*(Q2*s - 2*Q2*w - t*w)), 
   "R09_1_1_1_1_soft_plus_1_m1" -> Pi/(2*Q2*s), 
   "R09_1_1_1_1_soft_plus_1_p0" -> 
    -1/2*(Pi*(EulerGamma + Log[(Pi*Q2)/(omega + Q2)]))/(Q2*s), 
   "R09_1_1_1_1_soft_plus_1_p1" -> 
    -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 
        4*EulerGamma*Log[(Pi*Q2)/(omega + Q2)] - 2*Log[Q2/(omega + Q2)]*
         Log[(Pi^2*Q2)/(omega + Q2)] - 8*PolyLog[2, omega/(omega + Q2)]))/
      (Q2*s), "R09_1_1_1_1_soft_plus_1_p2" -> 0, 
   "R09_1_1_1_1_soft_minus_1_m1" -> Pi/(2*Q2*s), 
   "R09_1_1_1_1_soft_minus_1_p0" -> 
    -1/2*(Pi*(EulerGamma + Log[-((Pi*Q2)/(omega - Q2))]))/(Q2*s), 
   "R09_1_1_1_1_soft_minus_1_p1" -> 
    -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 
        4*EulerGamma*Log[-((Pi*Q2)/(omega - Q2))] - 2*Log[-(Q2/(omega - Q2))]*
         Log[-((Pi^2*Q2)/(omega - Q2))] - 8*PolyLog[2, omega/(omega - Q2)]))/
      (Q2*s), "R09_1_1_1_1_soft_minus_1_p2" -> 0, 
   "R10_1_1_1_1_ordinary_m1" -> Pi/(2*s*(Q2 + s + t - w)), 
   "R10_1_1_1_1_ordinary_p0" -> (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((2*Q2 + s + t)^2*(s - w)^2*
          (1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2])*
          (1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2]))/
         (4*s^2*(Q2 + s + t - w)^2)])/(2*s*(Q2 + s + t - w)), 
   "R10_1_1_1_1_soft_plus_1_m1" -> Pi/(2*(omega + Q2)*s), 
   "R10_1_1_1_1_soft_plus_1_p0" -> 
    -1/2*(Pi*(EulerGamma + Log[(Pi*(omega + Q2))/Q2]))/((omega + Q2)*s), 
   "R10_1_1_1_1_soft_plus_1_p1" -> 
    -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 
        4*Log[Pi]*Log[(omega + Q2)/Q2] - 2*Log[(omega + Q2)/Q2]^2 - 
        4*EulerGamma*Log[(Pi*(omega + Q2))/Q2] - 8*PolyLog[2, -(omega/Q2)]))/
      ((omega + Q2)*s), "R10_1_1_1_1_soft_plus_1_p2" -> 0, 
   "R10_1_1_1_1_soft_minus_1_m1" -> -1/2*Pi/((omega - Q2)*s), 
   "R10_1_1_1_1_soft_minus_1_p0" -> 
    (Pi*(EulerGamma + Log[Pi - (omega*Pi)/Q2]))/(2*(omega - Q2)*s), 
   "R10_1_1_1_1_soft_minus_1_p1" -> 
    (Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 2*Log[1 - omega/Q2]*
        (2*Log[Pi] + Log[1 - omega/Q2]) - 4*EulerGamma*
        Log[Pi - (omega*Pi)/Q2] - 8*PolyLog[2, omega/Q2]))/
     (8*(omega - Q2)*s), "R10_1_1_1_1_soft_minus_1_p2" -> 0, 
   "R01_1_1_0_0_ordinary_p0_plus" -> Pi/2, "R01_1_1_0_0_ordinary_p1_plus" -> 
    (2*Pi - EulerGamma*Pi - Pi*Log[Pi] - Pi*Log[w])/2, 
   "R01_1_1_0_0_ordinary_p0_minus" -> Pi/2, 
   "R01_1_1_0_0_ordinary_p1_minus" -> (2*Pi - EulerGamma*Pi - Pi*Log[Pi] - 
      Pi*Log[w])/2, "R01_1_1_1_1_ordinary_m1_plus" -> 
    -(Pi/(w*(-omega - Q2 + w))), "R01_1_1_1_1_ordinary_p0_plus" -> 
    (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
      Pi*Log[((s - w)*(-omega + s + w))/((omega + Q2 - w)*w)])/
     (w*(-omega - Q2 + w)), "R01_1_1_1_1_ordinary_m1_minus" -> 
    -(Pi/(w*(omega - Q2 + w))), "R01_1_1_1_1_ordinary_p0_minus" -> 
    (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
      Pi*Log[((s - w)*(omega + s + w))/((-omega + Q2 - w)*w)])/
     (w*(omega - Q2 + w)), "R02_1_1_1_1_ordinary_m1_plus" -> 
    -(Pi/((omega - s)*s + Q2*w)), "R02_1_1_1_1_ordinary_p0_plus" -> 
    (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
      Pi*Log[-(((s - w)*(-omega + s + w))/((omega - s)*s + Q2*w))])/
     ((omega - s)*s + Q2*w), "R02_1_1_1_1_ordinary_m1_minus" -> 
    -(Pi/((-omega - s)*s + Q2*w)), "R02_1_1_1_1_ordinary_p0_minus" -> 
    (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
      Pi*Log[-(((s - w)*(omega + s + w))/((-omega - s)*s + Q2*w))])/
     ((-omega - s)*s + Q2*w), "R03_1_1_0_1_ordinary_p0_plus" -> 
    (Pi*Log[(1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/
        (1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])])/
     (2*(omega + 2*Q2)*Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
        (omega + 2*Q2)^2]), "R03_1_1_0_1_ordinary_p0_minus" -> 
    (Pi*Log[(1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])/
        (1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])])/
     (2*(-omega + 2*Q2)*Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
         4*Q2*w)/(-omega + 2*Q2)^2]), "R03_1_1_1_1_ordinary_m1_plus" -> 
    Pi/(2*(Q2*(omega - s) - 2*Q2*w - s*w)), "R03_1_1_1_1_ordinary_p0_plus" -> 
    (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((omega + 2*Q2)^2*(omega - s - w)^2*
          (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
             (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
              s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
         (4*(Q2*(omega - s) - 2*Q2*w - s*w)^2)])/
     (2*(Q2*(omega - s) - 2*Q2*w - s*w)), "R03_1_1_1_1_ordinary_m1_minus" -> 
    Pi/(2*(Q2*(-omega - s) - 2*Q2*w - s*w)), 
   "R03_1_1_1_1_ordinary_p0_minus" -> (-(EulerGamma*Pi) - Pi*Log[Pi] - 
      Pi*Log[w] + Pi*Log[((-omega + 2*Q2)^2*(-omega - s - w)^2*
          (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
             (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
              2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^2]))/
         (4*(Q2*(-omega - s) - 2*Q2*w - s*w)^2)])/
     (2*(Q2*(-omega - s) - 2*Q2*w - s*w)), "R04_1_1_1_1_ordinary_m1_plus" -> 
    Pi/(2*(omega - s)*(omega + Q2 - w)), "R04_1_1_1_1_ordinary_p0_plus" -> 
    (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((omega + 2*Q2)^2*(omega - s - w)^2*
          (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
             (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
              s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/(4*(omega - s)^2*
          (omega + Q2 - w)^2)])/(2*(omega - s)*(omega + Q2 - w)), 
   "R04_1_1_1_1_ordinary_m1_minus" -> Pi/(2*(-omega - s)*(-omega + Q2 - w)), 
   "R04_1_1_1_1_ordinary_p0_minus" -> (-(EulerGamma*Pi) - Pi*Log[Pi] - 
      Pi*Log[w] + Pi*Log[((-omega + 2*Q2)^2*(-omega - s - w)^2*
          (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
             (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
              2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^2]))/
         (4*(-omega - s)^2*(-omega + Q2 - w)^2)])/
     (2*(-omega - s)*(-omega + Q2 - w)), "R09_1_1_1_1_ordinary_m1_plus" -> 
    Pi/(2*(Q2*s - 2*Q2*w - (omega - s)*w)), "R09_1_1_1_1_ordinary_p0_plus" -> 
    (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((omega + 2*Q2)^2*(s - w)^2*
          (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
             (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
              s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
         (4*(Q2*s - 2*Q2*w - (omega - s)*w)^2)])/
     (2*(Q2*s - 2*Q2*w - (omega - s)*w)), "R09_1_1_1_1_ordinary_m1_minus" -> 
    Pi/(2*(Q2*s - 2*Q2*w - (-omega - s)*w)), 
   "R09_1_1_1_1_ordinary_p0_minus" -> (-(EulerGamma*Pi) - Pi*Log[Pi] - 
      Pi*Log[w] + Pi*Log[((-omega + 2*Q2)^2*(s - w)^2*
          (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
             (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
              2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^2]))/
         (4*(Q2*s - 2*Q2*w - (-omega - s)*w)^2)])/
     (2*(Q2*s - 2*Q2*w - (-omega - s)*w)), "R10_1_1_1_1_ordinary_m1_plus" -> 
    Pi/(2*s*(omega + Q2 - w)), "R10_1_1_1_1_ordinary_p0_plus" -> 
    (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((omega + 2*Q2)^2*(s - w)^2*
          (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
             (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
              s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/(4*s^2*(omega + Q2 - w)^2)])/
     (2*s*(omega + Q2 - w)), "R10_1_1_1_1_ordinary_m1_minus" -> 
    Pi/(2*s*(-omega + Q2 - w)), "R10_1_1_1_1_ordinary_p0_minus" -> 
    (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((-omega + 2*Q2)^2*(s - w)^2*
          (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
             (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
              2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^2]))/
         (4*s^2*(-omega + Q2 - w)^2)])/(2*s*(-omega + Q2 - w))|>, 
 "series" -> <|"R01_1_1_0_0_ordinary" -> <|"minimum_power" -> 0, 
     "available_through" -> 1, "coefficient_ids" -> 
      <|"0" -> "R01_1_1_0_0_ordinary_p0", "1" -> "R01_1_1_0_0_ordinary_p1"|>, 
     "original_series" -> SeriesData[eps, 0, 
       {Pi/2, (2*Pi - EulerGamma*Pi - Pi*Log[Pi] - Pi*Log[w])/2}, 0, 2, 1], 
     "origin" -> <|"master" -> CutIntegral["R01", {1, 1, 0, 0}], 
       "kind" -> "ordinary positive-w cut master"|>|>, 
   "R01_1_1_0_0_soft_plus_1" -> <|"minimum_power" -> 0, 
     "available_through" -> 2, "coefficient_ids" -> 
      <|"0" -> "R01_1_1_0_0_soft_plus_1_p0", 
       "1" -> "R01_1_1_0_0_soft_plus_1_p1", 
       "2" -> "R01_1_1_0_0_soft_plus_1_p2"|>, "original_series" -> 
      SeriesData[eps, 0, {Pi/2, -1/2*(Pi*(-2 + EulerGamma + Log[Pi])), 
        -1/8*(Pi*(Pi^2 + 8*(-2 + Log[Pi]) - 2*(EulerGamma^2 + 
             2*EulerGamma*(-2 + Log[Pi]) + Log[Pi]^2)))}, 0, 3, 1], 
     "origin" -> <|"master" -> CutIntegral["R01", {1, 1, 0, 0}], 
       "kind" -> "regular endpoint of a regulated soft region", 
       "branch" -> 1, "piece" -> <|"Power" -> -eps, "Regular" -> 
          SeriesData[eps, 0, {Pi/2, -1/2*(EulerGamma*Pi) + 
             (Pi*(4 - 4*Log[2]))/4 - (Pi*Log[Pi/4])/2, 
            (Pi*(6*EulerGamma^2 - Pi^2))/24 + (Pi*(-2*(-4 + Pi^2/6) - 
                8*Log[2] + 4*Log[2]^2))/4 - (Pi*(4 - 4*Log[2])*Log[Pi/4])/4 + 
             (Pi*Log[Pi/4]^2)/4 - EulerGamma*((Pi*(4 - 4*Log[2]))/4 - 
               (Pi*Log[Pi/4])/2)}, 0, 3, 1]|>|>|>, 
   "R01_1_1_0_0_soft_minus_1" -> <|"minimum_power" -> 0, 
     "available_through" -> 2, "coefficient_ids" -> 
      <|"0" -> "R01_1_1_0_0_soft_minus_1_p0", 
       "1" -> "R01_1_1_0_0_soft_minus_1_p1", 
       "2" -> "R01_1_1_0_0_soft_minus_1_p2"|>, "original_series" -> 
      SeriesData[eps, 0, {Pi/2, -1/2*(Pi*(-2 + EulerGamma + Log[Pi])), 
        -1/8*(Pi*(Pi^2 + 8*(-2 + Log[Pi]) - 2*(EulerGamma^2 + 
             2*EulerGamma*(-2 + Log[Pi]) + Log[Pi]^2)))}, 0, 3, 1], 
     "origin" -> <|"master" -> CutIntegral["R01", {1, 1, 0, 0}], 
       "kind" -> "regular endpoint of a regulated soft region", 
       "branch" -> -1, "piece" -> <|"Power" -> -eps, "Regular" -> 
          SeriesData[eps, 0, {Pi/2, -1/2*(EulerGamma*Pi) + 
             (Pi*(4 - 4*Log[2]))/4 - (Pi*Log[Pi/4])/2, 
            (Pi*(6*EulerGamma^2 - Pi^2))/24 + (Pi*(-2*(-4 + Pi^2/6) - 
                8*Log[2] + 4*Log[2]^2))/4 - (Pi*(4 - 4*Log[2])*Log[Pi/4])/4 + 
             (Pi*Log[Pi/4]^2)/4 - EulerGamma*((Pi*(4 - 4*Log[2]))/4 - 
               (Pi*Log[Pi/4])/2)}, 0, 3, 1]|>|>|>, 
   "R01_1_1_1_1_ordinary" -> <|"minimum_power" -> -1, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"-1" -> "R01_1_1_1_1_ordinary_m1", 
       "0" -> "R01_1_1_1_1_ordinary_p0"|>, "original_series" -> 
      SeriesData[eps, 0, {-(Pi/(w*(-Q2 - s - t + w))), 
        (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
          Pi*Log[((s - w)*(-t + w))/((Q2 + s + t - w)*w)])/
         (w*(-Q2 - s - t + w))}, -1, 1, 1], 
     "origin" -> <|"master" -> CutIntegral["R01", {1, 1, 1, 1}], 
       "kind" -> "ordinary positive-w cut master"|>|>, 
   "R01_1_1_1_1_soft_plus_1" -> <|"minimum_power" -> -1, 
     "available_through" -> 2, "coefficient_ids" -> 
      <|"-1" -> "R01_1_1_1_1_soft_plus_1_m1", 
       "0" -> "R01_1_1_1_1_soft_plus_1_p0", 
       "1" -> "R01_1_1_1_1_soft_plus_1_p1", 
       "2" -> "R01_1_1_1_1_soft_plus_1_p2"|>, "original_series" -> 
      SeriesData[eps, 0, {Pi/(omega + Q2), 
        -((Pi*(EulerGamma + Log[Pi] + Log[-((omega + Q2)/(omega*s - s^2))]))/
          (omega + Q2)), (Pi*(-Pi^2 + 6*(EulerGamma + Log[Pi])^2 + 
           6*Log[-((omega + Q2)/(omega*s - s^2))]*(2*(EulerGamma + Log[Pi]) + 
             Log[-((omega + Q2)/(omega*s - s^2))])))/(12*(omega + Q2))}, -1, 
       3, 1], "origin" -> <|"master" -> CutIntegral["R01", {1, 1, 1, 1}], 
       "kind" -> "regular endpoint of a regulated soft region", 
       "branch" -> 1, "piece" -> <|"Power" -> -1 - 2*eps, 
         "Regular" -> SeriesData[eps, 0, {Pi/(omega + Q2 - w), 
            -((EulerGamma*Pi)/(omega + Q2 - w)) + 
             2*(-1/2*(Pi*Log[Pi])/(omega + Q2 - w) - (Pi*Log[(omega + Q2 - w)/
                   ((omega - s - w)*(-s + w))])/(2*(omega + Q2 - w))), 
            -1/12*(Pi*(-6*EulerGamma^2 - Pi^2))/(omega + Q2 - w) + 
             (Pi*(6*EulerGamma^2 - Pi^2))/(3*(omega + Q2 - w)) - 
             4*EulerGamma*(-1/2*(Pi*Log[Pi])/(omega + Q2 - w) - 
               (Pi*Log[(omega + Q2 - w)/((omega - s - w)*(-s + w))])/
                (2*(omega + Q2 - w))) + 2*((Pi^3/12 + (Pi*Log[Pi]^2)/4)/
                (omega + Q2 - w) + (Pi*Log[Pi]*Log[(omega + Q2 - w)/
                   ((omega - s - w)*(-s + w))])/(2*(omega + Q2 - w)) + 
               (Pi*Log[(omega + Q2 - w)/((omega - s - w)*(-s + w))]^2)/
                (4*(omega + Q2 - w))) - EulerGamma*((2*EulerGamma*Pi)/
                (omega + Q2 - w) - 2*(-1/2*(Pi*Log[Pi])/(omega + Q2 - w) - 
                 (Pi*Log[(omega + Q2 - w)/((omega - s - w)*(-s + w))])/
                  (2*(omega + Q2 - w))))}, -1, 2, 1], 
         "Region" -> {0, -1}|>|>|>, "R01_1_1_1_1_soft_minus_1" -> 
    <|"minimum_power" -> -1, "available_through" -> 2, 
     "coefficient_ids" -> <|"-1" -> "R01_1_1_1_1_soft_minus_1_m1", 
       "0" -> "R01_1_1_1_1_soft_minus_1_p0", 
       "1" -> "R01_1_1_1_1_soft_minus_1_p1", 
       "2" -> "R01_1_1_1_1_soft_minus_1_p2"|>, "original_series" -> 
      SeriesData[eps, 0, {-(Pi/(omega - Q2)), 
        (Pi*(EulerGamma + Log[Pi] - Log[-((s*(omega + s))/(omega - Q2))]))/
         (omega - Q2), (Pi*(Pi^2 - 6*(EulerGamma + Log[Pi])^2 - 
           6*Log[-((s*(omega + s))/(omega - Q2))]*
            (-2*(EulerGamma + Log[Pi]) + Log[-((s*(omega + s))/(omega - 
                 Q2))])))/(12*(omega - Q2))}, -1, 3, 1], 
     "origin" -> <|"master" -> CutIntegral["R01", {1, 1, 1, 1}], 
       "kind" -> "regular endpoint of a regulated soft region", 
       "branch" -> -1, "piece" -> <|"Power" -> -1 - 2*eps, 
         "Regular" -> SeriesData[eps, 0, {-(Pi/(omega - Q2 + w)), 
            (EulerGamma*Pi)/(omega - Q2 + w) + 2*((Pi*Log[Pi])/
                (2*(omega - Q2 + w)) + (Pi*Log[(omega - Q2 + w)/((-s + w)*
                    (omega + s + w))])/(2*(omega - Q2 + w))), 
            (Pi*(-6*EulerGamma^2 - Pi^2))/(12*(omega - Q2 + w)) - 
             (Pi*(6*EulerGamma^2 - Pi^2))/(3*(omega - Q2 + w)) - 
             4*EulerGamma*((Pi*Log[Pi])/(2*(omega - Q2 + w)) + 
               (Pi*Log[(omega - Q2 + w)/((-s + w)*(omega + s + w))])/
                (2*(omega - Q2 + w))) + 2*((-1/12*Pi^3 - (Pi*Log[Pi]^2)/4)/
                (omega - Q2 + w) - (Pi*Log[Pi]*Log[(omega - Q2 + w)/
                   ((-s + w)*(omega + s + w))])/(2*(omega - Q2 + w)) - 
               (Pi*Log[(omega - Q2 + w)/((-s + w)*(omega + s + w))]^2)/
                (4*(omega - Q2 + w))) - EulerGamma*((-2*EulerGamma*Pi)/
                (omega - Q2 + w) - 2*((Pi*Log[Pi])/(2*(omega - Q2 + w)) + 
                 (Pi*Log[(omega - Q2 + w)/((-s + w)*(omega + s + w))])/
                  (2*(omega - Q2 + w))))}, -1, 2, 1], 
         "Region" -> {0, -1}|>|>|>, "R02_1_1_1_1_ordinary" -> 
    <|"minimum_power" -> -1, "available_through" -> 0, 
     "coefficient_ids" -> <|"-1" -> "R02_1_1_1_1_ordinary_m1", 
       "0" -> "R02_1_1_1_1_ordinary_p0"|>, "original_series" -> 
      SeriesData[eps, 0, {-(Pi/(s*t + Q2*w)), (EulerGamma*Pi + Pi*Log[Pi] + 
          Pi*Log[w] - Pi*Log[-(((s - w)*(-t + w))/(s*t + Q2*w))])/
         (s*t + Q2*w)}, -1, 1, 1], "origin" -> 
      <|"master" -> CutIntegral["R02", {1, 1, 1, 1}], 
       "kind" -> "ordinary positive-w cut master"|>|>, 
   "R02_1_1_1_1_soft_plus_1" -> <|"minimum_power" -> -1, 
     "available_through" -> 2, "coefficient_ids" -> 
      <|"-1" -> "R02_1_1_1_1_soft_plus_1_m1", 
       "0" -> "R02_1_1_1_1_soft_plus_1_p0", 
       "1" -> "R02_1_1_1_1_soft_plus_1_p1", 
       "2" -> "R02_1_1_1_1_soft_plus_1_p2"|>, "original_series" -> 
      SeriesData[eps, 0, {-(Pi/((omega - s)*s)), (Pi*(EulerGamma + Log[Pi]))/
         ((omega - s)*s), (Pi*(Pi^2 - 2*(EulerGamma + Log[Pi])^2))/
         (4*(omega - s)*s)}, -1, 3, 1], "origin" -> 
      <|"master" -> CutIntegral["R02", {1, 1, 1, 1}], 
       "kind" -> "regular endpoint of a regulated soft region", 
       "branch" -> 1, "piece" -> <|"Power" -> -eps, "Regular" -> 
          SeriesData[eps, 0, {-(Pi/((omega - s)*s + Q2*w)), 
            (EulerGamma*Pi)/((omega - s)*s + Q2*w) + (2*((Pi*Log[Pi])/2 - 
                (Pi*Log[-(((s - w)*(-omega + s + w))/((omega - s)*s + 
                      Q2*w))])/2))/((omega - s)*s + Q2*w), 
            (Pi*(-6*EulerGamma^2 - Pi^2))/(12*((omega - s)*s + Q2*w)) - 
             (Pi*(6*EulerGamma^2 - Pi^2))/(3*((omega - s)*s + Q2*w)) - 
             (4*EulerGamma*((Pi*Log[Pi])/2 - (Pi*Log[-(((s - w)*(-omega + s + 
                       w))/((omega - s)*s + Q2*w))])/2))/((omega - s)*s + Q2*
                w) - EulerGamma*((-2*EulerGamma*Pi)/((omega - s)*s + Q2*w) - 
               (2*((Pi*Log[Pi])/2 - (Pi*Log[-(((s - w)*(-omega + s + w))/
                       ((omega - s)*s + Q2*w))])/2))/((omega - s)*s + 
                 Q2*w)) + (2*(-1/4*(Pi*Log[Pi]^2) + (Pi*Log[Pi]*
                  Log[-(((s - w)*(-omega + s + w))/((omega - s)*s + Q2*w))])/
                 2 + (Pi*(-1/2*Log[-(((s - w)*(-omega + s + w))/((omega - s)*
                          s + Q2*w))]^2 - PolyLog[2, -((((omega - s)*s + 
                        Q2*w)*(-1 - ((s - w)*(-omega + s + w))/((omega - s)*
                          s + Q2*w)))/((s - w)*(-omega + s + w)))]))/2))/
              ((omega - s)*s + Q2*w)}, -1, 2, 1]|>|>|>, 
   "R02_1_1_1_1_soft_minus_1" -> <|"minimum_power" -> -1, 
     "available_through" -> 2, "coefficient_ids" -> 
      <|"-1" -> "R02_1_1_1_1_soft_minus_1_m1", 
       "0" -> "R02_1_1_1_1_soft_minus_1_p0", 
       "1" -> "R02_1_1_1_1_soft_minus_1_p1", 
       "2" -> "R02_1_1_1_1_soft_minus_1_p2"|>, "original_series" -> 
      SeriesData[eps, 0, {Pi/(s*(omega + s)), -((Pi*(EulerGamma + Log[Pi]))/
          (s*(omega + s))), (Pi*(-Pi^2 + 2*(EulerGamma + Log[Pi])^2))/
         (4*s*(omega + s))}, -1, 3, 1], "origin" -> 
      <|"master" -> CutIntegral["R02", {1, 1, 1, 1}], 
       "kind" -> "regular endpoint of a regulated soft region", 
       "branch" -> -1, "piece" -> <|"Power" -> -eps, "Regular" -> 
          SeriesData[eps, 0, {Pi/(s*(omega + s) - Q2*w), 
            -((EulerGamma*Pi)/(s*(omega + s) - Q2*w)) + 
             (2*(-1/2*(Pi*Log[Pi]) + (Pi*Log[-(((s - w)*(omega + s + w))/
                     ((-omega - s)*s + Q2*w))])/2))/(s*(omega + s) - Q2*w), 
            -1/12*(Pi*(-6*EulerGamma^2 - Pi^2))/(s*(omega + s) - Q2*w) + 
             (Pi*(6*EulerGamma^2 - Pi^2))/(3*(s*(omega + s) - Q2*w)) - 
             (4*EulerGamma*(-1/2*(Pi*Log[Pi]) + (Pi*Log[-(((s - w)*(omega + 
                       s + w))/((-omega - s)*s + Q2*w))])/2))/
              (s*(omega + s) - Q2*w) - EulerGamma*((2*EulerGamma*Pi)/
                (s*(omega + s) - Q2*w) - (2*(-1/2*(Pi*Log[Pi]) + 
                  (Pi*Log[-(((s - w)*(omega + s + w))/((-omega - s)*s + 
                        Q2*w))])/2))/(s*(omega + s) - Q2*w)) + 
             (2*((Pi*Log[Pi]^2)/4 - (Pi*Log[Pi]*Log[-(((s - w)*(omega + s + 
                       w))/((-omega - s)*s + Q2*w))])/2 + 
                (Pi*(Log[-(((s - w)*(omega + s + w))/((-omega - s)*s + 
                         Q2*w))]^2/2 + PolyLog[2, -((((-omega - s)*s + Q2*w)*
                       (-1 - ((s - w)*(omega + s + w))/((-omega - s)*s + 
                          Q2*w)))/((s - w)*(omega + s + w)))]))/2))/
              (s*(omega + s) - Q2*w)}, -1, 2, 1]|>|>|>, 
   "R03_1_1_0_1_ordinary" -> <|"minimum_power" -> 0, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"0" -> "R03_1_1_0_1_ordinary_p0"|>, "original_series" -> 
      SeriesData[eps, 0, 
       {(Pi*Log[(1 - Sqrt[1 - (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2])/
            (1 + Sqrt[1 - (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2])])/
         (2*(2*Q2 + s + t)*Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/
            (2*Q2 + s + t)^2])}, 0, 1, 1], "origin" -> 
      <|"master" -> CutIntegral["R03", {1, 1, 0, 1}], 
       "kind" -> "ordinary positive-w cut master"|>|>, 
   "R03_1_1_0_1_soft_plus_1" -> <|"minimum_power" -> 0, 
     "available_through" -> 2, "coefficient_ids" -> 
      <|"0" -> "R03_1_1_0_1_soft_plus_1_p0", 
       "1" -> "R03_1_1_0_1_soft_plus_1_p1", 
       "2" -> "R03_1_1_0_1_soft_plus_1_p2"|>, "original_series" -> 
      SeriesData[eps, 0, {(Pi*Log[Q2/(omega + Q2)])/(2*omega), 
        (Pi*Log[Q2/(omega + Q2)]*(-2*(EulerGamma + Log[Pi]) + 
            Log[(omega + Q2)/Q2]) - 4*Pi*PolyLog[2, omega/(omega + Q2)])/
         (4*omega)}, 0, 3, 1], "origin" -> 
      <|"master" -> CutIntegral["R03", {1, 1, 0, 1}], 
       "kind" -> "regular endpoint of a regulated soft region", 
       "branch" -> 1, "piece" -> <|"Power" -> -eps, "Regular" -> 
          SeriesData[eps, 0, {-1/2*(Pi*(1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - 
                       w))/(omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(omega + 
                       Q2 - w))/(omega + 2*Q2)^2]))*Log[
                (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/
                 (1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])])/
              ((omega + 2*Q2)*(-1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                     (omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                     (omega + 2*Q2)^2]))), (EulerGamma*Pi*(1 + 
                (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/
                 (1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2]))*
               Log[(1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/
                 (1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])])/
              (2*(omega + 2*Q2)*(-1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                     (omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                     (omega + 2*Q2)^2]))) + 
             ((Pi*(1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^
                        2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                       (omega + 2*Q2)^2]))*Log[Pi]*Log[
                  (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/
                   (1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])])/
                (2*(-1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^
                        2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                       (omega + 2*Q2)^2]))) + Pi*
                (-(((1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^
                          2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                          (omega + 2*Q2)^2]))*Log[2]*Log[(1 - Sqrt[
                        1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/
                      (1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^
                          2])])/(-1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                         (omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - 
                          w))/(omega + 2*Q2)^2]))) + 
                 ((1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^
                          2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                         (omega + 2*Q2)^2]))*(2*Log[4]*Log[(1 - Sqrt[
                         1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/
                       (1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^
                          2])] + Log[(1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                          (omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(omega + 
                          Q2 - w))/(omega + 2*Q2)^2])]^2 + 4*PolyLog[2, 
                      1 - (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 
                          2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                          (omega + 2*Q2)^2])]))/(4*(-1 + (1 - Sqrt[
                       1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/
                     (1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^
                          2])))))/(omega + 2*Q2)}, 0, 2, 1]|>|>|>, 
   "R03_1_1_0_1_soft_minus_1" -> <|"minimum_power" -> 0, 
     "available_through" -> 2, "coefficient_ids" -> 
      <|"0" -> "R03_1_1_0_1_soft_minus_1_p0", 
       "1" -> "R03_1_1_0_1_soft_minus_1_p1", 
       "2" -> "R03_1_1_0_1_soft_minus_1_p2"|>, "original_series" -> 
      SeriesData[eps, 0, {(Pi*Log[1 - omega/Q2])/(2*omega), 
        (-2*Pi*(EulerGamma + ArcTanh[omega/(omega - 2*Q2)] + Log[Pi])*
           Log[1 - omega/Q2] - 4*Pi*PolyLog[2, omega/Q2])/(4*omega)}, 0, 3, 
       1], "origin" -> <|"master" -> CutIntegral["R03", {1, 1, 0, 1}], 
       "kind" -> "regular endpoint of a regulated soft region", 
       "branch" -> -1, "piece" -> <|"Power" -> -eps, "Regular" -> 
          SeriesData[eps, 0, {(Pi*(1 + (1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                    (-omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(-omega + Q2 - 
                      w))/(-omega + 2*Q2)^2]))*Log[(1 - Sqrt[
                  1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])/
                (1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])])/
             (2*(omega - 2*Q2)*(-1 + (1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                    (-omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(-omega + Q2 - 
                      w))/(-omega + 2*Q2)^2]))), 
            -1/2*(EulerGamma*Pi*(1 + (1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                      (-omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(-omega + Q2 - 
                        w))/(-omega + 2*Q2)^2]))*Log[
                 (1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])/
                  (1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^
                       2])])/((omega - 2*Q2)*(-1 + (1 - Sqrt[1 - 
                     (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])/
                  (1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^
                       2]))) + (-1/2*(Pi*(1 + (1 - Sqrt[1 - (4*Q2*(-omega + 
                          Q2 - w))/(-omega + 2*Q2)^2])/(1 + Sqrt[
                      1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2]))*
                  Log[Pi]*Log[(1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                        (-omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(-omega + 
                          Q2 - w))/(-omega + 2*Q2)^2])])/(-1 + 
                  (1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])/
                   (1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^
                        2])) + Pi*(((1 + (1 - Sqrt[1 - (4*Q2*(-omega + Q2 - 
                          w))/(-omega + 2*Q2)^2])/(1 + Sqrt[1 - 
                        (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2]))*Log[2]*
                   Log[(1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^
                          2])/(1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                         (-omega + 2*Q2)^2])])/(-1 + (1 - Sqrt[1 - 
                       (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])/
                    (1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^
                         2])) - ((1 + (1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                         (-omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(-omega + 
                          Q2 - w))/(-omega + 2*Q2)^2]))*(2*Log[4]*
                     Log[(1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 
                          2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                          (-omega + 2*Q2)^2])] + Log[(1 - Sqrt[1 - 
                          (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])/
                       (1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^
                          2])]^2 + 4*PolyLog[2, 1 - (1 - Sqrt[1 - 
                          (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])/
                        (1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 
                          2*Q2)^2])]))/(4*(-1 + (1 - Sqrt[1 - (4*Q2*(-omega + 
                          Q2 - w))/(-omega + 2*Q2)^2])/(1 + Sqrt[1 - 
                        (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])))))/
              (omega - 2*Q2)}, 0, 2, 1]|>|>|>, "R03_1_1_1_1_ordinary" -> 
    <|"minimum_power" -> -1, "available_through" -> 0, 
     "coefficient_ids" -> <|"-1" -> "R03_1_1_1_1_ordinary_m1", 
       "0" -> "R03_1_1_1_1_ordinary_p0"|>, "original_series" -> 
      SeriesData[eps, 0, {Pi/(2*(Q2*t - 2*Q2*w - s*w)), 
        (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
          Pi*Log[((2*Q2 + s + t)^2*(t - w)^2*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 
                  4*Q2*w)/(2*Q2 + s + t)^2])*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 
                  4*Q2*w)/(2*Q2 + s + t)^2]))/(4*(Q2*t - 2*Q2*w - s*w)^2)])/
         (2*(Q2*t - 2*Q2*w - s*w))}, -1, 1, 1], 
     "origin" -> <|"master" -> CutIntegral["R03", {1, 1, 1, 1}], 
       "kind" -> "ordinary positive-w cut master"|>|>, 
   "R03_1_1_1_1_soft_plus_1" -> <|"minimum_power" -> -1, 
     "available_through" -> 2, "coefficient_ids" -> 
      <|"-1" -> "R03_1_1_1_1_soft_plus_1_m1", 
       "0" -> "R03_1_1_1_1_soft_plus_1_p0", 
       "1" -> "R03_1_1_1_1_soft_plus_1_p1", 
       "2" -> "R03_1_1_1_1_soft_plus_1_p2"|>, "original_series" -> 
      SeriesData[eps, 0, {Pi/(2*Q2*(omega - s)), 
        -1/2*(Pi*(EulerGamma + Log[(Pi*Q2)/(omega + Q2)]))/(Q2*(omega - s)), 
        -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 4*EulerGamma*
             Log[(Pi*Q2)/(omega + Q2)] - 2*Log[Q2/(omega + Q2)]*
             Log[(Pi^2*Q2)/(omega + Q2)] - 8*PolyLog[2, omega/(omega + Q2)]))/
          (Q2*(omega - s))}, -1, 3, 1], "origin" -> 
      <|"master" -> CutIntegral["R03", {1, 1, 1, 1}], 
       "kind" -> "regular endpoint of a regulated soft region", 
       "branch" -> 1, "piece" -> <|"Power" -> -eps, "Regular" -> 
          SeriesData[eps, 0, {Pi/(2*(omega*Q2 - s*w - Q2*(s + 2*w))), 
            -1/2*(EulerGamma*Pi)/(omega*Q2 - s*w - Q2*(s + 2*w)) + 
             (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((omega + 2*Q2)^2*(omega - s - 
                       w)^2*(1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
                         s^2 + 4*Q2*w)/(omega + 2*Q2)^2])*(1 + Sqrt[
                       ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                        (omega + 2*Q2)^2]))/(4*(Q2*(omega - s) - 2*Q2*w - 
                       s*w)^2)])/4))/(omega*Q2 - s*w - Q2*(s + 2*w)), 
            -1/24*(Pi*(-6*EulerGamma^2 - Pi^2))/(omega*Q2 - s*w - 
                Q2*(s + 2*w)) + (Pi*(6*EulerGamma^2 - Pi^2))/(6*(omega*Q2 - 
                s*w - Q2*(s + 2*w))) - (4*EulerGamma*(-1/4*(Pi*Log[Pi]) + 
                (Pi*Log[((omega + 2*Q2)^2*(omega - s - w)^2*(1 - Sqrt[
                       ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                        (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 
                         2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                    (4*(Q2*(omega - s) - 2*Q2*w - s*w)^2)])/4))/
              (omega*Q2 - s*w - Q2*(s + 2*w)) - EulerGamma*((EulerGamma*Pi)/
                (omega*Q2 - s*w - Q2*(s + 2*w)) - (2*(-1/4*(Pi*Log[Pi]) + 
                  (Pi*Log[((omega + 2*Q2)^2*(omega - s - w)^2*(1 - Sqrt[
                         ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                          (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 
                          2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                      (4*(Q2*(omega - s) - 2*Q2*w - s*w)^2)])/4))/
                (omega*Q2 - s*w - Q2*(s + 2*w))) + (2*((Pi*Log[Pi]^2)/8 - 
                (Pi*Log[Pi]*Log[((omega + 2*Q2)^2*(omega - s - w)^2*
                     (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                         4*Q2*w)/(omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^
                          2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                         2]))/(4*(Q2*(omega - s) - 2*Q2*w - s*w)^2)])/4 + 
                (Pi*(Log[((omega + 2*Q2)^2*(omega - s - w)^2*(1 - Sqrt[
                          ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                          (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 
                          2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                       (4*(Q2*(omega - s) - 2*Q2*w - s*w)^2)]^2/4 + 
                   PolyLog[2, (2*(Q2*(omega - s) - 2*Q2*w - s*w)*(-1 + 
                       ((omega + 2*Q2)*(omega - s - w)*(1 - Sqrt[
                          ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                          (omega + 2*Q2)^2]))/(2*(Q2*(omega - s) - 2*Q2*w - 
                          s*w))))/((omega + 2*Q2)*(omega - s - w)*(1 - 
                       Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                         (omega + 2*Q2)^2]))] + PolyLog[2, 
                    (2*(Q2*(omega - s) - 2*Q2*w - s*w)*(-1 + ((omega + 2*Q2)*
                         (omega - s - w)*(1 + Sqrt[((omega - s)^2 + 
                          2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                        (2*(Q2*(omega - s) - 2*Q2*w - s*w))))/((omega + 2*Q2)*
                      (omega - s - w)*(1 + Sqrt[((omega - s)^2 + 2*(omega - 
                          s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))]))/2))/
              (omega*Q2 - s*w - Q2*(s + 2*w))}, -1, 2, 1]|>|>|>, 
   "R03_1_1_1_1_soft_minus_1" -> <|"minimum_power" -> -1, 
     "available_through" -> 2, "coefficient_ids" -> 
      <|"-1" -> "R03_1_1_1_1_soft_minus_1_m1", 
       "0" -> "R03_1_1_1_1_soft_minus_1_p0", 
       "1" -> "R03_1_1_1_1_soft_minus_1_p1", 
       "2" -> "R03_1_1_1_1_soft_minus_1_p2"|>, "original_series" -> 
      SeriesData[eps, 0, {-1/2*Pi/(Q2*(omega + s)), 
        (Pi*(EulerGamma + Log[-((Pi*Q2)/(omega - Q2))]))/(2*Q2*(omega + s)), 
        (Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 4*EulerGamma*
            Log[-((Pi*Q2)/(omega - Q2))] - 2*Log[-(Q2/(omega - Q2))]*
            Log[-((Pi^2*Q2)/(omega - Q2))] - 
           8*PolyLog[2, omega/(omega - Q2)]))/(8*Q2*(omega + s))}, -1, 3, 1], 
     "origin" -> <|"master" -> CutIntegral["R03", {1, 1, 1, 1}], 
       "kind" -> "regular endpoint of a regulated soft region", 
       "branch" -> -1, "piece" -> <|"Power" -> -eps, "Regular" -> 
          SeriesData[eps, 0, {-1/2*Pi/(Q2*(omega + s) + (2*Q2 + s)*w), 
            (EulerGamma*Pi)/(2*(Q2*(omega + s) + (2*Q2 + s)*w)) + 
             (2*((Pi*Log[Pi])/4 - (Pi*Log[((-omega + 2*Q2)^2*(-omega - s - w)^
                      2*(1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                         4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[
                       ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                        (-omega + 2*Q2)^2]))/(4*(Q2*(-omega - s) - 2*Q2*w - 
                       s*w)^2)])/4))/(Q2*(omega + s) + (2*Q2 + s)*w), 
            (Pi*(-6*EulerGamma^2 - Pi^2))/(24*(Q2*(omega + s) + (2*Q2 + s)*
                 w)) - (Pi*(6*EulerGamma^2 - Pi^2))/(6*(Q2*(omega + s) + 
                (2*Q2 + s)*w)) - (4*EulerGamma*((Pi*Log[Pi])/4 - 
                (Pi*Log[((-omega + 2*Q2)^2*(-omega - s - w)^2*(1 - 
                      Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                        (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
                         2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                         2]))/(4*(Q2*(-omega - s) - 2*Q2*w - s*w)^2)])/4))/
              (Q2*(omega + s) + (2*Q2 + s)*w) - EulerGamma*
              (-((EulerGamma*Pi)/(Q2*(omega + s) + (2*Q2 + s)*w)) - 
               (2*((Pi*Log[Pi])/4 - (Pi*Log[((-omega + 2*Q2)^2*(-omega - s - 
                         w)^2*(1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + 
                          s^2 + 4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[
                         ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                          (-omega + 2*Q2)^2]))/(4*(Q2*(-omega - s) - 2*Q2*w - 
                         s*w)^2)])/4))/(Q2*(omega + s) + (2*Q2 + s)*w)) + 
             (2*(-1/8*(Pi*Log[Pi]^2) + (Pi*Log[Pi]*Log[((-omega + 2*Q2)^2*
                     (-omega - s - w)^2*(1 - Sqrt[((-omega - s)^2 + 
                         2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^2])*
                     (1 + Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                         4*Q2*w)/(-omega + 2*Q2)^2]))/(4*(Q2*(-omega - s) - 
                       2*Q2*w - s*w)^2)])/4 + 
                (Pi*(-1/4*Log[((-omega + 2*Q2)^2*(-omega - s - w)^2*
                        (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                          4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^
                          2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 
                          2*Q2)^2]))/(4*(Q2*(-omega - s) - 2*Q2*w - s*w)^2)]^
                     2 - PolyLog[2, (2*(Q2*(-omega - s) - 2*Q2*w - s*w)*
                      (-1 + ((-omega + 2*Q2)*(-omega - s - w)*(1 - Sqrt[
                          ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                          (-omega + 2*Q2)^2]))/(2*(Q2*(-omega - s) - 2*Q2*w - 
                          s*w))))/((-omega + 2*Q2)*(-omega - s - w)*
                      (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                          4*Q2*w)/(-omega + 2*Q2)^2]))] - PolyLog[2, 
                    (2*(Q2*(-omega - s) - 2*Q2*w - s*w)*(-1 + 
                       ((-omega + 2*Q2)*(-omega - s - w)*(1 + Sqrt[
                          ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                          (-omega + 2*Q2)^2]))/(2*(Q2*(-omega - s) - 2*Q2*w - 
                          s*w))))/((-omega + 2*Q2)*(-omega - s - w)*
                      (1 + Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                          4*Q2*w)/(-omega + 2*Q2)^2]))]))/2))/
              (Q2*(omega + s) + (2*Q2 + s)*w)}, -1, 2, 1]|>|>|>, 
   "R04_1_1_1_1_ordinary" -> <|"minimum_power" -> -1, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"-1" -> "R04_1_1_1_1_ordinary_m1", 
       "0" -> "R04_1_1_1_1_ordinary_p0"|>, "original_series" -> 
      SeriesData[eps, 0, {Pi/(2*t*(Q2 + s + t - w)), 
        (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
          Pi*Log[((2*Q2 + s + t)^2*(t - w)^2*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 
                  4*Q2*w)/(2*Q2 + s + t)^2])*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 
                  4*Q2*w)/(2*Q2 + s + t)^2]))/(4*t^2*(Q2 + s + t - w)^2)])/
         (2*t*(Q2 + s + t - w))}, -1, 1, 1], 
     "origin" -> <|"master" -> CutIntegral["R04", {1, 1, 1, 1}], 
       "kind" -> "ordinary positive-w cut master"|>|>, 
   "R04_1_1_1_1_soft_plus_1" -> <|"minimum_power" -> -1, 
     "available_through" -> 2, "coefficient_ids" -> 
      <|"-1" -> "R04_1_1_1_1_soft_plus_1_m1", 
       "0" -> "R04_1_1_1_1_soft_plus_1_p0", 
       "1" -> "R04_1_1_1_1_soft_plus_1_p1", 
       "2" -> "R04_1_1_1_1_soft_plus_1_p2"|>, "original_series" -> 
      SeriesData[eps, 0, {Pi/(2*(omega + Q2)*(omega - s)), 
        -1/2*(Pi*(EulerGamma + Log[(Pi*(omega + Q2))/Q2]))/
          ((omega + Q2)*(omega - s)), 
        -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 
            4*Log[Pi]*Log[(omega + Q2)/Q2] - 2*Log[(omega + Q2)/Q2]^2 - 
            4*EulerGamma*Log[(Pi*(omega + Q2))/Q2] - 
            8*PolyLog[2, -(omega/Q2)]))/((omega + Q2)*(omega - s))}, -1, 3, 
       1], "origin" -> <|"master" -> CutIntegral["R04", {1, 1, 1, 1}], 
       "kind" -> "regular endpoint of a regulated soft region", 
       "branch" -> 1, "piece" -> <|"Power" -> -eps, "Regular" -> 
          SeriesData[eps, 0, {Pi/(2*(omega - s)*(omega + Q2 - w)), 
            -1/2*(EulerGamma*Pi)/((omega - s)*(omega + Q2 - w)) + 
             (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((omega + 2*Q2)^2*(omega - s - 
                       w)^2*(1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
                         s^2 + 4*Q2*w)/(omega + 2*Q2)^2])*(1 + Sqrt[
                       ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                        (omega + 2*Q2)^2]))/(4*(omega - s)^2*(omega + Q2 - w)^
                      2)])/4))/((omega - s)*(omega + Q2 - w)), 
            -1/24*(Pi*(-6*EulerGamma^2 - Pi^2))/((omega - s)*(omega + Q2 - 
                 w)) + (Pi*(6*EulerGamma^2 - Pi^2))/(6*(omega - s)*(omega + 
                Q2 - w)) - (4*EulerGamma*(-1/4*(Pi*Log[Pi]) + 
                (Pi*Log[((omega + 2*Q2)^2*(omega - s - w)^2*(1 - Sqrt[
                       ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                        (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 
                         2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                    (4*(omega - s)^2*(omega + Q2 - w)^2)])/4))/
              ((omega - s)*(omega + Q2 - w)) - EulerGamma*((EulerGamma*Pi)/
                ((omega - s)*(omega + Q2 - w)) - (2*(-1/4*(Pi*Log[Pi]) + 
                  (Pi*Log[((omega + 2*Q2)^2*(omega - s - w)^2*(1 - Sqrt[
                         ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                          (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 
                          2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                      (4*(omega - s)^2*(omega + Q2 - w)^2)])/4))/
                ((omega - s)*(omega + Q2 - w))) + (2*((Pi*Log[Pi]^2)/8 - 
                (Pi*Log[Pi]*Log[((omega + 2*Q2)^2*(omega - s - w)^2*
                     (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                         4*Q2*w)/(omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^
                          2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                         2]))/(4*(omega - s)^2*(omega + Q2 - w)^2)])/4 + 
                (Pi*(Log[((omega + 2*Q2)^2*(omega - s - w)^2*(1 - Sqrt[
                          ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                          (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 
                          2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                       (4*(omega - s)^2*(omega + Q2 - w)^2)]^2/4 + 
                   PolyLog[2, (2*(omega - s)*(omega + Q2 - w)*(-1 + 
                       ((omega + 2*Q2)*(omega - s - w)*(1 - Sqrt[
                          ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                          (omega + 2*Q2)^2]))/(2*(omega - s)*(omega + Q2 - 
                          w))))/((omega + 2*Q2)*(omega - s - w)*(1 - 
                       Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                         (omega + 2*Q2)^2]))] + PolyLog[2, (2*(omega - s)*
                      (omega + Q2 - w)*(-1 + ((omega + 2*Q2)*(omega - s - w)*
                         (1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                          4*Q2*w)/(omega + 2*Q2)^2]))/(2*(omega - s)*(omega + 
                          Q2 - w))))/((omega + 2*Q2)*(omega - s - w)*
                      (1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                          4*Q2*w)/(omega + 2*Q2)^2]))]))/2))/((omega - s)*(
                omega + Q2 - w))}, -1, 2, 1]|>|>|>, 
   "R04_1_1_1_1_soft_minus_1" -> <|"minimum_power" -> -1, 
     "available_through" -> 2, "coefficient_ids" -> 
      <|"-1" -> "R04_1_1_1_1_soft_minus_1_m1", 
       "0" -> "R04_1_1_1_1_soft_minus_1_p0", 
       "1" -> "R04_1_1_1_1_soft_minus_1_p1", 
       "2" -> "R04_1_1_1_1_soft_minus_1_p2"|>, "original_series" -> 
      SeriesData[eps, 0, {Pi/(2*(omega - Q2)*(omega + s)), 
        -1/2*(Pi*(EulerGamma + Log[Pi - (omega*Pi)/Q2]))/
          ((omega - Q2)*(omega + s)), 
        -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 4*EulerGamma*
             Log[Pi - (omega*Pi)/Q2] - 2*Log[Pi - (omega*Pi)/Q2]^2 - 
            8*PolyLog[2, omega/Q2]))/((omega - Q2)*(omega + s))}, -1, 3, 1], 
     "origin" -> <|"master" -> CutIntegral["R04", {1, 1, 1, 1}], 
       "kind" -> "regular endpoint of a regulated soft region", 
       "branch" -> -1, "piece" -> <|"Power" -> -eps, "Regular" -> 
          SeriesData[eps, 0, {Pi/(2*(omega + s)*(omega - Q2 + w)), 
            -1/2*(EulerGamma*Pi)/((omega + s)*(omega - Q2 + w)) + 
             (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((-omega + 2*Q2)^2*(-omega - s - 
                       w)^2*(1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + 
                         s^2 + 4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[
                       ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                        (-omega + 2*Q2)^2]))/(4*(-omega - s)^2*(-omega + Q2 - 
                       w)^2)])/4))/((omega + s)*(omega - Q2 + w)), 
            -1/24*(Pi*(-6*EulerGamma^2 - Pi^2))/((omega + s)*(omega - Q2 + 
                 w)) + (Pi*(6*EulerGamma^2 - Pi^2))/(6*(omega + s)*(omega - 
                Q2 + w)) - (4*EulerGamma*(-1/4*(Pi*Log[Pi]) + 
                (Pi*Log[((-omega + 2*Q2)^2*(-omega - s - w)^2*(1 - 
                      Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                        (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
                         2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                         2]))/(4*(-omega - s)^2*(-omega + Q2 - w)^2)])/4))/
              ((omega + s)*(omega - Q2 + w)) - EulerGamma*((EulerGamma*Pi)/
                ((omega + s)*(omega - Q2 + w)) - (2*(-1/4*(Pi*Log[Pi]) + 
                  (Pi*Log[((-omega + 2*Q2)^2*(-omega - s - w)^2*(1 - 
                        Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                          4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[
                         ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                          (-omega + 2*Q2)^2]))/(4*(-omega - s)^2*
                       (-omega + Q2 - w)^2)])/4))/((omega + s)*(omega - Q2 + 
                  w))) + (2*((Pi*Log[Pi]^2)/8 - (Pi*Log[Pi]*
                  Log[((-omega + 2*Q2)^2*(-omega - s - w)^2*(1 - Sqrt[
                       ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                        (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
                         2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                         2]))/(4*(-omega - s)^2*(-omega + Q2 - w)^2)])/4 + 
                (Pi*(Log[((-omega + 2*Q2)^2*(-omega - s - w)^2*(1 - Sqrt[
                          ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                          (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
                          2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                          2]))/(4*(-omega - s)^2*(-omega + Q2 - w)^2)]^2/4 + 
                   PolyLog[2, (2*(-omega - s)*(-omega + Q2 - w)*(-1 + 
                       ((-omega + 2*Q2)*(-omega - s - w)*(1 - Sqrt[
                          ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                          (-omega + 2*Q2)^2]))/(2*(-omega - s)*(-omega + Q2 - 
                          w))))/((-omega + 2*Q2)*(-omega - s - w)*(1 - 
                       Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                          4*Q2*w)/(-omega + 2*Q2)^2]))] + PolyLog[2, 
                    (2*(-omega - s)*(-omega + Q2 - w)*(-1 + ((-omega + 2*Q2)*
                         (-omega - s - w)*(1 + Sqrt[((-omega - s)^2 + 
                          2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                          2]))/(2*(-omega - s)*(-omega + Q2 - w))))/
                     ((-omega + 2*Q2)*(-omega - s - w)*(1 + Sqrt[
                        ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                         (-omega + 2*Q2)^2]))]))/2))/((omega + s)*(omega - 
                Q2 + w))}, -1, 2, 1]|>|>|>, "R09_1_1_1_1_ordinary" -> 
    <|"minimum_power" -> -1, "available_through" -> 0, 
     "coefficient_ids" -> <|"-1" -> "R09_1_1_1_1_ordinary_m1", 
       "0" -> "R09_1_1_1_1_ordinary_p0"|>, "original_series" -> 
      SeriesData[eps, 0, {Pi/(2*(Q2*s - 2*Q2*w - t*w)), 
        (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
          Pi*Log[((2*Q2 + s + t)^2*(s - w)^2*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 
                  4*Q2*w)/(2*Q2 + s + t)^2])*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 
                  4*Q2*w)/(2*Q2 + s + t)^2]))/(4*(Q2*s - 2*Q2*w - t*w)^2)])/
         (2*(Q2*s - 2*Q2*w - t*w))}, -1, 1, 1], 
     "origin" -> <|"master" -> CutIntegral["R09", {1, 1, 1, 1}], 
       "kind" -> "ordinary positive-w cut master"|>|>, 
   "R09_1_1_1_1_soft_plus_1" -> <|"minimum_power" -> -1, 
     "available_through" -> 2, "coefficient_ids" -> 
      <|"-1" -> "R09_1_1_1_1_soft_plus_1_m1", 
       "0" -> "R09_1_1_1_1_soft_plus_1_p0", 
       "1" -> "R09_1_1_1_1_soft_plus_1_p1", 
       "2" -> "R09_1_1_1_1_soft_plus_1_p2"|>, "original_series" -> 
      SeriesData[eps, 0, {Pi/(2*Q2*s), 
        -1/2*(Pi*(EulerGamma + Log[(Pi*Q2)/(omega + Q2)]))/(Q2*s), 
        -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 4*EulerGamma*
             Log[(Pi*Q2)/(omega + Q2)] - 2*Log[Q2/(omega + Q2)]*
             Log[(Pi^2*Q2)/(omega + Q2)] - 8*PolyLog[2, omega/(omega + Q2)]))/
          (Q2*s)}, -1, 3, 1], "origin" -> 
      <|"master" -> CutIntegral["R09", {1, 1, 1, 1}], 
       "kind" -> "regular endpoint of a regulated soft region", 
       "branch" -> 1, "piece" -> <|"Power" -> -eps, "Regular" -> 
          SeriesData[eps, 0, {Pi/(2*(Q2*(s - 2*w) + (-omega + s)*w)), 
            -1/2*(EulerGamma*Pi)/(Q2*(s - 2*w) + (-omega + s)*w) + 
             (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((omega + 2*Q2)^2*(s - w)^2*
                     (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                         4*Q2*w)/(omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^
                          2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                         2]))/(4*(Q2*s - 2*Q2*w - (omega - s)*w)^2)])/4))/
              (Q2*(s - 2*w) + (-omega + s)*w), 
            -1/24*(Pi*(-6*EulerGamma^2 - Pi^2))/(Q2*(s - 2*w) + (-omega + s)*
                 w) + (Pi*(6*EulerGamma^2 - Pi^2))/(6*(Q2*(s - 2*w) + 
                (-omega + s)*w)) - (4*EulerGamma*(-1/4*(Pi*Log[Pi]) + 
                (Pi*Log[((omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[((omega - s)^
                          2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                         2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
                         s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                    (4*(Q2*s - 2*Q2*w - (omega - s)*w)^2)])/4))/
              (Q2*(s - 2*w) + (-omega + s)*w) - EulerGamma*((EulerGamma*Pi)/
                (Q2*(s - 2*w) + (-omega + s)*w) - (2*(-1/4*(Pi*Log[Pi]) + 
                  (Pi*Log[((omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[
                         ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                          (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 
                          2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                      (4*(Q2*s - 2*Q2*w - (omega - s)*w)^2)])/4))/
                (Q2*(s - 2*w) + (-omega + s)*w)) + (2*((Pi*Log[Pi]^2)/8 - 
                (Pi*Log[Pi]*Log[((omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[
                       ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                        (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 
                         2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                    (4*(Q2*s - 2*Q2*w - (omega - s)*w)^2)])/4 + 
                (Pi*(Log[((omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[((omega - s)^
                          2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                          2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
                          s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/(4*(Q2*s - 
                          2*Q2*w - (omega - s)*w)^2)]^2/4 + PolyLog[2, 
                    (2*(Q2*s - 2*Q2*w - (omega - s)*w)*(-1 + ((omega + 2*Q2)*
                         (s - w)*(1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
                          s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/(2*(Q2*s - 
                          2*Q2*w - (omega - s)*w))))/((omega + 2*Q2)*(s - w)*
                      (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                          4*Q2*w)/(omega + 2*Q2)^2]))] + PolyLog[2, 
                    (2*(Q2*s - 2*Q2*w - (omega - s)*w)*(-1 + ((omega + 2*Q2)*
                         (s - w)*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
                          s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/(2*(Q2*s - 
                          2*Q2*w - (omega - s)*w))))/((omega + 2*Q2)*(s - w)*
                      (1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                          4*Q2*w)/(omega + 2*Q2)^2]))]))/2))/
              (Q2*(s - 2*w) + (-omega + s)*w)}, -1, 2, 1]|>|>|>, 
   "R09_1_1_1_1_soft_minus_1" -> <|"minimum_power" -> -1, 
     "available_through" -> 2, "coefficient_ids" -> 
      <|"-1" -> "R09_1_1_1_1_soft_minus_1_m1", 
       "0" -> "R09_1_1_1_1_soft_minus_1_p0", 
       "1" -> "R09_1_1_1_1_soft_minus_1_p1", 
       "2" -> "R09_1_1_1_1_soft_minus_1_p2"|>, "original_series" -> 
      SeriesData[eps, 0, {Pi/(2*Q2*s), 
        -1/2*(Pi*(EulerGamma + Log[-((Pi*Q2)/(omega - Q2))]))/(Q2*s), 
        -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 4*EulerGamma*
             Log[-((Pi*Q2)/(omega - Q2))] - 2*Log[-(Q2/(omega - Q2))]*
             Log[-((Pi^2*Q2)/(omega - Q2))] - 8*PolyLog[2, omega/(omega - 
                Q2)]))/(Q2*s)}, -1, 3, 1], "origin" -> 
      <|"master" -> CutIntegral["R09", {1, 1, 1, 1}], 
       "kind" -> "regular endpoint of a regulated soft region", 
       "branch" -> -1, "piece" -> <|"Power" -> -eps, "Regular" -> 
          SeriesData[eps, 0, {Pi/(2*(Q2*(s - 2*w) + (omega + s)*w)), 
            -1/2*(EulerGamma*Pi)/(Q2*(s - 2*w) + (omega + s)*w) + 
             (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((-omega + 2*Q2)^2*(s - w)^2*
                     (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                         4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[
                       ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                        (-omega + 2*Q2)^2]))/(4*(Q2*s - 2*Q2*w - (-omega - s)*
                        w)^2)])/4))/(Q2*(s - 2*w) + (omega + s)*w), 
            -1/24*(Pi*(-6*EulerGamma^2 - Pi^2))/(Q2*(s - 2*w) + (omega + s)*
                 w) + (Pi*(6*EulerGamma^2 - Pi^2))/(6*(Q2*(s - 2*w) + 
                (omega + s)*w)) - (4*EulerGamma*(-1/4*(Pi*Log[Pi]) + 
                (Pi*Log[((-omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[
                       ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                        (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
                         2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                         2]))/(4*(Q2*s - 2*Q2*w - (-omega - s)*w)^2)])/4))/
              (Q2*(s - 2*w) + (omega + s)*w) - EulerGamma*((EulerGamma*Pi)/
                (Q2*(s - 2*w) + (omega + s)*w) - (2*(-1/4*(Pi*Log[Pi]) + 
                  (Pi*Log[((-omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[
                         ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                          (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
                          2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                          2]))/(4*(Q2*s - 2*Q2*w - (-omega - s)*w)^2)])/4))/
                (Q2*(s - 2*w) + (omega + s)*w)) + (2*((Pi*Log[Pi]^2)/8 - 
                (Pi*Log[Pi]*Log[((-omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[
                       ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                        (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
                         2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                         2]))/(4*(Q2*s - 2*Q2*w - (-omega - s)*w)^2)])/4 + 
                (Pi*(Log[((-omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[((-omega - s)^
                          2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 
                          2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 2*(-omega - 
                          s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^2]))/
                       (4*(Q2*s - 2*Q2*w - (-omega - s)*w)^2)]^2/4 + 
                   PolyLog[2, (2*(Q2*s - 2*Q2*w - (-omega - s)*w)*(-1 + 
                       ((-omega + 2*Q2)*(s - w)*(1 - Sqrt[((-omega - s)^2 + 
                          2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                          2]))/(2*(Q2*s - 2*Q2*w - (-omega - s)*w))))/
                     ((-omega + 2*Q2)*(s - w)*(1 - Sqrt[((-omega - s)^2 + 
                          2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                          2]))] + PolyLog[2, (2*(Q2*s - 2*Q2*w - (-omega - s)*
                        w)*(-1 + ((-omega + 2*Q2)*(s - w)*(1 + Sqrt[
                          ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                          (-omega + 2*Q2)^2]))/(2*(Q2*s - 2*Q2*w - 
                          (-omega - s)*w))))/((-omega + 2*Q2)*(s - w)*
                      (1 + Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                          4*Q2*w)/(-omega + 2*Q2)^2]))]))/2))/
              (Q2*(s - 2*w) + (omega + s)*w)}, -1, 2, 1]|>|>|>, 
   "R10_1_1_1_1_ordinary" -> <|"minimum_power" -> -1, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"-1" -> "R10_1_1_1_1_ordinary_m1", 
       "0" -> "R10_1_1_1_1_ordinary_p0"|>, "original_series" -> 
      SeriesData[eps, 0, {Pi/(2*s*(Q2 + s + t - w)), 
        (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
          Pi*Log[((2*Q2 + s + t)^2*(s - w)^2*(1 - Sqrt[(s^2 + 2*s*t + t^2 + 
                  4*Q2*w)/(2*Q2 + s + t)^2])*(1 + Sqrt[(s^2 + 2*s*t + t^2 + 
                  4*Q2*w)/(2*Q2 + s + t)^2]))/(4*s^2*(Q2 + s + t - w)^2)])/
         (2*s*(Q2 + s + t - w))}, -1, 1, 1], 
     "origin" -> <|"master" -> CutIntegral["R10", {1, 1, 1, 1}], 
       "kind" -> "ordinary positive-w cut master"|>|>, 
   "R10_1_1_1_1_soft_plus_1" -> <|"minimum_power" -> -1, 
     "available_through" -> 2, "coefficient_ids" -> 
      <|"-1" -> "R10_1_1_1_1_soft_plus_1_m1", 
       "0" -> "R10_1_1_1_1_soft_plus_1_p0", 
       "1" -> "R10_1_1_1_1_soft_plus_1_p1", 
       "2" -> "R10_1_1_1_1_soft_plus_1_p2"|>, "original_series" -> 
      SeriesData[eps, 0, {Pi/(2*(omega + Q2)*s), 
        -1/2*(Pi*(EulerGamma + Log[(Pi*(omega + Q2))/Q2]))/((omega + Q2)*s), 
        -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 
            4*Log[Pi]*Log[(omega + Q2)/Q2] - 2*Log[(omega + Q2)/Q2]^2 - 
            4*EulerGamma*Log[(Pi*(omega + Q2))/Q2] - 
            8*PolyLog[2, -(omega/Q2)]))/((omega + Q2)*s)}, -1, 3, 1], 
     "origin" -> <|"master" -> CutIntegral["R10", {1, 1, 1, 1}], 
       "kind" -> "regular endpoint of a regulated soft region", 
       "branch" -> 1, "piece" -> <|"Power" -> -eps, "Regular" -> 
          SeriesData[eps, 0, {Pi/(2*s*(omega + Q2 - w)), 
            -1/2*(EulerGamma*Pi)/(s*(omega + Q2 - w)) + 
             (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((omega + 2*Q2)^2*(s - w)^2*
                     (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                         4*Q2*w)/(omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^
                          2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                         2]))/(4*s^2*(omega + Q2 - w)^2)])/4))/
              (s*(omega + Q2 - w)), -1/24*(Pi*(-6*EulerGamma^2 - Pi^2))/(s*
                (omega + Q2 - w)) + (Pi*(6*EulerGamma^2 - Pi^2))/
              (6*s*(omega + Q2 - w)) - (4*EulerGamma*(-1/4*(Pi*Log[Pi]) + 
                (Pi*Log[((omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[((omega - s)^
                          2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                         2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
                         s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/(4*s^2*
                     (omega + Q2 - w)^2)])/4))/(s*(omega + Q2 - w)) - 
             EulerGamma*((EulerGamma*Pi)/(s*(omega + Q2 - w)) - 
               (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((omega + 2*Q2)^2*(s - w)^2*
                       (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                          4*Q2*w)/(omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^
                          2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                          2]))/(4*s^2*(omega + Q2 - w)^2)])/4))/
                (s*(omega + Q2 - w))) + (2*((Pi*Log[Pi]^2)/8 - 
                (Pi*Log[Pi]*Log[((omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[
                       ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                        (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 
                         2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                    (4*s^2*(omega + Q2 - w)^2)])/4 + 
                (Pi*(Log[((omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[((omega - s)^
                          2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                          2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
                          s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/(4*s^2*
                        (omega + Q2 - w)^2)]^2/4 + PolyLog[2, 
                    (2*s*(omega + Q2 - w)*(-1 + ((omega + 2*Q2)*(s - w)*
                         (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                          4*Q2*w)/(omega + 2*Q2)^2]))/(2*s*(omega + Q2 - 
                          w))))/((omega + 2*Q2)*(s - w)*(1 - Sqrt[
                        ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                         (omega + 2*Q2)^2]))] + PolyLog[2, (2*s*(omega + Q2 - 
                       w)*(-1 + ((omega + 2*Q2)*(s - w)*(1 + Sqrt[
                          ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                          (omega + 2*Q2)^2]))/(2*s*(omega + Q2 - w))))/
                     ((omega + 2*Q2)*(s - w)*(1 + Sqrt[((omega - s)^2 + 
                          2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                          2]))]))/2))/(s*(omega + Q2 - w))}, -1, 2, 1]|>|>|>, 
   "R10_1_1_1_1_soft_minus_1" -> <|"minimum_power" -> -1, 
     "available_through" -> 2, "coefficient_ids" -> 
      <|"-1" -> "R10_1_1_1_1_soft_minus_1_m1", 
       "0" -> "R10_1_1_1_1_soft_minus_1_p0", 
       "1" -> "R10_1_1_1_1_soft_minus_1_p1", 
       "2" -> "R10_1_1_1_1_soft_minus_1_p2"|>, "original_series" -> 
      SeriesData[eps, 0, {-1/2*Pi/((omega - Q2)*s), 
        (Pi*(EulerGamma + Log[Pi - (omega*Pi)/Q2]))/(2*(omega - Q2)*s), 
        (Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 2*Log[1 - omega/Q2]*
            (2*Log[Pi] + Log[1 - omega/Q2]) - 4*EulerGamma*
            Log[Pi - (omega*Pi)/Q2] - 8*PolyLog[2, omega/Q2]))/
         (8*(omega - Q2)*s)}, -1, 3, 1], "origin" -> 
      <|"master" -> CutIntegral["R10", {1, 1, 1, 1}], 
       "kind" -> "regular endpoint of a regulated soft region", 
       "branch" -> -1, "piece" -> <|"Power" -> -eps, "Regular" -> 
          SeriesData[eps, 0, {-1/2*Pi/(s*(omega - Q2 + w)), 
            (EulerGamma*Pi)/(2*s*(omega - Q2 + w)) + (2*((Pi*Log[Pi])/4 - 
                (Pi*Log[((-omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[
                       ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                        (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
                         2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                         2]))/(4*s^2*(-omega + Q2 - w)^2)])/4))/
              (s*(omega - Q2 + w)), (Pi*(-6*EulerGamma^2 - Pi^2))/
              (24*s*(omega - Q2 + w)) - (Pi*(6*EulerGamma^2 - Pi^2))/
              (6*s*(omega - Q2 + w)) - (4*EulerGamma*((Pi*Log[Pi])/4 - 
                (Pi*Log[((-omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[
                       ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                        (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
                         2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                         2]))/(4*s^2*(-omega + Q2 - w)^2)])/4))/
              (s*(omega - Q2 + w)) - EulerGamma*(-((EulerGamma*Pi)/
                 (s*(omega - Q2 + w))) - (2*((Pi*Log[Pi])/4 - 
                  (Pi*Log[((-omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[
                         ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                          (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
                          2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                          2]))/(4*s^2*(-omega + Q2 - w)^2)])/4))/
                (s*(omega - Q2 + w))) + (2*(-1/8*(Pi*Log[Pi]^2) + 
                (Pi*Log[Pi]*Log[((-omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[
                       ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                        (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
                         2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                         2]))/(4*s^2*(-omega + Q2 - w)^2)])/4 + 
                (Pi*(-1/4*Log[((-omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[
                          ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                          (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
                          2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                          2]))/(4*s^2*(-omega + Q2 - w)^2)]^2 - PolyLog[2, 
                    (2*s*(-omega + Q2 - w)*(-1 + ((-omega + 2*Q2)*(s - w)*
                         (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                          4*Q2*w)/(-omega + 2*Q2)^2]))/(2*s*(-omega + Q2 - 
                          w))))/((-omega + 2*Q2)*(s - w)*(1 - Sqrt[
                        ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                         (-omega + 2*Q2)^2]))] - PolyLog[2, (2*s*(-omega + 
                       Q2 - w)*(-1 + ((-omega + 2*Q2)*(s - w)*(1 + Sqrt[
                          ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                          (-omega + 2*Q2)^2]))/(2*s*(-omega + Q2 - w))))/
                     ((-omega + 2*Q2)*(s - w)*(1 + Sqrt[((-omega - s)^2 + 
                          2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                          2]))]))/2))/(s*(omega - Q2 + w))}, -1, 2, 
           1]|>|>|>|>, "endpoint_definitions" -> 
  <|"R01_1_1_0_0_soft_plus_1" -> 
    <|"master" -> CutIntegral["R01", {1, 1, 0, 0}], "branch" -> 1, 
     "power" -> -eps, "coefficient_ids" -> 
      <|"0" -> "R01_1_1_0_0_soft_plus_1_p0", 
       "1" -> "R01_1_1_0_0_soft_plus_1_p1", 
       "2" -> "R01_1_1_0_0_soft_plus_1_p2"|>, "definition" -> 
      HoldComplete[Limit[regularRegion, w -> 0, Direction -> "FromAbove"]], 
     "piece" -> <|"Power" -> -eps, "Regular" -> SeriesData[eps, 0, 
         {Pi/2, -1/2*(EulerGamma*Pi) + (Pi*(4 - 4*Log[2]))/4 - 
           (Pi*Log[Pi/4])/2, (Pi*(6*EulerGamma^2 - Pi^2))/24 + 
           (Pi*(-2*(-4 + Pi^2/6) - 8*Log[2] + 4*Log[2]^2))/4 - 
           (Pi*(4 - 4*Log[2])*Log[Pi/4])/4 + (Pi*Log[Pi/4]^2)/4 - 
           EulerGamma*((Pi*(4 - 4*Log[2]))/4 - (Pi*Log[Pi/4])/2)}, 0, 3, 
         1]|>|>, "R01_1_1_0_0_soft_minus_1" -> 
    <|"master" -> CutIntegral["R01", {1, 1, 0, 0}], "branch" -> -1, 
     "power" -> -eps, "coefficient_ids" -> 
      <|"0" -> "R01_1_1_0_0_soft_minus_1_p0", 
       "1" -> "R01_1_1_0_0_soft_minus_1_p1", 
       "2" -> "R01_1_1_0_0_soft_minus_1_p2"|>, "definition" -> 
      HoldComplete[Limit[regularRegion, w -> 0, Direction -> "FromAbove"]], 
     "piece" -> <|"Power" -> -eps, "Regular" -> SeriesData[eps, 0, 
         {Pi/2, -1/2*(EulerGamma*Pi) + (Pi*(4 - 4*Log[2]))/4 - 
           (Pi*Log[Pi/4])/2, (Pi*(6*EulerGamma^2 - Pi^2))/24 + 
           (Pi*(-2*(-4 + Pi^2/6) - 8*Log[2] + 4*Log[2]^2))/4 - 
           (Pi*(4 - 4*Log[2])*Log[Pi/4])/4 + (Pi*Log[Pi/4]^2)/4 - 
           EulerGamma*((Pi*(4 - 4*Log[2]))/4 - (Pi*Log[Pi/4])/2)}, 0, 3, 
         1]|>|>, "R01_1_1_1_1_soft_plus_1" -> 
    <|"master" -> CutIntegral["R01", {1, 1, 1, 1}], "branch" -> 1, 
     "power" -> -1 - 2*eps, "coefficient_ids" -> 
      <|"-1" -> "R01_1_1_1_1_soft_plus_1_m1", 
       "0" -> "R01_1_1_1_1_soft_plus_1_p0", 
       "1" -> "R01_1_1_1_1_soft_plus_1_p1", 
       "2" -> "R01_1_1_1_1_soft_plus_1_p2"|>, "definition" -> 
      HoldComplete[Limit[regularRegion, w -> 0, Direction -> "FromAbove"]], 
     "piece" -> <|"Power" -> -1 - 2*eps, "Regular" -> SeriesData[eps, 0, 
         {Pi/(omega + Q2 - w), -((EulerGamma*Pi)/(omega + Q2 - w)) + 
           2*(-1/2*(Pi*Log[Pi])/(omega + Q2 - w) - 
             (Pi*Log[(omega + Q2 - w)/((omega - s - w)*(-s + w))])/
              (2*(omega + Q2 - w))), -1/12*(Pi*(-6*EulerGamma^2 - Pi^2))/
             (omega + Q2 - w) + (Pi*(6*EulerGamma^2 - Pi^2))/
            (3*(omega + Q2 - w)) - 4*EulerGamma*
            (-1/2*(Pi*Log[Pi])/(omega + Q2 - w) - (Pi*Log[(omega + Q2 - w)/
                 ((omega - s - w)*(-s + w))])/(2*(omega + Q2 - w))) + 
           2*((Pi^3/12 + (Pi*Log[Pi]^2)/4)/(omega + Q2 - w) + 
             (Pi*Log[Pi]*Log[(omega + Q2 - w)/((omega - s - w)*(-s + w))])/
              (2*(omega + Q2 - w)) + (Pi*Log[(omega + Q2 - w)/
                  ((omega - s - w)*(-s + w))]^2)/(4*(omega + Q2 - w))) - 
           EulerGamma*((2*EulerGamma*Pi)/(omega + Q2 - w) - 
             2*(-1/2*(Pi*Log[Pi])/(omega + Q2 - w) - (Pi*Log[(omega + Q2 - w)/
                   ((omega - s - w)*(-s + w))])/(2*(omega + Q2 - w))))}, -1, 
         2, 1], "Region" -> {0, -1}|>|>, "R01_1_1_1_1_soft_minus_1" -> 
    <|"master" -> CutIntegral["R01", {1, 1, 1, 1}], "branch" -> -1, 
     "power" -> -1 - 2*eps, "coefficient_ids" -> 
      <|"-1" -> "R01_1_1_1_1_soft_minus_1_m1", 
       "0" -> "R01_1_1_1_1_soft_minus_1_p0", 
       "1" -> "R01_1_1_1_1_soft_minus_1_p1", 
       "2" -> "R01_1_1_1_1_soft_minus_1_p2"|>, "definition" -> 
      HoldComplete[Limit[regularRegion, w -> 0, Direction -> "FromAbove"]], 
     "piece" -> <|"Power" -> -1 - 2*eps, "Regular" -> SeriesData[eps, 0, 
         {-(Pi/(omega - Q2 + w)), (EulerGamma*Pi)/(omega - Q2 + w) + 
           2*((Pi*Log[Pi])/(2*(omega - Q2 + w)) + (Pi*Log[(omega - Q2 + w)/
                 ((-s + w)*(omega + s + w))])/(2*(omega - Q2 + w))), 
          (Pi*(-6*EulerGamma^2 - Pi^2))/(12*(omega - Q2 + w)) - 
           (Pi*(6*EulerGamma^2 - Pi^2))/(3*(omega - Q2 + w)) - 
           4*EulerGamma*((Pi*Log[Pi])/(2*(omega - Q2 + w)) + 
             (Pi*Log[(omega - Q2 + w)/((-s + w)*(omega + s + w))])/
              (2*(omega - Q2 + w))) + 2*((-1/12*Pi^3 - (Pi*Log[Pi]^2)/4)/
              (omega - Q2 + w) - (Pi*Log[Pi]*Log[(omega - Q2 + w)/
                 ((-s + w)*(omega + s + w))])/(2*(omega - Q2 + w)) - 
             (Pi*Log[(omega - Q2 + w)/((-s + w)*(omega + s + w))]^2)/
              (4*(omega - Q2 + w))) - EulerGamma*((-2*EulerGamma*Pi)/
              (omega - Q2 + w) - 2*((Pi*Log[Pi])/(2*(omega - Q2 + w)) + 
               (Pi*Log[(omega - Q2 + w)/((-s + w)*(omega + s + w))])/
                (2*(omega - Q2 + w))))}, -1, 2, 1], "Region" -> {0, -1}|>|>, 
   "R02_1_1_1_1_soft_plus_1" -> 
    <|"master" -> CutIntegral["R02", {1, 1, 1, 1}], "branch" -> 1, 
     "power" -> -eps, "coefficient_ids" -> 
      <|"-1" -> "R02_1_1_1_1_soft_plus_1_m1", 
       "0" -> "R02_1_1_1_1_soft_plus_1_p0", 
       "1" -> "R02_1_1_1_1_soft_plus_1_p1", 
       "2" -> "R02_1_1_1_1_soft_plus_1_p2"|>, "definition" -> 
      HoldComplete[Limit[regularRegion, w -> 0, Direction -> "FromAbove"]], 
     "piece" -> <|"Power" -> -eps, "Regular" -> SeriesData[eps, 0, 
         {-(Pi/((omega - s)*s + Q2*w)), (EulerGamma*Pi)/((omega - s)*s + 
             Q2*w) + (2*((Pi*Log[Pi])/2 - (Pi*Log[-(((s - w)*(-omega + s + 
                     w))/((omega - s)*s + Q2*w))])/2))/((omega - s)*s + 
             Q2*w), (Pi*(-6*EulerGamma^2 - Pi^2))/(12*((omega - s)*s + 
              Q2*w)) - (Pi*(6*EulerGamma^2 - Pi^2))/
            (3*((omega - s)*s + Q2*w)) - (4*EulerGamma*((Pi*Log[Pi])/2 - 
              (Pi*Log[-(((s - w)*(-omega + s + w))/((omega - s)*s + Q2*w))])/
               2))/((omega - s)*s + Q2*w) - EulerGamma*
            ((-2*EulerGamma*Pi)/((omega - s)*s + Q2*w) - 
             (2*((Pi*Log[Pi])/2 - (Pi*Log[-(((s - w)*(-omega + s + w))/
                     ((omega - s)*s + Q2*w))])/2))/((omega - s)*s + Q2*w)) + 
           (2*(-1/4*(Pi*Log[Pi]^2) + (Pi*Log[Pi]*Log[-(((s - w)*(-omega + s + 
                     w))/((omega - s)*s + Q2*w))])/2 + 
              (Pi*(-1/2*Log[-(((s - w)*(-omega + s + w))/((omega - s)*s + 
                       Q2*w))]^2 - PolyLog[2, -((((omega - s)*s + Q2*w)*
                     (-1 - ((s - w)*(-omega + s + w))/((omega - s)*s + 
                        Q2*w)))/((s - w)*(-omega + s + w)))]))/2))/
            ((omega - s)*s + Q2*w)}, -1, 2, 1]|>|>, 
   "R02_1_1_1_1_soft_minus_1" -> 
    <|"master" -> CutIntegral["R02", {1, 1, 1, 1}], "branch" -> -1, 
     "power" -> -eps, "coefficient_ids" -> 
      <|"-1" -> "R02_1_1_1_1_soft_minus_1_m1", 
       "0" -> "R02_1_1_1_1_soft_minus_1_p0", 
       "1" -> "R02_1_1_1_1_soft_minus_1_p1", 
       "2" -> "R02_1_1_1_1_soft_minus_1_p2"|>, "definition" -> 
      HoldComplete[Limit[regularRegion, w -> 0, Direction -> "FromAbove"]], 
     "piece" -> <|"Power" -> -eps, "Regular" -> SeriesData[eps, 0, 
         {Pi/(s*(omega + s) - Q2*w), -((EulerGamma*Pi)/(s*(omega + s) - 
              Q2*w)) + (2*(-1/2*(Pi*Log[Pi]) + 
              (Pi*Log[-(((s - w)*(omega + s + w))/((-omega - s)*s + Q2*w))])/
               2))/(s*(omega + s) - Q2*w), 
          -1/12*(Pi*(-6*EulerGamma^2 - Pi^2))/(s*(omega + s) - Q2*w) + 
           (Pi*(6*EulerGamma^2 - Pi^2))/(3*(s*(omega + s) - Q2*w)) - 
           (4*EulerGamma*(-1/2*(Pi*Log[Pi]) + (Pi*Log[-(((s - w)*(omega + s + 
                     w))/((-omega - s)*s + Q2*w))])/2))/(s*(omega + s) - 
             Q2*w) - EulerGamma*((2*EulerGamma*Pi)/(s*(omega + s) - Q2*w) - 
             (2*(-1/2*(Pi*Log[Pi]) + (Pi*Log[-(((s - w)*(omega + s + w))/
                     ((-omega - s)*s + Q2*w))])/2))/(s*(omega + s) - Q2*w)) + 
           (2*((Pi*Log[Pi]^2)/4 - (Pi*Log[Pi]*Log[-(((s - w)*(omega + s + w))/
                   ((-omega - s)*s + Q2*w))])/2 + 
              (Pi*(Log[-(((s - w)*(omega + s + w))/((-omega - s)*s + Q2*w))]^
                   2/2 + PolyLog[2, -((((-omega - s)*s + Q2*w)*(-1 - 
                      ((s - w)*(omega + s + w))/((-omega - s)*s + Q2*w)))/
                    ((s - w)*(omega + s + w)))]))/2))/(s*(omega + s) - 
             Q2*w)}, -1, 2, 1]|>|>, "R03_1_1_0_1_soft_plus_1" -> 
    <|"master" -> CutIntegral["R03", {1, 1, 0, 1}], "branch" -> 1, 
     "power" -> -eps, "coefficient_ids" -> 
      <|"0" -> "R03_1_1_0_1_soft_plus_1_p0", 
       "1" -> "R03_1_1_0_1_soft_plus_1_p1", 
       "2" -> "R03_1_1_0_1_soft_plus_1_p2"|>, "definition" -> 
      HoldComplete[Limit[regularRegion, w -> 0, Direction -> "FromAbove"]], 
     "piece" -> <|"Power" -> -eps, "Regular" -> SeriesData[eps, 0, 
         {-1/2*(Pi*(1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^
                    2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^
                    2]))*Log[(1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                   (omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                   (omega + 2*Q2)^2])])/((omega + 2*Q2)*
             (-1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/(
                1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2]))), 
          (EulerGamma*Pi*(1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                   (omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                   (omega + 2*Q2)^2]))*Log[(1 - Sqrt[1 - (4*Q2*(omega + Q2 - 
                     w))/(omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - 
                     w))/(omega + 2*Q2)^2])])/(2*(omega + 2*Q2)*
             (-1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/(
                1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2]))) + 
           ((Pi*(1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/
                 (1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2]))*
               Log[Pi]*Log[(1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                     (omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                     (omega + 2*Q2)^2])])/(2*(-1 + 
                (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/
                 (1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2]))) + 
             Pi*(-(((1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^
                         2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                        (omega + 2*Q2)^2]))*Log[2]*Log[(1 - Sqrt[
                      1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/
                    (1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^
                         2])])/(-1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                       (omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - 
                         w))/(omega + 2*Q2)^2]))) + 
               ((1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/
                   (1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2]))*
                 (2*Log[4]*Log[(1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                         (omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - 
                          w))/(omega + 2*Q2)^2])] + 
                  Log[(1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^
                          2])/(1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/
                         (omega + 2*Q2)^2])]^2 + 4*PolyLog[2, 1 - 
                     (1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/
                      (1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^
                          2])]))/(4*(-1 + (1 - Sqrt[1 - (4*Q2*(omega + Q2 - 
                         w))/(omega + 2*Q2)^2])/(1 + Sqrt[1 - 
                      (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])))))/
            (omega + 2*Q2)}, 0, 2, 1]|>|>, "R03_1_1_0_1_soft_minus_1" -> 
    <|"master" -> CutIntegral["R03", {1, 1, 0, 1}], "branch" -> -1, 
     "power" -> -eps, "coefficient_ids" -> 
      <|"0" -> "R03_1_1_0_1_soft_minus_1_p0", 
       "1" -> "R03_1_1_0_1_soft_minus_1_p1", 
       "2" -> "R03_1_1_0_1_soft_minus_1_p2"|>, "definition" -> 
      HoldComplete[Limit[regularRegion, w -> 0, Direction -> "FromAbove"]], 
     "piece" -> <|"Power" -> -eps, "Regular" -> SeriesData[eps, 0, 
         {(Pi*(1 + (1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])/
              (1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2]))*
            Log[(1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])/
              (1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])])/
           (2*(omega - 2*Q2)*(-1 + (1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                  (-omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                  (-omega + 2*Q2)^2]))), 
          -1/2*(EulerGamma*Pi*(1 + (1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                    (-omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(-omega + Q2 - 
                      w))/(-omega + 2*Q2)^2]))*Log[(1 - Sqrt[
                  1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])/
                (1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])])/
             ((omega - 2*Q2)*(-1 + (1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                    (-omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(-omega + Q2 - 
                      w))/(-omega + 2*Q2)^2]))) + 
           (-1/2*(Pi*(1 + (1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                      (-omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(-omega + Q2 - 
                        w))/(-omega + 2*Q2)^2]))*Log[Pi]*
                Log[(1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^
                       2])/(1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                      (-omega + 2*Q2)^2])])/(-1 + (1 - Sqrt[1 - 
                    (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])/
                 (1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^
                      2])) + Pi*(((1 + (1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                       (-omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(-omega + Q2 - 
                         w))/(-omega + 2*Q2)^2]))*Log[2]*
                 Log[(1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^
                        2])/(1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                       (-omega + 2*Q2)^2])])/(-1 + (1 - Sqrt[1 - 
                     (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])/
                  (1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^
                       2])) - ((1 + (1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                       (-omega + 2*Q2)^2])/(1 + Sqrt[1 - (4*Q2*(-omega + Q2 - 
                         w))/(-omega + 2*Q2)^2]))*(2*Log[4]*Log[
                    (1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^
                          2])/(1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/
                         (-omega + 2*Q2)^2])] + Log[(1 - Sqrt[1 - 
                        (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])/
                     (1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^
                          2])]^2 + 4*PolyLog[2, 1 - (1 - Sqrt[1 - 
                         (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])/
                      (1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^
                          2])]))/(4*(-1 + (1 - Sqrt[1 - (4*Q2*(-omega + Q2 - 
                         w))/(-omega + 2*Q2)^2])/(1 + Sqrt[1 - 
                      (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])))))/
            (omega - 2*Q2)}, 0, 2, 1]|>|>, "R03_1_1_1_1_soft_plus_1" -> 
    <|"master" -> CutIntegral["R03", {1, 1, 1, 1}], "branch" -> 1, 
     "power" -> -eps, "coefficient_ids" -> 
      <|"-1" -> "R03_1_1_1_1_soft_plus_1_m1", 
       "0" -> "R03_1_1_1_1_soft_plus_1_p0", 
       "1" -> "R03_1_1_1_1_soft_plus_1_p1", 
       "2" -> "R03_1_1_1_1_soft_plus_1_p2"|>, "definition" -> 
      HoldComplete[Limit[regularRegion, w -> 0, Direction -> "FromAbove"]], 
     "piece" -> <|"Power" -> -eps, "Regular" -> SeriesData[eps, 0, 
         {Pi/(2*(omega*Q2 - s*w - Q2*(s + 2*w))), 
          -1/2*(EulerGamma*Pi)/(omega*Q2 - s*w - Q2*(s + 2*w)) + 
           (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((omega + 2*Q2)^2*(omega - s - w)^
                    2*(1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                       4*Q2*w)/(omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 
                       2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                  (4*(Q2*(omega - s) - 2*Q2*w - s*w)^2)])/4))/
            (omega*Q2 - s*w - Q2*(s + 2*w)), 
          -1/24*(Pi*(-6*EulerGamma^2 - Pi^2))/(omega*Q2 - s*w - 
              Q2*(s + 2*w)) + (Pi*(6*EulerGamma^2 - Pi^2))/
            (6*(omega*Q2 - s*w - Q2*(s + 2*w))) - 
           (4*EulerGamma*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((omega + 2*Q2)^2*
                   (omega - s - w)^2*(1 - Sqrt[((omega - s)^2 + 2*(omega - s)*
                        s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2])*(1 + 
                    Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                      (omega + 2*Q2)^2]))/(4*(Q2*(omega - s) - 2*Q2*w - s*w)^
                    2)])/4))/(omega*Q2 - s*w - Q2*(s + 2*w)) - 
           EulerGamma*((EulerGamma*Pi)/(omega*Q2 - s*w - Q2*(s + 2*w)) - 
             (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((omega + 2*Q2)^2*(omega - s - 
                       w)^2*(1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
                         s^2 + 4*Q2*w)/(omega + 2*Q2)^2])*(1 + Sqrt[
                       ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                        (omega + 2*Q2)^2]))/(4*(Q2*(omega - s) - 2*Q2*w - 
                       s*w)^2)])/4))/(omega*Q2 - s*w - Q2*(s + 2*w))) + 
           (2*((Pi*Log[Pi]^2)/8 - (Pi*Log[Pi]*Log[((omega + 2*Q2)^2*
                   (omega - s - w)^2*(1 - Sqrt[((omega - s)^2 + 2*(omega - s)*
                        s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2])*(1 + 
                    Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                      (omega + 2*Q2)^2]))/(4*(Q2*(omega - s) - 2*Q2*w - s*w)^
                    2)])/4 + (Pi*(Log[((omega + 2*Q2)^2*(omega - s - w)^2*
                      (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                          4*Q2*w)/(omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^
                          2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                          2]))/(4*(Q2*(omega - s) - 2*Q2*w - s*w)^2)]^2/4 + 
                 PolyLog[2, (2*(Q2*(omega - s) - 2*Q2*w - s*w)*(-1 + 
                     ((omega + 2*Q2)*(omega - s - w)*(1 - Sqrt[((omega - s)^
                          2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                          2]))/(2*(Q2*(omega - s) - 2*Q2*w - s*w))))/
                   ((omega + 2*Q2)*(omega - s - w)*(1 - Sqrt[((omega - s)^2 + 
                        2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                        2]))] + PolyLog[2, (2*(Q2*(omega - s) - 2*Q2*w - s*w)*
                    (-1 + ((omega + 2*Q2)*(omega - s - w)*(1 + Sqrt[
                         ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                          (omega + 2*Q2)^2]))/(2*(Q2*(omega - s) - 2*Q2*w - 
                        s*w))))/((omega + 2*Q2)*(omega - s - w)*(1 + 
                     Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                       (omega + 2*Q2)^2]))]))/2))/(omega*Q2 - s*w - 
             Q2*(s + 2*w))}, -1, 2, 1]|>|>, "R03_1_1_1_1_soft_minus_1" -> 
    <|"master" -> CutIntegral["R03", {1, 1, 1, 1}], "branch" -> -1, 
     "power" -> -eps, "coefficient_ids" -> 
      <|"-1" -> "R03_1_1_1_1_soft_minus_1_m1", 
       "0" -> "R03_1_1_1_1_soft_minus_1_p0", 
       "1" -> "R03_1_1_1_1_soft_minus_1_p1", 
       "2" -> "R03_1_1_1_1_soft_minus_1_p2"|>, "definition" -> 
      HoldComplete[Limit[regularRegion, w -> 0, Direction -> "FromAbove"]], 
     "piece" -> <|"Power" -> -eps, "Regular" -> SeriesData[eps, 0, 
         {-1/2*Pi/(Q2*(omega + s) + (2*Q2 + s)*w), 
          (EulerGamma*Pi)/(2*(Q2*(omega + s) + (2*Q2 + s)*w)) + 
           (2*((Pi*Log[Pi])/4 - (Pi*Log[((-omega + 2*Q2)^2*(-omega - s - w)^2*
                   (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                       4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^
                        2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                       2]))/(4*(Q2*(-omega - s) - 2*Q2*w - s*w)^2)])/4))/
            (Q2*(omega + s) + (2*Q2 + s)*w), (Pi*(-6*EulerGamma^2 - Pi^2))/
            (24*(Q2*(omega + s) + (2*Q2 + s)*w)) - 
           (Pi*(6*EulerGamma^2 - Pi^2))/(6*(Q2*(omega + s) + (2*Q2 + s)*w)) - 
           (4*EulerGamma*((Pi*Log[Pi])/4 - (Pi*Log[((-omega + 2*Q2)^2*
                   (-omega - s - w)^2*(1 - Sqrt[((-omega - s)^2 + 
                       2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^2])*
                   (1 + Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                       4*Q2*w)/(-omega + 2*Q2)^2]))/(4*(Q2*(-omega - s) - 
                     2*Q2*w - s*w)^2)])/4))/(Q2*(omega + s) + (2*Q2 + s)*w) - 
           EulerGamma*(-((EulerGamma*Pi)/(Q2*(omega + s) + (2*Q2 + s)*w)) - 
             (2*((Pi*Log[Pi])/4 - (Pi*Log[((-omega + 2*Q2)^2*(-omega - s - w)^
                      2*(1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                         4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[
                       ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                        (-omega + 2*Q2)^2]))/(4*(Q2*(-omega - s) - 2*Q2*w - 
                       s*w)^2)])/4))/(Q2*(omega + s) + (2*Q2 + s)*w)) + 
           (2*(-1/8*(Pi*Log[Pi]^2) + (Pi*Log[Pi]*Log[((-omega + 2*Q2)^2*
                   (-omega - s - w)^2*(1 - Sqrt[((-omega - s)^2 + 
                       2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^2])*
                   (1 + Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                       4*Q2*w)/(-omega + 2*Q2)^2]))/(4*(Q2*(-omega - s) - 
                     2*Q2*w - s*w)^2)])/4 + (Pi*(-1/4*Log[((-omega + 2*Q2)^2*
                      (-omega - s - w)^2*(1 - Sqrt[((-omega - s)^2 + 
                          2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                          2])*(1 + Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + 
                          s^2 + 4*Q2*w)/(-omega + 2*Q2)^2]))/
                     (4*(Q2*(-omega - s) - 2*Q2*w - s*w)^2)]^2 - PolyLog[2, 
                  (2*(Q2*(-omega - s) - 2*Q2*w - s*w)*(-1 + ((-omega + 2*Q2)*
                       (-omega - s - w)*(1 - Sqrt[((-omega - s)^2 + 
                          2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                          2]))/(2*(Q2*(-omega - s) - 2*Q2*w - s*w))))/
                   ((-omega + 2*Q2)*(-omega - s - w)*(1 - Sqrt[
                      ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                       (-omega + 2*Q2)^2]))] - PolyLog[2, 
                  (2*(Q2*(-omega - s) - 2*Q2*w - s*w)*(-1 + ((-omega + 2*Q2)*
                       (-omega - s - w)*(1 + Sqrt[((-omega - s)^2 + 
                          2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                          2]))/(2*(Q2*(-omega - s) - 2*Q2*w - s*w))))/
                   ((-omega + 2*Q2)*(-omega - s - w)*(1 + Sqrt[
                      ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                       (-omega + 2*Q2)^2]))]))/2))/(Q2*(omega + s) + 
             (2*Q2 + s)*w)}, -1, 2, 1]|>|>, "R04_1_1_1_1_soft_plus_1" -> 
    <|"master" -> CutIntegral["R04", {1, 1, 1, 1}], "branch" -> 1, 
     "power" -> -eps, "coefficient_ids" -> 
      <|"-1" -> "R04_1_1_1_1_soft_plus_1_m1", 
       "0" -> "R04_1_1_1_1_soft_plus_1_p0", 
       "1" -> "R04_1_1_1_1_soft_plus_1_p1", 
       "2" -> "R04_1_1_1_1_soft_plus_1_p2"|>, "definition" -> 
      HoldComplete[Limit[regularRegion, w -> 0, Direction -> "FromAbove"]], 
     "piece" -> <|"Power" -> -eps, "Regular" -> SeriesData[eps, 0, 
         {Pi/(2*(omega - s)*(omega + Q2 - w)), 
          -1/2*(EulerGamma*Pi)/((omega - s)*(omega + Q2 - w)) + 
           (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((omega + 2*Q2)^2*(omega - s - w)^
                    2*(1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                       4*Q2*w)/(omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 
                       2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                  (4*(omega - s)^2*(omega + Q2 - w)^2)])/4))/
            ((omega - s)*(omega + Q2 - w)), 
          -1/24*(Pi*(-6*EulerGamma^2 - Pi^2))/((omega - s)*(omega + Q2 - 
               w)) + (Pi*(6*EulerGamma^2 - Pi^2))/(6*(omega - s)*
             (omega + Q2 - w)) - (4*EulerGamma*(-1/4*(Pi*Log[Pi]) + 
              (Pi*Log[((omega + 2*Q2)^2*(omega - s - w)^2*(1 - Sqrt[
                     ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                      (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 
                       2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                  (4*(omega - s)^2*(omega + Q2 - w)^2)])/4))/
            ((omega - s)*(omega + Q2 - w)) - EulerGamma*
            ((EulerGamma*Pi)/((omega - s)*(omega + Q2 - w)) - 
             (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((omega + 2*Q2)^2*(omega - s - 
                       w)^2*(1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
                         s^2 + 4*Q2*w)/(omega + 2*Q2)^2])*(1 + Sqrt[
                       ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                        (omega + 2*Q2)^2]))/(4*(omega - s)^2*(omega + Q2 - w)^
                      2)])/4))/((omega - s)*(omega + Q2 - w))) + 
           (2*((Pi*Log[Pi]^2)/8 - (Pi*Log[Pi]*Log[((omega + 2*Q2)^2*
                   (omega - s - w)^2*(1 - Sqrt[((omega - s)^2 + 2*(omega - s)*
                        s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2])*(1 + 
                    Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                      (omega + 2*Q2)^2]))/(4*(omega - s)^2*(omega + Q2 - w)^
                    2)])/4 + (Pi*(Log[((omega + 2*Q2)^2*(omega - s - w)^2*
                      (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                          4*Q2*w)/(omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^
                          2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                          2]))/(4*(omega - s)^2*(omega + Q2 - w)^2)]^2/4 + 
                 PolyLog[2, (2*(omega - s)*(omega + Q2 - w)*(-1 + 
                     ((omega + 2*Q2)*(omega - s - w)*(1 - Sqrt[((omega - s)^
                          2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                          2]))/(2*(omega - s)*(omega + Q2 - w))))/
                   ((omega + 2*Q2)*(omega - s - w)*(1 - Sqrt[((omega - s)^2 + 
                        2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                        2]))] + PolyLog[2, (2*(omega - s)*(omega + Q2 - w)*
                    (-1 + ((omega + 2*Q2)*(omega - s - w)*(1 + Sqrt[
                         ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                          (omega + 2*Q2)^2]))/(2*(omega - s)*(omega + Q2 - 
                        w))))/((omega + 2*Q2)*(omega - s - w)*(1 + 
                     Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                       (omega + 2*Q2)^2]))]))/2))/((omega - s)*
             (omega + Q2 - w))}, -1, 2, 1]|>|>, "R04_1_1_1_1_soft_minus_1" -> 
    <|"master" -> CutIntegral["R04", {1, 1, 1, 1}], "branch" -> -1, 
     "power" -> -eps, "coefficient_ids" -> 
      <|"-1" -> "R04_1_1_1_1_soft_minus_1_m1", 
       "0" -> "R04_1_1_1_1_soft_minus_1_p0", 
       "1" -> "R04_1_1_1_1_soft_minus_1_p1", 
       "2" -> "R04_1_1_1_1_soft_minus_1_p2"|>, "definition" -> 
      HoldComplete[Limit[regularRegion, w -> 0, Direction -> "FromAbove"]], 
     "piece" -> <|"Power" -> -eps, "Regular" -> SeriesData[eps, 0, 
         {Pi/(2*(omega + s)*(omega - Q2 + w)), 
          -1/2*(EulerGamma*Pi)/((omega + s)*(omega - Q2 + w)) + 
           (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((-omega + 2*Q2)^2*(-omega - s - 
                     w)^2*(1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + 
                       s^2 + 4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[
                     ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                      (-omega + 2*Q2)^2]))/(4*(-omega - s)^2*(-omega + Q2 - 
                     w)^2)])/4))/((omega + s)*(omega - Q2 + w)), 
          -1/24*(Pi*(-6*EulerGamma^2 - Pi^2))/((omega + s)*(omega - Q2 + 
               w)) + (Pi*(6*EulerGamma^2 - Pi^2))/(6*(omega + s)*
             (omega - Q2 + w)) - (4*EulerGamma*(-1/4*(Pi*Log[Pi]) + 
              (Pi*Log[((-omega + 2*Q2)^2*(-omega - s - w)^2*(1 - 
                    Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                      (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
                       2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^2]))/
                  (4*(-omega - s)^2*(-omega + Q2 - w)^2)])/4))/
            ((omega + s)*(omega - Q2 + w)) - EulerGamma*
            ((EulerGamma*Pi)/((omega + s)*(omega - Q2 + w)) - 
             (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((-omega + 2*Q2)^2*(-omega - s - 
                       w)^2*(1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + 
                         s^2 + 4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[
                       ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                        (-omega + 2*Q2)^2]))/(4*(-omega - s)^2*(-omega + Q2 - 
                       w)^2)])/4))/((omega + s)*(omega - Q2 + w))) + 
           (2*((Pi*Log[Pi]^2)/8 - (Pi*Log[Pi]*Log[((-omega + 2*Q2)^2*
                   (-omega - s - w)^2*(1 - Sqrt[((-omega - s)^2 + 
                       2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^2])*
                   (1 + Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                       4*Q2*w)/(-omega + 2*Q2)^2]))/(4*(-omega - s)^2*
                   (-omega + Q2 - w)^2)])/4 + 
              (Pi*(Log[((-omega + 2*Q2)^2*(-omega - s - w)^2*(1 - Sqrt[
                        ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                         (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
                          2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                          2]))/(4*(-omega - s)^2*(-omega + Q2 - w)^2)]^2/4 + 
                 PolyLog[2, (2*(-omega - s)*(-omega + Q2 - w)*(-1 + 
                     ((-omega + 2*Q2)*(-omega - s - w)*(1 - Sqrt[
                         ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                          (-omega + 2*Q2)^2]))/(2*(-omega - s)*(-omega + Q2 - 
                        w))))/((-omega + 2*Q2)*(-omega - s - w)*(1 - 
                     Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                       (-omega + 2*Q2)^2]))] + PolyLog[2, (2*(-omega - s)*
                    (-omega + Q2 - w)*(-1 + ((-omega + 2*Q2)*(-omega - s - w)*
                       (1 + Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                          4*Q2*w)/(-omega + 2*Q2)^2]))/(2*(-omega - s)*
                       (-omega + Q2 - w))))/((-omega + 2*Q2)*(-omega - s - w)*
                    (1 + Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                        4*Q2*w)/(-omega + 2*Q2)^2]))]))/2))/
            ((omega + s)*(omega - Q2 + w))}, -1, 2, 1]|>|>, 
   "R09_1_1_1_1_soft_plus_1" -> 
    <|"master" -> CutIntegral["R09", {1, 1, 1, 1}], "branch" -> 1, 
     "power" -> -eps, "coefficient_ids" -> 
      <|"-1" -> "R09_1_1_1_1_soft_plus_1_m1", 
       "0" -> "R09_1_1_1_1_soft_plus_1_p0", 
       "1" -> "R09_1_1_1_1_soft_plus_1_p1", 
       "2" -> "R09_1_1_1_1_soft_plus_1_p2"|>, "definition" -> 
      HoldComplete[Limit[regularRegion, w -> 0, Direction -> "FromAbove"]], 
     "piece" -> <|"Power" -> -eps, "Regular" -> SeriesData[eps, 0, 
         {Pi/(2*(Q2*(s - 2*w) + (-omega + s)*w)), 
          -1/2*(EulerGamma*Pi)/(Q2*(s - 2*w) + (-omega + s)*w) + 
           (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((omega + 2*Q2)^2*(s - w)^2*
                   (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                      (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 
                       2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                  (4*(Q2*s - 2*Q2*w - (omega - s)*w)^2)])/4))/
            (Q2*(s - 2*w) + (-omega + s)*w), 
          -1/24*(Pi*(-6*EulerGamma^2 - Pi^2))/(Q2*(s - 2*w) + 
              (-omega + s)*w) + (Pi*(6*EulerGamma^2 - Pi^2))/
            (6*(Q2*(s - 2*w) + (-omega + s)*w)) - 
           (4*EulerGamma*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((omega + 2*Q2)^2*
                   (s - w)^2*(1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
                       s^2 + 4*Q2*w)/(omega + 2*Q2)^2])*(1 + Sqrt[
                     ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                      (omega + 2*Q2)^2]))/(4*(Q2*s - 2*Q2*w - (omega - s)*w)^
                    2)])/4))/(Q2*(s - 2*w) + (-omega + s)*w) - 
           EulerGamma*((EulerGamma*Pi)/(Q2*(s - 2*w) + (-omega + s)*w) - 
             (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((omega + 2*Q2)^2*(s - w)^2*
                     (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                         4*Q2*w)/(omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^
                          2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                         2]))/(4*(Q2*s - 2*Q2*w - (omega - s)*w)^2)])/4))/
              (Q2*(s - 2*w) + (-omega + s)*w)) + 
           (2*((Pi*Log[Pi]^2)/8 - (Pi*Log[Pi]*Log[((omega + 2*Q2)^2*(s - w)^2*
                   (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                      (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 
                       2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                  (4*(Q2*s - 2*Q2*w - (omega - s)*w)^2)])/4 + 
              (Pi*(Log[((omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[((omega - s)^2 + 
                          2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2])*
                      (1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                          4*Q2*w)/(omega + 2*Q2)^2]))/(4*(Q2*s - 2*Q2*w - 
                        (omega - s)*w)^2)]^2/4 + PolyLog[2, 
                  (2*(Q2*s - 2*Q2*w - (omega - s)*w)*(-1 + ((omega + 2*Q2)*
                       (s - w)*(1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
                          s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/(2*(Q2*s - 
                        2*Q2*w - (omega - s)*w))))/((omega + 2*Q2)*(s - w)*
                    (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                        4*Q2*w)/(omega + 2*Q2)^2]))] + PolyLog[2, 
                  (2*(Q2*s - 2*Q2*w - (omega - s)*w)*(-1 + ((omega + 2*Q2)*
                       (s - w)*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
                          s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/(2*(Q2*s - 
                        2*Q2*w - (omega - s)*w))))/((omega + 2*Q2)*(s - w)*
                    (1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                        4*Q2*w)/(omega + 2*Q2)^2]))]))/2))/
            (Q2*(s - 2*w) + (-omega + s)*w)}, -1, 2, 1]|>|>, 
   "R09_1_1_1_1_soft_minus_1" -> 
    <|"master" -> CutIntegral["R09", {1, 1, 1, 1}], "branch" -> -1, 
     "power" -> -eps, "coefficient_ids" -> 
      <|"-1" -> "R09_1_1_1_1_soft_minus_1_m1", 
       "0" -> "R09_1_1_1_1_soft_minus_1_p0", 
       "1" -> "R09_1_1_1_1_soft_minus_1_p1", 
       "2" -> "R09_1_1_1_1_soft_minus_1_p2"|>, "definition" -> 
      HoldComplete[Limit[regularRegion, w -> 0, Direction -> "FromAbove"]], 
     "piece" -> <|"Power" -> -eps, "Regular" -> SeriesData[eps, 0, 
         {Pi/(2*(Q2*(s - 2*w) + (omega + s)*w)), 
          -1/2*(EulerGamma*Pi)/(Q2*(s - 2*w) + (omega + s)*w) + 
           (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((-omega + 2*Q2)^2*(s - w)^2*
                   (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                       4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^
                        2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                       2]))/(4*(Q2*s - 2*Q2*w - (-omega - s)*w)^2)])/4))/
            (Q2*(s - 2*w) + (omega + s)*w), 
          -1/24*(Pi*(-6*EulerGamma^2 - Pi^2))/(Q2*(s - 2*w) + 
              (omega + s)*w) + (Pi*(6*EulerGamma^2 - Pi^2))/
            (6*(Q2*(s - 2*w) + (omega + s)*w)) - 
           (4*EulerGamma*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((-omega + 2*Q2)^2*
                   (s - w)^2*(1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + 
                       s^2 + 4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[
                     ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                      (-omega + 2*Q2)^2]))/(4*(Q2*s - 2*Q2*w - (-omega - s)*
                      w)^2)])/4))/(Q2*(s - 2*w) + (omega + s)*w) - 
           EulerGamma*((EulerGamma*Pi)/(Q2*(s - 2*w) + (omega + s)*w) - 
             (2*(-1/4*(Pi*Log[Pi]) + (Pi*Log[((-omega + 2*Q2)^2*(s - w)^2*
                     (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                         4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[
                       ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                        (-omega + 2*Q2)^2]))/(4*(Q2*s - 2*Q2*w - (-omega - s)*
                        w)^2)])/4))/(Q2*(s - 2*w) + (omega + s)*w)) + 
           (2*((Pi*Log[Pi]^2)/8 - (Pi*Log[Pi]*Log[((-omega + 2*Q2)^2*
                   (s - w)^2*(1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + 
                       s^2 + 4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[
                     ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                      (-omega + 2*Q2)^2]))/(4*(Q2*s - 2*Q2*w - (-omega - s)*
                      w)^2)])/4 + (Pi*(Log[((-omega + 2*Q2)^2*(s - w)^2*
                      (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                          4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[
                        ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                         (-omega + 2*Q2)^2]))/(4*(Q2*s - 2*Q2*w - 
                        (-omega - s)*w)^2)]^2/4 + PolyLog[2, 
                  (2*(Q2*s - 2*Q2*w - (-omega - s)*w)*(-1 + ((-omega + 2*Q2)*
                       (s - w)*(1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + 
                          s^2 + 4*Q2*w)/(-omega + 2*Q2)^2]))/(2*(Q2*s - 
                        2*Q2*w - (-omega - s)*w))))/((-omega + 2*Q2)*(s - w)*
                    (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                        4*Q2*w)/(-omega + 2*Q2)^2]))] + PolyLog[2, 
                  (2*(Q2*s - 2*Q2*w - (-omega - s)*w)*(-1 + ((-omega + 2*Q2)*
                       (s - w)*(1 + Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + 
                          s^2 + 4*Q2*w)/(-omega + 2*Q2)^2]))/(2*(Q2*s - 
                        2*Q2*w - (-omega - s)*w))))/((-omega + 2*Q2)*(s - w)*
                    (1 + Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                        4*Q2*w)/(-omega + 2*Q2)^2]))]))/2))/
            (Q2*(s - 2*w) + (omega + s)*w)}, -1, 2, 1]|>|>, 
   "R10_1_1_1_1_soft_plus_1" -> 
    <|"master" -> CutIntegral["R10", {1, 1, 1, 1}], "branch" -> 1, 
     "power" -> -eps, "coefficient_ids" -> 
      <|"-1" -> "R10_1_1_1_1_soft_plus_1_m1", 
       "0" -> "R10_1_1_1_1_soft_plus_1_p0", 
       "1" -> "R10_1_1_1_1_soft_plus_1_p1", 
       "2" -> "R10_1_1_1_1_soft_plus_1_p2"|>, "definition" -> 
      HoldComplete[Limit[regularRegion, w -> 0, Direction -> "FromAbove"]], 
     "piece" -> <|"Power" -> -eps, "Regular" -> SeriesData[eps, 0, 
         {Pi/(2*s*(omega + Q2 - w)), -1/2*(EulerGamma*Pi)/
             (s*(omega + Q2 - w)) + (2*(-1/4*(Pi*Log[Pi]) + 
              (Pi*Log[((omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[((omega - s)^2 + 
                       2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2])*
                   (1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                      (omega + 2*Q2)^2]))/(4*s^2*(omega + Q2 - w)^2)])/4))/
            (s*(omega + Q2 - w)), -1/24*(Pi*(-6*EulerGamma^2 - Pi^2))/
             (s*(omega + Q2 - w)) + (Pi*(6*EulerGamma^2 - Pi^2))/
            (6*s*(omega + Q2 - w)) - (4*EulerGamma*(-1/4*(Pi*Log[Pi]) + 
              (Pi*Log[((omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[((omega - s)^2 + 
                       2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2])*
                   (1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                      (omega + 2*Q2)^2]))/(4*s^2*(omega + Q2 - w)^2)])/4))/
            (s*(omega + Q2 - w)) - EulerGamma*((EulerGamma*Pi)/
              (s*(omega + Q2 - w)) - (2*(-1/4*(Pi*Log[Pi]) + 
                (Pi*Log[((omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[((omega - s)^
                          2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^
                         2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
                         s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/(4*s^2*
                     (omega + Q2 - w)^2)])/4))/(s*(omega + Q2 - w))) + 
           (2*((Pi*Log[Pi]^2)/8 - (Pi*Log[Pi]*Log[((omega + 2*Q2)^2*(s - w)^2*
                   (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                      (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 
                       2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                  (4*s^2*(omega + Q2 - w)^2)])/4 + 
              (Pi*(Log[((omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[((omega - s)^2 + 
                          2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2])*
                      (1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                          4*Q2*w)/(omega + 2*Q2)^2]))/(4*s^2*(omega + Q2 - w)^
                       2)]^2/4 + PolyLog[2, (2*s*(omega + Q2 - w)*
                    (-1 + ((omega + 2*Q2)*(s - w)*(1 - Sqrt[((omega - s)^2 + 
                          2*(omega - s)*s + s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
                      (2*s*(omega + Q2 - w))))/((omega + 2*Q2)*(s - w)*
                    (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                        4*Q2*w)/(omega + 2*Q2)^2]))] + PolyLog[2, 
                  (2*s*(omega + Q2 - w)*(-1 + ((omega + 2*Q2)*(s - w)*
                       (1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 
                          4*Q2*w)/(omega + 2*Q2)^2]))/(2*s*(omega + Q2 - 
                        w))))/((omega + 2*Q2)*(s - w)*(1 + Sqrt[
                      ((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
                       (omega + 2*Q2)^2]))]))/2))/(s*(omega + Q2 - w))}, -1, 
         2, 1]|>|>, "R10_1_1_1_1_soft_minus_1" -> 
    <|"master" -> CutIntegral["R10", {1, 1, 1, 1}], "branch" -> -1, 
     "power" -> -eps, "coefficient_ids" -> 
      <|"-1" -> "R10_1_1_1_1_soft_minus_1_m1", 
       "0" -> "R10_1_1_1_1_soft_minus_1_p0", 
       "1" -> "R10_1_1_1_1_soft_minus_1_p1", 
       "2" -> "R10_1_1_1_1_soft_minus_1_p2"|>, "definition" -> 
      HoldComplete[Limit[regularRegion, w -> 0, Direction -> "FromAbove"]], 
     "piece" -> <|"Power" -> -eps, "Regular" -> SeriesData[eps, 0, 
         {-1/2*Pi/(s*(omega - Q2 + w)), (EulerGamma*Pi)/
            (2*s*(omega - Q2 + w)) + (2*((Pi*Log[Pi])/4 - 
              (Pi*Log[((-omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[((-omega - s)^
                        2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                       2])*(1 + Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + 
                       s^2 + 4*Q2*w)/(-omega + 2*Q2)^2]))/(4*s^2*
                   (-omega + Q2 - w)^2)])/4))/(s*(omega - Q2 + w)), 
          (Pi*(-6*EulerGamma^2 - Pi^2))/(24*s*(omega - Q2 + w)) - 
           (Pi*(6*EulerGamma^2 - Pi^2))/(6*s*(omega - Q2 + w)) - 
           (4*EulerGamma*((Pi*Log[Pi])/4 - (Pi*Log[((-omega + 2*Q2)^2*
                   (s - w)^2*(1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + 
                       s^2 + 4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[
                     ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                      (-omega + 2*Q2)^2]))/(4*s^2*(-omega + Q2 - w)^2)])/4))/
            (s*(omega - Q2 + w)) - EulerGamma*
            (-((EulerGamma*Pi)/(s*(omega - Q2 + w))) - 
             (2*((Pi*Log[Pi])/4 - (Pi*Log[((-omega + 2*Q2)^2*(s - w)^2*
                     (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                         4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[
                       ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                        (-omega + 2*Q2)^2]))/(4*s^2*(-omega + Q2 - w)^2)])/
                 4))/(s*(omega - Q2 + w))) + 
           (2*(-1/8*(Pi*Log[Pi]^2) + (Pi*Log[Pi]*Log[((-omega + 2*Q2)^2*
                   (s - w)^2*(1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + 
                       s^2 + 4*Q2*w)/(-omega + 2*Q2)^2])*(1 + Sqrt[
                     ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                      (-omega + 2*Q2)^2]))/(4*s^2*(-omega + Q2 - w)^2)])/4 + 
              (Pi*(-1/4*Log[((-omega + 2*Q2)^2*(s - w)^2*(1 - Sqrt[
                        ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                         (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
                          2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                          2]))/(4*s^2*(-omega + Q2 - w)^2)]^2 - PolyLog[2, 
                  (2*s*(-omega + Q2 - w)*(-1 + ((-omega + 2*Q2)*(s - w)*
                       (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
                          4*Q2*w)/(-omega + 2*Q2)^2]))/(2*s*(-omega + Q2 - 
                        w))))/((-omega + 2*Q2)*(s - w)*(1 - Sqrt[
                      ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                       (-omega + 2*Q2)^2]))] - PolyLog[2, (2*s*(-omega + Q2 - 
                     w)*(-1 + ((-omega + 2*Q2)*(s - w)*(1 + Sqrt[
                         ((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
                          (-omega + 2*Q2)^2]))/(2*s*(-omega + Q2 - w))))/
                   ((-omega + 2*Q2)*(s - w)*(1 + Sqrt[((-omega - s)^2 + 
                        2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^
                        2]))]))/2))/(s*(omega - Q2 + w))}, -1, 2, 1]|>|>|>, 
 "reconstruction_residuals" -> <|"R01_1_1_0_0_ordinary" -> 0, 
   "R01_1_1_0_0_soft_plus_1" -> 0, "R01_1_1_0_0_soft_minus_1" -> 0, 
   "R01_1_1_1_1_ordinary" -> 0, "R01_1_1_1_1_soft_plus_1" -> 0, 
   "R01_1_1_1_1_soft_minus_1" -> 0, "R02_1_1_1_1_ordinary" -> 0, 
   "R02_1_1_1_1_soft_plus_1" -> 0, "R02_1_1_1_1_soft_minus_1" -> 0, 
   "R03_1_1_0_1_ordinary" -> 0, "R03_1_1_0_1_soft_plus_1" -> 0, 
   "R03_1_1_0_1_soft_minus_1" -> 0, "R03_1_1_1_1_ordinary" -> 0, 
   "R03_1_1_1_1_soft_plus_1" -> 0, "R03_1_1_1_1_soft_minus_1" -> 0, 
   "R04_1_1_1_1_ordinary" -> 0, "R04_1_1_1_1_soft_plus_1" -> 0, 
   "R04_1_1_1_1_soft_minus_1" -> 0, "R09_1_1_1_1_ordinary" -> 0, 
   "R09_1_1_1_1_soft_plus_1" -> 0, "R09_1_1_1_1_soft_minus_1" -> 0, 
   "R10_1_1_1_1_ordinary" -> 0, "R10_1_1_1_1_soft_plus_1" -> 0, 
   "R10_1_1_1_1_soft_minus_1" -> 0|>, 
 "measure" -> "d^D r delta_plus(r^2) delta_plus((P-r)^2); no 2 pi factors", 
 "source_sha256" -> <|"/bigTMD/collins_support/reports/sidis-highpt-001/conti\
nuation-001/real-qgg-kira-check-001/reduction.wl" -> 
    "5a7dbcb2fda0c7b4e9aab2180ed81e79b5fadd7c09d918c82b086d265d77fb29", 
   "/bigTMD/collins_support/reports/sidis-highpt-001/continuation-001/real-sa\
me-kira-check-001/reduction.wl" -> 
    "a51ffb4f4daeb1396a18c79a4696bd8b579093e45993bce1bfbebefd3c70c668", 
   "/bigTMD/collins_support/reports/sidis-highpt-001/continuation-001/real-di\
stinct-kira-check-001/reduction.wl" -> 
    "7430d1979cb4713bbedb87d637fa7c106f19987134287f48fe3402d0e72ecaf3", 
   "/bigTMD/collins_support/reports/sidis-highpt-001/continuation-001/real-hq\
qbar-kira-check-001/reduction.wl" -> 
    "30240a0811399df79141c57d9f0988a8d5e4f210ce9b121407cbb4d97fef7289", 
   "/bigTMD/collins_sidis_highpt/common/cut_distribution.wl" -> 
    "bbe397ee2e6a0d7a2c105dd03b480063576a7f498bb68b55d742b6e0fdfdd459", 
   "/bigTMD/collins_sidis_highpt/tools/prepare_real_master_coefficients.wls" \
-> "2e6506bb2e8535eac9f5f464e2a6fe83dfa9f4faa7638ffbe616797a1ceec434", 
   "/bigTMD/SIDIS/common/s08_result/s08_result.wl" -> 
    "76b97660cedd87b8c9dbcf5cb3b46ae8a95835e30ba0bcab7b67c3c78ffcf755", 
   "/bigTMD/SIDIS/common/s10_result/s10_result.wl" -> 
    "dba9edd52b6cc80846a08f65ec2b98b908a4d7a429edff359dd3a460c597a253", 
   "/bigTMD/SIDIS/common/s15_result/s15_result.wl" -> 
    "82cb3ca0de4501b3c045d025e6b93f4228426c344023b2a727fc93d69615ef0b"|>, 
 "qualification" -> "Exact archived master Laurent/endpoint selections with \
explicit branch-coordinate views. No hard coefficient loaded or integral \
evaluated.", "branch_views" -> <|"R01_1_1_0_0_ordinary_plus" -> 
    <|"minimum_power" -> 0, "available_through" -> 1, 
     "coefficient_ids" -> <|"0" -> "R01_1_1_0_0_ordinary_p0_plus", 
       "1" -> "R01_1_1_0_0_ordinary_p1_plus"|>, "source_series" -> 
      "R01_1_1_0_0_ordinary", "coordinate_map" -> t -> omega - s, 
     "domain" -> Q2 > 0 && s > w > 0 && omega > 0 && 
       -Q2 - s + w < omega - s < -((Q2*w)/s)|>, 
   "R01_1_1_0_0_ordinary_minus" -> <|"minimum_power" -> 0, 
     "available_through" -> 1, "coefficient_ids" -> 
      <|"0" -> "R01_1_1_0_0_ordinary_p0_minus", 
       "1" -> "R01_1_1_0_0_ordinary_p1_minus"|>, "source_series" -> 
      "R01_1_1_0_0_ordinary", "coordinate_map" -> t -> -omega - s, 
     "domain" -> Q2 > 0 && s > w > 0 && omega > 0 && 
       -Q2 - s + w < -omega - s < -((Q2*w)/s)|>, 
   "R01_1_1_1_1_ordinary_plus" -> <|"minimum_power" -> -1, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"-1" -> "R01_1_1_1_1_ordinary_m1_plus", 
       "0" -> "R01_1_1_1_1_ordinary_p0_plus"|>, "source_series" -> 
      "R01_1_1_1_1_ordinary", "coordinate_map" -> t -> omega - s, 
     "domain" -> Q2 > 0 && s > w > 0 && omega > 0 && 
       -Q2 - s + w < omega - s < -((Q2*w)/s)|>, 
   "R01_1_1_1_1_ordinary_minus" -> <|"minimum_power" -> -1, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"-1" -> "R01_1_1_1_1_ordinary_m1_minus", 
       "0" -> "R01_1_1_1_1_ordinary_p0_minus"|>, "source_series" -> 
      "R01_1_1_1_1_ordinary", "coordinate_map" -> t -> -omega - s, 
     "domain" -> Q2 > 0 && s > w > 0 && omega > 0 && 
       -Q2 - s + w < -omega - s < -((Q2*w)/s)|>, 
   "R02_1_1_1_1_ordinary_plus" -> <|"minimum_power" -> -1, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"-1" -> "R02_1_1_1_1_ordinary_m1_plus", 
       "0" -> "R02_1_1_1_1_ordinary_p0_plus"|>, "source_series" -> 
      "R02_1_1_1_1_ordinary", "coordinate_map" -> t -> omega - s, 
     "domain" -> Q2 > 0 && s > w > 0 && omega > 0 && 
       -Q2 - s + w < omega - s < -((Q2*w)/s)|>, 
   "R02_1_1_1_1_ordinary_minus" -> <|"minimum_power" -> -1, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"-1" -> "R02_1_1_1_1_ordinary_m1_minus", 
       "0" -> "R02_1_1_1_1_ordinary_p0_minus"|>, "source_series" -> 
      "R02_1_1_1_1_ordinary", "coordinate_map" -> t -> -omega - s, 
     "domain" -> Q2 > 0 && s > w > 0 && omega > 0 && 
       -Q2 - s + w < -omega - s < -((Q2*w)/s)|>, 
   "R03_1_1_0_1_ordinary_plus" -> <|"minimum_power" -> 0, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"0" -> "R03_1_1_0_1_ordinary_p0_plus"|>, "source_series" -> 
      "R03_1_1_0_1_ordinary", "coordinate_map" -> t -> omega - s, 
     "domain" -> Q2 > 0 && s > w > 0 && omega > 0 && 
       -Q2 - s + w < omega - s < -((Q2*w)/s)|>, 
   "R03_1_1_0_1_ordinary_minus" -> <|"minimum_power" -> 0, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"0" -> "R03_1_1_0_1_ordinary_p0_minus"|>, "source_series" -> 
      "R03_1_1_0_1_ordinary", "coordinate_map" -> t -> -omega - s, 
     "domain" -> Q2 > 0 && s > w > 0 && omega > 0 && 
       -Q2 - s + w < -omega - s < -((Q2*w)/s)|>, 
   "R03_1_1_1_1_ordinary_plus" -> <|"minimum_power" -> -1, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"-1" -> "R03_1_1_1_1_ordinary_m1_plus", 
       "0" -> "R03_1_1_1_1_ordinary_p0_plus"|>, "source_series" -> 
      "R03_1_1_1_1_ordinary", "coordinate_map" -> t -> omega - s, 
     "domain" -> Q2 > 0 && s > w > 0 && omega > 0 && 
       -Q2 - s + w < omega - s < -((Q2*w)/s)|>, 
   "R03_1_1_1_1_ordinary_minus" -> <|"minimum_power" -> -1, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"-1" -> "R03_1_1_1_1_ordinary_m1_minus", 
       "0" -> "R03_1_1_1_1_ordinary_p0_minus"|>, "source_series" -> 
      "R03_1_1_1_1_ordinary", "coordinate_map" -> t -> -omega - s, 
     "domain" -> Q2 > 0 && s > w > 0 && omega > 0 && 
       -Q2 - s + w < -omega - s < -((Q2*w)/s)|>, 
   "R04_1_1_1_1_ordinary_plus" -> <|"minimum_power" -> -1, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"-1" -> "R04_1_1_1_1_ordinary_m1_plus", 
       "0" -> "R04_1_1_1_1_ordinary_p0_plus"|>, "source_series" -> 
      "R04_1_1_1_1_ordinary", "coordinate_map" -> t -> omega - s, 
     "domain" -> Q2 > 0 && s > w > 0 && omega > 0 && 
       -Q2 - s + w < omega - s < -((Q2*w)/s)|>, 
   "R04_1_1_1_1_ordinary_minus" -> <|"minimum_power" -> -1, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"-1" -> "R04_1_1_1_1_ordinary_m1_minus", 
       "0" -> "R04_1_1_1_1_ordinary_p0_minus"|>, "source_series" -> 
      "R04_1_1_1_1_ordinary", "coordinate_map" -> t -> -omega - s, 
     "domain" -> Q2 > 0 && s > w > 0 && omega > 0 && 
       -Q2 - s + w < -omega - s < -((Q2*w)/s)|>, 
   "R09_1_1_1_1_ordinary_plus" -> <|"minimum_power" -> -1, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"-1" -> "R09_1_1_1_1_ordinary_m1_plus", 
       "0" -> "R09_1_1_1_1_ordinary_p0_plus"|>, "source_series" -> 
      "R09_1_1_1_1_ordinary", "coordinate_map" -> t -> omega - s, 
     "domain" -> Q2 > 0 && s > w > 0 && omega > 0 && 
       -Q2 - s + w < omega - s < -((Q2*w)/s)|>, 
   "R09_1_1_1_1_ordinary_minus" -> <|"minimum_power" -> -1, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"-1" -> "R09_1_1_1_1_ordinary_m1_minus", 
       "0" -> "R09_1_1_1_1_ordinary_p0_minus"|>, "source_series" -> 
      "R09_1_1_1_1_ordinary", "coordinate_map" -> t -> -omega - s, 
     "domain" -> Q2 > 0 && s > w > 0 && omega > 0 && 
       -Q2 - s + w < -omega - s < -((Q2*w)/s)|>, 
   "R10_1_1_1_1_ordinary_plus" -> <|"minimum_power" -> -1, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"-1" -> "R10_1_1_1_1_ordinary_m1_plus", 
       "0" -> "R10_1_1_1_1_ordinary_p0_plus"|>, "source_series" -> 
      "R10_1_1_1_1_ordinary", "coordinate_map" -> t -> omega - s, 
     "domain" -> Q2 > 0 && s > w > 0 && omega > 0 && 
       -Q2 - s + w < omega - s < -((Q2*w)/s)|>, 
   "R10_1_1_1_1_ordinary_minus" -> <|"minimum_power" -> -1, 
     "available_through" -> 0, "coefficient_ids" -> 
      <|"-1" -> "R10_1_1_1_1_ordinary_m1_minus", 
       "0" -> "R10_1_1_1_1_ordinary_p0_minus"|>, "source_series" -> 
      "R10_1_1_1_1_ordinary", "coordinate_map" -> t -> -omega - s, 
     "domain" -> Q2 > 0 && s > w > 0 && omega > 0 && 
       -Q2 - s + w < -omega - s < -((Q2*w)/s)|>|>, 
 "branch_view_reconstruction_residuals" -> 
  <|"R01_1_1_0_0_ordinary_plus" -> 0, "R01_1_1_0_0_ordinary_minus" -> 0, 
   "R01_1_1_1_1_ordinary_plus" -> 0, "R01_1_1_1_1_ordinary_minus" -> 0, 
   "R02_1_1_1_1_ordinary_plus" -> 0, "R02_1_1_1_1_ordinary_minus" -> 0, 
   "R03_1_1_0_1_ordinary_plus" -> 0, "R03_1_1_0_1_ordinary_minus" -> 0, 
   "R03_1_1_1_1_ordinary_plus" -> 0, "R03_1_1_1_1_ordinary_minus" -> 0, 
   "R04_1_1_1_1_ordinary_plus" -> 0, "R04_1_1_1_1_ordinary_minus" -> 0, 
   "R09_1_1_1_1_ordinary_plus" -> 0, "R09_1_1_1_1_ordinary_minus" -> 0, 
   "R10_1_1_1_1_ordinary_plus" -> 0, "R10_1_1_1_1_ordinary_minus" -> 0|>, 
 "view_source_sha256" -> <|"/bigTMD/collins_support/reports/sidis-highpt-001/\
continuation-001/real-portable-002/portable-real.wl" -> 
    "2e9b52611454b5b8ed31faf1150d338eaa0e18afa9e7accf0e18f451a6391932", 
   "/bigTMD/collins_sidis_highpt/tools/prepare_master_branch_views.wls" -> 
    "d958723d086d563e11370ee909414f9959b8ddecc738218ce911d0ca5453a58f"|>, 
 "original_values_before_transport_conversion" -> 
  <|"R01_1_1_0_0_ordinary_p0" -> Pi/2, "R01_1_1_0_0_ordinary_p1" -> 
    (2*Pi - EulerGamma*Pi - Pi*Log[Pi] - Pi*Log[w])/2, 
   "R01_1_1_0_0_soft_plus_1_p0" -> Pi/2, "R01_1_1_0_0_soft_plus_1_p1" -> 
    -1/2*(Pi*(-2 + EulerGamma + Log[Pi])), "R01_1_1_0_0_soft_plus_1_p2" -> 
    -1/8*(Pi*(Pi^2 + 8*(-2 + Log[Pi]) - 
       2*(EulerGamma^2 + 2*EulerGamma*(-2 + Log[Pi]) + Log[Pi]^2))), 
   "R01_1_1_0_0_soft_minus_1_p0" -> Pi/2, "R01_1_1_0_0_soft_minus_1_p1" -> 
    -1/2*(Pi*(-2 + EulerGamma + Log[Pi])), "R01_1_1_0_0_soft_minus_1_p2" -> 
    -1/8*(Pi*(Pi^2 + 8*(-2 + Log[Pi]) - 
       2*(EulerGamma^2 + 2*EulerGamma*(-2 + Log[Pi]) + Log[Pi]^2))), 
   "R01_1_1_1_1_ordinary_m1" -> -(Pi/(w*(-Q2 - s - t + w))), 
   "R01_1_1_1_1_ordinary_p0" -> (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
      Pi*Log[((s - w)*(-t + w))/((Q2 + s + t - w)*w)])/(w*(-Q2 - s - t + w)), 
   "R01_1_1_1_1_soft_plus_1_m1" -> Pi/(omega + Q2), 
   "R01_1_1_1_1_soft_plus_1_p0" -> 
    -((Pi*(EulerGamma + Log[Pi] + Log[-((omega + Q2)/(omega*s - s^2))]))/
      (omega + Q2)), "R01_1_1_1_1_soft_plus_1_p1" -> 
    (Pi*(-Pi^2 + 6*(EulerGamma + Log[Pi])^2 + 
       6*Log[-((omega + Q2)/(omega*s - s^2))]*(2*(EulerGamma + Log[Pi]) + 
         Log[-((omega + Q2)/(omega*s - s^2))])))/(12*(omega + Q2)), 
   "R01_1_1_1_1_soft_plus_1_p2" -> 0, "R01_1_1_1_1_soft_minus_1_m1" -> 
    -(Pi/(omega - Q2)), "R01_1_1_1_1_soft_minus_1_p0" -> 
    (Pi*(EulerGamma + Log[Pi] - Log[-((s*(omega + s))/(omega - Q2))]))/
     (omega - Q2), "R01_1_1_1_1_soft_minus_1_p1" -> 
    (Pi*(Pi^2 - 6*(EulerGamma + Log[Pi])^2 - 
       6*Log[-((s*(omega + s))/(omega - Q2))]*(-2*(EulerGamma + Log[Pi]) + 
         Log[-((s*(omega + s))/(omega - Q2))])))/(12*(omega - Q2)), 
   "R01_1_1_1_1_soft_minus_1_p2" -> 0, "R02_1_1_1_1_ordinary_m1" -> 
    -(Pi/(s*t + Q2*w)), "R02_1_1_1_1_ordinary_p0" -> 
    (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
      Pi*Log[-(((s - w)*(-t + w))/(s*t + Q2*w))])/(s*t + Q2*w), 
   "R02_1_1_1_1_soft_plus_1_m1" -> -(Pi/((omega - s)*s)), 
   "R02_1_1_1_1_soft_plus_1_p0" -> (Pi*(EulerGamma + Log[Pi]))/
     ((omega - s)*s), "R02_1_1_1_1_soft_plus_1_p1" -> 
    (Pi*(Pi^2 - 2*(EulerGamma + Log[Pi])^2))/(4*(omega - s)*s), 
   "R02_1_1_1_1_soft_plus_1_p2" -> 0, "R02_1_1_1_1_soft_minus_1_m1" -> 
    Pi/(s*(omega + s)), "R02_1_1_1_1_soft_minus_1_p0" -> 
    -((Pi*(EulerGamma + Log[Pi]))/(s*(omega + s))), 
   "R02_1_1_1_1_soft_minus_1_p1" -> (Pi*(-Pi^2 + 2*(EulerGamma + Log[Pi])^2))/
     (4*s*(omega + s)), "R02_1_1_1_1_soft_minus_1_p2" -> 0, 
   "R03_1_1_0_1_ordinary_p0" -> 
    (Pi*Log[(1 - Sqrt[1 - (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2])/
        (1 + Sqrt[1 - (4*Q2*(Q2 + s + t - w))/(2*Q2 + s + t)^2])])/
     (2*(2*Q2 + s + t)*Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2]), 
   "R03_1_1_0_1_soft_plus_1_p0" -> (Pi*Log[Q2/(omega + Q2)])/(2*omega), 
   "R03_1_1_0_1_soft_plus_1_p1" -> 
    (Pi*Log[Q2/(omega + Q2)]*(-2*(EulerGamma + Log[Pi]) + 
        Log[(omega + Q2)/Q2]) - 4*Pi*PolyLog[2, omega/(omega + Q2)])/
     (4*omega), "R03_1_1_0_1_soft_plus_1_p2" -> 0, 
   "R03_1_1_0_1_soft_minus_1_p0" -> (Pi*Log[1 - omega/Q2])/(2*omega), 
   "R03_1_1_0_1_soft_minus_1_p1" -> 
    (-2*Pi*(EulerGamma + ArcTanh[omega/(omega - 2*Q2)] + Log[Pi])*
       Log[1 - omega/Q2] - 4*Pi*PolyLog[2, omega/Q2])/(4*omega), 
   "R03_1_1_0_1_soft_minus_1_p2" -> 0, "R03_1_1_1_1_ordinary_m1" -> 
    Pi/(2*(Q2*t - 2*Q2*w - s*w)), "R03_1_1_1_1_ordinary_p0" -> 
    (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((2*Q2 + s + t)^2*(t - w)^2*
          (1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2])*
          (1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2]))/
         (4*(Q2*t - 2*Q2*w - s*w)^2)])/(2*(Q2*t - 2*Q2*w - s*w)), 
   "R03_1_1_1_1_soft_plus_1_m1" -> Pi/(2*Q2*(omega - s)), 
   "R03_1_1_1_1_soft_plus_1_p0" -> 
    -1/2*(Pi*(EulerGamma + Log[(Pi*Q2)/(omega + Q2)]))/(Q2*(omega - s)), 
   "R03_1_1_1_1_soft_plus_1_p1" -> 
    -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 
        4*EulerGamma*Log[(Pi*Q2)/(omega + Q2)] - 2*Log[Q2/(omega + Q2)]*
         Log[(Pi^2*Q2)/(omega + Q2)] - 8*PolyLog[2, omega/(omega + Q2)]))/
      (Q2*(omega - s)), "R03_1_1_1_1_soft_plus_1_p2" -> 0, 
   "R03_1_1_1_1_soft_minus_1_m1" -> -1/2*Pi/(Q2*(omega + s)), 
   "R03_1_1_1_1_soft_minus_1_p0" -> 
    (Pi*(EulerGamma + Log[-((Pi*Q2)/(omega - Q2))]))/(2*Q2*(omega + s)), 
   "R03_1_1_1_1_soft_minus_1_p1" -> 
    (Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 4*EulerGamma*
        Log[-((Pi*Q2)/(omega - Q2))] - 2*Log[-(Q2/(omega - Q2))]*
        Log[-((Pi^2*Q2)/(omega - Q2))] - 8*PolyLog[2, omega/(omega - Q2)]))/
     (8*Q2*(omega + s)), "R03_1_1_1_1_soft_minus_1_p2" -> 0, 
   "R04_1_1_1_1_ordinary_m1" -> Pi/(2*t*(Q2 + s + t - w)), 
   "R04_1_1_1_1_ordinary_p0" -> (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((2*Q2 + s + t)^2*(t - w)^2*
          (1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2])*
          (1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2]))/
         (4*t^2*(Q2 + s + t - w)^2)])/(2*t*(Q2 + s + t - w)), 
   "R04_1_1_1_1_soft_plus_1_m1" -> Pi/(2*(omega + Q2)*(omega - s)), 
   "R04_1_1_1_1_soft_plus_1_p0" -> 
    -1/2*(Pi*(EulerGamma + Log[(Pi*(omega + Q2))/Q2]))/
      ((omega + Q2)*(omega - s)), "R04_1_1_1_1_soft_plus_1_p1" -> 
    -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 
        4*Log[Pi]*Log[(omega + Q2)/Q2] - 2*Log[(omega + Q2)/Q2]^2 - 
        4*EulerGamma*Log[(Pi*(omega + Q2))/Q2] - 8*PolyLog[2, -(omega/Q2)]))/
      ((omega + Q2)*(omega - s)), "R04_1_1_1_1_soft_plus_1_p2" -> 0, 
   "R04_1_1_1_1_soft_minus_1_m1" -> Pi/(2*(omega - Q2)*(omega + s)), 
   "R04_1_1_1_1_soft_minus_1_p0" -> 
    -1/2*(Pi*(EulerGamma + Log[Pi - (omega*Pi)/Q2]))/
      ((omega - Q2)*(omega + s)), "R04_1_1_1_1_soft_minus_1_p1" -> 
    -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 4*EulerGamma*Log[Pi - (omega*Pi)/Q2] - 
        2*Log[Pi - (omega*Pi)/Q2]^2 - 8*PolyLog[2, omega/Q2]))/
      ((omega - Q2)*(omega + s)), "R04_1_1_1_1_soft_minus_1_p2" -> 0, 
   "R09_1_1_1_1_ordinary_m1" -> Pi/(2*(Q2*s - 2*Q2*w - t*w)), 
   "R09_1_1_1_1_ordinary_p0" -> (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((2*Q2 + s + t)^2*(s - w)^2*
          (1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2])*
          (1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2]))/
         (4*(Q2*s - 2*Q2*w - t*w)^2)])/(2*(Q2*s - 2*Q2*w - t*w)), 
   "R09_1_1_1_1_soft_plus_1_m1" -> Pi/(2*Q2*s), 
   "R09_1_1_1_1_soft_plus_1_p0" -> 
    -1/2*(Pi*(EulerGamma + Log[(Pi*Q2)/(omega + Q2)]))/(Q2*s), 
   "R09_1_1_1_1_soft_plus_1_p1" -> 
    -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 
        4*EulerGamma*Log[(Pi*Q2)/(omega + Q2)] - 2*Log[Q2/(omega + Q2)]*
         Log[(Pi^2*Q2)/(omega + Q2)] - 8*PolyLog[2, omega/(omega + Q2)]))/
      (Q2*s), "R09_1_1_1_1_soft_plus_1_p2" -> 0, 
   "R09_1_1_1_1_soft_minus_1_m1" -> Pi/(2*Q2*s), 
   "R09_1_1_1_1_soft_minus_1_p0" -> 
    -1/2*(Pi*(EulerGamma + Log[-((Pi*Q2)/(omega - Q2))]))/(Q2*s), 
   "R09_1_1_1_1_soft_minus_1_p1" -> 
    -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 
        4*EulerGamma*Log[-((Pi*Q2)/(omega - Q2))] - 2*Log[-(Q2/(omega - Q2))]*
         Log[-((Pi^2*Q2)/(omega - Q2))] - 8*PolyLog[2, omega/(omega - Q2)]))/
      (Q2*s), "R09_1_1_1_1_soft_minus_1_p2" -> 0, 
   "R10_1_1_1_1_ordinary_m1" -> Pi/(2*s*(Q2 + s + t - w)), 
   "R10_1_1_1_1_ordinary_p0" -> (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((2*Q2 + s + t)^2*(s - w)^2*
          (1 - Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2])*
          (1 + Sqrt[(s^2 + 2*s*t + t^2 + 4*Q2*w)/(2*Q2 + s + t)^2]))/
         (4*s^2*(Q2 + s + t - w)^2)])/(2*s*(Q2 + s + t - w)), 
   "R10_1_1_1_1_soft_plus_1_m1" -> Pi/(2*(omega + Q2)*s), 
   "R10_1_1_1_1_soft_plus_1_p0" -> 
    -1/2*(Pi*(EulerGamma + Log[(Pi*(omega + Q2))/Q2]))/((omega + Q2)*s), 
   "R10_1_1_1_1_soft_plus_1_p1" -> 
    -1/8*(Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 
        4*Log[Pi]*Log[(omega + Q2)/Q2] - 2*Log[(omega + Q2)/Q2]^2 - 
        4*EulerGamma*Log[(Pi*(omega + Q2))/Q2] - 8*PolyLog[2, -(omega/Q2)]))/
      ((omega + Q2)*s), "R10_1_1_1_1_soft_plus_1_p2" -> 0, 
   "R10_1_1_1_1_soft_minus_1_m1" -> -1/2*Pi/((omega - Q2)*s), 
   "R10_1_1_1_1_soft_minus_1_p0" -> 
    (Pi*(EulerGamma + Log[Pi - (omega*Pi)/Q2]))/(2*(omega - Q2)*s), 
   "R10_1_1_1_1_soft_minus_1_p1" -> 
    (Pi*(-2*EulerGamma^2 + Pi^2 - 2*Log[Pi]^2 - 2*Log[1 - omega/Q2]*
        (2*Log[Pi] + Log[1 - omega/Q2]) - 4*EulerGamma*
        Log[Pi - (omega*Pi)/Q2] - 8*PolyLog[2, omega/Q2]))/
     (8*(omega - Q2)*s), "R10_1_1_1_1_soft_minus_1_p2" -> 0, 
   "R01_1_1_0_0_ordinary_p0_plus" -> Pi/2, "R01_1_1_0_0_ordinary_p1_plus" -> 
    (2*Pi - EulerGamma*Pi - Pi*Log[Pi] - Pi*Log[w])/2, 
   "R01_1_1_0_0_ordinary_p0_minus" -> Pi/2, 
   "R01_1_1_0_0_ordinary_p1_minus" -> (2*Pi - EulerGamma*Pi - Pi*Log[Pi] - 
      Pi*Log[w])/2, "R01_1_1_1_1_ordinary_m1_plus" -> 
    -(Pi/(w*(-omega - Q2 + w))), "R01_1_1_1_1_ordinary_p0_plus" -> 
    (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
      Pi*Log[((s - w)*(-omega + s + w))/((omega + Q2 - w)*w)])/
     (w*(-omega - Q2 + w)), "R01_1_1_1_1_ordinary_m1_minus" -> 
    -(Pi/(w*(omega - Q2 + w))), "R01_1_1_1_1_ordinary_p0_minus" -> 
    (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
      Pi*Log[((s - w)*(omega + s + w))/((-omega + Q2 - w)*w)])/
     (w*(omega - Q2 + w)), "R02_1_1_1_1_ordinary_m1_plus" -> 
    -(Pi/((omega - s)*s + Q2*w)), "R02_1_1_1_1_ordinary_p0_plus" -> 
    (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
      Pi*Log[-(((s - w)*(-omega + s + w))/((omega - s)*s + Q2*w))])/
     ((omega - s)*s + Q2*w), "R02_1_1_1_1_ordinary_m1_minus" -> 
    -(Pi/((-omega - s)*s + Q2*w)), "R02_1_1_1_1_ordinary_p0_minus" -> 
    (EulerGamma*Pi + Pi*Log[Pi] + Pi*Log[w] - 
      Pi*Log[-(((s - w)*(omega + s + w))/((-omega - s)*s + Q2*w))])/
     ((-omega - s)*s + Q2*w), "R03_1_1_0_1_ordinary_p0_plus" -> 
    (Pi*Log[(1 - Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])/
        (1 + Sqrt[1 - (4*Q2*(omega + Q2 - w))/(omega + 2*Q2)^2])])/
     (2*(omega + 2*Q2)*Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
        (omega + 2*Q2)^2]), "R03_1_1_0_1_ordinary_p0_minus" -> 
    (Pi*Log[(1 - Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])/
        (1 + Sqrt[1 - (4*Q2*(-omega + Q2 - w))/(-omega + 2*Q2)^2])])/
     (2*(-omega + 2*Q2)*Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 
         4*Q2*w)/(-omega + 2*Q2)^2]), "R03_1_1_1_1_ordinary_m1_plus" -> 
    Pi/(2*(Q2*(omega - s) - 2*Q2*w - s*w)), "R03_1_1_1_1_ordinary_p0_plus" -> 
    (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((omega + 2*Q2)^2*(omega - s - w)^2*
          (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
             (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
              s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
         (4*(Q2*(omega - s) - 2*Q2*w - s*w)^2)])/
     (2*(Q2*(omega - s) - 2*Q2*w - s*w)), "R03_1_1_1_1_ordinary_m1_minus" -> 
    Pi/(2*(Q2*(-omega - s) - 2*Q2*w - s*w)), 
   "R03_1_1_1_1_ordinary_p0_minus" -> (-(EulerGamma*Pi) - Pi*Log[Pi] - 
      Pi*Log[w] + Pi*Log[((-omega + 2*Q2)^2*(-omega - s - w)^2*
          (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
             (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
              2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^2]))/
         (4*(Q2*(-omega - s) - 2*Q2*w - s*w)^2)])/
     (2*(Q2*(-omega - s) - 2*Q2*w - s*w)), "R04_1_1_1_1_ordinary_m1_plus" -> 
    Pi/(2*(omega - s)*(omega + Q2 - w)), "R04_1_1_1_1_ordinary_p0_plus" -> 
    (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((omega + 2*Q2)^2*(omega - s - w)^2*
          (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
             (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
              s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/(4*(omega - s)^2*
          (omega + Q2 - w)^2)])/(2*(omega - s)*(omega + Q2 - w)), 
   "R04_1_1_1_1_ordinary_m1_minus" -> Pi/(2*(-omega - s)*(-omega + Q2 - w)), 
   "R04_1_1_1_1_ordinary_p0_minus" -> (-(EulerGamma*Pi) - Pi*Log[Pi] - 
      Pi*Log[w] + Pi*Log[((-omega + 2*Q2)^2*(-omega - s - w)^2*
          (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
             (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
              2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^2]))/
         (4*(-omega - s)^2*(-omega + Q2 - w)^2)])/
     (2*(-omega - s)*(-omega + Q2 - w)), "R09_1_1_1_1_ordinary_m1_plus" -> 
    Pi/(2*(Q2*s - 2*Q2*w - (omega - s)*w)), "R09_1_1_1_1_ordinary_p0_plus" -> 
    (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((omega + 2*Q2)^2*(s - w)^2*
          (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
             (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
              s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/
         (4*(Q2*s - 2*Q2*w - (omega - s)*w)^2)])/
     (2*(Q2*s - 2*Q2*w - (omega - s)*w)), "R09_1_1_1_1_ordinary_m1_minus" -> 
    Pi/(2*(Q2*s - 2*Q2*w - (-omega - s)*w)), 
   "R09_1_1_1_1_ordinary_p0_minus" -> (-(EulerGamma*Pi) - Pi*Log[Pi] - 
      Pi*Log[w] + Pi*Log[((-omega + 2*Q2)^2*(s - w)^2*
          (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
             (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
              2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^2]))/
         (4*(Q2*s - 2*Q2*w - (-omega - s)*w)^2)])/
     (2*(Q2*s - 2*Q2*w - (-omega - s)*w)), "R10_1_1_1_1_ordinary_m1_plus" -> 
    Pi/(2*s*(omega + Q2 - w)), "R10_1_1_1_1_ordinary_p0_plus" -> 
    (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((omega + 2*Q2)^2*(s - w)^2*
          (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q2*w)/
             (omega + 2*Q2)^2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
              s^2 + 4*Q2*w)/(omega + 2*Q2)^2]))/(4*s^2*(omega + Q2 - w)^2)])/
     (2*s*(omega + Q2 - w)), "R10_1_1_1_1_ordinary_m1_minus" -> 
    Pi/(2*s*(-omega + Q2 - w)), "R10_1_1_1_1_ordinary_p0_minus" -> 
    (-(EulerGamma*Pi) - Pi*Log[Pi] - Pi*Log[w] + 
      Pi*Log[((-omega + 2*Q2)^2*(s - w)^2*
          (1 - Sqrt[((-omega - s)^2 + 2*(-omega - s)*s + s^2 + 4*Q2*w)/
             (-omega + 2*Q2)^2])*(1 + Sqrt[((-omega - s)^2 + 
              2*(-omega - s)*s + s^2 + 4*Q2*w)/(-omega + 2*Q2)^2]))/
         (4*s^2*(-omega + Q2 - w)^2)])/(2*s*(-omega + Q2 - w))|>, 
 "transport_conversion" -> <|"literal_function" -> 
    ArcTanh[omega/(omega - 2*Q2)], "converted_function" -> 
    Log[1 - omega/Q2]/2, "physical_branch" -> Q2 > 0 && s > w > 0 && 
     omega > 0 && -Q2 - s + w < -omega - s < -((Q2*w)/s), 
   "real_domain_proof" -> True, "symbolic_identity_residual" -> 0, 
   "source_sha256" -> <|"/bigTMD/collins_support/reports/sidis-highpt-001/con\
tinuation-001/real-portable-views-001/portable-real.wl" -> 
      "07a0feecf527a56b5ed509368c47c06ea924b81bd72355876b8b0fa15c91552d", 
     "/bigTMD/collins_sidis_highpt/tools/prepare_real_master_transport.wls" \
-> "8bc529ea075cabe5a29fc81fd9c2c14211c6af77f52b82dec8a762a337e1abb8"|>|>|>
