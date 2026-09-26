<|"ep_soft" -> <|"r03/soft_standard" -> -(Bq^2*CF) + (2*CF)/eps^2 - 
     (4*Bq*CF)/eta - (4*CF)/(eps*eta) - (CF*Pi^2)/6 + 2*Bq*CF*V + 
     (2*CF*V)/eps, "r03/soft_global" -> (2*CF)/eps^2 + (Bq*CF)/eps - 
     (2*Bq*CF)/eta - (2*CF)/(eps*eta) - (CF*Pi^2)/6 + Bq*CF*V + (CF*V)/eps + 
     2*Bq*CF*Y + (2*CF*Y)/eps, "r03/soft_injet" -> 
    -1/2*(Bh^2*CF) + CF/eps^2 - (2*Bh*CF)/eta - (2*CF)/(eps*eta) - Bh*CF*g - 
     (CF*g)/eps - (CF*Pi^2)/12 + Bh*CF*V + (CF*V)/eps, 
   "r03/soft_cs_out" -> -1/2*(Bq^2*CF) - CF/eps^2 - (Bq*CF)/eps + 
     (CF*Pi^2)/12 + Bq*CF*r + (CF*r)/eps - (CF*r^2)/2, 
   "r03/recoil_soft_bare" -> Bq*CF*r + (CF*r)/eps - (CF*r^2)/2 + 2*Bq*CF*Y + 
     (2*CF*Y)/eps, "r03/recoil_soft_finite" -> Bq*CF*r - (CF*r^2)/2 + 
     2*Bq*CF*Y, "r03/jet_common_overlap" -> -1/2*(Bh^2*CF) + CF/eps^2 - 
     (2*Bh*CF)/eta - (2*CF)/(eps*eta) - Bh*CF*g - (CF*g)/eps - (CF*Pi^2)/12 + 
     Bh*CF*V + (CF*V)/eps, "r03/jet_comparison_bare" -> 
    -1/2*(B^2*CF) + CF/eps^2 - (2*B*CF)/eta - (2*CF)/(eps*eta) - 
     (CF*Pi^2)/12, "r03/jet_comparison_overlap" -> 
    -1/2*(B^2*CF) + CF/eps^2 - (2*B*CF)/eta - (2*CF)/(eps*eta) - 
     (CF*Pi^2)/12, "r03/jet_UU_bare_remainder" -> 0, 
   "r03/jet_UT_bare_remainder" -> 0|>, "ep_tmd_full" -> 
  <|"fqq" -> <|"delta" -> -1/2*(Bq^2*CF) - (CF*Pi^2)/12 + Bq*CF*Tq, 
     "D0" -> -2*Bq*CF, "D1" -> 0, "regular" -> CF + Bq*CF - CF*z + Bq*CF*z|>, 
   "fqg" -> <|"delta" -> 0, "D0" -> 0, "D1" -> 0, 
     "regular" -> -(Bq*TR) + 2*TR*z + 2*Bq*TR*z - 2*TR*z^2 - 2*Bq*TR*z^2|>, 
   "hqq" -> <|"delta" -> -1/2*(Bq^2*CF) - (CF*Pi^2)/12 + Bq*CF*Tq, 
     "D0" -> -2*Bq*CF, "D1" -> 0, "regular" -> 2*Bq*CF|>, 
   "dqq" -> <|"delta" -> -1/2*(Bh^2*CF) - (CF*Pi^2)/12 + Bh*CF*Th, 
     "D0" -> -2*Bh*CF, "D1" -> 0, "regular" -> -(CF/(-1 + z)) - 
       (Bh*CF)/(-1 + z) + (2*CF*z)/(-1 + z) - (CF*z^2)/(-1 + z) + 
       (Bh*CF*z^2)/(-1 + z) - (2*CF*Log[z])/(-1 + z) - 
       (2*CF*z^2*Log[z])/(-1 + z)|>, "dgq" -> <|"delta" -> 0, "D0" -> 0, 
     "D1" -> 0, "regular" -> 2*Bh*CF - (2*Bh*CF)/z + CF*z - Bh*CF*z - 
       4*CF*Log[z] + (4*CF*Log[z])/z + 2*CF*z*Log[z]|>, 
   "collins" -> <|"delta" -> -1/2*(Bh^2*CF) - (CF*Pi^2)/12 + Bh*CF*Th, 
     "D0" -> -2*Bh*CF, "D1" -> 0, "regular" -> (-2*Bh*CF)/(-1 + z) + 
       (2*Bh*CF*z)/(-1 + z) - (4*CF*z*Log[z])/(-1 + z)|>|>, 
 "ep_fourier" -> <|"Gaussian" -> Sqrt[Pi]/(E^(bb^2/(4*ss))*Sqrt[ss]), 
   "Schwinger_integrand" -> xx^(-1 - eps)/E^xx, "Schwinger_evaluated" -> 
    Gamma[-eps], "full_D_scalar" -> ((bb^2)^eps*E^(eps*EulerGamma)*
      Gamma[-eps])/4^eps, "full_D_rank_one" -> (-I)*2^(-1 - 2*eps)*bb*
     (bb^2)^eps*E^(eps*EulerGamma)*(1 + eps)*Gamma[-1 - eps], 
   "rank_one_residual" -> 0, "operator_angular_conversion" -> 
    1/(Gamma[1 - eps]*Gamma[1 + eps]), "ratio_to_native_sphere" -> 
    -((E^(eps*(B - 2*EulerGamma))*Gamma[1 - eps])/(eps*Gamma[1 + eps])), 
   "Laurent_ratio" -> -1/6*(6 + B*eps*(6 + B*eps*(3 + B*eps)) + 
       4*eps^3*Zeta[3])/eps, "fragmentation_phase_ratio" -> z^(-2*eps), 
   "C11_UV_ratio" -> E^(eps*EulerGamma)/Gamma[1 - eps], 
   "physical_phase" -> HoldComplete[{kT == -pT/z, Exp[(-I)*(pT . b/z)] == 
       Exp[I*kT . b]}], "Collins_tree" -> HoldComplete[
     CollinsTree[i] == (-I)*b[i]*(Hhat3[z]/(2*z))], 
   "log_definition" -> HoldComplete[
     B == Log[mu^2*bb^2*(Exp[2*EulerGamma]/4)]], 
   "local_normalization" -> HoldComplete[{N0 == 1, N1 == 0, 
      N2 == -Zeta[2]/2}], "scope" -> "Fourier is an analytic transform of the \
actually evaluated fixed-radius density; the raw geometric sphere is never \
replaced by this normalization identity in producing coefficients."|>, 
 "ep_observable" -> <|"first_order_coefficients" -> 
    <|"UU0" -> D0*f0*HUU, "UT0" -> C0*h0*HUT, 
     "UU1" -> -8*CF*D0*f0*HUU + D1*f0*HUU + D0*f1*HUU - 3*CF*D0*f0*HUU*L - 
       CF*D0*f0*HUU*L^2 + (CF*D0*f0*HUU*Pi^2)/6 + Bq*CF*D0*f0*HUU*r - 
       (CF*D0*f0*HUU*r^2)/2 + 2*Bq*CF*D0*f0*HUU*Y, 
     "UT1" -> C1*h0*HUT - 8*C0*CF*h0*HUT + C0*h1*HUT - 3*C0*CF*h0*HUT*L - 
       C0*CF*h0*HUT*L^2 + (C0*CF*h0*HUT*Pi^2)/6 + Bq*C0*CF*h0*HUT*r - 
       (C0*CF*h0*HUT*r^2)/2 + 2*Bq*C0*CF*h0*HUT*Y|>, 
   "physical_local_OPE_integrands" -> 
    <|"UU0" -> (bh*bq*(s^2 + u^2)*BesselJ[0, bq*qT]*BesselJ[0, (bh*jT)/zh]*
        FFq[zh]*PDFq[x])/(2*Pi^2*t^2*zh^2), 
     "UU1" -> (bh*bq*BesselJ[0, bq*qT]*BesselJ[0, (bh*jT)/zh]*
        ((-16*CF*(s^2 + u^2)*FFq[zh]*PDFq[x])/t^2 - 
         (6*CF*L*(s^2 + u^2)*FFq[zh]*PDFq[x])/t^2 - 
         (2*CF*L^2*(s^2 + u^2)*FFq[zh]*PDFq[x])/t^2 + 
         (CF*Pi^2*(s^2 + u^2)*FFq[zh]*PDFq[x])/(3*t^2) + 
         (2*Bq*CF*r*(s^2 + u^2)*FFq[zh]*PDFq[x])/t^2 - 
         (CF*r^2*(s^2 + u^2)*FFq[zh]*PDFq[x])/t^2 + 
         (4*Bq*CF*(s^2 + u^2)*Y*FFq[zh]*PDFq[x])/t^2 + 
         (2*(s^2 + u^2)*PDFq[x]*((-1/2*(Bh^2*CF) - (CF*Pi^2)/12 + Bh*CF*Th)*
             FFq[zh] - 2*Bh*CF*(FFq[zh]*Log[1 - zh] + Inactive[Integrate][
               (-FFq[zh] + FFq[zh/xi]/xi)/(1 - xi), {xi, zh, 1}]) + 
            Inactive[Integrate][(FFg[zh/xi]*(2*Bh*CF - (2*Bh*CF)/xi + CF*xi - 
                Bh*CF*xi - 4*CF*Log[xi] + (4*CF*Log[xi])/xi + 2*CF*xi*
                 Log[xi]))/xi, {xi, zh, 1}] + Inactive[Integrate][
             (FFq[zh/xi]*(-(CF/(-1 + xi)) - (Bh*CF)/(-1 + xi) + (2*CF*xi)/
                 (-1 + xi) - (CF*xi^2)/(-1 + xi) + (Bh*CF*xi^2)/(-1 + xi) - 
                (2*CF*Log[xi])/(-1 + xi) - (2*CF*xi^2*Log[xi])/(-1 + xi)))/
              xi, {xi, zh, 1}]))/t^2 + (2*(s^2 + u^2)*FFq[zh]*
           ((-1/2*(Bq^2*CF) - (CF*Pi^2)/12 + Bq*CF*Tq)*PDFq[x] + 
            Inactive[Integrate][((-(Bq*TR) + 2*TR*xi + 2*Bq*TR*xi - 
                2*TR*xi^2 - 2*Bq*TR*xi^2)*PDFg[x/xi])/xi, {xi, x, 1}] + 
            Inactive[Integrate][((CF + Bq*CF - CF*xi + Bq*CF*xi)*PDFq[x/xi])/
              xi, {xi, x, 1}] - 2*Bq*CF*(Log[1 - x]*PDFq[x] + 
              Inactive[Integrate][(-PDFq[x] + PDFq[x/xi]/xi)/(1 - xi), {xi, 
                x, 1}])))/t^2))/(4*Pi^2*zh^2), 
     "UT0" -> -1/4*(bh^2*bq*(-s^2 + t^2 - u^2)*BesselJ[0, bq*qT]*
         BesselJ[1, (bh*jT)/zh]*Hhatq[zh]*Transversityq[x])/(Pi^2*t^2*zh^3), 
     "UT1" -> (bh^2*bq*BesselJ[0, bq*qT]*BesselJ[1, (bh*jT)/zh]*
        ((16*CF*(-s^2 + t^2 - u^2)*Hhatq[zh]*Transversityq[x])/t^2 + 
         (6*CF*L*(-s^2 + t^2 - u^2)*Hhatq[zh]*Transversityq[x])/t^2 + 
         (2*CF*L^2*(-s^2 + t^2 - u^2)*Hhatq[zh]*Transversityq[x])/t^2 - 
         (CF*Pi^2*(-s^2 + t^2 - u^2)*Hhatq[zh]*Transversityq[x])/(3*t^2) - 
         (2*Bq*CF*r*(-s^2 + t^2 - u^2)*Hhatq[zh]*Transversityq[x])/t^2 + 
         (CF*r^2*(-s^2 + t^2 - u^2)*Hhatq[zh]*Transversityq[x])/t^2 - 
         (4*Bq*CF*(-s^2 + t^2 - u^2)*Y*Hhatq[zh]*Transversityq[x])/t^2 - 
         (2*(-s^2 + t^2 - u^2)*Transversityq[x]*
           ((-1/2*(Bh^2*CF) - (CF*Pi^2)/12 + Bh*CF*Th)*Hhatq[zh] - 
            2*Bh*CF*(Hhatq[zh]*Log[1 - zh] + Inactive[Integrate][
               (-Hhatq[zh] + Hhatq[zh/xi]/xi)/(1 - xi), {xi, zh, 1}]) + 
            Inactive[Integrate][(Hhatq[zh/xi]*((-2*Bh*CF)/(-1 + xi) + 
                (2*Bh*CF*xi)/(-1 + xi) - (4*CF*xi*Log[xi])/(-1 + xi)))/xi, 
             {xi, zh, 1}]))/t^2 - (2*(-s^2 + t^2 - u^2)*Hhatq[zh]*
           ((-1/2*(Bq^2*CF) - (CF*Pi^2)/12 + Bq*CF*Tq)*Transversityq[x] + 
            Inactive[Integrate][(2*Bq*CF*Transversityq[x/xi])/xi, 
             {xi, x, 1}] - 2*Bq*CF*(Log[1 - x]*Transversityq[x] + 
              Inactive[Integrate][(-Transversityq[x] + Transversityq[x/xi]/
                  xi)/(1 - xi), {xi, x, 1}])))/t^2 - 
         (2*(-s^2 + t^2 - u^2)*Transversityq[x]*
           (2*Inactive[Integrate][0, {u, zh, 1}] + Inactive[Integrate][0, 
             {v, 0, 1}] + Log[1 - zh]*Inactive[Integrate][0, {v, 0, 1}] + 
            (Log[1 - zh]^2*Inactive[Integrate][0, {v, 0, 1}])/2 + 
            Inactive[Integrate][Inactive[Integrate][
              (-(CA/((-1 + v)^2*(-1 + u*v))) + (2*CF)/((-1 + v)^2*
                  (-1 + u*v)) + (CA*u)/((-1 + v)^2*(-1 + u*v)) - 
                (Bh*CA*u)/((-1 + v)^2*(-1 + u*v)) - (2*CF*u)/((-1 + v)^2*
                  (-1 + u*v)) + (2*Bh*CF*u)/((-1 + v)^2*(-1 + u*v)) + 
                (Bh*CA*u^2)/((-1 + v)^2*(-1 + u*v)) - (2*Bh*CF*u^2)/
                 ((-1 + v)^2*(-1 + u*v)) - (4*CF*v)/((-1 + v)^2*(-1 + u*v)) + 
                (2*CA*u*v)/((-1 + v)^2*(-1 + u*v)) - (Bh*CA*u*v)/((-1 + v)^2*
                  (-1 + u*v)) + (2*CF*u*v)/((-1 + v)^2*(-1 + u*v)) - 
                (2*Bh*CF*u*v)/((-1 + v)^2*(-1 + u*v)) - (2*CA*u^2*v)/
                 ((-1 + v)^2*(-1 + u*v)) + (2*CF*u^2*v)/((-1 + v)^2*
                  (-1 + u*v)) + (2*Bh*CF*u^2*v)/((-1 + v)^2*(-1 + u*v)) + 
                (2*Bh*CF*u^3*v)/((-1 + v)^2*(-1 + u*v)) + (2*CF*v^2)/
                 ((-1 + v)^2*(-1 + u*v)) + (2*CF*u*v^2)/((-1 + v)^2*
                  (-1 + u*v)) - (CA*u^2*v^2)/((-1 + v)^2*(-1 + u*v)) + 
                (Bh*CA*u^2*v^2)/((-1 + v)^2*(-1 + u*v)) - (4*CF*u^2*v^2)/
                 ((-1 + v)^2*(-1 + u*v)) + (CA*u^3*v^2)/((-1 + v)^2*
                  (-1 + u*v)) - (4*Bh*CF*u^3*v^2)/((-1 + v)^2*(-1 + u*v)) - 
                (2*CF*u*v^3)/((-1 + v)^2*(-1 + u*v)) + (2*CF*u^2*v^3)/
                 ((-1 + v)^2*(-1 + u*v)) + (2*Bh*CF*u^3*v^3)/((-1 + v)^2*
                  (-1 + u*v)) + (2*CA*u*Log[u])/((-1 + v)^2*(-1 + u*v)) - 
                (4*CF*u*Log[u])/((-1 + v)^2*(-1 + u*v)) - (2*CA*u^2*Log[u])/
                 ((-1 + v)^2*(-1 + u*v)) + (4*CF*u^2*Log[u])/((-1 + v)^2*
                  (-1 + u*v)) + (2*CA*u*v*Log[u])/((-1 + v)^2*(-1 + u*v)) + 
                (4*CF*u*v*Log[u])/((-1 + v)^2*(-1 + u*v)) - 
                (4*CF*u^2*v*Log[u])/((-1 + v)^2*(-1 + u*v)) - 
                (4*CF*u^3*v*Log[u])/((-1 + v)^2*(-1 + u*v)) - 
                (2*CA*u^2*v^2*Log[u])/((-1 + v)^2*(-1 + u*v)) + 
                (8*CF*u^3*v^2*Log[u])/((-1 + v)^2*(-1 + u*v)) - 
                (4*CF*u^3*v^3*Log[u])/((-1 + v)^2*(-1 + u*v)))*(
                -(HFNative[flavor, zh/u, zh/u, mu]/u) + HFNative[flavor, 
                  zh/u, zh/(u*v), mu]/u + ((-1 + v)*zh*Derivative[0, 0, 1, 0][
                    HFNative][flavor, zh/u, zh/u, mu])/u^2), {v, 0, 1}], 
             {u, zh, 1}]))/t^2))/(8*Pi^2*zh^3)|>, 
   "native_bindings" -> {HUU -> (2*(s^2 + u^2))/t^2, 
     HUT -> (-2*(-s^2 + t^2 - u^2))/t^2, f0 -> PDFq[x], 
     h0 -> Transversityq[x], D0 -> FFq[zh], C0 -> Hhatq[zh], 
     f1 -> (-1/2*(Bq^2*CF) - (CF*Pi^2)/12 + Bq*CF*Tq)*PDFq[x] + 
       Inactive[Integrate][((-(Bq*TR) + 2*TR*xi + 2*Bq*TR*xi - 2*TR*xi^2 - 
           2*Bq*TR*xi^2)*PDFg[x/xi])/xi, {xi, x, 1}] + 
       Inactive[Integrate][((CF + Bq*CF - CF*xi + Bq*CF*xi)*PDFq[x/xi])/xi, 
        {xi, x, 1}] - 2*Bq*CF*(Log[1 - x]*PDFq[x] + Inactive[Integrate][
          (-PDFq[x] + PDFq[x/xi]/xi)/(1 - xi), {xi, x, 1}]), 
     h1 -> (-1/2*(Bq^2*CF) - (CF*Pi^2)/12 + Bq*CF*Tq)*Transversityq[x] + 
       Inactive[Integrate][(2*Bq*CF*Transversityq[x/xi])/xi, {xi, x, 1}] - 
       2*Bq*CF*(Log[1 - x]*Transversityq[x] + Inactive[Integrate][
          (-Transversityq[x] + Transversityq[x/xi]/xi)/(1 - xi), 
          {xi, x, 1}]), D1 -> (-1/2*(Bh^2*CF) - (CF*Pi^2)/12 + Bh*CF*Th)*
        FFq[zh] - 2*Bh*CF*(FFq[zh]*Log[1 - zh] + Inactive[Integrate][
          (-FFq[zh] + FFq[zh/xi]/xi)/(1 - xi), {xi, zh, 1}]) + 
       Inactive[Integrate][(FFg[zh/xi]*(2*Bh*CF - (2*Bh*CF)/xi + CF*xi - 
           Bh*CF*xi - 4*CF*Log[xi] + (4*CF*Log[xi])/xi + 2*CF*xi*Log[xi]))/
         xi, {xi, zh, 1}] + Inactive[Integrate][
        (FFq[zh/xi]*(-(CF/(-1 + xi)) - (Bh*CF)/(-1 + xi) + 
           (2*CF*xi)/(-1 + xi) - (CF*xi^2)/(-1 + xi) + (Bh*CF*xi^2)/
            (-1 + xi) - (2*CF*Log[xi])/(-1 + xi) - (2*CF*xi^2*Log[xi])/
            (-1 + xi)))/xi, {xi, zh, 1}], 
     C1 -> (-1/2*(Bh^2*CF) - (CF*Pi^2)/12 + Bh*CF*Th)*Hhatq[zh] - 
       2*Bh*CF*(Hhatq[zh]*Log[1 - zh] + Inactive[Integrate][
          (-Hhatq[zh] + Hhatq[zh/xi]/xi)/(1 - xi), {xi, zh, 1}]) + 
       Inactive[Integrate][(Hhatq[zh/xi]*((-2*Bh*CF)/(-1 + xi) + 
           (2*Bh*CF*xi)/(-1 + xi) - (4*CF*xi*Log[xi])/(-1 + xi)))/xi, 
        {xi, zh, 1}]}, "HF_full_contact_action" -> 
    2*Inactive[Integrate][0, {u, zh, 1}] + Inactive[Integrate][0, 
      {v, 0, 1}] + Log[1 - zh]*Inactive[Integrate][0, {v, 0, 1}] + 
     (Log[1 - zh]^2*Inactive[Integrate][0, {v, 0, 1}])/2 + 
     Inactive[Integrate][Inactive[Integrate][(-(CA/((-1 + v)^2*(-1 + u*v))) + 
         (2*CF)/((-1 + v)^2*(-1 + u*v)) + (CA*u)/((-1 + v)^2*(-1 + u*v)) - 
         (Bh*CA*u)/((-1 + v)^2*(-1 + u*v)) - (2*CF*u)/((-1 + v)^2*
           (-1 + u*v)) + (2*Bh*CF*u)/((-1 + v)^2*(-1 + u*v)) + 
         (Bh*CA*u^2)/((-1 + v)^2*(-1 + u*v)) - (2*Bh*CF*u^2)/
          ((-1 + v)^2*(-1 + u*v)) - (4*CF*v)/((-1 + v)^2*(-1 + u*v)) + 
         (2*CA*u*v)/((-1 + v)^2*(-1 + u*v)) - (Bh*CA*u*v)/
          ((-1 + v)^2*(-1 + u*v)) + (2*CF*u*v)/((-1 + v)^2*(-1 + u*v)) - 
         (2*Bh*CF*u*v)/((-1 + v)^2*(-1 + u*v)) - (2*CA*u^2*v)/
          ((-1 + v)^2*(-1 + u*v)) + (2*CF*u^2*v)/((-1 + v)^2*(-1 + u*v)) + 
         (2*Bh*CF*u^2*v)/((-1 + v)^2*(-1 + u*v)) + (2*Bh*CF*u^3*v)/
          ((-1 + v)^2*(-1 + u*v)) + (2*CF*v^2)/((-1 + v)^2*(-1 + u*v)) + 
         (2*CF*u*v^2)/((-1 + v)^2*(-1 + u*v)) - (CA*u^2*v^2)/
          ((-1 + v)^2*(-1 + u*v)) + (Bh*CA*u^2*v^2)/((-1 + v)^2*(-1 + u*v)) - 
         (4*CF*u^2*v^2)/((-1 + v)^2*(-1 + u*v)) + (CA*u^3*v^2)/
          ((-1 + v)^2*(-1 + u*v)) - (4*Bh*CF*u^3*v^2)/((-1 + v)^2*
           (-1 + u*v)) - (2*CF*u*v^3)/((-1 + v)^2*(-1 + u*v)) + 
         (2*CF*u^2*v^3)/((-1 + v)^2*(-1 + u*v)) + (2*Bh*CF*u^3*v^3)/
          ((-1 + v)^2*(-1 + u*v)) + (2*CA*u*Log[u])/((-1 + v)^2*(-1 + u*v)) - 
         (4*CF*u*Log[u])/((-1 + v)^2*(-1 + u*v)) - (2*CA*u^2*Log[u])/
          ((-1 + v)^2*(-1 + u*v)) + (4*CF*u^2*Log[u])/((-1 + v)^2*
           (-1 + u*v)) + (2*CA*u*v*Log[u])/((-1 + v)^2*(-1 + u*v)) + 
         (4*CF*u*v*Log[u])/((-1 + v)^2*(-1 + u*v)) - (4*CF*u^2*v*Log[u])/
          ((-1 + v)^2*(-1 + u*v)) - (4*CF*u^3*v*Log[u])/
          ((-1 + v)^2*(-1 + u*v)) - (2*CA*u^2*v^2*Log[u])/
          ((-1 + v)^2*(-1 + u*v)) + (8*CF*u^3*v^2*Log[u])/
          ((-1 + v)^2*(-1 + u*v)) - (4*CF*u^3*v^3*Log[u])/
          ((-1 + v)^2*(-1 + u*v)))*(-(HFNative[flavor, zh/u, zh/u, mu]/u) + 
         HFNative[flavor, zh/u, zh/(u*v), mu]/u + 
         ((-1 + v)*zh*Derivative[0, 0, 1, 0][HFNative][flavor, zh/u, zh/u, 
            mu])/u^2), {v, 0, 1}], {u, zh, 1}], 
   "HF_kernel" -> <|"delta" -> 0, "v_delta_delta" -> 0, 
     "v_derivative_delta" -> 0, "D0" -> 0, "v_delta_D0" -> 0, 
     "v_derivative_D0" -> 0, "D1" -> 0, "v_delta_D1" -> 0, 
     "v_derivative_D1" -> 0, "regular" -> -(CA/((-1 + v)^2*(-1 + u*v))) + 
       (2*CF)/((-1 + v)^2*(-1 + u*v)) + (CA*u)/((-1 + v)^2*(-1 + u*v)) - 
       (B*CA*u)/((-1 + v)^2*(-1 + u*v)) - (2*CF*u)/((-1 + v)^2*(-1 + u*v)) + 
       (2*B*CF*u)/((-1 + v)^2*(-1 + u*v)) + (B*CA*u^2)/
        ((-1 + v)^2*(-1 + u*v)) - (2*B*CF*u^2)/((-1 + v)^2*(-1 + u*v)) - 
       (4*CF*v)/((-1 + v)^2*(-1 + u*v)) + (2*CA*u*v)/
        ((-1 + v)^2*(-1 + u*v)) - (B*CA*u*v)/((-1 + v)^2*(-1 + u*v)) + 
       (2*CF*u*v)/((-1 + v)^2*(-1 + u*v)) - (2*B*CF*u*v)/
        ((-1 + v)^2*(-1 + u*v)) - (2*CA*u^2*v)/((-1 + v)^2*(-1 + u*v)) + 
       (2*CF*u^2*v)/((-1 + v)^2*(-1 + u*v)) + (2*B*CF*u^2*v)/
        ((-1 + v)^2*(-1 + u*v)) + (2*B*CF*u^3*v)/((-1 + v)^2*(-1 + u*v)) + 
       (2*CF*v^2)/((-1 + v)^2*(-1 + u*v)) + (2*CF*u*v^2)/
        ((-1 + v)^2*(-1 + u*v)) - (CA*u^2*v^2)/((-1 + v)^2*(-1 + u*v)) + 
       (B*CA*u^2*v^2)/((-1 + v)^2*(-1 + u*v)) - (4*CF*u^2*v^2)/
        ((-1 + v)^2*(-1 + u*v)) + (CA*u^3*v^2)/((-1 + v)^2*(-1 + u*v)) - 
       (4*B*CF*u^3*v^2)/((-1 + v)^2*(-1 + u*v)) - 
       (2*CF*u*v^3)/((-1 + v)^2*(-1 + u*v)) + (2*CF*u^2*v^3)/
        ((-1 + v)^2*(-1 + u*v)) + (2*B*CF*u^3*v^3)/((-1 + v)^2*(-1 + u*v)) + 
       (2*CA*u*Log[u])/((-1 + v)^2*(-1 + u*v)) - (4*CF*u*Log[u])/
        ((-1 + v)^2*(-1 + u*v)) - (2*CA*u^2*Log[u])/((-1 + v)^2*(-1 + u*v)) + 
       (4*CF*u^2*Log[u])/((-1 + v)^2*(-1 + u*v)) + (2*CA*u*v*Log[u])/
        ((-1 + v)^2*(-1 + u*v)) + (4*CF*u*v*Log[u])/((-1 + v)^2*(-1 + u*v)) - 
       (4*CF*u^2*v*Log[u])/((-1 + v)^2*(-1 + u*v)) - (4*CF*u^3*v*Log[u])/
        ((-1 + v)^2*(-1 + u*v)) - (2*CA*u^2*v^2*Log[u])/
        ((-1 + v)^2*(-1 + u*v)) + (8*CF*u^3*v^2*Log[u])/
        ((-1 + v)^2*(-1 + u*v)) - (4*CF*u^3*v^3*Log[u])/
        ((-1 + v)^2*(-1 + u*v)), "v_delta_regular" -> 0, 
     "v_derivative_regular" -> 0|>, "ratio_of_common_integrals" -> 
    N0/U0 + (a*(N1*U0 - N0*U1))/U0^2, "ratio_condition" -> 
    HoldComplete[U0 != 0], "convolution_measures" -> 
    HoldComplete[{dxi/xi, du/u, dv/(1 - v)}], "Fourier_measures" -> 
    {(bq*BesselJ[0, bq*qT])/(2*Pi), (bh*BesselJ[0, (bh*jT)/zh])/(2*Pi*zh^2), 
     (bh^2*BesselJ[1, (bh*jT)/zh])/(4*Pi*zh^3)}, 
   "electromagnetic_prefactor" -> "Born scalar factors strip alpha_em^2 and \
quark charges. Restore the common coupling/phase-space prefactor outside this \
coefficient polynomial. Literal paper prefactor discrepancies stay \
qualified.", "scales" -> HoldComplete[{L == LQ == Log[mu^2/Q2], 
      Bq == Log[mu^2*bq^2*(Exp[2*EulerGamma]/4)], 
      Bh == Log[mu^2*bh^2*(Exp[2*EulerGamma]/4)], B == Bh, 
      Tq == Log[mu^2/zetaP], Th == Log[mu^2/zetaJ], zetaJ == pT^2*R^2}], 
   "local_domain" -> HoldComplete[bq*LambdaQCD < rhoOPE && 
      bh*LambdaQCD < rhoOPE], "all_b_operator" -> 
    HoldComplete[HUU*Hhard*TMDf1[x, bq]*TMDD1[zh, bh]*Soft[bq], 
     HUT*Hhard*TMDh1[x, bq]*TMDCollins[zh, bh]*Soft[bq]], 
   "no_double_counting" -> "All-b Collins TMD includes HF. Add the separate \
HF term only in the local small-b expansion, never again to the all-b \
operator.", "order" -> "Strict a=alpha_s/(2pi); common linear flavor/Fourier \
integration before the asymmetry ratio.", "scope" -> "Shared physical-J0 \
scalar/rank continuation, physical HF endpoint class and narrow cone. No fit, \
unrestricted NLO, R=1, full twist-three or Figure6 certification."|>, 
 "ep_consumed_sphere" -> 1 - (eps^2*Pi^2)/12, 
 "ep_soft_details" -> 
  <|"values" -> <|"r03/soft_standard" -> <|"constant" -> RUExact[0], 
       "terms" -> {<|"ref" -> "r03/measured_normalization", 
          "factor" -> RUExact[(CF*(2*eta + eps*(-4 - Bq*eps*(4 + Bq*eta) + 
                 2*(1 + Bq*eps)*eta*V)))/(eps^2*eta)]|>}, "eta_order" -> 0, 
       "eps_order" -> 0, "value" -> RUExact[-(Bq^2*CF) + (2*CF)/eps^2 - 
          (4*Bq*CF)/eta - (4*CF)/(eps*eta) - (CF*Pi^2)/6 + 2*Bq*CF*V + 
          (2*CF*V)/eps], "sectors" -> {"recoil_soft", "jet_UU", "jet_UT"}|>, 
     "r03/soft_global" -> <|"constant" -> RUExact[0], 
       "terms" -> {<|"ref" -> "r03/measured_normalization", 
          "factor" -> RUExact[(CF*(2*eta + Bq*eps^2*(-2 + eta*(V + 2*Y)) + 
               eps*(-2 + eta*(Bq + V + 2*Y))))/(eps^2*eta)]|>}, 
       "eta_order" -> 0, "eps_order" -> 0, "value" -> 
        RUExact[(2*CF)/eps^2 + (Bq*CF)/eps - (2*Bq*CF)/eta - 
          (2*CF)/(eps*eta) - (CF*Pi^2)/6 + Bq*CF*V + (CF*V)/eps + 2*Bq*CF*Y + 
          (2*CF*Y)/eps], "sectors" -> {"recoil_soft", "jet_UU", "jet_UT"}|>, 
     "r03/soft_injet" -> <|"constant" -> RUExact[0], 
       "terms" -> {<|"ref" -> "r03/measured_normalization", 
          "factor" -> RUExact[(CF*(2*eta - eps*(4 + Bh*eps*(4 + Bh*eta) + 
                 2*(1 + Bh*eps)*eta*g) + 2*eps*(1 + Bh*eps)*eta*V))/
             (2*eps^2*eta)]|>}, "eta_order" -> 0, "eps_order" -> 0, 
       "value" -> RUExact[-1/2*(Bh^2*CF) + CF/eps^2 - (2*Bh*CF)/eta - 
          (2*CF)/(eps*eta) - Bh*CF*g - (CF*g)/eps - (CF*Pi^2)/12 + Bh*CF*V + 
          (CF*V)/eps], "sectors" -> {"recoil_soft", "jet_UU", "jet_UT"}|>, 
     "r03/soft_cs_out" -> <|"constant" -> RUExact[0], 
       "terms" -> {<|"ref" -> "r03/measured_normalization", 
          "factor" -> RUExact[-1/2*(CF*(2 + eps*(Bq - r)*(2 + Bq*eps - 
                  eps*r)))/eps^2]|>}, "eta_order" -> 0, "eps_order" -> 0, 
       "value" -> RUExact[-1/2*(Bq^2*CF) - CF/eps^2 - (Bq*CF)/eps + 
          (CF*Pi^2)/12 + Bq*CF*r + (CF*r)/eps - (CF*r^2)/2], 
       "sectors" -> {"recoil_soft", "jet_UU", "jet_UT"}|>, 
     "r03/recoil_soft_bare" -> <|"constant" -> RUExact[0], 
       "terms" -> {<|"ref" -> "r03/soft_global", "factor" -> RUExact[1]|>, 
         <|"ref" -> "r03/soft_cs_out", "factor" -> RUExact[1]|>, 
         <|"ref" -> "r03/soft_standard", "factor" -> RUExact[-1/2]|>}, 
       "eta_order" -> 0, "eps_order" -> 0, "value" -> 
        RUExact[Bq*CF*r + (CF*r)/eps - (CF*r^2)/2 + 2*Bq*CF*Y + 
          (2*CF*Y)/eps], "sectors" -> {"recoil_soft"}|>, 
     "r03/recoil_soft_finite" -> 
      <|"constant" -> RUExact[-((CF*r + 2*CF*Y)/eps)], 
       "terms" -> {<|"ref" -> "r03/recoil_soft_bare", "factor" -> 
           RUExact[1]|>}, "eta_order" -> 0, "eps_order" -> 0, 
       "value" -> RUExact[Bq*CF*r - (CF*r^2)/2 + 2*Bq*CF*Y], 
       "sectors" -> {"recoil_soft"}|>, "r03/jet_common_overlap" -> 
      <|"constant" -> RUExact[0], "terms" -> 
        {<|"ref" -> "r03/measured_normalization", "factor" -> 
           RUExact[(CF*(2*eta + eps*(-4 - Bh*eps*(4 + Bh*eta) + 
                 2*(1 + Bh*eps)*eta*(-g + V))))/(2*eps^2*eta)]|>}, 
       "eta_order" -> 0, "eps_order" -> 0, "value" -> 
        RUExact[-1/2*(Bh^2*CF) + CF/eps^2 - (2*Bh*CF)/eta - 
          (2*CF)/(eps*eta) - Bh*CF*g - (CF*g)/eps - (CF*Pi^2)/12 + Bh*CF*V + 
          (CF*V)/eps], "sectors" -> {"jet_UU", "jet_UT"}|>, 
     "r03/jet_comparison_bare" -> <|"constant" -> RUExact[0], 
       "terms" -> {<|"ref" -> "r03/measured_normalization", 
          "factor" -> RUExact[(CF*(2*eta + 2*eps*(1 + B*eps)*eta*g - eps*
                (4 + B*eps*(4 + B*eta) + 2*(1 + B*eps)*eta*g)))/
             (2*eps^2*eta)]|>}, "eta_order" -> 0, "eps_order" -> 0, 
       "value" -> RUExact[-1/2*(B^2*CF) + CF/eps^2 - (2*B*CF)/eta - 
          (2*CF)/(eps*eta) - (CF*Pi^2)/12], "sectors" -> 
        {"jet_UU", "jet_UT"}|>, "r03/jet_comparison_overlap" -> 
      <|"constant" -> RUExact[0], "terms" -> 
        {<|"ref" -> "r03/measured_normalization", "factor" -> 
           RUExact[(CF*(2*eta + eps*(-4 - B*eps*(4 + B*eta))))/
             (2*eps^2*eta)]|>}, "eta_order" -> 0, "eps_order" -> 0, 
       "value" -> RUExact[-1/2*(B^2*CF) + CF/eps^2 - (2*B*CF)/eta - 
          (2*CF)/(eps*eta) - (CF*Pi^2)/12], "sectors" -> 
        {"jet_UU", "jet_UT"}|>, "r03/jet_UU_bare_remainder" -> 
      <|"constant" -> RUExact[0], "terms" -> {<|"ref" -> "r03/soft_injet", 
          "factor" -> RUExact[1]|>, <|"ref" -> "r03/jet_common_overlap", 
          "factor" -> RUExact[-1]|>}, "eta_order" -> 0, "eps_order" -> 0, 
       "value" -> RUExact[0], "sectors" -> {"jet_UU"}|>, 
     "r03/jet_UT_bare_remainder" -> <|"constant" -> RUExact[0], 
       "terms" -> {<|"ref" -> "r03/soft_injet", "factor" -> RUExact[1]|>, 
         <|"ref" -> "r03/jet_common_overlap", "factor" -> RUExact[-1]|>}, 
       "eta_order" -> 0, "eps_order" -> 0, "value" -> RUExact[0], 
       "sectors" -> {"jet_UT"}|>|>, "recoil_bare" -> 
    Bq*CF*r + (CF*r)/eps - (CF*r^2)/2 + 2*Bq*CF*Y + (2*CF*Y)/eps, 
   "recoil_UV" -> -((CF*r + 2*CF*Y)/eps), "recoil_finite" -> 
    Bq*CF*r - (CF*r^2)/2 + 2*Bq*CF*Y, "jet_overlap" -> 
    -1/2*(Bh^2*CF) + CF/eps^2 - (2*Bh*CF)/eta - (2*CF)/(eps*eta) - Bh*CF*g - 
     (CF*g)/eps - (CF*Pi^2)/12 + Bh*CF*V + (CF*V)/eps, 
   "jet_bare_remainder" -> 0, "local_UV_definition" -> 
    HoldComplete[{N0 == 1, N1 == 0, PolyGamma[0, 1] == -EulerGamma}], 
   "measurement" -> <|"projectors" -> <|"generated_vertex" -> 
        <|"generated_term" -> DiracGamma[LorentzIndex[Lor2, D], D] . 
            DiracGamma[Momentum[k + pp, D], D] . DiracGamma[
             LorentzIndex[Lor1, D], D]/(Pair[Momentum[k, D], 
             Momentum[k, D]] + 2*Pair[Momentum[k, D], Momentum[pp, D]] + 
            Pair[Momentum[pp, D], Momentum[pp, D]]), "amputated_chain" -> 
          DiracGamma[LorentzIndex[Lor2, D], D] . DiracGamma[
            Momentum[k + pp, D], D] . DiracGamma[LorentzIndex[Lor1, D], D], 
         "propagator_route" -> k + pp, "amputation_weight" -> 1, 
         "vertex_D" -> DiracGamma[LorentzIndex[Lor2, D], D], 
         "physical_vertices" -> {{{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, -1, 0}, 
            {0, 0, 0, -1}}, {{0, 0, 0, 1}, {0, 0, 1, 0}, {0, -1, 0, 0}, 
            {-1, 0, 0, 0}}, {{0, 0, 0, -I}, {0, 0, I, 0}, {0, I, 0, 0}, 
            {-I, 0, 0, 0}}, {{0, 0, 1, 0}, {0, 0, 0, -1}, {-1, 0, 0, 0}, 
            {0, 1, 0, 0}}}|>, "operator_density_matrices" -> 
        {{{1, 0, -1, 0}, {0, 1, 0, 1}, {1, 0, -1, 0}, {0, -1, 0, -1}}, 
         {{0, 1, 0, 1}, {1, 0, -1, 0}, {0, 1, 0, 1}, {-1, 0, 1, 0}}}, 
       "physical_projectors" -> {{{1/2, 0, 1/2, 0}, {0, 1/2, 0, -1/2}, 
          {-1/2, 0, -1/2, 0}, {0, 1/2, 0, -1/2}}, {{0, -1/2*I, 0, I/2}, 
          {-1/2*I, 0, -1/2*I, 0}, {0, I/2, 0, -1/2*I}, {-1/2*I, 0, -1/2*I, 
           0}}}, "tree_norms" -> {4, -4*I}, 
       "generated_vertex_eikonal_reduction_residuals" -> 
        {{{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}, 
         {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}, 
         {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}, 
         {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}}, 
       "evanescent_vertex_reduction" -> HoldComplete[
         Slash[np$37466] . GammaTilde[mu] . Slash[np$37466] == 
          (-GammaTilde[mu])*npSquared == 0], "soft_current" -> 
        {(2*Sinh[yy])/kt, 0, 0, (2*Cosh[yy])/kt}, 
       "soft_current_Ward_residual" -> 0, "D_contracted_current_squared" -> 
        4/kt^2, "evanescent_metric_contraction" -> 0, "D_prescription" -> "BM\
HV physical external spin, gamma5 and lightlike Wilson directions; \
D-dimensional internal phase space. The evanescent current contraction \
vanishes because both Wilson directions are physical. Common full-D virtual \
and intrinsic collinear operators cancel before this residual is formed.", 
       "regulated_open_numerators" -> {{{4/kt^2, 0, -4/kt^2, 0}, 
          {0, 4/kt^2, 0, 4/kt^2}, {4/kt^2, 0, -4/kt^2, 0}, 
          {0, -4/kt^2, 0, -4/kt^2}}, {{0, 4/kt^2, 0, 4/kt^2}, 
          {4/kt^2, 0, -4/kt^2, 0}, {0, 4/kt^2, 0, 4/kt^2}, 
          {-4/kt^2, 0, 4/kt^2, 0}}}, "projected_numerators" -> 
        {4/kt^2, 4/kt^2}, "normalized_cut_weights" -> {1, 1}, 
       "epsilon_projection_after_rapidity_normalization" -> {0, 0}, 
       "probe_origin" -> "eps*eta*delta/(2 CF) is inserted in the open \
eikonal cut matrix, before taking either spin trace. Its rapidity integral is \
1/eta. No finite output is adjusted."|>, "measurement" -> 
      <|"process" -> HoldComplete[e + pTransverse -> e + jet[h] + X], 
       "anti_kt_pair_distance" -> ((ph12^2 + (y1 - y2)^2)*
          Min[pT1^(-2), pT2^(-2)])/R^2, "beam_distances" -> 
        {pT1^(-2), pT2^(-2)}, "standard_E_scheme" -> 
        HoldComplete[PJ == Sum[kIn[i], {i, inJet}]], 
       "measurement" -> HoldComplete[
         DiracDelta[qVec + Sum[kOutT[i], {i, outJet}]]*
          DiracDelta[jVec - kFragVec - zh*lambdaInVec]*
          DiracDelta[zh - PhMinus/PJMinus]], "one_emission_out_recoil_LP" -> 
        {-pT + pT*zJ, 0}, "out_recoil_squared" -> pT^2 - 2*pT^2*zJ + 
         pT^2*zJ^2, "injet_pair_bound" -> HoldComplete[
         kt^2 < zpart^2*(1 - zpart)^2*pT^2*R^2], 
       "hadron_transverse_from_hard_split" -> (kt*zh)/zpart, 
       "hard_injet_scaling" -> -(pT*R*zh*(-1 + zpart)), 
       "allowed_LP_regions" -> {"intrinsic jet-collinear kT~jT/zh", 
         "in-jet soft-collinear kT~jT/zh", 
         "out-of-jet soft giving measured qT"}, "hard_region_restriction" -> 
        "At one emission, exact transverse conservation fixes qT=-k_out,T. At \
fixed jet rapidity a hard jet-collinear out parton has k_out,T=(1-zJ)pT+O(R \
pT), so zJ away from one is excluded from the small-qT singular distribution. \
A hard in-jet split at angle R has jT=zh(1-zpart)pT R and lies outside \
small-jT LP. Its soft endpoints are retained, not discarded. The common \
virtual operator is identical before subtraction and carries no cone \
boundary.", "distribution_scope" -> "Expansion by regions of the joint qT,jT \
singular distribution, not evaluation of a plus distribution at zJ=1 and not \
an integral over the semi-inclusive pp jet-energy fraction. Endpoint soft \
real and virtual terms remain in the beam/jet soft allocation. The intrinsic \
TMD contains its full parton-fraction distributions and quark/gluon \
matching.", "out_soft_allocation" -> HoldComplete[Exp[I*bqVec . kOutT]*
          ThetaOutsideJet], "in_soft_allocation" -> 
        HoldComplete[Exp[I*bhVec . kInPerp]*ThetaInsideJet], 
       "zero_bin_cancellation" -> HoldComplete[(CollinearNaive - ZeroBin) + 
           SoftIn - (CollinearNaive - ZeroBin + StandardSoftHalf) == 
          SoftIn - StandardSoftHalf], "joint_Fourier_variables" -> 
        {bqVec, bhVec}, "soft_geometry_series" -> 4/rho^2 + (4*Cos[ph])/rho + 
         (3 + 2*Cos[2*ph])/3, "support_qualification" -> "The declared TMD \
expansion assumes zh=O(1), jT/(zh pT R)<<1 and qT/pT<<1; it is not a \
simultaneous small-zh or threshold factorization. Generic finite zh is \
retained inside the intrinsic operator distributions.", 
       "radius" -> "Only the leading local cone term 4/rho^2 is kept; the \
displayed subleading geometry is not a complete finite-R renormalized \
correction."|>, "collinear_regions" -> <|"generated_D_cut_inputs" -> 
        <|"UU_quark" -> (CF*(-1 + eps - 2*eps*z - z^2 + eps*z^2))/(-1 + z), 
         "UU_gluon" -> -((CF*(-2 + 2*z - z^2 + eps*z^2))/z), 
         "Collins_quark" -> (-2*CF*z)/(-1 + z)|>, "physical_J0_D_phase" -> 
        t^(-1 - eps)*BesselJ[0, (2*Sqrt[A*t])/z], 
       "rank_one_factor_removed" -> "The Collins coefficient is the scalar \
after removing the external physical -i b_alpha Hhat tensor. Its physical-J0 \
scalar/rank continuation is the retained prescription; the final rank-one \
inverse transform carries J1 and is not replaced with the UU measure.", 
       "regulated_measured_collinear_integrands" -> 
        <|"UU_quark" -> (CF*t^(-1 - eps)*(-1 + eps - 2*eps*z - z^2 + eps*z^2)*
            BesselJ[0, (2*Sqrt[A*t])/z]*UnitStep[-(lam^2*t) + 
              R^2*(1 - z)^2*z^2])/(-1 + z), "UU_gluon" -> 
          -((CF*t^(-1 - eps)*(-2 + 2*z - z^2 + eps*z^2)*BesselJ[0, 
              (2*Sqrt[A*t])/z]*UnitStep[-(lam^2*t) + R^2*(1 - z)^2*z^2])/z), 
         "Collins_quark" -> (-2*CF*t^(-1 - eps)*z*BesselJ[0, (2*Sqrt[A*t])/z]*
            UnitStep[-(lam^2*t) + R^2*(1 - z)^2*z^2])/(-1 + z)|>, 
       "LP_cone_test" -> 1, "intrinsic_unmeasured_integrands" -> 
        <|"UU_quark" -> (CF*t^(-1 - eps)*(-1 + eps - 2*eps*z - z^2 + eps*z^2)*
            BesselJ[0, (2*Sqrt[A*t])/z])/(-1 + z), "UU_gluon" -> 
          -((CF*t^(-1 - eps)*(-2 + 2*z - z^2 + eps*z^2)*BesselJ[0, 
              (2*Sqrt[A*t])/z])/z), "Collins_quark" -> 
          (-2*CF*t^(-1 - eps)*z*BesselJ[0, (2*Sqrt[A*t])/z])/(-1 + z)|>, 
       "LP_measured_integrands" -> <|"UU_quark" -> 
          (CF*t^(-1 - eps)*(-1 + eps - 2*eps*z - z^2 + eps*z^2)*
            BesselJ[0, (2*Sqrt[A*t])/z])/(-1 + z), "UU_gluon" -> 
          -((CF*t^(-1 - eps)*(-2 + 2*z - z^2 + eps*z^2)*BesselJ[0, 
              (2*Sqrt[A*t])/z])/z), "Collins_quark" -> 
          (-2*CF*t^(-1 - eps)*z*BesselJ[0, (2*Sqrt[A*t])/z])/(-1 + z)|>, 
       "common_real_integrand_residuals" -> <|"UU_quark" -> 0, 
         "UU_gluon" -> 0, "Collins_quark" -> 0|>, "soft_endpoint_residues" -> 
        <|"UU_quark" -> 2*CF, "UU_gluon" -> 0, "Collins_quark" -> 2*CF|>, 
       "soft_endpoint_rescaled_boundary" -> -t + R^2*w^2, 
       "soft_cone_boundary" -> HoldComplete[t < w^2*R^2], 
       "common_virtual_D_operator" -> <|"left_sail" -> 
          <|"open_projected_matrix" -> {{{(4 - 4*v)/4, (2*kx - (2*I)*ky)/
                4, (-4 + 4*v)/4, (2*kx - (2*I)*ky)/4}, {(-2*kx - (2*I)*ky)/
                4, (4 - 4*v)/4, (2*kx + (2*I)*ky)/4, (4 - 4*v)/4}, 
              {(4 - 4*v)/4, (-2*kx + (2*I)*ky)/4, (-4 + 4*v)/4, (-2*kx + 
                 (2*I)*ky)/4}, {(-2*kx - (2*I)*ky)/4, (-4 + 4*v)/4, 
               (2*kx + (2*I)*ky)/4, (-4 + 4*v)/4}}, {{(2*kx - (2*I)*ky)/4, 
               (4 - 4*v)/4, (-2*kx + (2*I)*ky)/4, (4 - 4*v)/4}, 
              {(4 - 4*v)/4, (-2*kx - (2*I)*ky)/4, (-4 + 4*v)/4, (-2*kx - 
                 (2*I)*ky)/4}, {(-2*kx + (2*I)*ky)/4, (4 - 4*v)/4, 
               (2*kx - (2*I)*ky)/4, (4 - 4*v)/4}, {(-4 + 4*v)/4, (-2*kx - 
                 (2*I)*ky)/4, (4 - 4*v)/4, (-2*kx - (2*I)*ky)/4}}}, 
           "denominators" -> {-kT2 + 4*kminus*v, -kT2 - 4*kminus*(1 - v), 
             2*v}, "rational_integrand" -> 
            {{{(4 - 4*v)/(8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (2*kx - (2*I)*ky)/(8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 
                  4*kminus*v)), (-4 + 4*v)/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v)), (2*kx - (2*I)*ky)/(8*(-kT2 - 
                  4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v))}, 
              {(-2*kx - (2*I)*ky)/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v)), (4 - 4*v)/(8*(-kT2 - 4*kminus*(1 - v))*
                 v*(-kT2 + 4*kminus*v)), (2*kx + (2*I)*ky)/
                (8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (4 - 4*v)/(8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*
                   v))}, {(4 - 4*v)/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v)), (-2*kx + (2*I)*ky)/
                (8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (-4 + 4*v)/(8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*
                   v)), (-2*kx + (2*I)*ky)/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v))}, {(-2*kx - (2*I)*ky)/
                (8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (-4 + 4*v)/(8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*
                   v)), (2*kx + (2*I)*ky)/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v)), (-4 + 4*v)/(8*(-kT2 - 4*kminus*
                   (1 - v))*v*(-kT2 + 4*kminus*v))}}, 
             {{(2*kx - (2*I)*ky)/(8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 
                  4*kminus*v)), (4 - 4*v)/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v)), (-2*kx + (2*I)*ky)/
                (8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (4 - 4*v)/(8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*
                   v))}, {(4 - 4*v)/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v)), (-2*kx - (2*I)*ky)/
                (8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (-4 + 4*v)/(8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*
                   v)), (-2*kx - (2*I)*ky)/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v))}, {(-2*kx + (2*I)*ky)/
                (8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (4 - 4*v)/(8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (2*kx - (2*I)*ky)/(8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 
                  4*kminus*v)), (4 - 4*v)/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v))}, {(-4 + 4*v)/(8*(-kT2 - 4*kminus*
                   (1 - v))*v*(-kT2 + 4*kminus*v)), (-2*kx - (2*I)*ky)/
                (8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (4 - 4*v)/(8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (-2*kx - (2*I)*ky)/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v))}}}, "rapidity_weight" -> 
            E^(eta*Lnu)/v^eta|>, "right_sail" -> <|"open_projected_matrix" -> 
            {{{(2*(1 - kminus - v) + 2*(1 + kminus - v))/4, (-kx + I*ky)/
                2, (2*(-1 - kminus + v) + 2*(-1 + kminus + v))/4, (kx - I*ky)/
                2}, {(kx + I*ky)/2, (2*(1 - kminus - v) - 2*(-1 - kminus + 
                   v))/4, (kx + I*ky)/2, (2*(1 + kminus - v) - 
                 2*(-1 + kminus + v))/4}, {(2*(1 - kminus - v) + 
                 2*(1 + kminus - v))/4, (-kx + I*ky)/2, (2*(-1 - kminus + 
                   v) + 2*(-1 + kminus + v))/4, (kx - I*ky)/2}, 
              {(-kx - I*ky)/2, (-2*(1 - kminus - v) + 2*(-1 - kminus + v))/
                4, (-kx - I*ky)/2, (-2*(1 + kminus - v) + 2*(-1 + kminus + 
                   v))/4}}, {{(kx + I*ky)/2, (2*(1 - kminus - v) - 
                 2*(-1 - kminus + v))/4, (kx + I*ky)/2, (2*(1 + kminus - v) - 
                 2*(-1 + kminus + v))/4}, {(2*(1 - kminus - v) + 
                 2*(1 + kminus - v))/4, (-kx + I*ky)/2, (2*(-1 - kminus + 
                   v) + 2*(-1 + kminus + v))/4, (kx - I*ky)/2}, 
              {(kx + I*ky)/2, (2*(1 - kminus - v) - 2*(-1 - kminus + v))/
                4, (kx + I*ky)/2, (2*(1 + kminus - v) - 2*(-1 + kminus + v))/
                4}, {(-2*(1 - kminus - v) - 2*(1 + kminus - v))/4, 
               (kx - I*ky)/2, (-2*(-1 - kminus + v) - 2*(-1 + kminus + v))/
                4, (-kx + I*ky)/2}}}, "denominators" -> {-kT2 + 4*kminus*v, 
             -kT2 - 4*kminus*(1 - v), 2*v}, "rational_integrand" -> 
            {{{(2*(1 - kminus - v) + 2*(1 + kminus - v))/(8*(-kT2 - 
                  4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), (-kx + I*ky)/
                (4*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (2*(-1 - kminus + v) + 2*(-1 + kminus + v))/
                (8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (kx - I*ky)/(4*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 
                  4*kminus*v))}, {(kx + I*ky)/(4*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v)), (2*(1 - kminus - v) - 
                 2*(-1 - kminus + v))/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v)), (kx + I*ky)/(4*(-kT2 - 4*kminus*
                   (1 - v))*v*(-kT2 + 4*kminus*v)), (2*(1 + kminus - v) - 
                 2*(-1 + kminus + v))/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v))}, {(2*(1 - kminus - v) + 
                 2*(1 + kminus - v))/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v)), (-kx + I*ky)/(4*(-kT2 - 4*kminus*
                   (1 - v))*v*(-kT2 + 4*kminus*v)), (2*(-1 - kminus + v) + 
                 2*(-1 + kminus + v))/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v)), (kx - I*ky)/(4*(-kT2 - 4*kminus*
                   (1 - v))*v*(-kT2 + 4*kminus*v))}, {(-kx - I*ky)/
                (4*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (-2*(1 - kminus - v) + 2*(-1 - kminus + v))/
                (8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (-kx - I*ky)/(4*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 
                  4*kminus*v)), (-2*(1 + kminus - v) + 2*(-1 + kminus + v))/
                (8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v))}}, 
             {{(kx + I*ky)/(4*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 
                  4*kminus*v)), (2*(1 - kminus - v) - 2*(-1 - kminus + v))/
                (8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (kx + I*ky)/(4*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 
                  4*kminus*v)), (2*(1 + kminus - v) - 2*(-1 + kminus + v))/
                (8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v))}, 
              {(2*(1 - kminus - v) + 2*(1 + kminus - v))/(8*(-kT2 - 
                  4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), (-kx + I*ky)/
                (4*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (2*(-1 - kminus + v) + 2*(-1 + kminus + v))/
                (8*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 4*kminus*v)), 
               (kx - I*ky)/(4*(-kT2 - 4*kminus*(1 - v))*v*(-kT2 + 
                  4*kminus*v))}, {(kx + I*ky)/(4*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v)), (2*(1 - kminus - v) - 
                 2*(-1 - kminus + v))/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v)), (kx + I*ky)/(4*(-kT2 - 4*kminus*
                   (1 - v))*v*(-kT2 + 4*kminus*v)), (2*(1 + kminus - v) - 
                 2*(-1 + kminus + v))/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v))}, {(-2*(1 - kminus - v) - 
                 2*(1 + kminus - v))/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v)), (kx - I*ky)/(4*(-kT2 - 4*kminus*
                   (1 - v))*v*(-kT2 + 4*kminus*v)), (-2*(-1 - kminus + v) - 
                 2*(-1 + kminus + v))/(8*(-kT2 - 4*kminus*(1 - v))*v*
                 (-kT2 + 4*kminus*v)), (-kx + I*ky)/(4*(-kT2 - 4*kminus*
                   (1 - v))*v*(-kT2 + 4*kminus*v))}}}, "rapidity_weight" -> 
            E^(eta*Lnu)/v^eta|>, "self_energy" -> 
          <|"shifted_D_even_numerator" -> 2*DiracGamma[Momentum[p, D], D] - 
             D*DiracGamma[Momentum[p, D], D] - 2*v*DiracGamma[Momentum[p, 
                D], D] + D*v*DiracGamma[Momentum[p, D], D], 
           "shifted_D_odd_numerator" -> -2*DiracGamma[Momentum[loopMomentum, 
                D], D] + D*DiracGamma[Momentum[loopMomentum, D], D], 
           "both_leg_open_matrix" -> {{{(-4*(-1 + eps)*(-1 + v) + 
                 12*(-1 + eps + v - eps*v))/8, 0, (12*(-1 + eps)*(-1 + v) - 
                 4*(-1 + eps + v - eps*v))/8, 0}, {0, (-4*(-1 + eps)*
                  (-1 + v) + 12*(-1 + eps + v - eps*v))/8, 0, 
               (-4*(-1 + eps)*(-1 + v) + 12*(-1 + eps + v - eps*v))/8}, 
              {(-4*(-1 + eps)*(-1 + v) + 12*(-1 + eps + v - eps*v))/8, 0, 
               (12*(-1 + eps)*(-1 + v) - 4*(-1 + eps + v - eps*v))/8, 0}, 
              {0, (12*(-1 + eps)*(-1 + v) - 4*(-1 + eps + v - eps*v))/8, 0, 
               (12*(-1 + eps)*(-1 + v) - 4*(-1 + eps + v - eps*v))/8}}, 
             {{0, (-8*(-1 + eps)*(-1 + v) + 8*(-1 + eps + v - eps*v))/8, 0, 
               (-8*(-1 + eps)*(-1 + v) + 8*(-1 + eps + v - eps*v))/8}, 
              {2*(-1 + eps + v - eps*v), 0, (8*(-1 + eps)*(-1 + v) - 
                 8*(-1 + eps + v - eps*v))/8, 0}, {0, (-8*(-1 + eps)*
                  (-1 + v) + 8*(-1 + eps + v - eps*v))/8, 0, 
               (-8*(-1 + eps)*(-1 + v) + 8*(-1 + eps + v - eps*v))/8}, 
              {(8*(-1 + eps)*(-1 + v) - 8*(-1 + eps + v - eps*v))/8, 0, -2*
                (-1 + eps)*(-1 + v), 0}}}, "combined_denominator" -> 
            (ellSquared + I*i0 + externalVirtuality*(1 - v)*v)^2, 
           "on_shell_even_integrand" -> {{{(-4*(-1 + eps)*(-1 + v) + 
                 12*(-1 + eps + v - eps*v))/(8*(ellSquared + I*i0)^2), 0, 
               (12*(-1 + eps)*(-1 + v) - 4*(-1 + eps + v - eps*v))/
                (8*(ellSquared + I*i0)^2), 0}, {0, (-4*(-1 + eps)*(-1 + v) + 
                 12*(-1 + eps + v - eps*v))/(8*(ellSquared + I*i0)^2), 0, 
               (-4*(-1 + eps)*(-1 + v) + 12*(-1 + eps + v - eps*v))/
                (8*(ellSquared + I*i0)^2)}, {(-4*(-1 + eps)*(-1 + v) + 
                 12*(-1 + eps + v - eps*v))/(8*(ellSquared + I*i0)^2), 0, 
               (12*(-1 + eps)*(-1 + v) - 4*(-1 + eps + v - eps*v))/
                (8*(ellSquared + I*i0)^2), 0}, {0, (12*(-1 + eps)*(-1 + v) - 
                 4*(-1 + eps + v - eps*v))/(8*(ellSquared + I*i0)^2), 0, 
               (12*(-1 + eps)*(-1 + v) - 4*(-1 + eps + v - eps*v))/
                (8*(ellSquared + I*i0)^2)}}, {{0, (-8*(-1 + eps)*(-1 + v) + 
                 8*(-1 + eps + v - eps*v))/(8*(ellSquared + I*i0)^2), 0, 
               (-8*(-1 + eps)*(-1 + v) + 8*(-1 + eps + v - eps*v))/
                (8*(ellSquared + I*i0)^2)}, {(2*(-1 + eps + v - eps*v))/
                (ellSquared + I*i0)^2, 0, (8*(-1 + eps)*(-1 + v) - 
                 8*(-1 + eps + v - eps*v))/(8*(ellSquared + I*i0)^2), 0}, 
              {0, (-8*(-1 + eps)*(-1 + v) + 8*(-1 + eps + v - eps*v))/
                (8*(ellSquared + I*i0)^2), 0, (-8*(-1 + eps)*(-1 + v) + 
                 8*(-1 + eps + v - eps*v))/(8*(ellSquared + I*i0)^2)}, 
              {(8*(-1 + eps)*(-1 + v) - 8*(-1 + eps + v - eps*v))/
                (8*(ellSquared + I*i0)^2), 0, (-2*(-1 + eps)*(-1 + v))/
                (ellSquared + I*i0)^2, 0}}}, "parameter_interval" -> {0, 1}, 
           "external_virtuality" -> 0, "odd_term_prescription" -> "The \
displayed shifted odd loop numerator integrates to zero only on the complete \
translation-invariant dimensional domain; retain the UV/IR distinction in the \
even scaleless integral."|>, "normalized_sail_routing" -> 
          <|"incoming" -> {1, 0, 0, 1}, "virtual_quark" -> {1 - kminus - v, 
             -kx, -ky, 1 + kminus - v}, "gluon" -> {kminus + v, kx, ky, 
             -kminus + v}, "external_lightcone_scale" -> 1|>, 
         "scale_scope" -> "Open matrix blocks use Pplus=1 by positive \
longitudinal rescaling; the general positive Pplus denominators and contour \
Jacobian are exported separately."|>, "common_virtual_residual" -> 
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
         0, 0, 0, 0}, "common_zero_bin_subtracted_difference" -> 
        softIn - standardHalf, "region_order" -> "First expand each \
fixed-fraction collinear integrand in lambda=jT/(zh pT), retaining its \
D-dimensional numerator. Its z->1 endpoint is a distinct soft region: set \
1-z=lambda*w before taking the limit; the surviving cone boundary is t<w^2 \
R^2. Subtract this zero bin from both intrinsic operators and add the \
appropriate soft factors. The HF coefficient starts at first order; its \
intrinsic operator is common and no one-loop eikonal multiplier of that \
coefficient enters at this order."|>, "fixed_radius_cut" -> 
      HoldComplete[DiracDelta[k^2]*Theta[k0]*DiracDelta[k . n - 1]*
        DiracDelta[-kTransverse^2 - tau]], "eikonal_cut_weight" -> 4/kt^2, 
     "beam_jet_current" -> {(Sqrt[tau]*Cosh[yy] - Sqrt[tau]*Sinh[yy])^(-1) - 
        Cosh[Y]/(-(Sqrt[tau]*Cos[ph]) + Sqrt[tau]*Cosh[Y]*Cosh[yy] - 
          Sqrt[tau]*Sinh[Y]*Sinh[yy]), 
       -(-(Sqrt[tau]*Cos[ph]) + Sqrt[tau]*Cosh[Y]*Cosh[yy] - 
          Sqrt[tau]*Sinh[Y]*Sinh[yy])^(-1), 0, 
       (Sqrt[tau]*Cosh[yy] - Sqrt[tau]*Sinh[yy])^(-1) - 
        Sinh[Y]/(-(Sqrt[tau]*Cos[ph]) + Sqrt[tau]*Cosh[Y]*Cosh[yy] - 
          Sqrt[tau]*Sinh[Y]*Sinh[yy])}, "beam_jet_Ward" -> 0, 
     "beam_jet_squared" -> (-2*E^(-Y + yy))/(tau*Cos[ph] - tau*Cosh[Y - yy]), 
     "beam_jet_stereographic_kernel" -> (4*rr^2)/(tau + rr^2*tau - 
        2*rr*tau*Cos[ph]), "conditional_eikonal_weight" -> 
      rr^2/(1 + rr^2 - 2*rr*Cos[ph]), "angular_Jacobian" -> 
      (Pi^(-1 + eps)*Gamma[1 - eps])/2, "angular_conversion" -> 
      HoldComplete[dy*(dOmega/totalOmega) == 
        (Gamma[1 - eps]/(2*Pi^(1 - eps)))*d^(2 - 2*eps)*
         (w/(w . w)^(1 - eps))], "global_indices" -> {-eps + eta/2, 1}, 
     "longitudinal_rescaling_Jacobian" -> aa^(-1), 
     "longitudinal_rescaling" -> HoldComplete[{k . n == aa, 
        k . p == tau/(2*aa), yy == Log[aa/Sqrt[tau]], dkPlus/kPlus == dy}], 
     "regulators" -> HoldComplete[{standard == (nu/Sqrt[tau])^eta/
          Abs[2*Sinh[yy]]^eta, global == ((nu/Sqrt[tau])^eta*Exp[(-eta)*Y])/
          rr^eta, injet == (nu/Sqrt[tau])^eta*Exp[(-eta)*yyLocal]}], 
     "regulator_allocation" -> "Standard soft and beam/jet soft have distinct \
rapidity coordinates; their common eta residue is combined at fixed epsilon, \
with the saved V/Y argument map. The in-jet local cone uses Vstandard=V-g. \
Physical J0 is the declared shared scalar/rank-one continuation, not a \
D-dimensional angular Bessel identity.", "cut_family_specialization" -> 
      HoldComplete[M[u -> 0]], "normalization" -> "The squared soft current \
multiplies the physical emitted-gluon cut with both spin projectors evaluated \
before integration. Its fixed-radius scalar measure is the u=0 member of M. \
Physical k+>0 and k->0 boundaries stay explicit when reinstating rapidity."|>\
, "factors" -> <|"transforms" -> <|"Euler_integrand" -> 
        (1 - u$1707)^(-1 + b$1707)*u$1707^(-1 + a$1707), 
       "Euler_evaluated" -> (Gamma[a$1707]*Gamma[b$1707])/
         Gamma[a$1707 + b$1707], "Euler_domain" -> HoldComplete[
         a$1707 > 0 && b$1707 > 0], "Laplace_integrand" -> 
        t$1707^(-1 + delta$1707)/E^(aa$1707*t$1707), "Laplace_evaluated" -> 
        Gamma[delta$1707]/aa$1707^delta$1707, "Gaussian_evaluated" -> 
        Sqrt[Pi]/Sqrt[t$1707], "physical_azimuth_integrand" -> 
        t$1707^(-1 + delta$1707)*BesselJ[0, 2*Sqrt[aa$1707*t$1707]], 
       "physical_azimuth_evaluated" -> Gamma[delta$1707]/
         (aa$1707^delta$1707*Gamma[1 - delta$1707]), 
       "physical_azimuth_domain" -> "A>0, 0<delta<1/4 for absolute \
convergence; analytic continuation in delta=-eps-eta/2 afterwards.", 
       "radial_gamma_ratio" -> Gamma[-eps - eta/2]/Gamma[1 + eps + eta/2], 
       "standard_original" -> HoldComplete[
         2*Integrate[(2*Sinh[yy$1707])^(-eta), {yy$1707, 0, Infinity}]], 
       "standard_substitution" -> HoldComplete[u$1707 == Exp[-2*yy$1707]], 
       "standard_Jacobian" -> u$1707^(-1), "standard_parameter_integrand" -> 
        u$1707^(-1 + eta/2)/(1 - u$1707)^eta, 
       "standard_rapidity_evaluated" -> (Gamma[1 - eta]*Gamma[eta/2])/
         Gamma[1 - eta/2], "standard_domain" -> "0<Re(eta)<1", 
       "eta_standard_regular" -> (2*Gamma[1 - eta]*Gamma[1 + eta/2])/
         Gamma[1 - eta/2], "global_original" -> HoldComplete[
         Integrate[1/((w . w)^a$1707*((w - e) . (w - e))^b$1707), 
           {w, EuclideanSpace[dd$1707]}]/Pi^(dd$1707/2)], 
       "global_indices" -> {a$1707 -> -eps + eta/2, b$1707 -> 1, 
         dd$1707 -> 2 - 2*eps}, "global_Schwinger" -> 
        HoldComplete[lambda$1707^(a$1707 - 1)*kappa$1707^(b$1707 - 1)*
          (Exp[(-lambda$1707)*w . w - kappa$1707*(w - e) . (w - e)]/
           (Gamma[a$1707]*Gamma[b$1707]))], "global_square_completion" -> 
        HoldComplete[lambda$1707*w . w + kappa$1707*(w - e) . (w - e) == 
          t$1707*(w - (1 - u$1707)*e) . (w - (1 - u$1707)*e) + 
           t$1707*u$1707*(1 - u$1707)], "global_parameter_Jacobian" -> 
        t$1707, "global_parameter_powers" -> t$1707^(a$1707 - dd$1707/2)*
         u$1707^(-1 + a$1707)*(t$1707 - t$1707*u$1707)^(-1 + b$1707), 
       "global_scale_integral_evaluated" -> ((1 - u$1707)*u$1707)^
          (-a$1707 - b$1707 + dd$1707/2)*Gamma[a$1707 + b$1707 - dd$1707/2], 
       "global_beta_integrand" -> (1 - u$1707)^(-1 - a$1707 + dd$1707/2)*
         u$1707^(-1 - b$1707 + dd$1707/2), "global_general_evaluated" -> 
        (Gamma[a$1707 + b$1707 - dd$1707/2]*Gamma[-a$1707 + dd$1707/2]*
          Gamma[-b$1707 + dd$1707/2])/(Gamma[a$1707]*Gamma[b$1707]*
          Gamma[-a$1707 - b$1707 + dd$1707]), "global_angular_evaluated" -> 
        (Gamma[-eps]*Gamma[1 - eta/2]*Gamma[eta/2])/(Gamma[1 - eps - eta/2]*
          Gamma[-eps + eta/2]), "eta_global_regular" -> 
        (2*Gamma[-eps]*Gamma[1 - eta/2]*Gamma[1 + eta/2])/
         (Gamma[1 - eps - eta/2]*Gamma[-eps + eta/2]), 
       "rapidity_regularization_identity" -> HoldComplete[
         eta*Gamma[eta/2] == 2*Gamma[1 + eta/2]], "global_domain" -> "a,b>0, \
d/2-a>0, d/2-b>0, a+b-d/2>0. Here eps<0 and 0<eta<2; the scalar integrals \
admit meromorphic continuation afterwards.", "narrow_cone_step" -> "Expand \
cosh(y-Y)-cos(phi) and the E-scheme anti-kt boundary locally to rho^2/2 and \
rho>R; retain this approximation only in cone sectors.", 
       "cone_original" -> 2*rr$1707^(-1 - 2*eps), "cone_lower_boundary" -> 
        rad$1707, "cone_evaluated" -> 1/(eps*rad$1707^(2*eps)), 
       "cone_log_evaluated" -> 1/(E^(eps*r)*eps), "cone_domain" -> "Re(eps)>0 \
for the out-of-cone angular integral alone; continue its evaluated \
meromorphic result before multiplying the separately regulated radial \
integral.", "injet_original" -> E^(-(eta*yy$1707)), "injet_lower_boundary" -> 
        -1/2*g, "injet_rapidity_evaluated" -> E^((eta*g)/2)/eta, 
       "injet_domain" -> "Re(eta)>0, real g", "continuation_order" -> "Evalua\
te each factor in its own nonempty convergence domain, continue Beta/Gamma \
functions, expand eta first at fixed noninteger eps, cancel unexpanded eta \
residues, and only then expand eps. Kira never differentiates a cone \
boundary."|>, "ratios_to_native_sphere" -> 
      <|"standard" -> (CF*(2*eta + eps*(-4 - B*eps*(4 + B*eta) + 
             2*(1 + B*eps)*eta*V)))/(eps^2*eta), 
       "global" -> (CF*(2*eta + B*eps^2*(-2 + eta*(V + 2*Y)) + 
           eps*(-2 + eta*(B + V + 2*Y))))/(eps^2*eta), 
       "injet" -> (CF*(2*eta - eps*(4 + B*eps*(4 + B*eta) + 2*(1 + B*eps)*eta*
              g) + 2*eps*(1 + B*eps)*eta*V))/(2*eps^2*eta), 
       "cs_out" -> -1/2*(CF*(2 + eps*(B - r)*(2 + B*eps - eps*r)))/eps^2|>, 
     "unexpanded_ratios" -> <|"standard" -> 
        (4*CF*E^(eps*(B - 2*EulerGamma) + eta*(-EulerGamma + (B - V)/2))*
          Gamma[1 - eta]*Gamma[-eps - eta/2]*Gamma[1 + eta/2])/
         (eta*Gamma[1 - eta/2]*Gamma[1 + eps + eta/2]), 
       "global" -> (2*CF*E^(eps*(B - 2*EulerGamma) + 
            eta*(-EulerGamma + (B - V)/2) - eta*Y)*Gamma[1 - eps]*Gamma[-eps]*
          Gamma[1 - eta/2]*Gamma[-eps - eta/2]*Gamma[1 + eta/2])/
         (eta*Gamma[1 - eps - eta/2]*Gamma[-eps + eta/2]*
          Gamma[1 + eps + eta/2]), "injet" -> 
        (2*CF*E^(eps*(B - 2*EulerGamma) + (eta*g)/2 + 
            eta*(-EulerGamma + (B - V)/2))*Gamma[-eps - eta/2])/
         (eta*Gamma[1 + eps + eta/2]), "cs_out" -> 
        (CF*E^(eps*(B - 2*EulerGamma) - eps*r)*Gamma[-eps])/
         (eps*Gamma[1 + eps])|>, "fixed_radius_sphere_origin" -> "Actual \
three-cut M family, same radial density and D-dimensional angular measure \
before Fourier transformation. The angular ratios describe the conditional \
eikonal weight, not an additional inclusive angular moment.", 
     "rapidity_Jacobian" -> 1, "physical_cut_Jacobian" -> 1/2, 
     "rapidity_map" -> HoldComplete[{kPlus == Sqrt[tau]*Exp[yy], 
        kMinus == Sqrt[tau]*Exp[-yy], kPlus*kMinus == tau}], 
     "positive_energy" -> HoldComplete[tau > 0 && kPlus > 0 && kMinus > 0], 
     "theta_boundary" -> <|"bulk" -> -E^(-(eta*y0)), 
       "surface" -> E^(-(eta*y0)), "sum" -> 0|>, "IBP_domain" -> "Only the \
fixed-radius/fixed-longitudinal scalar cut family is reduced. Eikonal angles, \
eta powers and cone theta functions are integrated with their exact \
boundaries by the displayed transformations. No ordinary IBP is applied \
across a cone boundary.", "order" -> "Analytic eta continuation and eta \
expansion at fixed noninteger eps precede every epsilon expansion."|>, 
   "inclusive_jet" -> "Excluded from the identified-hadron operator; the \
fragmenting jet replaces it.", "scope" -> "Leading-power joint qT,jT, \
physical J0 continuation and leading narrow cone; R=1 and nonsingular NLO \
uncertified."|>, "highpt_matching" -> 
  <|"Uqq" -> <|"delta" -> -1/12*(CF*(6*L^2 - Pi^2)), "plus0" -> 2*CF*L, 
     "plus1" -> -4*CF, "regular" -> -(CF*(1 + L - z + L*z - 2*Log[1 - z] - 
         2*z*Log[1 - z]))|>, "Uqg" -> <|"delta" -> 0, "plus0" -> 0, 
     "plus1" -> 0, "regular" -> (CF*(2*L - 2*L*z - z^2 + L*z^2 - 
         4*Log[1 - z] + 4*z*Log[1 - z] - 2*z^2*Log[1 - z]))/z|>, 
   "Ugg" -> <|"delta" -> -1/12*(CA*(6*L^2 - Pi^2)), "plus0" -> 2*CA*L, 
     "plus1" -> -4*CA, "regular" -> (-2*CA*(-1 + 2*z - z^2 + z^3)*
        (L - 2*Log[1 - z]))/z|>, "Ugq" -> <|"delta" -> 0, "plus0" -> 0, 
     "plus1" -> 0, "regular" -> TF*(L - 2*z - 2*L*z + 2*z^2 + 2*L*z^2 - 
        2*Log[1 - z] + 4*z*Log[1 - z] - 4*z^2*Log[1 - z])|>, 
   "Tqq" -> <|"delta" -> -1/12*(CF*(6*L^2 - Pi^2)), "plus0" -> 2*CF*L, 
     "plus1" -> -4*CF, "regular" -> -2*CF*(L - 2*Log[1 - z])|>|>, 
 "highpt_born_banks" -> 
  <|"UU_Hqq" -> 
    <|"LO" -> <|"L" -> (16*eq^2*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 6*Q2^3*s + 
            7*Q2^2*s^2 + 4*Q2*s^3 + s^4 + 2*Q2^3*t + 2*Q2^2*s*t + Q2^2*t^2 + 
            s^2*t^2))/(Nc*s*(Q2 + s)^2*t) - (16*eq^2*(-1 + Nc)*(1 + Nc)*Pi^3*
           (2*Q2^4 + 6*Q2^3*s + 7*Q2^2*s^2 + 4*Q2*s^3 + s^4 + 2*Q2^3*t - 
            2*Q2^2*s*t - 4*Q2*s^2*t + Q2^2*t^2 - 4*Q2*s*t^2 + s^2*t^2))/
          (Nc*s*(Q2 + s)^2*t), "T" -> (-32*eq^2*(-1 + Nc)*(1 + Nc)*Pi^3*
          (2*Q2^4 + 6*Q2^3*s + 7*Q2^2*s^2 + 4*Q2*s^3 + s^4 + 2*Q2^3*t + 
           2*Q2^2*s*t + Q2^2*t^2 + s^2*t^2))/(Nc*s*(Q2 + s)^2*t)|>|>, 
   "UT_Hqq" -> <|"LO" -> <|"L" -> 0, "T" -> (64*eq^2*Pi^3*(-1 + SUNN)*
          (1 + SUNN))/SUNN|>|>|>, "highpt_assembly" -> 
  <|"UU" -> <|"LO" -> Inactive[Sum][
       (Q2*f1[{i, sigma}, ((Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*xB)/
           (Q2 - (pJT*Sqrt[Q2])/u), muCommon]*
         ((-32*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                (-u^(-1) + u)) + Q2^2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2 + 
             6*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                 (pJT*Sqrt[Q2])/u)) + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                (Q2 - (pJT*Sqrt[Q2])/u)) + 7*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*
                   (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^2 + 
             Q2^2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2*
              (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/
                   u))^2 + 4*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                 (Q2 - (pJT*Sqrt[Q2])/u))^3 + 
             Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                  (pJT*Sqrt[Q2])/u))^4)*(1 + (1 - y)^2)*quarkCharge[i]^2)/
           (Nc*Q2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))*
            (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))*
            (Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                  (pJT*Sqrt[Q2])/u)))^2) + 4*(1 - y)*
           ((16*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                  (-u^(-1) + u)) + Q2^2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^
                 2 + 6*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                  (Q2 - (pJT*Sqrt[Q2])/u)) + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                  (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                  (Q2 - (pJT*Sqrt[Q2])/u)) + 7*Q2^4*
                (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/
                     u))^2 + Q2^2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2*
                (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/
                     u))^2 + 4*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                   (Q2 - (pJT*Sqrt[Q2])/u))^3 + Q2^4*
                (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/
                     u))^4)*quarkCharge[i]^2)/(Nc*Q2*(-Q2 - pJT*Sqrt[Q2]*
                (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                (Q2 - (pJT*Sqrt[Q2])/u))*(Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[Q2]*
                     (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)))^2) - 
            (16*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                  (-u^(-1) + u)) + Q2^2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^
                 2 + 6*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                  (Q2 - (pJT*Sqrt[Q2])/u)) - 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                  (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                  (Q2 - (pJT*Sqrt[Q2])/u)) - 4*Q2^2*(-Q2 - pJT*Sqrt[Q2]*
                   (-u^(-1) + u))^2*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                  (Q2 - (pJT*Sqrt[Q2])/u)) + 7*Q2^4*
                (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/
                     u))^2 - 4*Q2^3*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))*
                (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/
                     u))^2 + Q2^2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2*
                (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/
                     u))^2 + 4*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                   (Q2 - (pJT*Sqrt[Q2])/u))^3 + Q2^4*
                (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/
                     u))^4)*quarkCharge[i]^2)/(Nc*Q2*(-Q2 - pJT*Sqrt[Q2]*
                (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                (Q2 - (pJT*Sqrt[Q2])/u))*(Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[Q2]*
                     (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)))^2)))*
         Inactive[Integrate][b$1432*BesselJ[0, (b$1432*jT)/zh]*
           D1Tilde[{i, sigma}, zh, b$1432, muCommon, pJT^2*R^2], 
          {b$1432, 0, Infinity}])/(2*Pi*(Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*
         y^2), {i, 1, Nf}, {sigma, {-1, 1}}], "Born_times_jet_NLO" -> 
      Inactive[Sum][(Inactive[Integrate][b$1449*BesselJ[0, (b$1449*jT)/zh]*
            D1Tilde["g", zh, b$1449, muCommon, pJT^2*R^2], 
           {b$1449, 0, Infinity}]*Inactive[Integrate][
           ((-1 + Nc^2)*Q2*f1[{i, sigma}, (xB*(Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + 
                    u))/zz$1431))/(Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)), 
              muCommon]*(-zz$1431^2 + 2*Log[muCommon^2/(pJT^2*R^2)] - 
              2*zz$1431*Log[muCommon^2/(pJT^2*R^2)] + zz$1431^2*Log[
                muCommon^2/(pJT^2*R^2)] - 4*Log[1 - zz$1431] + 
              4*zz$1431*Log[1 - zz$1431] - 2*zz$1431^2*Log[1 - zz$1431])*
             ((-32*(-1 + Nc)*(1 + Nc)*Pi^3*(1 + (1 - y)^2)*(2*Q2^4 + 
                 6*Q2^4*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                    (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431))) + 7*Q2^4*
                  (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                     (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2 + 4*Q2^4*
                  (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                     (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^3 + Q2^4*
                  (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                     (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^4 + 2*Q2^3*
                  (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) + 
                 2*Q2^3*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                    (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                     (-u^(-1) + u))/zz$1431) + Q2^2*(-Q2 - (pJT*Sqrt[Q2]*
                      (-u^(-1) + u))/zz$1431)^2 + Q2^2*
                  (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                     (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2*
                  (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2)*
                quarkCharge[i]^2)/(Nc*Q2*(Q2 + Q2*(-1 + (Q2 + (pJT*Sqrt[Q2]*
                        (-u^(-1) + u))/zz$1431)/(Q2 - (pJT*Sqrt[Q2])/
                       (u*zz$1431))))^2*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + 
                      u))/zz$1431)/(Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))*
                (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)) + 
              4*(1 - y)*((16*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 6*Q2^4*
                    (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                      (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431))) + 7*Q2^4*
                    (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                       (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2 + 4*Q2^4*
                    (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                       (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^3 + Q2^4*
                    (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                       (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^4 + 2*Q2^3*
                    (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) + 
                   2*Q2^3*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                      (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                       (-u^(-1) + u))/zz$1431) + Q2^2*(-Q2 - (pJT*Sqrt[Q2]*
                        (-u^(-1) + u))/zz$1431)^2 + Q2^2*(-1 + 
                      (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                        (pJT*Sqrt[Q2])/(u*zz$1431)))^2*(-Q2 - (pJT*Sqrt[Q2]*
                        (-u^(-1) + u))/zz$1431)^2)*quarkCharge[i]^2)/
                 (Nc*Q2*(Q2 + Q2*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/
                         zz$1431)/(Q2 - (pJT*Sqrt[Q2])/(u*zz$1431))))^2*
                  (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                    (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                     (-u^(-1) + u))/zz$1431)) - (16*(-1 + Nc)*(1 + Nc)*Pi^3*
                  (2*Q2^4 + 6*Q2^4*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/
                        zz$1431)/(Q2 - (pJT*Sqrt[Q2])/(u*zz$1431))) + 
                   7*Q2^4*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                       (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2 + 4*Q2^4*
                    (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                       (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^3 + Q2^4*
                    (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                       (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^4 + 2*Q2^3*
                    (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) - 
                   2*Q2^3*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                      (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                       (-u^(-1) + u))/zz$1431) - 4*Q2^3*(-1 + 
                      (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                        (pJT*Sqrt[Q2])/(u*zz$1431)))^2*(-Q2 - (pJT*Sqrt[Q2]*
                       (-u^(-1) + u))/zz$1431) + Q2^2*(-Q2 - (pJT*Sqrt[Q2]*
                        (-u^(-1) + u))/zz$1431)^2 - 4*Q2^2*(-1 + 
                     (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                       (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                        (-u^(-1) + u))/zz$1431)^2 + Q2^2*(-1 + 
                      (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                        (pJT*Sqrt[Q2])/(u*zz$1431)))^2*(-Q2 - (pJT*Sqrt[Q2]*
                        (-u^(-1) + u))/zz$1431)^2)*quarkCharge[i]^2)/
                 (Nc*Q2*(Q2 + Q2*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/
                         zz$1431)/(Q2 - (pJT*Sqrt[Q2])/(u*zz$1431))))^2*
                  (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                    (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                     (-u^(-1) + u))/zz$1431)))))/(2*Nc*y^2*
             (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)*zz$1431^3), 
           {zz$1431, (pJT*(u^(-1) + (u*xB)/(1 - xB)))/Sqrt[Q2], 1}])/(2*Pi) + 
        (Inactive[Integrate][b$1443*BesselJ[0, (b$1443*jT)/zh]*
            D1Tilde[{i, sigma}, zh, b$1443, muCommon, pJT^2*R^2], 
           {b$1443, 0, Infinity}]*(((-1 + Nc^2)*Q2*f1[{i, sigma}, 
              ((Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*xB)/(Q2 - (pJT*Sqrt[Q2])/u), 
              muCommon]*(Pi^2 - 6*Log[muCommon^2/(pJT^2*R^2)]^2)*
             ((-32*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 2*Q2^3*(-Q2 - 
                   pJT*Sqrt[Q2]*(-u^(-1) + u)) + Q2^2*(-Q2 - pJT*Sqrt[Q2]*
                     (-u^(-1) + u))^2 + 6*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*
                      (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)) + 
                 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))*(-1 + 
                   (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/
                      u)) + 7*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                     (Q2 - (pJT*Sqrt[Q2])/u))^2 + Q2^2*(-Q2 - pJT*Sqrt[Q2]*
                     (-u^(-1) + u))^2*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                     (Q2 - (pJT*Sqrt[Q2])/u))^2 + 4*Q2^4*
                  (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                      (pJT*Sqrt[Q2])/u))^3 + Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*
                       (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^4)*
                (1 + (1 - y)^2)*quarkCharge[i]^2)/(Nc*Q2*(-Q2 - pJT*Sqrt[Q2]*
                  (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                  (Q2 - (pJT*Sqrt[Q2])/u))*(Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[Q2]*
                       (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)))^2) + 
              4*(1 - y)*((16*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 2*Q2^3*
                    (-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u)) + Q2^2*
                    (-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2 + 6*Q2^4*
                    (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                       (pJT*Sqrt[Q2])/u)) + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                      (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                      (Q2 - (pJT*Sqrt[Q2])/u)) + 7*Q2^4*(-1 + 
                      (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/
                         u))^2 + Q2^2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2*
                    (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                        (pJT*Sqrt[Q2])/u))^2 + 4*Q2^4*(-1 + (Q2 + pJT*
                         Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^3 + 
                   Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                        (pJT*Sqrt[Q2])/u))^4)*quarkCharge[i]^2)/
                 (Nc*Q2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))*(-1 + 
                   (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))*
                  (Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                        (pJT*Sqrt[Q2])/u)))^2) - (16*(-1 + Nc)*(1 + Nc)*Pi^3*
                  (2*Q2^4 + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u)) + 
                   Q2^2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2 + 6*Q2^4*
                    (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                       (pJT*Sqrt[Q2])/u)) - 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                      (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                      (Q2 - (pJT*Sqrt[Q2])/u)) - 4*Q2^2*(-Q2 - pJT*Sqrt[Q2]*
                       (-u^(-1) + u))^2*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + 
                         u))/(Q2 - (pJT*Sqrt[Q2])/u)) + 7*Q2^4*
                    (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                        (pJT*Sqrt[Q2])/u))^2 - 4*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                      (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                       (Q2 - (pJT*Sqrt[Q2])/u))^2 + Q2^2*(-Q2 - pJT*Sqrt[Q2]*
                       (-u^(-1) + u))^2*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + 
                          u))/(Q2 - (pJT*Sqrt[Q2])/u))^2 + 4*Q2^4*
                    (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                        (pJT*Sqrt[Q2])/u))^3 + Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*
                         (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^4)*
                  quarkCharge[i]^2)/(Nc*Q2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))*
                  (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                     (pJT*Sqrt[Q2])/u))*(Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[Q2]*
                         (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)))^2))))/
            (24*Nc*(Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*y^2) + 
           ((-1 + Nc^2)*Q2*f1[{i, sigma}, ((Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*
                xB)/(Q2 - (pJT*Sqrt[Q2])/u), muCommon]*
             Log[muCommon^2/(pJT^2*R^2)]*Log[1 - (pJT*(u^(-1) + (u*xB)/
                   (1 - xB)))/Sqrt[Q2]]*((-32*(-1 + Nc)*(1 + Nc)*Pi^3*
                (2*Q2^4 + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u)) + 
                 Q2^2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2 + 6*Q2^4*
                  (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                     (pJT*Sqrt[Q2])/u)) + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                    (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                    (Q2 - (pJT*Sqrt[Q2])/u)) + 7*Q2^4*
                  (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                      (pJT*Sqrt[Q2])/u))^2 + Q2^2*(-Q2 - pJT*Sqrt[Q2]*
                     (-u^(-1) + u))^2*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                     (Q2 - (pJT*Sqrt[Q2])/u))^2 + 4*Q2^4*
                  (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                      (pJT*Sqrt[Q2])/u))^3 + Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*
                       (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^4)*
                (1 + (1 - y)^2)*quarkCharge[i]^2)/(Nc*Q2*(-Q2 - pJT*Sqrt[Q2]*
                  (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                  (Q2 - (pJT*Sqrt[Q2])/u))*(Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[Q2]*
                       (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)))^2) + 
              4*(1 - y)*((16*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 2*Q2^3*
                    (-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u)) + Q2^2*
                    (-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2 + 6*Q2^4*
                    (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                       (pJT*Sqrt[Q2])/u)) + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                      (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                      (Q2 - (pJT*Sqrt[Q2])/u)) + 7*Q2^4*(-1 + 
                      (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/
                         u))^2 + Q2^2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2*
                    (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                        (pJT*Sqrt[Q2])/u))^2 + 4*Q2^4*(-1 + (Q2 + pJT*
                         Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^3 + 
                   Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                        (pJT*Sqrt[Q2])/u))^4)*quarkCharge[i]^2)/
                 (Nc*Q2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))*(-1 + 
                   (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))*
                  (Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                        (pJT*Sqrt[Q2])/u)))^2) - (16*(-1 + Nc)*(1 + Nc)*Pi^3*
                  (2*Q2^4 + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u)) + 
                   Q2^2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2 + 6*Q2^4*
                    (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                       (pJT*Sqrt[Q2])/u)) - 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                      (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                      (Q2 - (pJT*Sqrt[Q2])/u)) - 4*Q2^2*(-Q2 - pJT*Sqrt[Q2]*
                       (-u^(-1) + u))^2*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + 
                         u))/(Q2 - (pJT*Sqrt[Q2])/u)) + 7*Q2^4*
                    (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                        (pJT*Sqrt[Q2])/u))^2 - 4*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                      (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                       (Q2 - (pJT*Sqrt[Q2])/u))^2 + Q2^2*(-Q2 - pJT*Sqrt[Q2]*
                       (-u^(-1) + u))^2*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + 
                          u))/(Q2 - (pJT*Sqrt[Q2])/u))^2 + 4*Q2^4*
                    (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                        (pJT*Sqrt[Q2])/u))^3 + Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*
                         (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^4)*
                  quarkCharge[i]^2)/(Nc*Q2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))*
                  (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                     (pJT*Sqrt[Q2])/u))*(Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[Q2]*
                         (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)))^2))))/
            (Nc*(Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*y^2) - 
           ((-1 + Nc^2)*Q2*f1[{i, sigma}, ((Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*
                xB)/(Q2 - (pJT*Sqrt[Q2])/u), muCommon]*
             Log[1 - (pJT*(u^(-1) + (u*xB)/(1 - xB)))/Sqrt[Q2]]^2*
             ((-32*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 2*Q2^3*(-Q2 - 
                   pJT*Sqrt[Q2]*(-u^(-1) + u)) + Q2^2*(-Q2 - pJT*Sqrt[Q2]*
                     (-u^(-1) + u))^2 + 6*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*
                      (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)) + 
                 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))*(-1 + 
                   (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/
                      u)) + 7*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                     (Q2 - (pJT*Sqrt[Q2])/u))^2 + Q2^2*(-Q2 - pJT*Sqrt[Q2]*
                     (-u^(-1) + u))^2*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                     (Q2 - (pJT*Sqrt[Q2])/u))^2 + 4*Q2^4*
                  (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                      (pJT*Sqrt[Q2])/u))^3 + Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*
                       (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^4)*
                (1 + (1 - y)^2)*quarkCharge[i]^2)/(Nc*Q2*(-Q2 - pJT*Sqrt[Q2]*
                  (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                  (Q2 - (pJT*Sqrt[Q2])/u))*(Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[Q2]*
                       (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)))^2) + 
              4*(1 - y)*((16*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 2*Q2^3*
                    (-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u)) + Q2^2*
                    (-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2 + 6*Q2^4*
                    (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                       (pJT*Sqrt[Q2])/u)) + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                      (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                      (Q2 - (pJT*Sqrt[Q2])/u)) + 7*Q2^4*(-1 + 
                      (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/
                         u))^2 + Q2^2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2*
                    (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                        (pJT*Sqrt[Q2])/u))^2 + 4*Q2^4*(-1 + (Q2 + pJT*
                         Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^3 + 
                   Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                        (pJT*Sqrt[Q2])/u))^4)*quarkCharge[i]^2)/
                 (Nc*Q2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))*(-1 + 
                   (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))*
                  (Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                        (pJT*Sqrt[Q2])/u)))^2) - (16*(-1 + Nc)*(1 + Nc)*Pi^3*
                  (2*Q2^4 + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u)) + 
                   Q2^2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2 + 6*Q2^4*
                    (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                       (pJT*Sqrt[Q2])/u)) - 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                      (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                      (Q2 - (pJT*Sqrt[Q2])/u)) - 4*Q2^2*(-Q2 - pJT*Sqrt[Q2]*
                       (-u^(-1) + u))^2*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + 
                         u))/(Q2 - (pJT*Sqrt[Q2])/u)) + 7*Q2^4*
                    (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                        (pJT*Sqrt[Q2])/u))^2 - 4*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                      (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                       (Q2 - (pJT*Sqrt[Q2])/u))^2 + Q2^2*(-Q2 - pJT*Sqrt[Q2]*
                       (-u^(-1) + u))^2*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + 
                          u))/(Q2 - (pJT*Sqrt[Q2])/u))^2 + 4*Q2^4*
                    (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                        (pJT*Sqrt[Q2])/u))^3 + Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*
                         (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^4)*
                  quarkCharge[i]^2)/(Nc*Q2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))*
                  (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                     (pJT*Sqrt[Q2])/u))*(Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[Q2]*
                         (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)))^2))))/
            (Nc*(Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*y^2) + Inactive[Integrate][
            -1/2*((-1 + Nc^2)*Q2*f1[{i, sigma}, (xB*(Q2 + (pJT*Sqrt[Q2]*
                      (-u^(-1) + u))/zz$1431))/(Q2 - (pJT*Sqrt[Q2])/
                    (u*zz$1431)), muCommon]*(1 - zz$1431 + Log[muCommon^2/
                   (pJT^2*R^2)] + zz$1431*Log[muCommon^2/(pJT^2*R^2)] - 
                 2*Log[1 - zz$1431] - 2*zz$1431*Log[1 - zz$1431])*
                ((-32*(-1 + Nc)*(1 + Nc)*Pi^3*(1 + (1 - y)^2)*(2*Q2^4 + 
                    6*Q2^4*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                       (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431))) + 7*Q2^4*
                     (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                        (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2 + 4*Q2^4*
                     (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                        (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^3 + Q2^4*
                     (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                        (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^4 + 2*Q2^3*
                     (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) + 
                    2*Q2^3*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                       (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - 
                      (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) + Q2^2*
                     (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2 + 
                    Q2^2*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                        (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2*
                     (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2)*
                   quarkCharge[i]^2)/(Nc*Q2*(Q2 + Q2*(-1 + (Q2 + 
                         (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                         (pJT*Sqrt[Q2])/(u*zz$1431))))^2*(-1 + 
                    (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                      (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                      (-u^(-1) + u))/zz$1431)) + 4*(1 - y)*
                  ((16*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 6*Q2^4*(-1 + 
                        (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431))) + 7*Q2^4*
                       (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2 + 4*Q2^4*
                       (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^3 + Q2^4*
                       (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^4 + 2*Q2^3*
                       (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) + 
                      2*Q2^3*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          zz$1431)/(Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))*
                       (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) + 
                      Q2^2*(-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2 + 
                      Q2^2*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2*
                       (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2)*
                     quarkCharge[i]^2)/(Nc*Q2*(Q2 + Q2*(-1 + (Q2 + 
                          (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431))))^2*(-1 + 
                      (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                        (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                        (-u^(-1) + u))/zz$1431)) - (16*(-1 + Nc)*(1 + Nc)*
                     Pi^3*(2*Q2^4 + 6*Q2^4*(-1 + (Q2 + (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)/(Q2 - (pJT*Sqrt[Q2])/
                          (u*zz$1431))) + 7*Q2^4*(-1 + (Q2 + (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)/(Q2 - (pJT*Sqrt[Q2])/
                          (u*zz$1431)))^2 + 4*Q2^4*(-1 + (Q2 + (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)/(Q2 - (pJT*Sqrt[Q2])/
                          (u*zz$1431)))^3 + Q2^4*(-1 + (Q2 + (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)/(Q2 - (pJT*Sqrt[Q2])/
                          (u*zz$1431)))^4 + 2*Q2^3*(-Q2 - (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431) - 2*Q2^3*(-1 + 
                        (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431) - 4*Q2^3*(-1 + 
                         (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431)))^2*(-Q2 - (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431) + Q2^2*(-Q2 - (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)^2 - 4*Q2^2*(-1 + 
                        (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)^2 + Q2^2*(-1 + 
                         (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431)))^2*(-Q2 - (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)^2)*quarkCharge[i]^2)/
                    (Nc*Q2*(Q2 + Q2*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          zz$1431)/(Q2 - (pJT*Sqrt[Q2])/(u*zz$1431))))^2*
                     (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                       (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - 
                      (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)))))/(Nc*y^2*
                (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)*zz$1431^2) + 
             (Log[1 - zz$1431]*((2*(-1 + Nc^2)*Q2*f1[{i, sigma}, 
                   ((Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*xB)/(Q2 - 
                     (pJT*Sqrt[Q2])/u), muCommon]*((-32*(-1 + Nc)*(1 + Nc)*
                     Pi^3*(2*Q2^4 + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + 
                          u)) + Q2^2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2 + 
                      6*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                         (Q2 - (pJT*Sqrt[Q2])/u)) + 2*Q2^3*(-Q2 - pJT*
                         Sqrt[Q2]*(-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)) + 
                      7*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u))^2 + Q2^2*(-Q2 - pJT*Sqrt[Q2]*
                          (-u^(-1) + u))^2*(-1 + (Q2 + pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^2 + 
                      4*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u))^3 + Q2^4*(-1 + (Q2 + pJT*
                          Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^4)*
                     (1 + (1 - y)^2)*quarkCharge[i]^2)/(Nc*Q2*(-Q2 - 
                      pJT*Sqrt[Q2]*(-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*
                         (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))*
                     (Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          (Q2 - (pJT*Sqrt[Q2])/u)))^2) + 4*(1 - y)*
                    ((16*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 2*Q2^3*(-Q2 - 
                          pJT*Sqrt[Q2]*(-u^(-1) + u)) + Q2^2*(-Q2 - pJT*
                          Sqrt[Q2]*(-u^(-1) + u))^2 + 6*Q2^4*(-1 + 
                          (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u)) + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                          (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + 
                          u))/(Q2 - (pJT*Sqrt[Q2])/u)) + 7*Q2^4*
                         (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u))^2 + Q2^2*(-Q2 - pJT*Sqrt[Q2]*
                          (-u^(-1) + u))^2*(-1 + (Q2 + pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^2 + 
                        4*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          (Q2 - (pJT*Sqrt[Q2])/u))^3 + Q2^4*(-1 + 
                          (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u))^4)*quarkCharge[i]^2)/(Nc*Q2*
                       (-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))*(-1 + 
                        (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u))*(Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[
                          Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)))^2) - 
                     (16*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 2*Q2^3*(-Q2 - 
                          pJT*Sqrt[Q2]*(-u^(-1) + u)) + Q2^2*(-Q2 - pJT*
                          Sqrt[Q2]*(-u^(-1) + u))^2 + 6*Q2^4*(-1 + 
                          (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u)) - 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                          (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + 
                          u))/(Q2 - (pJT*Sqrt[Q2])/u)) - 4*Q2^2*(-Q2 - 
                          pJT*Sqrt[Q2]*(-u^(-1) + u))^2*(-1 + (Q2 + pJT*
                          Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)) + 
                        7*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          (Q2 - (pJT*Sqrt[Q2])/u))^2 - 4*Q2^3*(-Q2 - 
                          pJT*Sqrt[Q2]*(-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[
                          Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^2 + 
                        Q2^2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2*
                         (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u))^2 + 4*Q2^4*(-1 + (Q2 + pJT*
                          Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^
                          3 + Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          (Q2 - (pJT*Sqrt[Q2])/u))^4)*quarkCharge[i]^2)/
                      (Nc*Q2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))*(-1 + 
                        (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u))*(Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[
                          Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)))^2))))/
                 (Nc*(Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*y^2) - 
                (2*(-1 + Nc^2)*Q2*f1[{i, sigma}, (xB*(Q2 + (pJT*Sqrt[Q2]*
                        (-u^(-1) + u))/zz$1431))/(Q2 - (pJT*Sqrt[Q2])/
                      (u*zz$1431)), muCommon]*((-32*(-1 + Nc)*(1 + Nc)*Pi^3*
                     (1 + (1 - y)^2)*(2*Q2^4 + 6*Q2^4*(-1 + (Q2 + 
                          (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431))) + 7*Q2^4*
                       (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2 + 4*Q2^4*
                       (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^3 + Q2^4*
                       (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^4 + 2*Q2^3*
                       (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) + 
                      2*Q2^3*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          zz$1431)/(Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))*
                       (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) + 
                      Q2^2*(-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2 + 
                      Q2^2*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2*
                       (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2)*
                     quarkCharge[i]^2)/(Nc*Q2*(Q2 + Q2*(-1 + (Q2 + 
                          (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431))))^2*(-1 + 
                      (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                        (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                        (-u^(-1) + u))/zz$1431)) + 4*(1 - y)*
                    ((16*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 6*Q2^4*(-1 + 
                          (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431))) + 7*Q2^4*
                         (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2 + 4*Q2^4*
                         (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^3 + Q2^4*
                         (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^4 + 2*Q2^3*
                         (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) + 
                        2*Q2^3*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          zz$1431)/(Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))*
                         (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) + 
                        Q2^2*(-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2 + 
                        Q2^2*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          zz$1431)/(Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2*
                         (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2)*
                       quarkCharge[i]^2)/(Nc*Q2*(Q2 + Q2*(-1 + (Q2 + 
                          (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431))))^2*(-1 + 
                        (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)) - (16*(-1 + Nc)*(1 + Nc)*
                       Pi^3*(2*Q2^4 + 6*Q2^4*(-1 + (Q2 + (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)/(Q2 - (pJT*Sqrt[Q2])/
                          (u*zz$1431))) + 7*Q2^4*(-1 + (Q2 + (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)/(Q2 - (pJT*Sqrt[Q2])/
                          (u*zz$1431)))^2 + 4*Q2^4*(-1 + (Q2 + (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)/(Q2 - (pJT*Sqrt[Q2])/
                          (u*zz$1431)))^3 + Q2^4*(-1 + (Q2 + (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)/(Q2 - (pJT*Sqrt[Q2])/
                          (u*zz$1431)))^4 + 2*Q2^3*(-Q2 - (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431) - 2*Q2^3*(-1 + 
                          (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - 
                          (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) - 4*Q2^3*
                         (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2*(-Q2 - 
                          (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) + Q2^2*
                         (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2 - 
                        4*Q2^2*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          zz$1431)/(Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))*
                         (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2 + 
                        Q2^2*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          zz$1431)/(Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2*
                         (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2)*
                       quarkCharge[i]^2)/(Nc*Q2*(Q2 + Q2*(-1 + (Q2 + 
                          (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431))))^2*(-1 + 
                        (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)))))/(Nc*y^2*(Q2 + 
                   (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)*zz$1431^2)))/
              (1 - zz$1431) + (-(((-1 + Nc^2)*Q2*f1[{i, sigma}, 
                   ((Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*xB)/(Q2 - 
                     (pJT*Sqrt[Q2])/u), muCommon]*Log[muCommon^2/(pJT^2*R^2)]*
                  ((-32*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 2*Q2^3*(-Q2 - 
                        pJT*Sqrt[Q2]*(-u^(-1) + u)) + Q2^2*(-Q2 - pJT*
                          Sqrt[Q2]*(-u^(-1) + u))^2 + 6*Q2^4*(-1 + 
                        (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u)) + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                         (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + 
                          u))/(Q2 - (pJT*Sqrt[Q2])/u)) + 7*Q2^4*
                       (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u))^2 + Q2^2*(-Q2 - pJT*Sqrt[Q2]*
                          (-u^(-1) + u))^2*(-1 + (Q2 + pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^2 + 
                      4*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u))^3 + Q2^4*(-1 + (Q2 + pJT*
                          Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^4)*
                     (1 + (1 - y)^2)*quarkCharge[i]^2)/(Nc*Q2*(-Q2 - 
                      pJT*Sqrt[Q2]*(-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*
                         (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))*
                     (Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          (Q2 - (pJT*Sqrt[Q2])/u)))^2) + 4*(1 - y)*
                    ((16*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 2*Q2^3*(-Q2 - 
                          pJT*Sqrt[Q2]*(-u^(-1) + u)) + Q2^2*(-Q2 - pJT*
                          Sqrt[Q2]*(-u^(-1) + u))^2 + 6*Q2^4*(-1 + 
                          (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u)) + 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                          (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + 
                          u))/(Q2 - (pJT*Sqrt[Q2])/u)) + 7*Q2^4*
                         (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u))^2 + Q2^2*(-Q2 - pJT*Sqrt[Q2]*
                          (-u^(-1) + u))^2*(-1 + (Q2 + pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^2 + 
                        4*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          (Q2 - (pJT*Sqrt[Q2])/u))^3 + Q2^4*(-1 + 
                          (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u))^4)*quarkCharge[i]^2)/(Nc*Q2*
                       (-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))*(-1 + 
                        (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u))*(Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[
                          Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)))^2) - 
                     (16*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 2*Q2^3*(-Q2 - 
                          pJT*Sqrt[Q2]*(-u^(-1) + u)) + Q2^2*(-Q2 - pJT*
                          Sqrt[Q2]*(-u^(-1) + u))^2 + 6*Q2^4*(-1 + 
                          (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u)) - 2*Q2^3*(-Q2 - pJT*Sqrt[Q2]*
                          (-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + 
                          u))/(Q2 - (pJT*Sqrt[Q2])/u)) - 4*Q2^2*(-Q2 - 
                          pJT*Sqrt[Q2]*(-u^(-1) + u))^2*(-1 + (Q2 + pJT*
                          Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)) + 
                        7*Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          (Q2 - (pJT*Sqrt[Q2])/u))^2 - 4*Q2^3*(-Q2 - 
                          pJT*Sqrt[Q2]*(-u^(-1) + u))*(-1 + (Q2 + pJT*Sqrt[
                          Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^2 + 
                        Q2^2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))^2*
                         (-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u))^2 + 4*Q2^4*(-1 + (Q2 + pJT*
                          Sqrt[Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u))^
                          3 + Q2^4*(-1 + (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          (Q2 - (pJT*Sqrt[Q2])/u))^4)*quarkCharge[i]^2)/
                      (Nc*Q2*(-Q2 - pJT*Sqrt[Q2]*(-u^(-1) + u))*(-1 + 
                        (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))/(Q2 - 
                          (pJT*Sqrt[Q2])/u))*(Q2 + Q2*(-1 + (Q2 + pJT*Sqrt[
                          Q2]*(-u^(-1) + u))/(Q2 - (pJT*Sqrt[Q2])/u)))^2))))/
                 (Nc*(Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*y^2)) + ((-1 + Nc^2)*
                 Q2*f1[{i, sigma}, (xB*(Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/
                      zz$1431))/(Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)), muCommon]*
                 Log[muCommon^2/(pJT^2*R^2)]*((-32*(-1 + Nc)*(1 + Nc)*Pi^3*
                    (1 + (1 - y)^2)*(2*Q2^4 + 6*Q2^4*(-1 + (Q2 + 
                         (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                         (pJT*Sqrt[Q2])/(u*zz$1431))) + 7*Q2^4*
                      (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                         (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2 + 4*Q2^4*
                      (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                         (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^3 + Q2^4*
                      (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                         (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^4 + 2*Q2^3*
                      (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) + 
                     2*Q2^3*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                        (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - 
                       (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) + Q2^2*
                      (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2 + 
                     Q2^2*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                         (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2*
                      (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2)*
                    quarkCharge[i]^2)/(Nc*Q2*(Q2 + Q2*(-1 + (Q2 + 
                          (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431))))^2*(-1 + 
                     (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                       (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                       (-u^(-1) + u))/zz$1431)) + 4*(1 - y)*
                   ((16*(-1 + Nc)*(1 + Nc)*Pi^3*(2*Q2^4 + 6*Q2^4*(-1 + 
                         (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431))) + 7*Q2^4*
                        (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2 + 4*Q2^4*
                        (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^3 + Q2^4*
                        (-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^4 + 2*Q2^3*
                        (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) + 
                       2*Q2^3*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          zz$1431)/(Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))*
                        (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) + 
                       Q2^2*(-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2 + 
                       Q2^2*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2*(-Q2 - 
                          (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2)*
                      quarkCharge[i]^2)/(Nc*Q2*(Q2 + Q2*(-1 + (Q2 + 
                          (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431))))^2*(-1 + 
                       (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                         (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                         (-u^(-1) + u))/zz$1431)) - (16*(-1 + Nc)*(1 + Nc)*
                      Pi^3*(2*Q2^4 + 6*Q2^4*(-1 + (Q2 + (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)/(Q2 - (pJT*Sqrt[Q2])/
                          (u*zz$1431))) + 7*Q2^4*(-1 + (Q2 + (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)/(Q2 - (pJT*Sqrt[Q2])/
                          (u*zz$1431)))^2 + 4*Q2^4*(-1 + (Q2 + (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)/(Q2 - (pJT*Sqrt[Q2])/
                          (u*zz$1431)))^3 + Q2^4*(-1 + (Q2 + (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431)/(Q2 - (pJT*Sqrt[Q2])/
                          (u*zz$1431)))^4 + 2*Q2^3*(-Q2 - (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431) - 2*Q2^3*(-1 + 
                         (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                          (-u^(-1) + u))/zz$1431) - 4*Q2^3*(-1 + 
                          (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2*(-Q2 - 
                         (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431) + Q2^2*
                        (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2 - 
                       4*Q2^2*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/
                          zz$1431)/(Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))*
                        (-Q2 - (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2 + 
                       Q2^2*(-1 + (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/
                          (Q2 - (pJT*Sqrt[Q2])/(u*zz$1431)))^2*(-Q2 - 
                          (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)^2)*
                      quarkCharge[i]^2)/(Nc*Q2*(Q2 + Q2*(-1 + (Q2 + 
                          (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                          (pJT*Sqrt[Q2])/(u*zz$1431))))^2*(-1 + 
                       (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)/(Q2 - 
                         (pJT*Sqrt[Q2])/(u*zz$1431)))*(-Q2 - (pJT*Sqrt[Q2]*
                         (-u^(-1) + u))/zz$1431)))))/(Nc*y^2*(Q2 + 
                  (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1431)*zz$1431^2))/
              (1 - zz$1431), {zz$1431, (pJT*(u^(-1) + (u*xB)/(1 - xB)))/
              Sqrt[Q2], 1}]))/(2*Pi), {i, 1, Nf}, {sigma, {-1, 1}}], 
     "TMD_input" -> Inactive[Integrate][b$1432*BesselJ[0, (b$1432*jT)/zh]*
         D1Tilde[{i, sigma}, zh, b$1432, muCommon, pJT^2*R^2], 
        {b$1432, 0, Infinity}]/(2*Pi), "flavor_route" -> 
      {{i, sigma}, {i, sigma}, 1}, "flavor_rules" -> 
      {eq -> quarkCharge[i], otherChargeMoment[1] -> -quarkCharge[i] + 
         Inactive[Sum][quarkCharge[spectator], {spectator, 1, Nf}], 
       otherChargeMoment[2] -> -quarkCharge[i]^2 + Inactive[Sum][
          quarkCharge[spectator]^2, {spectator, 1, Nf}], 
       otherChargeMoment1 -> -quarkCharge[i] + Inactive[Sum][
          quarkCharge[spectator], {spectator, 1, Nf}], 
       otherChargeMoment2 -> -quarkCharge[i]^2 + Inactive[Sum][
          quarkCharge[spectator]^2, {spectator, 1, Nf}]}, 
     "common_scale_map" -> {muCommon -> muCommon, mu2 -> muCommon^2, 
       muR -> muCommon, muPDF -> muCommon, muFF -> muCommon, SUNN -> Nc, 
       FeynCalc`SUNN -> Nc, CF -> (-1 + Nc^2)/(2*Nc), CA -> Nc, TF -> 1/2, 
       beta0 -> (11*Nc - 2*Nf)/3, Nf -> Nf}|>, 
   "UT" -> <|"LO" -> Inactive[Sum][(32*Mh*(-1 + Nc)*(1 + Nc)*Pi^2*Q2*
         (1 + (1 - y)^2)*zh*h1[{i, sigma}, ((Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*
            xB)/(Q2 - (pJT*Sqrt[Q2])/u), muCommon]*quarkCharge[i]^2*
         Inactive[Integrate][b$1510^2*BesselJ[1, (b$1510*jT)/zh]*
           H1perpTilde1[{i, sigma}, zh, b$1510, muCommon, pJT^2*R^2], 
          {b$1510, 0, Infinity}])/(Nc*(Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*y^2), 
       {i, 1, Nf}, {sigma, {-1, 1}}], "Born_times_jet_NLO" -> 
      Inactive[Sum][(Mh*zh*Inactive[Integrate][b$1521^2*
           BesselJ[1, (b$1521*jT)/zh]*H1perpTilde1[{i, sigma}, zh, b$1521, 
            muCommon, pJT^2*R^2], {b$1521, 0, Infinity}]*
         ((8*(-1 + Nc)*(1 + Nc)*(-1 + Nc^2)*Pi^3*Q2*(1 + (1 - y)^2)*
            h1[{i, sigma}, ((Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*xB)/
              (Q2 - (pJT*Sqrt[Q2])/u), muCommon]*(Pi^2 - 
             6*Log[muCommon^2/(pJT^2*R^2)]^2)*quarkCharge[i]^2)/
           (3*Nc^2*(Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*y^2) + 
          (64*(-1 + Nc)*(1 + Nc)*(-1 + Nc^2)*Pi^3*Q2*(1 + (1 - y)^2)*
            h1[{i, sigma}, ((Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*xB)/
              (Q2 - (pJT*Sqrt[Q2])/u), muCommon]*Log[muCommon^2/(pJT^2*R^2)]*
            Log[1 - (pJT*(u^(-1) + (u*xB)/(1 - xB)))/Sqrt[Q2]]*
            quarkCharge[i]^2)/(Nc^2*(Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*y^2) - 
          (64*(-1 + Nc)*(1 + Nc)*(-1 + Nc^2)*Pi^3*Q2*(1 + (1 - y)^2)*
            h1[{i, sigma}, ((Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*xB)/
              (Q2 - (pJT*Sqrt[Q2])/u), muCommon]*
            Log[1 - (pJT*(u^(-1) + (u*xB)/(1 - xB)))/Sqrt[Q2]]^2*
            quarkCharge[i]^2)/(Nc^2*(Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*y^2) + 
          Inactive[Integrate][(-64*(-1 + Nc)*(1 + Nc)*(-1 + Nc^2)*Pi^3*Q2*
              (1 + (1 - y)^2)*h1[{i, sigma}, (xB*(Q2 + (pJT*Sqrt[Q2]*
                    (-u^(-1) + u))/zz$1509))/(Q2 - (pJT*Sqrt[Q2])/
                  (u*zz$1509)), muCommon]*(Log[muCommon^2/(pJT^2*R^2)] - 2*
                Log[1 - zz$1509])*quarkCharge[i]^2)/(Nc^2*y^2*
              (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1509)*zz$1509^2) + 
            (Log[1 - zz$1509]*((128*(-1 + Nc)*(1 + Nc)*(-1 + Nc^2)*Pi^3*Q2*
                 (1 + (1 - y)^2)*h1[{i, sigma}, ((Q2 + pJT*Sqrt[Q2]*
                      (-u^(-1) + u))*xB)/(Q2 - (pJT*Sqrt[Q2])/u), muCommon]*
                 quarkCharge[i]^2)/(Nc^2*(Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*
                 y^2) - (128*(-1 + Nc)*(1 + Nc)*(-1 + Nc^2)*Pi^3*Q2*
                 (1 + (1 - y)^2)*h1[{i, sigma}, (xB*(Q2 + (pJT*Sqrt[Q2]*
                       (-u^(-1) + u))/zz$1509))/(Q2 - (pJT*Sqrt[Q2])/
                     (u*zz$1509)), muCommon]*quarkCharge[i]^2)/(Nc^2*y^2*
                 (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1509)*zz$1509^2)))/
             (1 - zz$1509) + ((-64*(-1 + Nc)*(1 + Nc)*(-1 + Nc^2)*Pi^3*Q2*
                (1 + (1 - y)^2)*h1[{i, sigma}, ((Q2 + pJT*Sqrt[Q2]*(-u^(-1) + 
                      u))*xB)/(Q2 - (pJT*Sqrt[Q2])/u), muCommon]*
                Log[muCommon^2/(pJT^2*R^2)]*quarkCharge[i]^2)/(Nc^2*
                (Q2 + pJT*Sqrt[Q2]*(-u^(-1) + u))*y^2) + (64*(-1 + Nc)*
                (1 + Nc)*(-1 + Nc^2)*Pi^3*Q2*(1 + (1 - y)^2)*h1[{i, sigma}, 
                 (xB*(Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1509))/
                  (Q2 - (pJT*Sqrt[Q2])/(u*zz$1509)), muCommon]*
                Log[muCommon^2/(pJT^2*R^2)]*quarkCharge[i]^2)/(Nc^2*y^2*
                (Q2 + (pJT*Sqrt[Q2]*(-u^(-1) + u))/zz$1509)*zz$1509^2))/
             (1 - zz$1509), {zz$1509, (pJT*(u^(-1) + (u*xB)/(1 - xB)))/
             Sqrt[Q2], 1}]))/(2*Pi), {i, 1, Nf}, {sigma, {-1, 1}}], 
     "TMD_input" -> (Mh*zh*Inactive[Integrate][b$1510^2*
          BesselJ[1, (b$1510*jT)/zh]*H1perpTilde1[{i, sigma}, zh, b$1510, 
           muCommon, pJT^2*R^2], {b$1510, 0, Infinity}])/(2*Pi), 
     "flavor_route" -> {{i, sigma}, {i, sigma}, 1}, 
     "flavor_rules" -> {eq -> quarkCharge[i], otherChargeMoment[1] -> 
        -quarkCharge[i] + Inactive[Sum][quarkCharge[spectator], 
          {spectator, 1, Nf}], otherChargeMoment[2] -> -quarkCharge[i]^2 + 
         Inactive[Sum][quarkCharge[spectator]^2, {spectator, 1, Nf}], 
       otherChargeMoment1 -> -quarkCharge[i] + Inactive[Sum][
          quarkCharge[spectator], {spectator, 1, Nf}], 
       otherChargeMoment2 -> -quarkCharge[i]^2 + Inactive[Sum][
          quarkCharge[spectator]^2, {spectator, 1, Nf}]}, 
     "common_scale_map" -> {muCommon -> muCommon, mu2 -> muCommon^2, 
       muR -> muCommon, muPDF -> muCommon, muFF -> muCommon, SUNN -> Nc, 
       FeynCalc`SUNN -> Nc, CF -> (-1 + Nc^2)/(2*Nc), CA -> Nc, TF -> 1/2, 
       beta0 -> (11*Nc - 2*Nf)/3, Nf -> Nf}|>|>|>
