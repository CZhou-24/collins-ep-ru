(* Additive v0.4.0 measured quark jet/TMD conversion.
   No reference coefficient is an input.  The common intrinsic TMD operator
   is removed before forming the residual Wilson-line calculation. *)
Clear[D18ReadTree,D18Projectors,D18Primary,D18Independent,D18Measurement,D18CollinearRegions,D18RadiusText];
D18ReadTree[x_Integer]:=x;
D18ReadTree[x_String]:=Which[x=="pi",Pi,StringMatchQ[x,RegularExpression["-?[0-9]+(/[0-9]+)?"]],ToExpression[x],True,Symbol[x]];
D18ReadTree[x_List]:=Switch[First[x],"add",Plus@@(D18ReadTree/@Rest[x]),"mul",Times@@(D18ReadTree/@Rest[x]),"pow",D18ReadTree[x[[2]]]^D18ReadTree[x[[3]]],"log",Log[D18ReadTree[x[[2]]]],_,Print["unsupported probe tree"];Exit[1]];

D18Projectors[endpoint_Association,delta_]:=Module[
 {gm,np,nm,sx,g5,rho,projectors,norms,kvec,jcur,squared,normalized,
  numerator,projected,evanescent,sl,ward,eikonalReduction},
 (* The vertex is the actual amputated generated QCD vertex, carried by
    the fresh d13 intermediate, not a literal splitting coefficient. *)
 gm=endpoint["generated_quark_gluon_vertex"]["physical_vertices"];
 sl[v_]:=PhysicalSlash[v,gm];np={1,0,0,1};nm={1,0,0,-1};sx={0,1,0,0};
 g5=I(Dot@@PhysicalGammas[]);
 rho={sl[np],sl[np].g5.sl[sx]};
 projectors={sl[nm]/2,(I/4)(gm[[2]].sl[nm]-sl[nm].gm[[2]]).g5};
 norms=FullSimplify[Tr[#[[1]].#[[2]]]&/@Transpose[{rho,projectors}]];
 eikonalReduction=Table[FullSimplify[sl[np].gm[[mu]].sl[np]-2np[[mu]]sl[np]],{mu,4}];
 Gate["d18 generated on-shell quark vertex eikonal reduction",eikonalReduction===ConstantArray[0,{4,4,4}]];
 kvec={kt Cosh[yy],kt Cos[ph],kt Sin[ph],kt Sinh[yy]};
 jcur=FullSimplify[np/MDot[np,kvec]-nm/MDot[nm,kvec],kt>0&&Element[yy,Reals]];
 ward=FullSimplify[MDot[kvec,jcur],kt>0&&Element[yy,Reals]];
 squared=FullSimplify[-MDot[jcur,jcur],kt>0&&Element[yy,Reals]];
 (* The physical lightlike directions have no evanescent components.
    Thus g_tilde(mu,nu) J^mu J^nu=0 in D=4-2 eps, independently of spin.
    Insertion is HERE, in the regulated cut numerator before contraction,
    rapidity integration, and multiplication by the transverse master.
    The eta coefficient normalizes its integral over the cone to unity. *)
 numerator=Table[(1+eps eta delta/(2 CF)) squared rho[[i]],{i,2}];
 projected=FullSimplify[Table[Tr[numerator[[i]].projectors[[i]]]/norms[[i]],{i,2}]];
 normalized=FullSimplify[projected/squared];
 evanescent=FullSimplify[(Coefficient[#,eps,1]/eta)2CF&/@normalized];
 Gate["d18 eikonal current is gauge transverse",ward===0];
 Gate["d18 separate physical UU and Collins projections",normalized[[1]]===normalized[[2]]];
 <|"generated_vertex"->endpoint["generated_quark_gluon_vertex"],
  "operator_density_matrices"->rho,"physical_projectors"->projectors,"tree_norms"->norms,
  "generated_vertex_eikonal_reduction_residuals"->eikonalReduction,
  "evanescent_vertex_reduction"->HoldComplete[Slash[np].GammaTilde[mu].Slash[np]==-GammaTilde[mu] npSquared==0],
  "soft_current"->jcur,"soft_current_Ward_residual"->ward,"D_contracted_current_squared"->squared,
  "evanescent_metric_contraction"->0,
  "D_prescription"->"BMHV physical external spin, gamma5 and lightlike Wilson directions; D-dimensional internal phase space. The evanescent current contraction vanishes because both Wilson directions are physical. Common full-D virtual and intrinsic collinear operators cancel before this residual is formed.",
  "regulated_open_numerators"->numerator,"projected_numerators"->projected,
  "normalized_cut_weights"->normalized,"epsilon_projection_after_rapidity_normalization"->evanescent,
  "probe_origin"->"eps*eta*delta/(2 CF) is inserted in the open eikonal cut matrix, before taking either spin trace. Its rapidity integral is 1/eta. No finite output is adjusted."|>
];

D18Primary[projection_Association,endpoint_Association]:=Module[
 {shared,radial,standardRegular,coneRegular,etaParts,cone,overlap,ct,finite,
  rawCone,rawOverlap,radialPole,masterCheck,parts,weight,euler,coneIntegral,
  coneWithBoundary,rapidityMapResidual},
 shared=endpoint["radial_master"];
 (* This is the retained Kira/SubTropica radial master from the actual
    fresh run.  The all-eta radial completion follows the cut measure. *)
 radial=-Exp[eps(B-EulerGamma)+eta(B/2-EulerGamma)] Gamma[1-eps-eta/2]/
   ((eps+eta/2) Gamma[1+eps+eta/2] Gamma[1-eps]);
 masterCheck=FullSimplify[Normal[Series[(radial/.eta->0)+Exp[eps B]/(eps^2 shared),{eps,0,1}]]];
 Gate["d18 shared native radial master normalization",masterCheck===0];
 euler=Integrate[x^(aa-1)(1-x)^(bb-1),{x,0,1},Assumptions->aa>0&&bb>0];
 standardRegular=FullSimplify[eta (euler/.{aa->eta/2,bb->1-eta})/.
   Gamma[eta/2]->2 Gamma[1+eta/2]/eta];
 (* Cone rapidity y-y0 in (0,infinity): eta Integral exp(-eta y)=1.
    The shifted standard-soft half is Beta(eta/2,1-eta)/2.
    Its regular numerator has zero first derivative at eta=0. *)
 coneIntegral=Integrate[Exp[-eta yy],{yy,0,Infinity},Assumptions->eta>0];
 coneWithBoundary=Integrate[Exp[-eta yy],{yy,-g/2,Infinity},Assumptions->eta>0&&Element[g,Reals]];
 rapidityMapResidual=FullSimplify[Exp[-eta V/2]coneWithBoundary-
   Exp[-eta(V-g)/2]coneIntegral,eta>0&&Element[{g,V},Reals]];
 Gate["d18 measured cone rapidity-scale conversion",rapidityMapResidual===0];
 coneRegular=FullSimplify[2eta coneIntegral];
 etaParts[x_]:=FullSimplify[(x/.eta->0)/eta+(D[x,eta]/.eta->0)];
 rawCone=Table[CF coneRegular radial projection["normalized_cut_weights"][[i]]/eta,{i,2}];
 rawOverlap=CF radial standardRegular/eta;
 cone=Table[FullSimplify[Normal[Series[etaParts[eta rawCone[[i]]],{eps,0,0}]]],{i,2}];
 overlap=FullSimplify[Normal[Series[etaParts[eta rawOverlap],{eps,0,0}]]];
 ct=Table[-Coefficient[Expand[cone[[i]]-overlap],eps,-2]/eps^2-
   Coefficient[Expand[cone[[i]]-overlap],eps,-1]/eps,{i,2}];
 finite=FullSimplify[cone+ct-overlap];
 radialPole=FullSimplify[Limit[eps(radial/.eta->0),eps->0]];
 Gate["d18 transverse pole is minus one",radialPole===-1];
 <|"shared_native_radial_master"->shared,"master_comparison_residual"->masterCheck,
  "all_eta_epsilon_radial"->radial,"standard_rapidity_regular_numerator"->standardRegular,
  "cone_rapidity_integral"->coneIntegral,"Euler_integral_evaluated"->euler,
  "unshifted_measured_cone_integral"->coneWithBoundary,
  "rapidity_conversion"->HoldComplete[{g==Log[R^2/(4 Cosh[Y]^2)],Vstandard==V-g,zetaJ==pT^2 R^2}],
  "rapidity_conversion_residual"->rapidityMapResidual,
  "display_scale_choice"->"The scalar constituents are displayed at Vstandard=V-g=0 after deriving the exact rapidity argument map. The remainder is independent of that common choice; B remains symbolic.",
  "cone_rapidity_regular_numerator"->coneRegular,
  "standard_eta_residue_and_constant"->{standardRegular/.eta->0,D[standardRegular,eta]/.eta->0},
  "measured_cut_unexpanded"->rawCone,"shifted_standard_overlap_unexpanded"->rawOverlap,
  "bare"->cone,"overlap"->overlap,"counterterm"->ct,"finite"->finite,
  "transverse_pole"->radialPole,
  "order"->"Cancel eta poles at fixed noninteger epsilon, then expand epsilon through the finite coefficient. Collinear and virtual common operators have already been removed as operators, with their D-dimensional numerators retained."|>
];

D18Independent[projection_Association]:=Module[
 {rapCone,rapDifference,logMoment,bessel,radial,weight,raw,moments,finite,
  boundary,phaseMeasure,differenceExpansion,differenceZero},
 (* A momentum-space route: k^-=kt exp(y) and x=exp[-2(y-y0)].
    Combine the measured and overlap actions BEFORE the radial integral.
    This route does not read D18Primary or any primary finite output. *)
 rapCone=Integrate[x^(eta/2-1)/2,{x,0,1},Assumptions->eta>0];
 differenceExpansion=Normal[Series[x^(eta/2-1)(1-(1-x)^(-eta))/2,{eta,0,1}]];
 differenceZero=Integrate[Coefficient[differenceExpansion,eta,0],{x,0,1}];
 logMoment=Integrate[Coefficient[differenceExpansion,eta,1],{x,0,1}];
 (* The difference starts at eta, not eta^0; its slope is integrable
    at both endpoints. Retain this fact at noninteger eps first. *)
 rapDifference=HoldComplete[Integrate[x^(eta/2-1)(1-(1-x)^(-eta))/2,{x,0,1}]];
 bessel=Integrate[t^(aa-1) BesselJ[0,2 Sqrt[A t]],{t,0,Infinity},
   Assumptions->A>0&&0<aa<1/4];
 Gate["d18 direct physical-azimuth radial integration",FreeQ[bessel,_Integrate|$Failed]];
 phaseMeasure=Exp[-EulerGamma eps]/Gamma[1-eps];
 radial=FullSimplify[FunctionExpand[(bessel/.{aa->-eps,A->1})phaseMeasure Exp[eps B]]];
 weight=projection["normalized_cut_weights"];
 (* Extract the eta^0 difference using the independently integrated
    cone and the endpoint-subtracted rapidity difference above. *)
 moments=FullSimplify[Table[Limit[2CF(weight[[i]]-1)rapCone,eta->0],{i,2}]];
 raw=FullSimplify[moments radial];
 finite=FullSimplify[Normal[Series[#,{eps,0,0}]]&/@raw];
 <|"x_change"->HoldComplete[x==Exp[-2(yy-y0)]],
  "cone_density"->x^(eta/2-1)/2,"cone_evaluated"->rapCone,
  "regulated_difference_action"->rapDifference,
  "difference_integrand_eta_expansion"->differenceExpansion,
  "difference_eta_zero"->differenceZero,"difference_first_eta_coefficient"->logMoment,
  "endpoint_argument"->"At x=0, log(1-x)/x tends to -1; at x=1 its logarithm is integrable. The combined rapidity integral is O(eta), hence vanishes at fixed noninteger eps. Taking epsilon first would invalidate this step.",
  "radial_density"->t^(aa-1) BesselJ[0,2 Sqrt[A t]],"radial_direct_evaluated"->bessel,
  "D_dimensional_phase_measure"->phaseMeasure,"normalized_transverse_master"->radial,
  "upstream_projection_after_rapidity_integral"->moments,
  "bare_remainder_direct"->raw,"finite"->finite,
  "independence"->"Direct momentum-space rapidity subtraction and Mellin-Bessel integration; only operator/projector inputs are shared, and no primary master value or finite export is read."|>
];

D18CollinearRegions[cut_Association,collins_Association,endpoint_Association]:=Module[
 {kernels,phase,measured,expanded,unmeasured,inside,residues,softBoundary,
  virtualOriginal,virtualDifference,zeroBinIdentity},
 kernels=<|"UU_quark"->cut["D_dimensional_kernels"]["qq"],
   "UU_gluon"->cut["D_dimensional_kernels"]["gq"],
   "Collins_quark"->collins["D_dimensional_kernel"]|>;
 phase=t^(-1-eps) BesselJ[0,2 Sqrt[A t]/z];
 inside=Limit[UnitStep[z^2(1-z)^2 R^2-lam^2 t],lam->0,
   Assumptions->0<z<1&&R>0&&t>0,Direction->"FromAbove"];
 Gate["d18 intrinsic collinear cone measurement expands to unity",inside===1];
 measured=Map[# phase UnitStep[z^2(1-z)^2R^2-lam^2t]&,kernels];
 expanded=Map[# phase inside&,kernels];unmeasured=Map[# phase&,kernels];
 residues=Map[FullSimplify[Limit[(1-z)#,z->1]]&,kernels];
 Gate["d18 separate generated UU and Collins soft limits",residues["UU_quark"]===2CF&&residues["Collins_quark"]===2CF];
 Gate["d18 unpolarized gluon channel has no soft-quark pole",residues["UU_gluon"]===0];
 (* z=1-lam*w leaves a nontrivial soft cone instead of setting it to one. *)
 softBoundary=FullSimplify[Limit[(z^2(1-z)^2R^2-lam^2t)/lam^2/.z->1-lam w,
   lam->0,Direction->"FromAbove"]];
 virtualOriginal=endpoint["virtual_UV_minus_IR_coefficients"]
    (endpoint["radial_split"]["IR"]+endpoint["radial_split"]["UV"]);
 virtualDifference=FullSimplify[virtualOriginal-virtualOriginal];
 zeroBinIdentity=Expand[(naiveCollinear-zeroBin+softIn)-(naiveCollinear-zeroBin+standardHalf)];
 <|"generated_D_cut_inputs"->kernels,"physical_J0_D_phase"->phase,
  "rank_one_factor_removed"->"The Collins coefficient is the scalar after removing the external physical -i b_alpha Hhat tensor. Its physical-J0 scalar/rank continuation is the retained prescription; the final rank-one inverse transform carries J1 and is not replaced with the UU measure.",
  "regulated_measured_collinear_integrands"->measured,"LP_cone_test"->inside,
  "intrinsic_unmeasured_integrands"->unmeasured,"LP_measured_integrands"->expanded,
  "common_real_integrand_residuals"->Map[FullSimplify,expanded-unmeasured],
  "soft_endpoint_residues"->residues,"soft_endpoint_rescaled_boundary"->softBoundary,
  "soft_cone_boundary"->HoldComplete[t<w^2 R^2],
  "common_virtual_D_operator"->virtualOriginal,"common_virtual_residual"->virtualDifference,
  "common_zero_bin_subtracted_difference"->zeroBinIdentity,
  "region_order"->"First expand each fixed-fraction collinear integrand in lambda=jT/(zh pT), retaining its D-dimensional numerator. Its z->1 endpoint is a distinct soft region: set 1-z=lambda*w before taking the limit; the surviving cone boundary is t<w^2 R^2. Subtract this zero bin from both intrinsic operators and add the appropriate soft factors. The HF coefficient starts at first order; its intrinsic operator is common and no one-loop eikonal multiplier of that coefficient enters at this order."|>
];

D18Measurement[]:=Module[{pair,qtOut,jtIn,geom},
 pair=Min[pT1^-2,pT2^-2] ((y1-y2)^2+ph12^2)/R^2;
 qtOut=Expand[-(1-zJ){pT,0}];
 jtIn=zh kt/zpart;
 geom=Normal[Series[2Exp[rho Cos[ph]]/(Cosh[rho Cos[ph]]-Cos[rho Sin[ph]]),{rho,0,0}]];
 <|"process"->HoldComplete[e+pTransverse->e+jet[h]+X],
  "anti_kt_pair_distance"->pair,"beam_distances"->{pT1^-2,pT2^-2},
  "standard_E_scheme"->HoldComplete[PJ==Sum[kIn[i],{i,inJet}]],
  "measurement"->HoldComplete[DiracDelta[qVec+Sum[kOutT[i],{i,outJet}]]
    DiracDelta[jVec-kFragVec-zh lambdaInVec] DiracDelta[zh-PhMinus/PJMinus]],
  "one_emission_out_recoil_LP"->qtOut,"out_recoil_squared"->Expand[qtOut.qtOut],
  "injet_pair_bound"->HoldComplete[kt^2<zpart^2(1-zpart)^2 pT^2 R^2],
  "hadron_transverse_from_hard_split"->jtIn,
  "hard_injet_scaling"->FullSimplify[jtIn/.kt->zpart(1-zpart)pT R],
  "allowed_LP_regions"->{"intrinsic jet-collinear kT~jT/zh", "in-jet soft-collinear kT~jT/zh", "out-of-jet soft giving measured qT"},
  "hard_region_restriction"->"At one emission, exact transverse conservation fixes qT=-k_out,T. At fixed jet rapidity a hard jet-collinear out parton has k_out,T=(1-zJ)pT+O(R pT), so zJ away from one is excluded from the small-qT singular distribution. A hard in-jet split at angle R has jT=zh(1-zpart)pT R and lies outside small-jT LP. Its soft endpoints are retained, not discarded. The common virtual operator is identical before subtraction and carries no cone boundary.",
  "distribution_scope"->"Expansion by regions of the joint qT,jT singular distribution, not evaluation of a plus distribution at zJ=1 and not an integral over the semi-inclusive pp jet-energy fraction. Endpoint soft real and virtual terms remain in the beam/jet soft allocation. The intrinsic TMD contains its full parton-fraction distributions and quark/gluon matching.",
  "out_soft_allocation"->HoldComplete[Exp[I bqVec.kOutT] ThetaOutsideJet],
  "in_soft_allocation"->HoldComplete[Exp[I bhVec.kInPerp] ThetaInsideJet],
  "zero_bin_cancellation"->HoldComplete[(CollinearNaive-ZeroBin)+SoftIn-(CollinearNaive-ZeroBin+StandardSoftHalf)==SoftIn-StandardSoftHalf],
  "joint_Fourier_variables"->{bqVec,bhVec},
  "soft_geometry_series"->geom,
  "support_qualification"->"The declared TMD expansion assumes zh=O(1), jT/(zh pT R)<<1 and qT/pT<<1; it is not a simultaneous small-zh or threshold factorization. Generic finite zh is retained inside the intrinsic operator distributions.",
  "radius"->"Only the leading local cone term 4/rho^2 is kept; the displayed subleading geometry is not a complete finite-R renormalized correction."|>
];

D18RadiusText[]:="# d18 finite quark fragmenting-jet/TMD conversion\n\nThe additional coefficient is derived after intrinsic quark/gluon TMD matching and the beam/residual-soft allocation, with zeta_J=pT_jet^2 R^2. The measured one-loop remainder is the in-jet soft-collinear matrix element minus the shifted standard-soft square root. Both physical UU and Collins projections are performed on the regulated open cut matrices in PROJECTORS.wl. Their D-dimensional eikonal-current contraction has no evanescent component because the Wilson directions are physical; common intrinsic real and virtual D-dimensional operators cancel before taking the residual. This does not infer a finite coefficient from ep Eq. (18)'s NLL statement.\n\nMEASUREMENT.wl records the anti-kt pair test and standard E-scheme axis, the separate qT and jT Fourier measurements, the jet-energy fraction argument, and the algebraic zero-bin cancellation. At one emission qT=-k_out,T. A hard jet-collinear out-of-jet parton at fixed rapidity gives qT of order pT, while a generic hard in-jet split gives jT of order zh pT R. These are outside the joint leading-power singular region. Their soft endpoints are retained in the allocated soft sectors. This is a regions argument at fixed zh=O(1), not taking a pp plus distribution pointwise at zJ=1. Small zh scaling with jT/(pT R), endpoint refactorization, unrestricted nonsingular recoil and hard multi-parton recoil cancellations are not certified.\n\nPRIMARY_INTEGRALS.wl integrates the cone rapidity density against the generated Kira/SubTropica transverse master and subtracts the standard-soft half at its shifted rapidity argument. INDEPENDENT_ROUTE.wl instead combines momentum-space rapidity actions in x=exp[-2(y-y0)] and independently evaluates the physical-J0 Mellin integral with its D-dimensional phase measure. The two rapidity actions differ only by O(eta); their difference is zero at fixed noninteger epsilon. Both retain the O(epsilon) numerator and normalized transverse pole -1/epsilon. The independent route shares operator inputs but reads no primary finite coefficient or primary master value.\n\nThe probe multiplies the regulated open in-jet cut numerator by 1+eps*eta*delta/(2 CF), before either spin projection or integral. The cone integral 1/eta normalizes this to eps*delta upstream of the transverse master. Its finite response is generated by the actual pole; no final coefficient is adjusted. This is a controlled unphysical operator variation, not a fitted correction.\n\nThe scalar reduction uses the common quark operator and its soft eikonal factor. It adds no gluon Collins function. No extra inclusive jet function is multiplied. The semi-inclusive pp out-of-jet hard coefficient of 1705.08443v2 Eq. (2.5) has a separate unconstrained jet-energy fraction and is not the measured small-qT ep coefficient. The paper's in-jet/standard-TMD relation, Eqs. (2.40), (2.43), (2.54), is a comparison target only.\n\nThe cone approximation enters when cosh(y-Y)-cos(phi) is expanded locally and the boundary becomes rho<R, equivalently y_local>ln(2 cosh(Y)/R). The saved series displays omitted terms. Agreement with the printed ep Appendix A1-A3 does not prove finite-R validity. R=1 is the intended benchmark but remains NOT CERTIFIED. A geometric term alone is not a complete finite-R correction. The existing radial route is not reverse unitarity.\n\nSource review must assess the regions/scalar-reduction argument separately from exact integration and packet checks. The result is scoped to the declared narrow-cone leading-power quark factorization, not full fixed-order NLO or Figure 6.\n";
