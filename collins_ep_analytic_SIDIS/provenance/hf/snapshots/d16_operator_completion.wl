(* Join freshly calculated projection, Wilson and spectral identities.
   Only definitions are external; no historical finite coefficient is read. *)
Clear[D16CompleteOperator];
D16CompleteOperator[gammaMatrices_:Automatic]:=Module[
 {projection,wilson,spectral,map,phi,value,derivative,zeroRules,physical,
  residuals,schemeDifference},
 projection=D16ProjectionNormalization[gammaMatrices];
 If[FailureQ[projection],Return[projection]];
 wilson=D16WilsonTaylor[];
 spectral=D16SpectralSupport[];
 If[FailureQ[spectral],Return[spectral]];
 (* The map below is the OUTPUT of the actual inverse-projector calculation,
    not a guessed fraction factor or an extension of a moment definition. *)
 map=projection["HFnative_from_K15"]/.{Global`z->xi,Global`z1->1/w,
   Global`HI->G[xi,w]};
 phi=(map/.w->v/xi)/u;
 value=phi/.v->1;derivative=FullSimplify[D[phi,v]/.v->1];
 zeroRules={G[xi,1/xi]->0,Derivative[0,1][G][xi,1/xi]->0};
 physical=FullSimplify[{value,derivative}/.zeroRules,u>0&&xi>0];
 schemeDifference=Expand[a cHFone (hfRen+a finiteSchemeShift)-a cHFone hfRen];
 residuals=Join[wilson["residuals"],<|
   "mapped_endpoint_value"->physical[[1]],"mapped_endpoint_derivative"->physical[[2]],
   "common_basis_factor"->projection["native_basis_factor"]-
    projection["native_moment_over_Kang"]/projection["native_F_over_Kang"],
   "HF_finite_scheme_shift_at_order_a"->Coefficient[schemeDifference,a,1]|>];
 <|"origin"->"DERIVED joined physical Clifford/Fourier projection, finite-endpoint Wilson transport, and two spectral-insertion/Appendix-A algebra; EXTERNAL operator definitions and spectral/boundary assumptions remain labeled",
  "projection"->projection,"Wilson_Taylor"->wilson,"spectral_support"->spectral,
  "parent_and_density"->projection["parent_and_density"],
  "native_basis_factor"->projection["native_basis_factor"],
  "tree_HF_coefficient"->wilson["tree_HF_coefficient"],
  "physical_endpoint_class"-><|
   "actual_F_to_F_map"->map,"phi"->phi,
   "unreduced_value"->value,"unreduced_derivative"->derivative,
   "source_endpoint_rules"->zeroRules,
   "mapped_value"->physical[[1]],"mapped_derivative"->physical[[2]],
   "phi_value"->physical[[1]],"phi_derivative"->physical[[2]],
   "source_identity_scope"->"The two F-type endpoint identities use the complete color-averaged gauge-covariant correlator, both spectral arguments and Appendix-A boundaries recorded in spectral_support. Taking a physical imaginary/chiral-odd projection is linear; the actual map above is regular at w=1/xi. A singular F-to-D map is excluded from this argument.",
   "domain"->HoldComplete[0<zh<1&&zh<=u<=1&&xi==zh/u&&0<v<1&&
     G[xi,1/xi]==0&&Derivative[0,1][G][xi,1/xi]==0],
   "diagonal_regularity"->"Use a uniform C^(1,alpha) endpoint test class for some alpha>0, or the corresponding Dini integrability condition. Zero value and derivative alone do not imply a convergent double-pole action. The source theorem proves the two jets, not an arbitrary higher regularity bound.",
   "lower_endpoint_regularity"->"Because the actual F-to-F map contains 1/w, require G(xi,w)/w locally integrable uniformly in xi; G=O(w^beta), beta>0, suffices. The quark-pole zero alone does not prove this condition. Native smooth/compact operator test fields satisfy the declared domain.",
   "subtraction_connection"->"At NLO use the leading collinear F operator identified here. d17 must remove the common damping and rapidity regulator on this convergent action and cancel the actual collinear poles. Only AFTER matching, a finite O(a) change of renormalized HF changes a*C_HF^(1)*HF at O(a^2). This does not remove Hhat<-HF mixing, prove an arbitrary bare Laurent interchange, or certify an all-order closed twist-three renormalization system.",
   "generic_contact_action"->(c0 value-c1 derivative),
   "mapped_contact_action"->FullSimplify[(c0 value-c1 derivative)/.zeroRules]|>,
  "finite_HF_scheme_change"->schemeDifference,"residuals"->residuals|>
];
