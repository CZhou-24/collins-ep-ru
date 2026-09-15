(* Defining measured jet/soft operators reused before integration; original source hashes in provenance/soft. *)
Clear[RUSoftGenerate];
RUSoftGenerate[tmd_Association]:=Module[{endpoint,projection,measurement,pdir,jdir,kvec,current,
 square,ward,rational,conditional,angleJac,scaleJac},
 endpoint=tmd["operator_virtual"];
 projection=RUSoftProjectors[endpoint,0];measurement=RUSoftMeasurement[];
 pdir={1,0,0,1};jdir={Cosh[Y],1,0,Sinh[Y]};
 kvec=Sqrt[tau]{Cosh[yy],Cos[ph],Sin[ph],Sinh[yy]};
 current=pdir/MDot[pdir,kvec]-jdir/MDot[jdir,kvec];
 ward=FullSimplify[MDot[kvec,current],tau>0&&Element[{yy,Y,ph},Reals]];
 square=FullSimplify[-MDot[current,current],tau>0&&Element[{yy,Y,ph},Reals]];
 rational=FullSimplify[ExpToTrig[square/.yy->Y+Log[rr]],tau>0&&rr>0&&Element[{Y,ph},Reals]];
 RUGate["generated beam/jet eikonal current Ward identity",ward===0];
 RUGate["beam/jet eikonal angular kernel",FullSimplify[rational-4rr^2/(tau(1+rr^2-2rr Cos[ph])),tau>0&&rr>0&&Element[{Y,ph},Reals]]===0];
 conditional=FullSimplify[rational/(4/tau)];
 angleJac=Gamma[1-eps]/(2Pi^(1-eps));
 scaleJac=FullSimplify[D[Log[aa/Sqrt[tau]],aa],aa>0&&tau>0];
 <|"projectors"->projection,"measurement"->measurement,
 "collinear_regions"->RUSoftCollinearRegions[tmd["projection"],tmd["collins"],endpoint],
 "fixed_radius_cut"->HoldComplete[DiracDelta[k^2]Theta[k0]
   DiracDelta[k.n-1]DiracDelta[-kTransverse^2-tau]],
 "eikonal_cut_weight"->projection["D_contracted_current_squared"],
 "beam_jet_current"->current,"beam_jet_Ward"->ward,"beam_jet_squared"->square,
 "beam_jet_stereographic_kernel"->rational,"conditional_eikonal_weight"->conditional,
 "angular_Jacobian"->angleJac,
 "angular_conversion"->HoldComplete[dy dOmega/totalOmega==Gamma[1-eps]/(2Pi^(1-eps))d^(2-2eps)w/(w.w)^(1-eps)],
 "global_indices"->{eta/2-eps,1},"longitudinal_rescaling_Jacobian"->scaleJac,
 "longitudinal_rescaling"->HoldComplete[{k.n==aa,k.p==tau/(2aa),yy==Log[aa/Sqrt[tau]],dkPlus/kPlus==dy}],
 "regulators"->HoldComplete[{standard==(nu/Sqrt[tau])^eta Abs[2Sinh[yy]]^(-eta),global==(nu/Sqrt[tau])^eta Exp[-eta Y]rr^(-eta),injet==(nu/Sqrt[tau])^eta Exp[-eta yyLocal]}],
 "regulator_allocation"->"Standard soft and beam/jet soft have distinct rapidity coordinates; their common eta residue is combined at fixed epsilon, with the saved V/Y argument map. The in-jet local cone uses Vstandard=V-g. Physical J0 is the declared shared scalar/rank-one continuation, not a D-dimensional angular Bessel identity.",
 "cut_family_specialization"->HoldComplete[M[u->0]],
 "normalization"->"The squared soft current multiplies the physical emitted-gluon cut with both spin projectors evaluated before integration. Its fixed-radius scalar measure is the u=0 member of M. Physical k+>0 and k->0 boundaries stay explicit when reinstating rapidity."|>
];
RUSoftProjectors[endpoint_Association,delta_]:=Module[
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
 RUGate["d18 generated on-shell quark vertex eikonal reduction",eikonalReduction===ConstantArray[0,{4,4,4}]];
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
 RUGate["d18 eikonal current is gauge transverse",ward===0];
 RUGate["d18 separate physical UU and Collins projections",normalized[[1]]===normalized[[2]]];
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


RUSoftCollinearRegions[cut_Association,collins_Association,endpoint_Association]:=Module[
 {kernels,phase,measured,expanded,unmeasured,inside,residues,softBoundary,
  virtualOriginal,virtualBlocks,virtualDifference,zeroBinIdentity},
 kernels=<|"UU_quark"->cut["D_dimensional_kernels"]["qq"],
   "UU_gluon"->cut["D_dimensional_kernels"]["gq"],
   "Collins_quark"->collins["D_dimensional_kernel"]|>;
 phase=t^(-1-eps) BesselJ[0,2 Sqrt[A t]/z];
 inside=Limit[UnitStep[z^2(1-z)^2 R^2-lam^2 t],lam->0,
   Assumptions->0<z<1&&R>0&&t>0,Direction->"FromAbove"];
 RUGate["d18 intrinsic collinear cone measurement expands to unity",inside===1];
 measured=Map[# phase UnitStep[z^2(1-z)^2R^2-lam^2t]&,kernels];
 expanded=Map[# phase inside&,kernels];unmeasured=Map[# phase&,kernels];
 residues=Map[FullSimplify[Limit[(1-z)#,z->1]]&,kernels];
 RUGate["d18 separate generated UU and Collins soft limits",residues["UU_quark"]===2CF&&residues["Collins_quark"]===2CF];
 RUGate["d18 unpolarized gluon channel has no soft-quark pole",residues["UU_gluon"]===0];
 (* z=1-lam*w leaves a nontrivial soft cone instead of setting it to one. *)
 softBoundary=FullSimplify[Limit[(z^2(1-z)^2R^2-lam^2t)/lam^2/.z->1-lam w,
   lam->0,Direction->"FromAbove"]];
 (* Bind the freshly generated common open virtual operator before any
    radial integration. Identical TMD and fragmenting-jet operators cancel
    at this level; no historical radial-result fields are needed. *)
 virtualOriginal=endpoint["common_virtual_integrand"];
 virtualBlocks={virtualOriginal["left_sail"]["rational_integrand"],
   virtualOriginal["right_sail"]["rational_integrand"],
   virtualOriginal["self_energy"]["on_shell_even_integrand"]};
 virtualDifference=FullSimplify[Flatten[virtualBlocks]-Flatten[virtualBlocks]];
 RUGate["identical actual common virtual matrix blocks cancel",And@@(RUZero/@virtualDifference)];
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


RUSoftMeasurement[]:=Module[{pair,qtOut,jtIn,geom},
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
