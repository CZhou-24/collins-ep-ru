(* Measured soft factors from the fresh fixed-radius cut sphere.
   No evaluated radial integral is imported. Analytic Fourier/rapidity
   transformations retain their boundaries outside integer-index IBP. *)
Clear[RUSoftFactors,RUSoftCoefficientAssembly];
RUSoftFactors[]:=Module[{chain,common,std,glob,cone,cs,etaFirst,expand,ratios,
  normalizedSphere,angularMellin,rapidityJac,cutJac,boundaryBulk,boundarySurface},
 chain=RUSoftReductionChain[];
 (* k+=sqrt(tau) Exp[y], k-=sqrt(tau) Exp[-y].
    d k+ d k- delta(k+k--tau)/2 = d y/2, with k+>0.
    The fixed-radius cut angular integral is supplied by the new M family.
    N=e^(gamma eps)/Gamma(1-eps) is used here only to DEFINE the normalization
    of that unevaluated sphere, not inserted as its evaluated value. *)
 rapidityJac=FullSimplify[D[Sqrt[tau] Exp[yy],yy]/(Sqrt[tau] Exp[yy]),tau>0];
 cutJac=1/2;
 angularMellin=chain["radial_gamma_ratio"];
 common=CF Exp[eps(B-2 EulerGamma)+eta((B-V)/2-EulerGamma)] angularMellin;
 std=2common chain["eta_standard_regular"]/eta;
 glob=common Exp[-eta Y] Gamma[1-eps] chain["eta_global_regular"]/eta;
 cone=2common chain["injet_rapidity_evaluated"];
 cs=CF Exp[eps(B-2 EulerGamma)] (angularMellin/.eta->0) chain["cone_log_evaluated"];
 RUGate["global and standard rapidity residues cancel at fixed epsilon",
   FullSimplify[(Cancel[eta glob]/.eta->0)-(Cancel[eta std]/.eta->0)/2]===0];
 RUGate["measured cone equals shifted standard half through eta zero at fixed epsilon",
   FullSimplify[(Cancel[eta cone]/.eta->0)-(Cancel[eta std]/.eta->0)/2]===0&&
   FullSimplify[(D[Cancel[eta cone],eta]/.eta->0)-
     ((D[Cancel[eta std],eta]/.eta->0)/2/.V->V-g)]===0];
 (* All expressions above multiply the actual newly evaluated N. *)
 etaFirst[x_]:=Module[{regular=Cancel[eta x],residue,finite},
   residue=FullSimplify[regular/.eta->0];
   finite=FullSimplify[D[regular,eta]/.eta->0];
   FullSimplify[residue/eta+finite]];
 expand[x_]:=FullSimplify[Normal[Series[FunctionExpand[x],{eps,0,0}]]];
 ratios=<|"standard"->expand[etaFirst[std]],"global"->expand[etaFirst[glob]],
  "injet"->expand[etaFirst[cone]],"cs_out"->expand[cs]|>;
 RUGate["soft transformation returns exact finite Laurent factors",
   FreeQ[Values[ratios],Indeterminate|ComplexInfinity|_DirectedInfinity|_Integrate|_Real]];
 boundaryBulk=Integrate[D[Exp[-eta yy],yy],{yy,y0,Infinity},
   Assumptions->eta>0&&Element[y0,Reals]];
 boundarySurface=Exp[-eta y0];
 RUGate["cone theta derivative keeps its surface",FullSimplify[boundaryBulk+boundarySurface]===0];
 RUGate["physical rapidity Jacobian",rapidityJac===1];
 <|"transforms"->chain,"ratios_to_native_sphere"->ratios,
  "unexpanded_ratios"-><|"standard"->std,"global"->glob,"injet"->cone,"cs_out"->cs|>,
  "fixed_radius_sphere_origin"->"Actual three-cut M family, same radial density and D-dimensional angular measure before Fourier transformation. The angular ratios describe the conditional eikonal weight, not an additional inclusive angular moment.",
  "rapidity_Jacobian"->rapidityJac,"physical_cut_Jacobian"->cutJac,
  "rapidity_map"->HoldComplete[{kPlus==Sqrt[tau]Exp[yy],kMinus==Sqrt[tau]Exp[-yy],kPlus kMinus==tau}],
  "positive_energy"->HoldComplete[tau>0&&kPlus>0&&kMinus>0],
  "theta_boundary"-><|"bulk"->boundaryBulk,"surface"->boundarySurface,"sum"->FullSimplify[boundaryBulk+boundarySurface]|>,
  "IBP_domain"->"Only the fixed-radius/fixed-longitudinal scalar cut family is reduced. Eikonal angles, eta powers and cone theta functions are integrated with their exact boundaries by the displayed transformations. No ordinary IBP is applied across a cone boundary.",
  "order"->"Analytic eta continuation and eta expansion at fixed noninteger eps precede every epsilon expansion."|>
];

RUSoftCoefficientAssembly[factors_Association,ref_String,nativeSphere_,measurement_Association]:=Module[
 {values=<||>,ratios=factors["ratios_to_native_sphere"],unexpanded=factors["unexpanded_ratios"],
  coefficient,actual,raw,rem,uv,finite,standardHalf,jetDiff,physicalRapidity,
  names={"standard","global","injet","cs_out"},softSectors,records,localUVRatio},
 softSectors={"recoil_soft","jet_UU","jet_UT"};
 Do[
   coefficient=ratios[name]/.B->If[name=="injet",Bh,Bq];
   AssociateTo[values,"r03/soft_"<>name->RUCertificate[0,{RURecord[ref,coefficient,nativeSphere]},softSectors]],
   {name,names}];
 actual[id_]:=values[id]["value"]/.RUExact[x_]:>x;
 records={RURecord["r03/soft_global",1,actual["r03/soft_global"]],
   RURecord["r03/soft_cs_out",1,actual["r03/soft_cs_out"]],
   RURecord["r03/soft_standard",-1/2,actual["r03/soft_standard"]]};
 AssociateTo[values,"r03/recoil_soft_bare"->RUCertificate[0,records,{"recoil_soft"}]];
 (* The local angular residue N[0]=1,N[1]=0 follows from the unit sphere
    and its MSbar Gaussian normalization (digamma(1)=-gamma). It fixes UV
    poles independently of the evaluated finite sphere. Keep that local
    counterterm unchanged under deliberately nonphysical master probes. *)
 raw=Expand[actual["r03/recoil_soft_bare"]];
 RUGate["recoil rapidity cancellation before UV subtraction",Coefficient[raw,eta,-1]===0];
 localUVRatio=Expand[(ratios["global"]+ratios["cs_out"]-ratios["standard"]/2)/.B->Bq];
 uv=-Sum[Coefficient[localUVRatio,eps,i]eps^i,{i,-2,-1}];finite=Expand[raw+uv];
 AssociateTo[values,"r03/recoil_soft_finite"->RUCertificate[uv,
   {RURecord["r03/recoil_soft_bare",1,raw]}, {"recoil_soft"}]];
 If[!TrueQ[$RUContext["validation_probe"]],
   RUGate["physical recoil UV poles cancel",And@@Table[Coefficient[finite,eps,i]===0,{i,-2,-1}]]];
 standardHalf=Expand[Normal[Series[(ratios["standard"]/2/.{B->Bh,V->V-g})nativeSphere,{eps,0,0}]]];
 jetDiff=FullSimplify[actual["r03/soft_injet"]-standardHalf];
 RUGate["in-jet/shifted standard-soft equality",jetDiff===0];
 AssociateTo[values,"r03/jet_common_overlap"->RUCertificate[0,
   {RURecord[ref,ratios["standard"]/2/.{B->Bh,V->V-g},nativeSphere]}, {"jet_UU","jet_UT"}]];
 (* Comparison uses the abstract fragment log B and derives the shifted
    standard rapidity choice V-g=0 before specializing it. *)
 AssociateTo[values,{"r03/jet_comparison_bare"->RUCertificate[0,
   {RURecord[ref,ratios["injet"]/.V->g,nativeSphere]}, {"jet_UU","jet_UT"}],
  "r03/jet_comparison_overlap"->RUCertificate[0,
   {RURecord[ref,ratios["standard"]/2/.V->0,nativeSphere]}, {"jet_UU","jet_UT"}]}];
 Do[AssociateTo[values,"r03/jet_"<>spin<>"_bare_remainder"->RUCertificate[0,
   {RURecord["r03/soft_injet",1,actual["r03/soft_injet"]],
    RURecord["r03/jet_common_overlap",-1,actual["r03/jet_common_overlap"]]}, {"jet_"<>spin}]],{spin,{"UU","UT"}}];
 <|"values"->values,"recoil_bare"->raw,"recoil_UV"->uv,"recoil_finite"->finite,
  "jet_overlap"->standardHalf,"jet_bare_remainder"->jetDiff,
  "local_UV_definition"->HoldComplete[{N0==1,N1==0,PolyGamma[0,1]==-EulerGamma}],
  "measurement"->measurement,"factors"->factors,
  "inclusive_jet"->"Excluded from the identified-hadron operator; the fragmenting jet replaces it.",
  "scope"->"Leading-power joint qT,jT, physical J0 continuation and leading narrow cone; R=1 and nonsingular NLO uncertified."|>
];
