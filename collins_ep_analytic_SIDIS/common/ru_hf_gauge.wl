(* v0.5.1 fresh HF generating source; exact pre-use identity in provenance/hf/COLLINS_REUSE_PLAN.json. No archived output or radial library is loaded. *)
(* Open operator amplitudes: generated QCD vertex plus expansion of a future
   Wilson-dressed quark. No Collins projector or reference kernel is an input.
   Common-regulator/contact completion is tracked separately from these
   algebraic off-endpoint Ward identities. *)
Clear[D17OpenGaugeCurrent,D17GaugeCompletion];
D17OpenGaugeCurrent[generated_Association,ea_,eb_]:=Module[
 {sk,srg,srl,vertex,jv,wa,wb,qa,qb,vc,axialvc},
 sk=(GS[r0]+GS[l]+GS[g])/(2(SP[r0,l]+SP[r0,g]+SP[l,g]));
 srg=(GS[r0]+GS[g])/(2SP[r0,g]);srl=(GS[r0]+GS[l])/(2SP[r0,l]);
 vertex=generated["triple_lorentz_polynomial"]/.{Lor1->mu,Lor2->be,Lor4->rho};
 jv=Contract[vertex FV[ea,mu]FV[eb,be]];
 qa=GS[eb].srg.GS[ea].sk;qb=GS[ea].srl.GS[eb].sk;
 wa=-SP[n,ea]/SP[n,l] GS[eb].srg+
   SP[n,ea]SP[n,eb]/(SP[n,l](SP[n,l]+SP[n,g]));
 wb=-SP[n,eb]/SP[n,g] GS[ea].srl+
   SP[n,ea]SP[n,eb]/(SP[n,g](SP[n,l]+SP[n,g]));
 vc=Contract[(-GAD[rho].sk+FV[n,rho]/(SP[n,l]+SP[n,g]))jv]/(2SP[l,g]);
 axialvc=Contract[(-GAD[rho].sk+
  ((GS[l]+GS[g]).sk FV[n,rho]+GS[n].sk(FV[l,rho]+FV[g,rho]))/
    (SP[n,l]+SP[n,g]))jv]/(2SP[l,g]);
 <|"color_order_tb_ta"->qa+wa-vc,"color_order_ta_tb"->qb+wb+vc,
 "quark_a"->qa,"quark_b"->qb,"wilson_a"->wa,"wilson_b"->wb,
 "triple_plus_wilson_triple"->vc,"axial_triple"->axialvc,
 "vertex_longitudinal_h"->Contract[(FV[l,rho]+FV[g,rho])jv],
 "vertex"->vertex|>
];
D17GaugeCompletion[generated_Association]:=Module[
 {cur,wardl,wardg,rl,rg,lg,nr,nl,ng,wardResults,reduced,
   split,leading,splitResidual,raw,pole,finite,ray1,ray2,ordered,axialResidual,
   parentReg,wardReg,regRemainder,hatGamma,hatA,hatB,sk0,srg0,srl0,hatWard},
 FCClearScalarProducts[];
 SP[r0]=0;SP[l]=0;SP[g]=0;SP[n]=0;
 SP[r0,l]=rl;SP[r0,g]=rg;SP[l,g]=lg;
 SP[n,r0]=nr;SP[n,l]=nl;SP[n,g]=ng;
 SP[eL,l]=0;SP[eG,g]=0;
 cur=D17OpenGaugeCurrent[generated,eL,eG];
 wardl=D17OpenGaugeCurrent[generated,l,eG];
 wardg=D17OpenGaugeCurrent[generated,eL,g];
 reduced[x_]:=Factor[DiracSimplify[DiracOrder[Contract[
   DiracSimplify[GS[r0].x]]/.Momentum[q_,D]:>Momentum[q]],
   DiracSubstitute67->True]];
 wardResults=<|
  "emitted_l_color_tb_ta"->reduced[wardl["color_order_tb_ta"]],
  "emitted_l_color_ta_tb"->reduced[wardl["color_order_ta_tb"]],
  "coherent_g_color_tb_ta"->reduced[wardg["color_order_tb_ta"]],
  "coherent_g_color_ta_tb"->reduced[wardg["color_order_ta_tb"]]|>;
 axialResidual=reduced[cur["axial_triple"]-cur["triple_plus_wilson_triple"]];
 (* The emitted unobserved gluon also has D-4 polarizations. Its hat
    component is orthogonal to every physical momentum and to n. The
    generated three-gluon vertex then contracts to -2(l.g) e_hat; retain
    its gamma rather than testing only physical emitted polarizations. *)
 hatGamma=DiracGamma[LorentzIndex[hatIndex,D-4],D-4];
 sk0=(GS[r0]+GS[l]+GS[g])/(2(rl+rg+lg));
 srg0=(GS[r0]+GS[g])/(2rg);srl0=(GS[r0]+GS[l])/(2rl);
 hatA=GS[g].srg0.hatGamma.sk0-hatGamma.sk0;
 hatB=hatGamma.srl0.GS[g].sk0-hatGamma.srl0+hatGamma.sk0;
 hatWard=<|"coherent_g_emitted_hat_tb_ta"->reduced[hatA],
   "coherent_g_emitted_hat_ta_tb"->reduced[hatB]|>;
 (* Exact finite-Feynman-regulator remainder in the axial/covariant
    reduction. The inverse-propagator term is kept, not set to zero at
    finite regulator. Its coefficient vanishes as damping is removed. *)
 parentReg=(GS[r0]+GS[l]+GS[g])/(2(rl+rg+lg)+I deltaK);
 wardReg=reduced[(GS[l]+GS[g]).parentReg-1];
 regRemainder=reduced[-I deltaK/(2(rl+rg+lg)+I deltaK)];
 (* The scalar multiplying identity in a Wilson emission is an actual open
    identity matrix. DiracSimplify accepts it as a scalar in the Dirac chain. *)
 FCClearScalarProducts[];SP[p]=0;SP[n]=0;SP[p,n]=1;
 SP[eA,p]=0;SP[eA,n]=0;SP[eB,p]=0;SP[eB,n]=0;
 split=(u GS[p]+rhoReg GS[n])/(2u rhoReg);
 pole=GS[p]/(2rhoReg);finite=GS[n]/(2u);
 splitResidual=DiracSimplify[split-pole-finite];
 leading=DiracSimplify[GS[eA].GS[p].GS[eB].pole];
 (* Ordered integrals follow a single finite future ray. The damping
    parameter is retained in the integral, not multiplied as separate PVs. *)
 ray1=Integrate[Exp[-(lambda+I omega1)s],{s,0,Infinity},
   Assumptions->lambda>0&&Element[omega1,Reals]];
 ray2=Integrate[Exp[-(lambda+I omega1)s1]
   Integrate[Exp[-(lambda+I omega2)s2],{s2,s1,Infinity},
    Assumptions->lambda>0&&Element[{omega1,omega2},Reals]],
   {s1,0,Infinity},Assumptions->lambda>0&&Element[{omega1,omega2},Reals]];
 <|"origin"->"DERIVED: open generated-vertex operator current plus future Wilson expansion, before any chiral-odd projection.",
 "open_current"->cur,"open_emitted_Ward_current"->wardl,
 "open_coherent_Ward_current"->wardg,"unprojected_Ward_residuals"->wardResults,
 "emitted_hat_Ward_currents"-><|"tb_ta"->hatA,"ta_tb"->hatB|>,
 "emitted_hat_Ward_residuals"->hatWard,
 "open_axial_minus_covariant_Wilson_residual"->axialResidual,
 "regulated_parent_Ward_remainder"->wardReg,
 "regulated_parent_Ward_remainder_identity"->Factor[wardReg-regRemainder],
 "regulated_parent_remainder_scope"->"At finite positive Feynman regulator, slash(r)[slash(h)S(k)-1]=-i deltaK slash(r)/(k^2+i deltaK). In the axial/covariant current difference it multiplies n.V/[(n.h-i lambda)(h^2+i deltaH)]. With physical polarizations n.V=(n.l-n.g)eL.eG, its numerator cancels the possible joint endpoint enhancement. The remaining damping contact annihilates the proved derivative-flat Hölder class. No finite-regulator Ward zero is asserted.",
 "triple_longitudinal_h_residual"->Factor[cur["vertex_longitudinal_h"]],
 "Ward_assumptions"->HoldComplete[r0^2==0&&l^2==0&&g^2==0&&n^2==0&&
  l.eL==0&&g.eG==0],
 "Ward_scope"->"Open on-shell quark amplitude, either gluon replaced by its momentum and the other physically transverse. Each independent color-ordered Dirac operator is zero before the Collins projection. The common damping is removed away from coincident longitudinal support; finite-regulator endpoint action is separate.",
 "diagram_inventory"->{"three generated QCD q to qgg diagrams",
  "Wilson l plus quark g","Wilson g plus quark l",
  "two path-ordered double Wilson insertions","Wilson off-shell gluon splitting to l and g"},
 "color_commutator"->HoldComplete[Ta.Tb-Tb.Ta],
 "special_propagator_exact_split"->split,
 "collinear_operator_piece"->pole,"special_propagator"->finite,
 "special_propagator_split_residual"->splitResidual,
 "transverse_F_projection_of_leading_piece"->leading,
 "leading_piece_scope"->"The collinear pole term vanishes algebraically between the physical transverse F density and transverse coherent vertex; it is not dropped before this contraction. Longitudinal pieces belong to the Wilson/EOM completion above.",
 "one_future_ray_integral"->ray1,"ordered_two_ray_integral"->ray2,
 "future_ray_regulator"->HoldComplete[Exp[-lambda(s1+s2)]],
 "completion_status"->"OPEN_WARD_AND_SPECIAL_PROPAGATOR_DERIVED_REGULATED_ACTION_RECORDED_SEPARATELY"|>
];
