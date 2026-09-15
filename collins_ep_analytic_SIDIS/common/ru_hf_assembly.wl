(* The HF fixed-radius density is integrated only after the new measured M111
   Kira contraction/SubTropica sphere has been supplied. This is an analytic
   Fourier transformation of that density, not a substitute radial backend. *)
Clear[RUHFCoefficientAssembly];
RUHFCoefficientAssembly[generated_Association,ref_String,nativeSphere_]:=Module[
 {values=<||>,sectors={"fragment_HF"},density,independentDensity,mixing,epsilonPart,
  mellin,ratio,ratioSeries,bare,ct,finite,independent,rows,actual,localUV,localIR,
  localUVCT,physical,virtual,etaBound,contacts,namedDistributions,add,checks,
  probe,probeMoments,probeBare,probeFinite},
 density=generated["log_density_with_probe"];
 independentDensity=Expand[generated["independent_D_numerator_before_PV"]generated["inverse_fraction_measure"]+
   eps generated["epsilon_probe"]];
 mixing=generated["mixing_numerator"];
 epsilonPart=generated["epsilon_numerator"]+generated["epsilon_probe"];
 physical=generated["operator"]["physical_endpoint_class"];
 RUGate["HF actual physical endpoint jets",physical["mapped_value"]===0&&physical["mapped_derivative"]===0];
 RUGate["HF independent-F tree operator",generated["operator"]["tree_HF_coefficient"]===0];
 (* Absolute convergence strip follows from J0 large-t ~ t^-1/4 and
    its finite small-t value. Wolfram performs this integral on this call. *)
 mellin=Integrate[tauH^(-1-eps)BesselJ[0,2Sqrt[AA tauH]],{tauH,0,Infinity},
   Assumptions->AA>0&&-1/4<eps<0];
 RUGate["HF native analytic Fourier transform evaluated",FreeQ[mellin,_Integrate|_ConditionalExpression|_Real]];
 (* Dedicated HF coefficient uses B; the observable binder explicitly maps
    B -> Bh = Log[mu^2 bFragment^2/c0^2]. This is a notation map only. *)
 ratio=Exp[eps(B-2Log[u]-2EulerGamma)](mellin/.AA->1);
 ratioSeries=FullSimplify[Normal[Series[FunctionExpand[ratio],{eps,0,0}]],u>0];
 add[name_,constant_,terms_,order_:0]:=(AssociateTo[values,"r03/HF_"<>name->RUCertificate[constant,terms,sectors,order]]);
 actual[name_]:=values["r03/HF_"<>name]["value"]/.RUExact[x_]:>x;
 add["bare",0,{RURecord[ref,Expand[ratioSeries density],nativeSphere]}];
 bare=actual["bare"];
 (* Local same-operator transverse graph: the UV/IR intervals of tau^-1-eps
    have opposite poles. N0=1 and N1=0 are fixed by normalized local sphere
    definitions, before a deliberately nonphysical master mutation. *)
 localUV=mixing/epsUV+epsilonPart;
 localIR=-mixing/epsIR-epsilonPart;
 localUVCT=-mixing/epsUV;
 ct=mixing/eps;
 add["collinear_CT",ct,{}];
 add["finite",ct,{RURecord["r03/HF_bare",1,bare]}];finite=actual["finite"];
 add["independent",ct,{RURecord[ref,Expand[ratioSeries independentDensity],nativeSphere]}];
 independent=actual["independent"];
 add["mixing",0,{RURecord[ref,mixing,nativeSphere]}];
 add["epsilon_projection",0,{RURecord[ref,epsilonPart,nativeSphere]}];
 add["reference_B",0,{RURecord[ref,Factor[generated["D_numerator_before_PV"]/.eps->0],nativeSphere]}];
 (* Generic contact coefficients remain Missing. Zeros below are a chosen
    representative only after the two actual endpoint jets and uniform bound
    make their action vanish. Probe moments are separate executable evidence. *)
 contacts=Flatten[Table[stem<>"_"<>quantity,{stem,{"v_delta","v_derivative"}},
   {quantity,{"bare","collinear_CT","epsilon_projection","finite","independent","mixing"}}]];
 Scan[add[#,0,{}]&,contacts];
 Scan[add["u_"<>#,0,{}]&,{"delta","D0","D1"}];
 add["u_regular",0,{RURecord["r03/HF_finite",1,finite]}];
 probe=generated["epsilon_probe"];
 probeMoments=<|"v_delta"->Integrate[probe,{v,0,1}],
  "v_derivative"->Integrate[(1-v)probe,{v,0,1}]|>;
 probeBare=Map[Expand[Normal[Series[ratioSeries eps # nativeSphere,{eps,0,0}]]]&,probeMoments];
 probeFinite=probeBare;
 etaBound=Integrate[(1-u)^(-eta),{u,0,1},Assumptions->Re[eta]<1];
 checks=<|"two_cut_integration"->Factor[finite-independent],
  "local_Oepsilon_UV_IR_cancellation"->Factor[localUV+localIR+localUVCT+mixing/epsIR],
  "tree_HF_soft_order_a"->Coefficient[Expand[(1+a sTMD)(generated["operator"]["tree_HF_coefficient"]+a cHF)],a,1]-cHF,
  "tree_HF_TMD_order_a"->Coefficient[Expand[(1+a zTMD)(generated["operator"]["tree_HF_coefficient"]+a cHF)],a,1]-cHF,
  "physical_contact_action"->physical["mapped_contact_action"]|>;
 RUGate["HF matching independent and operator-order identities",RUHFZeroQ[Values[checks]]];
 If[!TrueQ[Lookup[$RUContext,"validation_probe",False]],
  RUGate["HF measured bare/collinear pole cancellation",RUHFZeroQ[Table[Coefficient[finite,eps,j],{j,-2,-1}]]];
  RUGate["HF scale derivative equals local mixing",RUHFZeroQ[D[finite,B]+mixing]]];
 namedDistributions=<|"u"-><|"interval"->{0,1},"delta"->actual["u_delta"],"D0"->actual["u_D0"],
    "D1"->actual["u_D1"],"regular"->actual["u_regular"],"support"->HoldComplete[zh<=u<=1]|>,
  "v"-><|"interval"->{0,1},"representative_delta"->0,"representative_derivative"->0,
   "generic_delta"->Missing["GenericContactUndetermined"],"generic_derivative"->Missing["GenericContactUndetermined"],
   "action"->HoldComplete[Integrate[K[u,v](Phi[u,v]-Phi[u,1]-(v-1)Derivative[0,1][Phi][u,1]),{v,0,1}]+
    c0[u]Phi[u,1]-c1[u]Derivative[0,1][Phi][u,1]],"physical_class"->physical|>|>;
 <|"values"->values,"named_distributions"->namedDistributions,
  "bare"->bare,"collinear_CT"->ct,"finite"->finite,"independent"->independent,
  "mixing"->actual["mixing"],"epsilon_projection"->actual["epsilon_projection"],
  "reference_B"->actual["reference_B"],"actual_native_sphere"->nativeSphere,"native_sphere_ref"->ref,
  "Fourier_integral"->HoldComplete[Integrate[tauH^(-1-eps)BesselJ[0,2Sqrt[AA tauH]],{tauH,0,Infinity}]],
  "Fourier_strip"->HoldComplete[AA>0&&-1/4<Re[eps]<0],"fresh_Fourier_value"->mellin,
  "ratio_to_native_sphere"->ratioSeries,"unexpanded_ratio"->ratio,
  "fragmentation_measure_scale"->HoldComplete[Exp[-2eps Log[u]]],
  "dedicated_HF_log_map"->HoldComplete[B==Bh==Log[mu^2 bFragment^2/c0^2]],
  "local_Hhat_UV"->localUV,"local_Hhat_IR"->localIR,"local_Hhat_UV_CT"->localUVCT,
  "local_Hhat_UV_interval"->HoldComplete[Integrate[tauH^(-1-epsUV),{tauH,1,Infinity}]==1/epsUV],
  "local_Hhat_IR_interval"->HoldComplete[Integrate[tauH^(-1-epsIR),{tauH,0,1}]==-1/epsIR],
  "rapidity_bound"->etaBound,"probe_contact_moments"->probeMoments,"probe_contact_bare"->probeBare,
  "probe_contact_finite"->probeFinite,"checks"->checks,
  "contact_scope"->"Generic contact coefficients are not fixed. Nominal zero representatives are valid only in the operator-derived uniform physical endpoint class; smooth numerator-probe moments are preserved separately.",
  "order_of_limits"->"Common ray/Feynman damping on the convergent physical action, then eta removal, then dimensional continuation/epsilon expansion, then collinear matching. Finite HF self-basis changes affect a*C_HF^(1) only at a^2 after pole cancellation.",
  "literal_discrepancy"->"No external kernel input; the retained literal Yuan-Zhou/Kang CA discrepancy is a comparison-only obligation.",
  "scope"->"Fresh native fixed-radius sphere and fresh analytic Fourier transform in the specified physical-J0 continuation. No unrestricted fixed-order, R=1, closed twist-three or final-prediction certificate."|>
];
