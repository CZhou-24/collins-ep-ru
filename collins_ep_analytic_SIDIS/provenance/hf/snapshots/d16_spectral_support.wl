(* New candidate source. The proof is produced on every call; no imported exports.
   Literal primary-source snippets and qualifications: d16_spectral_support_notes.md.
   Physical external spin is two-dimensional; no claim about internal D traces.
*)
Clear[D16SpectralSupport];
D16SpectralSupport[] := Module[{adj,adjoints,allChecks,anti,appendixAction,boundaryProductDerivative,checks,coefficientRow,conjugateChecks,conjugateResult,dampingBound,delta,derivativePhase,dominatingAction,dualResidual,dualTrace,expectedCoefficientRow,finiteSchemeAfter,finiteSchemeBefore,finiteSchemeResidual,finiteSchemeStrictResidual,fractionSupport,fullSumResidual,g0,gSpatial,genericContact,goodBoundary,goodFamily,goodFinite,goodPole,gp,gs,halfDifference,halfDifferenceResidual,halfSum,halfSumResidual,ibpResidual,imaginaryTensor,inverseOperatorRenormalization,joint,jointBoundViolation,jointDenominator,jointNumerator,linearFinite,linearRescale,lowerAction,lowerActionLimit,lowerPowerAction,lowerSlow,lowerValue,mapped,mappedZeros,measureMap,nativeDoubleZero,nativeMap,nativeMapBoundary,nativePhi,nativePhiBoundary,newChecks,nonuniformPole,nonuniformSeries,operatorMixingResidual,oppositeMoments,p0,pauli,phaseFirst,phaseSecond,phaseSpaceJacobian,phaseSpaceJacobianResidual,phi,phiDerivative,phiValue,physicalContact,physicalSupport,positiveStateBoundary,probeContacts,probeDensity,probeTransportResidual,ps,quadraticDifference,quadraticF,quadraticLimits,quadraticRescale,reduced,renormalizedCoefficientRow,same,sameMoments,sigma,singularFirstDerivative,singularMap,slowAction,slowActionLimit,slowEndpoint,slowFlat,solutionFirst,solutionSecond,supportFirst,supportResult,supportSecond,tensor,tensorEndpoint,tensorMinusI,tensorReduction,weighted,zeroRules,gm,ms,opposite},
 Block[{l,m,k,w,x,y,u,v,z,xi,Mh,hh,hI,hr,hi,q1,q2,q3,qmMinus,qnI,aa,qmI,qnMinus,enI,bb,enMinus,emMinus,cc,emI,ff,rr,gg,jac,spectral,qN,rest,xx,lam,c,cut,eps,cf,ca,tt,ap,bp,pminus,pref,aa0,aa1,aa2,beta,alpha,yy,aPT,cHF1,fPrime,scheme1,cHat0,cHat1,zHH,zHF,zFH,zFF},
phaseFirst=l(w+y-1-x)+m(k-w-y);
phaseSecond=l(w-y)+m(k-w+y-1-x);
solutionFirst=Solve[{Coefficient[phaseFirst,l]==0,Coefficient[phaseFirst,m]==0},{x,y}];
solutionSecond=Solve[{Coefficient[phaseSecond,l]==0,Coefficient[phaseSecond,m]==0},{x,y}];
supportFirst=Reduce[Exists[{x,y},x>=0&&y>=0&&Coefficient[phaseFirst,l]==0&&Coefficient[phaseFirst,m]==0],{k,w},Reals];
supportSecond=Reduce[Exists[{x,y},x>=0&&y>=0&&Coefficient[phaseSecond,l]==0&&Coefficient[phaseSecond,m]==0],{k,w},Reals];
physicalSupport=Reduce[k>=1&&k>w&&w>0,{k,w},Reals];
fractionSupport=FullSimplify[(k>=1&&k>w&&w>0)/.{k->1/z,w->v/z},z>0];
positiveStateBoundary=Reduce[q1>=0&&q2>=0&&q3>=0&&q1+q2+q3==0,{q1,q2,q3},Reals];
tensorMinusI=qmMinus qnI aa+qmMinus enI bb+emMinus enI cc-
             qmI qnMinus aa-qmI enMinus bb-emI enMinus cc;
tensorEndpoint=Expand[tensorMinusI/.{qmMinus->0,qnMinus->0,emMinus->0,enMinus->0}];
(* Physical 4x4 Clifford matrices, two transverse external directions. *)
pauli={{{0,1},{1,0}},{{0,-I},{I,0}},{{1,0},{0,-1}}};
g0=DiagonalMatrix[{1,1,-1,-1}];
gSpatial=(ArrayFlatten[{{0 IdentityMatrix[2],#},{-#,0 IdentityMatrix[2]}}]&)/@pauli;
gp=g0-gSpatial[[3]];gm=(g0+gSpatial[[3]])/2;
delta=( -(Mh/(2 z)) (gp.#-#.gp) hh &)/@gSpatial[[{1,2}]];
reduced=( (Mh/z) #.gp hh &)/@gSpatial[[{1,2}]];
tensorReduction=Simplify[delta-reduced];
dualTrace=FullSimplify[Sum[Tr[gm.(-gSpatial[[j]]).delta[[j]]],{j,1,2}]];
dualResidual=FullSimplify[z dualTrace/(8 Mh)-hh];
imaginaryTensor=Simplify[delta/.hh->I hI];
(* Smooth F-to-F map; singular F-to-D is kept as a counterexample. *)
mapped[w_]:=rr[xi,w] ff[xi,w];
phi[v_]:=mapped[v/xi]/u;
phiValue=phi[1];
phiDerivative=FullSimplify[D[phi[v],v]/.v->1];
zeroRules={ff[xi,1/xi]->0,Derivative[0,1][ff][xi,1/xi]->0};
mappedZeros=FullSimplify[{phiValue,phiDerivative}/.zeroRules];
genericContact=c0 phiValue-c1 phiDerivative;
physicalContact=FullSimplify[genericContact/.zeroRules];
quadraticF=(w-1/xi)^2 gg[xi,w];
singularMap=Cancel[quadraticF/(1/xi-w)];
singularFirstDerivative=FullSimplify[D[singularMap,w]/.w->1/xi];
(* Formal Appendix A Fourier/IBP step keeps a general Jacobian and boundary. *)
derivativePhase=FullSimplify[D[Exp[I l w+I(k-w)m],w]/Exp[I l w+I(k-w)m]];
boundaryProductDerivative=Expand[D[jac[y] spectral[y] Exp[-I m y],y]];
ibpResidual=FullSimplify[boundaryProductDerivative-
  (jac[y]spectral[y]D[Exp[-I m y],y]+Exp[-I m y]D[jac[y]spectral[y],y])];
phaseSpaceJacobian=1/(2(y-rest));
phaseSpaceJacobianResidual=FullSimplify[(1/(2 qN))/.qN->y-rest]-phaseSpaceJacobian;
appendixAction=HoldComplete[
 Integrate[jac[y] spectral[y] D[Exp[-I m y],y],{y,rest,Infinity}]==
 (jac[y]spectral[y]Exp[-I m y]/.y->Infinity)-
 (jac[y]spectral[y]Exp[-I m y]/.y->rest)-
 Integrate[Exp[-I m y]D[jac[y]spectral[y],y],{y,rest,Infinity}]];
(* Linear and quadratic endpoint tests in the same old damping example. *)
same=(xx^2-lam^2)/(xx^2+lam^2)^2;opposite=1/(xx^2+lam^2);
sameMoments=Table[FullSimplify[Integrate[xx^n same,{xx,0,1},Assumptions->lam>0],lam>0],{n,1,2}];
oppositeMoments=Table[FullSimplify[Integrate[xx^n opposite,{xx,0,1},Assumptions->lam>0],lam>0],{n,1,2}];
linearFinite=Limit[sameMoments[[1]]+Log[lam],lam->0,Direction->"FromAbove"];
linearRescale=FullSimplify[Limit[(sameMoments[[1]]/.lam->c lam)-sameMoments[[1]],lam->0,Direction->"FromAbove",Assumptions->c>0],c>0];
quadraticLimits=Limit[#,lam->0,Direction->"FromAbove"]&/@{sameMoments[[2]],oppositeMoments[[2]]};
quadraticDifference=Limit[sameMoments[[2]]-oppositeMoments[[2]],lam->0,Direction->"FromAbove"];
quadraticRescale=Limit[(sameMoments[[2]]/.lam->c lam)-sameMoments[[2]],lam->0,Direction->"FromAbove",Assumptions->c>0];
(* Derivative zero alone does not imply integrability against a double pole. *)
slowFlat=xx/Log[1/xx];
slowEndpoint={Limit[slowFlat,xx->0,Direction->"FromAbove"],Limit[D[slowFlat,xx],xx->0,Direction->"FromAbove"]};
slowAction=Integrate[slowFlat/xx^2,{xx,cut,Exp[-1]},Assumptions->0<cut<Exp[-1]];
slowActionLimit=Limit[slowAction,cut->0,Direction->"FromAbove"];
(* Nonuniform UV/endpoints: derivative-flat in eps>0 but pole is only linear. *)
nonuniformSeries=Normal[Series[xx^(1+eps)/eps,{eps,0,0}]];
nonuniformPole=Residue[xx^(1+eps)/eps,{eps,0}];
goodFamily=Normal[Series[xx^(2+eps)/eps,{eps,0,0}]];
goodPole=Residue[xx^(2+eps)/eps,{eps,0}];
goodFinite=FullSimplify[goodFamily-goodPole/eps];
goodBoundary=Limit[#,xx->0,Direction->"FromAbove"]&/@{goodPole,D[goodPole,xx],goodFinite,D[goodFinite,xx]};
(* Joint endpoint for the actual conditional bulk times a quadratic field. *)
p0=2 cf u(1+u v-u)/(1-v)-ca u(1+v-u(1+v^2))/((1-v)^2(1-u v));
weighted=Factor[(1-v)^2 p0];
joint=FullSimplify[Limit[weighted/.{u->1-tt ap,v->1-tt bp},tt->0,Direction->"FromAbove",Assumptions->ap>0&&bp>0],ap>0&&bp>0];
checks=<|"tensor_endpoint"->tensorEndpoint,"tensor_reduction"->Flatten[tensorReduction],
 "dual_projection"->dualResidual,"mapped_double_zero"->mappedZeros,
 "physical_contact_action"->physicalContact,"IBP_product_rule"->ibpResidual,
 "phase_space_jacobian"->phaseSpaceJacobianResidual,
 "quadratic_prescription_difference"->quadraticDifference,"quadratic_damping_rescale"->quadraticRescale,
 "good_Laurent_boundary"->goodBoundary|>;
supportResult=<|"purpose"->"NATIVE_SPECTRAL_AND_ENDPOINT_ALGEBRA_WITH_EXPLICIT_OPERATOR_ASSUMPTIONS",
 "runtime"-><|"version"->$Version,"system"->$SystemID|>,
 "spectral"-><|"phase_first"->phaseFirst,"phase_second"->phaseSecond,"solution_first"->solutionFirst,
 "solution_second"->solutionSecond,"support_first"->supportFirst,"support_second"->supportSecond,
 "physical_support"->physicalSupport,"fraction_support"->fractionSupport,
 "nonnegative_boundary_example"->positiveStateBoundary,"antisymmetric_tensor"->tensorMinusI|>,
 "projection"-><|"Delta_transverse"->delta,"imaginary_Delta"->imaginaryTensor,"dual_trace"->dualTrace,
 "definition"->HoldComplete[HhatFU==(z/(8Mh)) Sum[Tr[slashm.GammaLower[rho].DeltaF[rho]],{rho,1,2}]]|>,
 "basis_map"-><|"phi"->phi[v],"value"->phiValue,"derivative"->phiDerivative,
 "generic_contact"->genericContact,"singular_F_to_D_first_derivative"->singularFirstDerivative|>,
 "appendix"-><|"Fourier_derivative"->derivativePhase,"IBP_action"->appendixAction,
 "spectral_measure_with_total_y"->phaseSpaceJacobian,
 "qualification"->"Full boundary/state-derivative assumptions are in SUPPORT_PROOF.md; singular spectral densities cannot be replaced by point values."|>,
 "endpoint"-><|"same_sign_moments_linear_quadratic"->sameMoments,
 "opposite_sign_moments_linear_quadratic"->oppositeMoments,"linear_finite"->linearFinite,
 "linear_rescale"->linearRescale,"quadratic_limits"->quadraticLimits,
 "slow_flat_endpoint"->slowEndpoint,"slow_flat_action"->slowAction,"slow_flat_action_limit"->slowActionLimit|>,
 "renormalization"-><|"nonuniform_regulated_family"->xx^(1+eps)/eps,
 "nonuniform_series"->nonuniformSeries,"nonuniform_pole"->nonuniformPole,
 "compatible_family"->goodFamily,"compatible_boundary"->goodBoundary|>,
 "joint_endpoint"-><|"weighted_bulk"->weighted,"directional_limit"->joint|>,
 "zero_residual_checks"->checks|>;

g0=DiagonalMatrix[{1,1,-1,-1}];
sigma={{{0,1},{1,0}},{{0,-I},{I,0}},{{1,0},{0,-1}}};
gs=(ArrayFlatten[{{0 IdentityMatrix[2],#},{-#,0 IdentityMatrix[2]}}]&)/@sigma;
ps=g0-gs[[3]];ms=(g0+gs[[3]])/2;
adj[m_]:=g0.ConjugateTranspose[m].g0;
tensor=(#.ps&)/@gs[[{1,2}]];
anti=Simplify[(adj[#]+#)&/@tensor];
delta=(Mh/z)#(hr+I hi)&/@tensor;
adjoints=FullSimplify[adj/@delta,Element[{hr,hi,Mh,z},Reals]];
halfSum=FullSimplify[(delta+adjoints)/2,Element[{hr,hi,Mh,z},Reals]];
halfSumResidual=Simplify[halfSum-((I Mh hi/z)#&)/@tensor];
fullSumResidual=Simplify[(delta+adjoints)-((2I Mh hi/z)#&)/@tensor];
halfDifference=FullSimplify[(delta-adjoints)/2,Element[{hr,hi,Mh,z},Reals]];
halfDifferenceResidual=Simplify[halfDifference-((Mh hr/z)#&)/@tensor];
measureMap=FullSimplify[pminus^2 (I/pminus)];
conjugateChecks=<|"Dirac_antihermiticity"->Flatten[anti],"half_sum_imaginary"->Flatten[halfSumResidual],
 "full_sum_twice_imaginary"->Flatten[fullSumResidual],"half_difference_real"->Flatten[halfDifferenceResidual]|>;
conjugateResult=<|"purpose"->"EXTERNAL_REFERENCE_TENSOR_NORMALIZATION_NOT_COMPLETE_NATIVE_CUT_MAP",
 "runtime"->$Version,"tensor"->tensor,"reference_Delta"->delta,"conjugate_Delta"->adjoints,
 "imaginary_half_sum"->halfSum,"real_half_difference"->halfDifference,
 "coordinate_measure_factor"->measureMap,
 "reference_coordinate_conversion"->HoldComplete[DeltaK15[z,z1]==I pminus DeltaMM09[1/z,1/z1]],
 "qualifications"->"Nc=3, Pminus>0, mplus=1/Pminus, lambda=Pminus*xiplus, mu=Pminus*etaplus; identical field/link/state conventions. Actual native cut sum must decide whether an h.c. half-sum is already included.",
 "zero_residual_checks"->conjugateChecks|>;


(* The parent d16 cut/TMD normalization supplies this declared native F basis.
   The present calculation checks its regularity and chain rule; it does not
   identify a gauge-incomplete cut with the reference operator. *)
nativeMap=4 Mh/w;
nativePhi=4 Mh xi ff[xi,v/xi]/(u v);
nativePhiBoundary={nativePhi/.v->1,FullSimplify[D[nativePhi,v]/.v->1]};
nativeMapBoundary=FullSimplify[{nativeMap,D[nativeMap,w]}/.w->1/xi];
nativeDoubleZero=FullSimplify[nativePhiBoundary/.zeroRules];
probeDensity=pref v^2(1-v)^2;
probeContacts={Integrate[probeDensity,{v,0,1}],Integrate[(1-v)probeDensity,{v,0,1}]};
probeTransportResidual=FullSimplify[
 Integrate[probeDensity (aa0+aa1(v-1)+aa2(v-1)^2),{v,0,1}]-
 (Integrate[probeDensity aa2(v-1)^2,{v,0,1}]+probeContacts[[1]]aa0-probeContacts[[2]]aa1)];
(* Quark-pole value zero does not establish integrability after the 1/w map. *)
lowerSlow=1/Log[1/w];
lowerValue=Limit[lowerSlow,w->0,Direction->"FromAbove"];
lowerAction=Integrate[lowerSlow/w,{w,cut,Exp[-1]},Assumptions->0<cut<Exp[-1]];
lowerActionLimit=Limit[lowerAction,cut->0,Direction->"FromAbove"];
lowerPowerAction=Integrate[w^(beta-1),{w,0,1},Assumptions->beta>0];
(* Endpoint domination and the bounded joint corner are actual inequalities. *)
dampingBound=Reduce[xx>0&&lam>0&&Abs[(xx^2-lam^2)/(xx^2+lam^2)^2]>1/xx^2,{xx,lam},Reals];
jointNumerator=xx(1-xx)+yy(2-2xx+xx^2);
jointDenominator=xx+yy-xx yy;
jointBoundViolation=Reduce[0<=xx<=1&&0<=yy<=1&&xx+yy>0&&
 (jointNumerator<0||jointNumerator>2jointDenominator),{xx,yy},Reals];
dominatingAction=Integrate[xx^(alpha-1),{xx,0,1},Assumptions->alpha>0];
(* Strict perturbative order algebra.  No all-order MS-bar identity follows. *)
finiteSchemeBefore=aPT cHF1 (fPrime-aPT scheme1);
finiteSchemeAfter=aPT cHF1 fPrime;
finiteSchemeResidual=Expand[finiteSchemeBefore-finiteSchemeAfter];
finiteSchemeStrictResidual=Normal[Series[finiteSchemeResidual,{aPT,0,1}]];
coefficientRow={cHat0+aPT cHat1,aPT cHF1};
inverseOperatorRenormalization={{1-aPT zHH,-aPT zHF},{-aPT zFH,1-aPT zFF}};
renormalizedCoefficientRow=(Normal[Series[#,{aPT,0,1}]]&)/@
 Expand[coefficientRow.inverseOperatorRenormalization];
expectedCoefficientRow={cHat0+aPT(cHat1-cHat0 zHH),aPT(cHF1-cHat0 zHF)};
operatorMixingResidual=Expand[renormalizedCoefficientRow-expectedCoefficientRow];
newChecks=<|"native_F_map_double_zero"->nativeDoubleZero,
 "probe_transport"->probeTransportResidual,
 "finite_HF_scheme_change_strict_NLO"->finiteSchemeStrictResidual,
 "operator_mixing_order"->operatorMixingResidual,
 "same_sign_damping_bound_violation"->Boole[dampingBound],
 "joint_bound_violation"->Boole[jointBoundViolation]|>;
allChecks=Join[checks,conjugateChecks,newChecks];
<|"schema"->"d16_spectral_support_v1",
 "origin"->"Native symbolic calculation plus explicit reconstruction of external spectral theorem; no archived final-output import",
 "reference_operator_sources"-><|
  "1512.07233v2"-><|"equations"->{"14","16","post16","A1","A2","A3","A4"},
   "source_sha256"->"821f6e14f1497a7e7b6f5bbd247785e7afe0a4ec80ba44fed832b301b9ce0418",
   "pdf_sha256"->"884e29121240051296c29b40045fa2fe9dd38a7734d5fd2df87ae679404479b8"|>,
  "0812.3783v2"-><|"equations"->{"1","3","4","5","6","7","8","9","10","11"},
   "source_sha256"->"1b71cbbf467a5b6db93edbfd8e16b4e375db9781c1ef04b41972560a45e7ae67",
   "pdf_sha256"->"f7893d68af91b73b8e38bbe84376baf677329959810051b9d07335180cddcadd"|>|>,
 "spectral"->supportResult["spectral"],
 "reference_projection"->supportResult["projection"],
 "conjugate_projection"->conjugateResult,
 "appendix_A_formal_IBP"->supportResult["appendix"],
 "spectral_and_Appendix_assumptions"->{
  "Complete physical-state resolution, positive on-shell lightcone momenta and translation invariance",
  "Second insertion uses the equal-lightfront field permutation of MM09 Eq.8 in the identified gauge-completed F operator; no independent zero-mode contact",
  "At the gluon pole each constituent minus component and each physical polarization minus component vanish, so the antisymmetric -i tensor is zero",
  "Quark-pole exclusion separately uses the vacuum-to-quark-state physical quantum numbers; it is not obtained from the first tensor zero",
  "Appendix A requires differentiation and spectral IBP of the full gauge-completed operator, including derivative-state, derivative-measure and both boundary terms",
  "No value-only argument deletes a singular measure or a derivative-state boundary; upper boundary vanishes under admissible smearing and the lower Fourier delta sets all constituent minus momenta to zero",
  "The elementary last-particle measure after y=sum(y_i) is 1/[2(y-rest)]; the literal source 1/(2 P_Y.m) notation is retained separately, not silently corrected"},
 "regular_F_basis_chain_rule"->supportResult["basis_map"],
 "declared_native_F_map"-><|"map"->HoldComplete[HFNative[xi,1/w]==4 Mh ff[xi,w]/w],
  "map_origin"->"Connected d16 parent normalization, HFNative=2 HFK=4 Mh z1 Im HhatFU; this library checks consequences, not the missing parent cut identification",
  "map_and_derivative_at_diagonal"->nativeMapBoundary,
  "actual_field"->nativePhi,"actual_field_boundary"->nativePhiBoundary,
  "physical_field_boundary"->nativeDoubleZero,
  "mapped_value"->nativeDoubleZero[[1]],"mapped_derivative"->nativeDoubleZero[[2]],
  "raw_mapped_value"->nativePhiBoundary[[1]],"raw_mapped_derivative"->nativePhiBoundary[[2]],
  "endpoint_substitution_rules"->zeroRules,
  "scope"->"Map is smooth at w=1/xi for xi>0; it is singular at w=0 and needs the separate lower-endpoint condition below"|>,
 "generic_contacts"-><|"action"->supportResult["basis_map"]["generic_contact"],
  "physical_action"->physicalContact,"probe_density"->probeDensity,"probe_contacts"->probeContacts,
  "interpretation"->"Vanishing action on a proved physical class does not derive c0 or c1 and does not erase generic probe contacts"|>,
 "diagonal_regularization"->Join[supportResult["endpoint"],<|
  "damping_bound_violation"->dampingBound,"dominating_integral"->dominatingAction,
  "sufficient_class"->"Uniform |Phi(1-x)|<=C x^(1+alpha), alpha>0; C^(1,alpha) and quadratic times finite logarithms suffice. Value and derivative zeros alone do not."|>],
 "lower_endpoint"-><|"reference_counterexample"->lowerSlow,"reference_value"->lowerValue,
  "native_divided_field_action"->lowerAction,"native_divided_field_action_limit"->lowerActionLimit,
  "power_bound_integral"->lowerPowerAction,
  "sufficient_class"->"At w=0 require integral |G(w)|/w dw finite, e.g. G=O(w^beta), beta>0. G=O(w) makes the native map bounded. A zero quark-pole value alone is insufficient."|>,
 "joint_endpoint"->Join[supportResult["joint_endpoint"],<|
  "ratio_numerator"->jointNumerator,"ratio_denominator"->jointDenominator,
  "violation_of_0_le_ratio_le_2"->jointBoundViolation,
  "qualification"->"Uniform quadratic diagonal coefficient, suitable lower-w regularity, and fixed zh>0 (u>=zh); bounded corner need not have a unique directional limit"|>],
 "renormalization_counterexamples"->supportResult["renormalization"],
 "NLO_order_counting"-><|"finite_HF_scheme_difference"->finiteSchemeResidual,
  "strict_NLO_difference"->finiteSchemeStrictResidual,
  "tree_and_one_loop_coefficient_row"->coefficientRow,
  "inverse_collinear_Z"->inverseOperatorRenormalization,
  "renormalized_coefficient_row_through_NLO"->renormalizedCoefficientRow,
  "operator_order"->{"Hhat","HF"},
  "zHF_meaning"->"Hhat-bare row to HF-renormalized column; tree Hhat coefficient times this mixing remains at O(a)",
  "hypothesis"->"Actual connected calculation establishes C_HF^(0)=0, finite regular O(a) HF scheme map, and well-defined common-regulator physical action",
  "conclusion"->"Only the effect of such an O(a) HF self/basis redefinition is postponed to O(a^2); tree-Hhat times one-loop Hhat<-HF mixing remains at O(a)",
  "limitations"->"No all-order MS-bar endpoint identity is proved. This counting does not repair an undefined endpoint convolution, singular O(1) basis change, missing gauge/cut normalization, or a divergent/nonfinite scheme relation. Common regularization must precede strict expansion."|>,
 "proof_scope"->"Exact algebraic consequences of displayed assumptions; source theorem and native operator/counterterm identification are distinct obligations. No full d17 physical finite packet is certified by this library.",
 "zero_residual_checks"->allChecks|>

 ]
];
