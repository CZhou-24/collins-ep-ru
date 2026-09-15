(* v0.3.1 diagonal homogeneous twist-three calculation. The independent
   H_F(z1,z2) coefficient is not calculated or declared zero: the requested
   homogeneous projection retains the Hhat contact term and excludes H_F.
   The derivative and intrinsic EOM terms below are actual open cut traces,
   not a replacement by a transversity splitting function. *)
Clear[D13CollinsDerivation,CollinsEPD13`EOMCoefficient];
D13CollinsDerivation[real_Association,endpoints_Association,
 derivativeFactor_:1,intrinsicFactor_:1]:=Module[
 {gm,sl,dp,sigma,np,nm,ex,ey,metric,rm,km,rvec,kvec,lvec,pol,
  parent,trace,tx,ty,phase,derivative,intrinsic,combined,uu,
  normU,normC,densityU,densityDerivative,measureRatio,parentU,
  parentVector,xiKernel,commonFactor,uuKernel,collinsKernel,
  cutColor,qD,virtualTensor,leftTensor,rightTensor,tensorNorm,
  eomLeft,eomRight,contactIntegral,covariantVertex,fieldVertex,
  completedVertex,contactWard,rayIntegral,contactLimit,
  scalarD,rankD,radialJ1Hybrid,rankRatio,continuedRank,
  rankResidual,normalizationResidual,epsKernel,
  homogeneousDerivativeDensity,intrinsicDensity,traceU,four,hat,
  diracEmissionFactors,graphPresence,sourceEikonal,assumptions,
  vertex,vertices,eomCoefficient,eomEquations,eomSolution,
  virtualP,virtualEll,virtualMap,virtualDenominators,virtualJacobian,virtualShiftResidual,
  fieldPrimitive,positionContact},
 gm=PhysicalGammas[];metric={1,-1,-1,-1};sl[vec_]:=PhysicalSlash[vec,gm];
 dp[aa_,bb_]:=MDot[aa,bb];sigma[aa_,bb_]:=I(sl[aa].sl[bb]-sl[bb].sl[aa])/2;
 np={1,0,0,1};nm={1,0,0,-1};ex={0,1,0,0};ey={0,0,1,0};
 rm=(rx^2+ry^2)/(4 Rplus);
 km=rm+((kt-rx)^2+ry^2)/(4(Kplus-Rplus));
 rvec=Rplus np+rm nm+rx ex+ry ey;
 kvec=Kplus np+km nm+kt ex;lvec=kvec-rvec;
 pol=Table[-metric[[mu]]KroneckerDelta[mu,nu]+metric[[mu]]metric[[nu]]
  (lvec[[mu]]nm[[nu]]+nm[[mu]]lvec[[nu]])/dp[lvec,nm],{mu,4},{nu,4}];
 (* The two cut vertices and color are the quark-gluon leg of the current
    actually generated in s10.  Its D-dimensional cut is independently
    reproduced below with the ordinary UU density before the operator is
    changed to a transverse derivative. *)
 diracEmissionFactors=Cases[real["open_current"],Dot[aa_,bb_,cc_]:>{aa,bb,cc},Infinity];
 graphPresence=Length[diracEmissionFactors]==2&&Length[real["routes"]]==2;
 vertex=D13CurrentVertex[real];If[FailureQ[vertex],Return[vertex]];
 vertices=vertex["physical_vertices"];
 cutColor=4 real["averages"]["eq"];
 parent=sigma[ex,nm];
 trace[alpha_]:=Module[{ins=sigma[alpha,np],fourTrace,hatTrace},
   fourTrace=Sum[pol[[mu,nu]]Tr[parent.sl[kvec].vertices[[nu]].ins.vertices[[mu]].sl[kvec]],{mu,4},{nu,4}];
   (* A hat gamma crosses two barred gammas in the physical tensor, whereas
      it crosses one in the unpolarized density. This fixes the opposite
      evanescent signs; D is not set to four in the cut numerator. *)
   hatTrace=-(D-4)vertex["amputation_weight"]^2 Tr[parent.sl[kvec].ins.sl[kvec]];
   Factor[fourTrace+hatTrace]];
 tx=trace[ex];ty=trace[ey];phase=1/(4(Kplus-Rplus));
 derivative=derivativeFactor Factor[(D[tx phase/dp[kvec,kvec]^2,rx]+
    D[ty phase/dp[kvec,kvec]^2,ry])/.{rx->0,ry->0}];
 homogeneousDerivativeDensity={sigma[ex,np],sigma[ey,np]};
 eomEquations=Thread[Flatten[{
   eomCoefficient sl[np].sigma[np,nm]+sl[ex].homogeneousDerivativeDensity[[1]]+sl[ey].homogeneousDerivativeDensity[[2]],
   eomCoefficient sigma[np,nm].sl[np]+homogeneousDerivativeDensity[[1]].sl[ex]+homogeneousDerivativeDensity[[2]].sl[ey]}]==0];
 eomSolution=Solve[eomEquations,eomCoefficient];
 intrinsicDensity=FullSimplify[(eomCoefficient/.First[eomSolution])sigma[np,nm]/Rplus];
 eomLeft=FullSimplify[Rplus sl[np].intrinsicDensity+
    sl[ex].homogeneousDerivativeDensity[[1]]+sl[ey].homogeneousDerivativeDensity[[2]]];
 eomRight=FullSimplify[Rplus intrinsicDensity.sl[np]+
    homogeneousDerivativeDensity[[1]].sl[ex]+homogeneousDerivativeDensity[[2]].sl[ey]];
 intrinsic=intrinsicFactor Module[{ins=intrinsicDensity,ft,ht},
  ft=Sum[pol[[mu,nu]]Tr[parent.sl[kvec].vertices[[nu]].ins.vertices[[mu]].sl[kvec]],{mu,4},{nu,4}];
  ht=-(D-4)vertex["amputation_weight"]^2 Tr[parent.sl[kvec].ins.sl[kvec]];
  Factor[((ft+ht)phase/dp[kvec,kvec]^2)/.{rx->0,ry->0}]];
 combined=Factor[derivative+intrinsic];
 uu=Module[{ins=sl[np],pr=sl[nm]/2,ft,ht},
  ft=Sum[pol[[mu,nu]]Tr[pr.sl[kvec].vertices[[nu]].ins.vertices[[mu]].sl[kvec]],{mu,4},{nu,4}];
  ht=(D-4)vertex["amputation_weight"]^2 Tr[pr.sl[kvec].ins.sl[kvec]];
  Factor[((ft+ht)phase/dp[kvec,kvec]^2)/.{rx->0,ry->0}]];
 normU=Tr[sl[nm].sl[np]/2];normC=Tr[parent.sigma[ex,np]];
 (* Correlator and moment normalization is kept explicit. zH is the hadron
    fraction relative to the observed parent k; zR relative to r; z=zH/zR.
    M=n+/z times the cut field correlator, p_perp=-z k_perp.
    Int d2r M_U=slash(n)D/(2 zR^2).
    Int d2r r_alpha M_C=-sigma(alpha,n)Hhat/(2 zR^3).
    The latter follows Int p_alpha p_beta H_C/M=delta(alpha,beta) Hhat.
    These factors, not a known evolution kernel, set the longitudinal z. *)
 densityU=1/(2 zR^2);densityDerivative=-1/(2 zR^3);
 measureRatio=Kplus/zR;
 parentU=zH^2/2;
 parentVector=-zH^2/4;
 uuKernel=Factor[(parentU measureRatio densityU uu)/.{Rplus->z Kplus,zH->z zR}];
 qD=Factor[cutColor real["qq_trace"]/(8ss)];
 commonFactor=2 cutColor;
 xiKernel=Factor[(parentVector measureRatio densityDerivative combined)/.{Rplus->z Kplus,zH->z zR}];
 (* The vector integral is i b_i/2 times the scalar Fourier master, and
    the tree Collins moment is -i b_i Hhat/zH.  Dividing by that tree and
    the convolution dzR/zR gives the independently calculated kernel. *)
 collinsKernel=Factor[xiKernel commonFactor kt^3 zR^2 z (-1/2)];
 normalizationResidual=FullSimplify[commonFactor uuKernel zR kt^2-qD];
 epsKernel=Factor[collinsKernel/.D->4-2eps];
 (* Explicit one-gluon gauge completion of iD_perp + integral g F_perp+.
    D=partial+i g A, Fourier mode exp(-i q.x), future ray, positive damping.
    The transverse A contact cancels; the surviving contact is longitudinal
    and vanishes in nbar.A=0. Ordinary staples remain on both endpoints. *)
 rayIntegral=Integrate[Exp[-(lambda+I qplus)ssRay],{ssRay,0,Infinity},Assumptions->lambda>0&&Element[qplus,Reals]];
 covariantVertex=-gS Aalpha;
 fieldVertex=-I gS(qalpha Aplus-qplus Aalpha)rayIntegral;
 contactLimit=FullSimplify[Limit[covariantVertex+fieldVertex,lambda->0,Direction->"FromAbove"],qplus!=0];
 completedVertex=contactLimit;
 contactWard=FullSimplify[(completedVertex/.{Aalpha->qalpha,Aplus->qplus})+gS qalpha];
 fieldPrimitive=Integrate[-D[aTransverse[ssRay],ssRay],ssRay];
 positionContact=FullSimplify[-gS aTransverse[xi]+gS((fieldPrimitive/.ssRay->infinityEndpoint)-(fieldPrimitive/.ssRay->xi))];
 (* The full D-transverse Gaussian derivative is evaluated before choosing
    a finite angular continuation.  The same b-independent scalar ratio
    maps rank zero and rank one onto s10's inherited physical-J0 extension.
    An independently continued physical J1 measure would be a DIFFERENT
    operator extension, and its 1/(1+eps) is displayed instead of discarded. *)
 scalarD=Exp[eps EulerGamma]Gamma[-eps] A^eps;
 rankD=FullSimplify[-I D[Exp[eps EulerGamma]Gamma[-1-eps] (bb^2/4)^(1+eps),bb],bb>0];
 rankResidual=FullSimplify[FunctionExpand[rankD/(I bb/2)-
    (scalarD/.A->bb^2/4)],bb>0];
 rankRatio=endpoints["D_angular_over_physical_J0"];
 continuedRank=FullSimplify[FunctionExpand[rankD/rankRatio]];
  radialJ1Hybrid=I bb Exp[eps EulerGamma]Gamma[-eps](bb^2/4)^eps/(2 Gamma[2+eps]Gamma[1-eps]);
 tensorNorm=Tr[parent.sigma[ex,np]];
 leftTensor=FullSimplify[Tr[parent.(sl[(1-v)np].sl[nm].sigma[ex,np]/4)]/tensorNorm];
 rightTensor=FullSimplify[Tr[parent.(sigma[ex,np].sl[nm].sl[(1-v)np]/4)]/tensorNorm];
 virtualTensor=FullSimplify[endpoints["sail_eta_series"][[1]](leftTensor+rightTensor)/(2(1-v))+
   endpoints["self_energy_parameter_integral"][[1]]];
 virtualP=Rplus np+(rx^2+ry^2)nm/(4Rplus)+rx ex+ry ey;
 virtualMap={qx+v rx,qy+v ry,qminus+(rx qx+ry qy)/(2Rplus)+v(rx^2+ry^2)/(4Rplus)};
 virtualEll=v Rplus np+virtualMap[[3]]nm+virtualMap[[1]]ex+virtualMap[[2]]ey;
 virtualDenominators=FullSimplify[{dp[virtualEll,virtualEll],dp[virtualP-virtualEll,virtualP-virtualEll],dp[nm,virtualEll]}];
 virtualJacobian=FullSimplify[Det[Table[D[virtualMap[[i]],{qx,qy,qminus}[[j]]],{i,3},{j,3}]]];
 virtualShiftResidual=FullSimplify[virtualDenominators-{4v Rplus qminus-qx^2-qy^2,-4(1-v)Rplus qminus-qx^2-qy^2,2v Rplus}];
 <|"status"->"DERIVED_HOMOGENEOUS_CUT_AND_GAUGE_CONTACT",
  "operator_basis"->HoldComplete[H_D[z1,z2]==PV[1/(1/z1-1/z2)]H_F[z1,z2]+DiracDelta[1/z1-1/z2]Hhat[z1]],
  "homogeneous_projection"->"Retain the Hhat contact and its EOM intrinsic term. Independent off-diagonal H_F coefficients remain excluded by the requested approximation; they are not asserted zero in QCD.",
  "operator_source"->"Yuan-Zhou arXiv:0903.4680v1 Eqs. (1)-(5): defining correlator and gauge-completed derivative basis, not the imported final tail.",
  "fresh_graph_presence"->graphPresence,"fresh_graph_emission_factors"->diracEmissionFactors,
  "generated_quark_gluon_vertex_consumed"->vertex,
  "color_from_generated_spin_color_average"->cutColor,
  "kinematics"-><|"r"->rvec,"k"->kvec,"cut_gluon"->lvec,
     "on_shell_residual"->FullSimplify[{dp[rvec,rvec],dp[lvec,lvec]}],"cut_jacobian"->phase|>,
  "axial_polarization"->pol,"derivative_open_tensors"->{tx,ty},
  "derivative_cut"->derivative,"intrinsic_EOM_density"->intrinsicDensity,
  (* Solve keeps its local variable; only the exported name is stable. *)
  "EOM_constraints"->(eomEquations/.eomCoefficient->CollinsEPD13`EOMCoefficient),
  "EOM_solution"->(eomSolution/.eomCoefficient->CollinsEPD13`EOMCoefficient),
  "left_EOM_residual"->eomLeft,"right_EOM_residual"->eomRight,
  "intrinsic_cut"->intrinsic,"combined_cut"->combined,
  "combined_cut_fraction"->Factor[combined/.Rplus->z Kplus],
  "UU_same_graph_cut"->uu,"UU_tree_projection_norm"->normU,"Collins_tree_projection_norm"->normC,
  "density_normalizations"-><|"UU"->densityU,"derivative"->densityDerivative,
     "correlator_and_longitudinal_measure"->measureRatio,"UU_parent_projection"->parentU,
     "Collins_parent_vector_projection"->parentVector|>,
  "UU_projected_fraction_weight"->uuKernel,"common_phase_and_coupling"->commonFactor,
  "common_normalization_origin"->"The transverse loop measure g_s^2 d^2k/(2pi)^3 becomes a dt with a=alpha_s/(2pi); the light-cone coordinates k=(kplus+kminus,kx,ky,kplus-kminus) have Jacobian2. The resulting 2CF is checked against the separately generated D-dimensional UU cut, not solved from that cut.",
  "moment_conversion"->HoldComplete[Hhat3[z]==2 Hhat[z]],
  "moment_conversion_origin"->"Yuan-Zhou Hhat=int d2p p2 HC/(2M); KPSY Hhat3=int d2p p2 HC/M. Thus -i b Hhat/z=-i b Hhat3/(2z), with an unchanged matching kernel.",
  "mass_and_Fourier_map"->"Set the auxiliary Yuan-Zhou mass M to native Mh. Partonic k_perp=-p_perp/z turns exp(-i p.b/z) into exp(+i k.b); hence the partonic rank integral has +i b/2, while the physical Collins tree has -i b Hhat/z=-i b Hhat3/(2z).",
  "common_normalization_residual"->normalizationResidual,
  "Collins_projected_fraction_weight"->xiKernel,"D_dimensional_kernel"->epsKernel,
  "epsilon0"->Factor[epsKernel/.eps->0],"epsilon1"->Factor[SeriesCoefficient[epsKernel,{eps,0,1}]],
  "future_ray_integral"->rayIntegral,"covariant_derivative_gluon_vertex"->covariantVertex,
  "field_strength_gluon_vertex"->fieldVertex,"completed_gluon_vertex"->completedVertex,
  "one_gluon_Ward_residual"->contactWard,"light_cone_contact"->FullSimplify[completedVertex/.Aplus->0],
  "light_cone_field_strength_primitive"->fieldPrimitive,"position_space_contact"->positionContact,
  "retarded_boundary_contact"->FullSimplify[positionContact/.aTransverse[infinityEndpoint]->0],
  "gauge_contact_support"->"For qplus!=0 the Fourier contact is explicit. The zero-mode statement uses the stronger position-space identity F(alpha,+)=-partialplus Aalpha in Aplus=0: the entire iD+integral F equals ipartial-g Aalpha(infinity), and the retarded boundary sets that field to zero. The ordinary-test-function identity qplus/(qplus-i0)=1 is not multiplied by an independent singular distribution. Full staples restore covariance.",
  "full_D_scalar_Fourier"->scalarD,"full_D_vector_Fourier"->rankD,
  "rank_one_derivative_residual"->rankResidual,"common_angular_continuation"->rankRatio,
  "native_continued_vector_Fourier"->continuedRank,"alternative_J1_hybrid"->radialJ1Hybrid,
  "alternative_hybrid_ratio"->FullSimplify[FunctionExpand[radialJ1Hybrid/continuedRank],bb>0],
  "angular_extension_scope"->"The common b-independent inverse Gamma(1-eps)Gamma(1+eps) multiplies both full-D rank-zero and rank-one loop operators. It commutes with the derivative defining the Collins moment. This is the inherited s10 scalar continuation extended at operator level; it is separate from C11 UV subtraction.",
  "virtual_tensor_left_right"->{leftTensor,rightTensor},"virtual_tensor_coefficient"->virtualTensor,
  "virtual_scalar_residual"->FullSimplify[virtualTensor-endpoints["virtual_UV_minus_IR_coefficients"][[1]]],
  "virtual_on_shell_external"->virtualP,"virtual_full_light_front_shift"->virtualMap,
  "virtual_shifted_loop"->virtualEll,"virtual_shifted_denominators"->virtualDenominators,
  "virtual_shift_residual"->virtualShiftResidual,"virtual_shift_jacobian"->virtualJacobian,
  "virtual_derivative_scope"->"On-shell external momentum: shift both ell_perp and ell_minus as displayed. The two propagators and Wilson denominator lose all r_perp dependence, the three-variable Jacobian is one and eta regulator is unchanged. Transverse differentiation therefore acts on the tree tensor and its EOM completion; translation boundary terms vanish in dimensional regularization.",
  "diagnostic_factors"-><|"derivative"->derivativeFactor,"intrinsic"->intrinsicFactor|>|>
];
