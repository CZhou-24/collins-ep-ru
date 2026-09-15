(* Selected generating operator/spectral fragments, enumerated before reuse in
   provenance/hf/COLLINS_REUSE_PLAN.json. No historical HF bulk is present.
   Source theorem assumptions are retained separately from computed identities. *)
Clear[RUHFOperator,PhysicalGammas,PhysicalSlash,MDot];
MDot[a_,b_]:=a.DiagonalMatrix[{1,-1,-1,-1}].b;
PhysicalGammas[]:=Module[{z=ConstantArray[0,{2,2}],id=IdentityMatrix[2],sigma},
 sigma={{{0,1},{1,0}},{{0,-I},{I,0}},{{1,0},{0,-1}}};
 Prepend[(ArrayFlatten[{{z,#},{-#,z}}]&/@sigma),ArrayFlatten[{{id,z},{z,-id}}]]];
PhysicalSlash[v_,gm_]:=Sum[{1,-1,-1,-1}[[j]]v[[j]]gm[[j]],{j,4}];
RUHFOperator[]:=Module[{projection,wilson,spectral,phaseFirst,phaseSecond,sol1,sol2,
 support1,support2,map,phi,zeros,boundary,phaseDerivative,ibp,slow,slowJets,
 lower,lowerIntegral,uniformIntegral,checks,positiveBoundary,tensor,tensorBoundary,
 deltaJac,contact},
 projection=D16ProjectionNormalization[];
 If[FailureQ[projection],Return[projection]];
 wilson=D16WilsonTaylor[];
 Block[{l,m,k,w,x,y,xi,ff,rr,jac,spectralField,cut,alphaH,betaH},
 phaseFirst=l(w+y-1-x)+m(k-w-y);
 phaseSecond=l(w-y)+m(k-w+y-1-x);
 sol1=Solve[{Coefficient[phaseFirst,l]==0,Coefficient[phaseFirst,m]==0},{x,y}];
 sol2=Solve[{Coefficient[phaseSecond,l]==0,Coefficient[phaseSecond,m]==0},{x,y}];
 support1=Reduce[Exists[{x,y},x>=0&&y>=0&&Coefficient[phaseFirst,l]==0&&Coefficient[phaseFirst,m]==0],{k,w},Reals];
 support2=Reduce[Exists[{x,y},x>=0&&y>=0&&Coefficient[phaseSecond,l]==0&&Coefficient[phaseSecond,m]==0],{k,w},Reals];
 positiveBoundary=Reduce[q1>=0&&q2>=0&&q3>=0&&q1+q2+q3==0,{q1,q2,q3},Reals];
 tensor=qmMinus qnI aa+qmMinus enI bb+emMinus enI cc-qmI qnMinus aa-qmI enMinus bb-emI enMinus cc;
 tensorBoundary=Expand[tensor/.{qmMinus->0,qnMinus->0,emMinus->0,enMinus->0}];
 deltaJac=FullSimplify[1/D[1/z-1/z1,z1]/.z1->z,z>0];
 contact=FullSimplify[(deltaJac/z1^2 z/z1)/.z1->z,z>0];
 map=projection["HFnative_from_K15"]/.{Global`z->xi,Global`z1->1/w,Global`HI->ff[xi,w]};
 phi=(map/.w->v/xi)/u;
 zeros={ff[xi,1/xi]->0,Derivative[0,1][ff][xi,1/xi]->0};
 boundary=FullSimplify[{phi/.v->1,D[phi,v]/.v->1}/.zeros,u>0&&xi>0];
 phaseDerivative=FullSimplify[D[Exp[I l w+I(k-w)m],w]/Exp[I l w+I(k-w)m]];
 ibp=Expand[D[jac[y]spectralField[y]Exp[-I m y],y]-
   jac[y]spectralField[y]D[Exp[-I m y],y]-Exp[-I m y]D[jac[y]spectralField[y],y]];
 slow=x/Log[1/x];slowJets={Limit[slow,x->0,Direction->"FromAbove"],Limit[D[slow,x],x->0,Direction->"FromAbove"]};
 lower=1/Log[1/w];lowerIntegral=Integrate[lower/w,{w,cut,Exp[-1]},Assumptions->0<cut<Exp[-1]];
 uniformIntegral=Integrate[x^(alphaH-1),{x,0,1},Assumptions->alphaH>0];
 checks=Join[wilson["residuals"],<|"mapped_endpoint_value"->boundary[[1]],
  "mapped_endpoint_derivative"->boundary[[2]],"spectral_IBP_product_rule"->ibp,
  "antisymmetric_tensor_at_spectral_boundary"->tensorBoundary,
  "EOM_unit_delta_contact"->contact-1,
  "basis_transport"->projection["native_basis_factor"]-projection["native_moment_over_Kang"]/projection["native_F_over_Kang"]|>];
 spectral=<|"phases"->{phaseFirst,phaseSecond},"solutions"->{sol1,sol2},
  "supports_before_pole_exclusion"->{support1,support2},
  "positive_state_boundary"->positiveBoundary,"antisymmetric_field_strength_tensor"->tensor,
  "tensor_at_zero_minus_components"->tensorBoundary,
  "ordered_support_after_theorem"->HoldComplete[k>=1&&0<w<k],
  "fractions"->HoldComplete[k==1/z&&w==v/z&&u==zh/z&&0<zh<=u<1&&0<v<1],
  "Appendix_A_phase_derivative"->phaseDerivative,
  "Appendix_A_IBP"->HoldComplete[Integrate[jac[y]spectralField[y]D[Exp[-I m y],y],{y,rest,Infinity}]==
    (jac[y]spectralField[y]Exp[-I m y]/.y->Infinity)-(jac[y]spectralField[y]Exp[-I m y]/.y->rest)-
    Integrate[Exp[-I m y]D[jac[y]spectralField[y],y],{y,rest,Infinity}]],
  "last_particle_measure"->1/(2(y-rest)),
  "theorem_assumptions"->{"Complete positive-energy spectral states and translation invariance.",
   "The second insertion uses the complete gauge-covariant equal-lightfront field permutation, with no independent zero-mode contact.",
   "Gluon-pole antisymmetric field-strength tensor and quark-pole physical-state exclusions are distinct assumptions of the cited operator theorem.",
   "Appendix A differentiates the full measure and state dependence and retains both boundaries before admissible smearing. Singular measures are not replaced by point values.",
   "The actual inverse projection is a regular F-to-F map at w=1/xi; no singular F-to-D replacement is used."}|>;
 <|"origin"->"Fresh Clifford inverse projection, free Wilson algebra, spectral phase and regular endpoint-map algebra; external operator definitions/theorem assumptions remain explicit.",
  "projection"->projection,"Wilson_Taylor"->wilson,"spectral_support"->spectral,
  "parent_and_density"->projection["parent_and_density"],"native_basis_factor"->projection["native_basis_factor"],
  "tree_HF_coefficient"->wilson["tree_HF_coefficient"],
  "EOM_native"->HoldComplete[HDNative[z,z1]==PV[1/(1/z-1/z1)]HFNative[z,z1]+DiracDelta[1/z-1/z1]Hhat3[z]],
  "EOM_literal_contact"->HoldComplete[DiracDelta[1/z-1/z1](z/z1)HhatKang[z1]],
  "EOM_delta_Jacobian"->deltaJac,"EOM_contact_coefficient"->contact,
  "physical_endpoint_class"-><|"actual_F_to_F_map"->map,"phi"->phi,"source_endpoint_rules"->zeros,
   "mapped_value"->boundary[[1]],"mapped_derivative"->boundary[[2]],
   "uniform_bound"->HoldComplete[Abs[Phi[u,1-x]]<=C[u]x^(1+alphaH)&&alphaH>0],
   "dominating_integral"->uniformIntegral,"slow_flat_counterexample"->slow,"slow_flat_jets"->slowJets,
   "slow_flat_double_pole_integral"->Log[Log[1/cut]],
   "lower_endpoint_counterexample"->lower,"lower_endpoint_divided_action"->lowerIntegral,
   "lower_endpoint_requirement"->"G(xi,w)/w locally integrable uniformly in xi; e.g. G=O(w^beta), beta>0.",
   "generic_contact_action"->c0 (phi/.v->1)-c1(D[phi,v]/.v->1),
   "mapped_contact_action"->FullSimplify[(c0 (phi/.v->1)-c1(D[phi,v]/.v->1))/.zeros],
   "scope"->"Zero endpoint jets alone do not prove convergence. Uniform Holder or Dini control and common regulator are required; generic c0,c1 remain unresolved."|>,
  "residuals"->checks|>
 ]
];
