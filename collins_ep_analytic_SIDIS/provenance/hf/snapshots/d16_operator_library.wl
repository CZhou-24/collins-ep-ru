(* Additive NLO operator definitions and explicit coordinate/projection algebra. *)
Clear[D16NLOStage];
D16NLOStage[]:=Module[{normalization,gm,np,nm,ex,ey,sl,sigma,traceNorm,
 jac,z1Jac,pvMeasure,deltaJac,contact,ray,pvReg,fieldPrimitive,
 boundary,ward,rank0,rank1,momentN,momentYZ,spin,defs,identities,
 conventions,operators,measurement,proofs,residuals,nodes,report,
 jetVector,hadronVector,beamTransverseZ,physicalZ,fractionDifference,completion},
 Get[FileNameJoin[{$NLOProduction,"common","assembly_helpers.wl"}]];
 Get[FileNameJoin[{$NLOProduction,"common","d14_convention_library.wl"}]];
 (* Re-run accepted DERIVATION CODE, including pinned SIDIS Gram algebra,
    physical Fourier integrals, moment measures and coupling normalization. *)
 normalization=D14Normalize[$NLOProduction];
 gm=PhysicalGammas[];np={1,0,0,1};nm={1,0,0,-1};
 Get[FileNameJoin[{$NLOProduction,"common","d16_projection_normalization.wl"}]];
 Get[FileNameJoin[{$NLOProduction,"common","d16_wilson_taylor.wl"}]];
 Get[FileNameJoin[{$NLOProduction,"common","d16_spectral_support.wl"}]];
 Get[FileNameJoin[{$NLOProduction,"common","d16_operator_completion.wl"}]];
 completion=D16CompleteOperator[gm];
 Gate["joined native operator projection, Wilson and endpoint algebra",
   AssociationQ[completion]&&And@@(TrueQ[FullSimplify[#]===0]&/@Values[completion["residuals"]])];
 NLOPut[completion,"operator_completion.wl"];
 ex={0,1,0,0};ey={0,0,1,0};sl[k_]:=PhysicalSlash[k,gm];
 sigma[k_,l_]:=I(sl[k].sl[l]-sl[l].sl[k])/2;
 traceNorm=Tr[sigma[ex,nm].sigma[ex,np]];
 (* Oriented z1 integral reverses when v=z/z1. Retain absolute Jacobian. *)
 z1Jac=FullSimplify[-D[z/v,v]/(z/v)^2,z>0&&0<v<1];
 pvMeasure=Cancel[z1Jac/(1/z-1/(z/v))];
 deltaJac=FullSimplify[1/D[1/z-1/z1,z1]/.z1->z,z>0];
 contact=FullSimplify[(deltaJac/z1^2 z/z1)/.z1->z,z>0];
 ray=Integrate[Exp[-(lambda+I qplus)tRay],{tRay,0,Infinity},
   Assumptions->lambda>0&&Element[qplus,Reals]];
 pvReg=FullSimplify[ComplexExpand[Re[I ray]],lambda>0&&Element[qplus,Reals]];
 fieldPrimitive=Integrate[-D[atrans[tRay],tRay],tRay];
 boundary=FullSimplify[-gS atrans[xi]+gS((fieldPrimitive/.tRay->futureEndpoint)-(fieldPrimitive/.tRay->xi))];
 ward=FullSimplify[Limit[-gS Aalpha-I gS(qalpha Aplus-qplus Aalpha)ray,
   lambda->0,Direction->"FromAbove"],qplus!=0];
 rank0=FullSimplify[2Pi normalization["fourier"]["radial_rank0_coefficient"],z>0];
 rank1=FullSimplify[2Pi normalization["fourier"]["radial_rank1_coefficient"],z>0];
 momentN=pSquared/Mh;momentYZ=pSquared/(2Mh);
 spin=<|"barred_dimension"->4,"physical_transverse_dimension"->2,
  "internal_dimension"->4-2eps,"hat_metric_trace"->-2eps,
  "bar_hat_anticommutator"->HoldComplete[AntiCommutator[gammaBar[mu],gammaHat[nu]]==0],
  "two_bar_tensor_hat_crossing"->(-1)^2,"one_bar_vector_hat_crossing"->-1,
  "physical_tensor_trace"->traceNorm,
  "projected_tensor_identity"->FullSimplify[Tr[sigma[ex,nm].sigma[ex,np]]/traceNorm],
  "rank0_angular_continuation"->1/(Gamma[1-eps]Gamma[1+eps]),
  "rank1_angular_continuation"->1/(Gamma[1-eps]Gamma[1+eps]),
  "prescription"->"Physical external spin plane; internal hat contractions retained until epsilon expansion. A common b-independent physical-J0 continuation acts on rank0 and rank1, inherited from d13/d14; eta is removed before epsilon. This is a specified extension, not all possible spin schemes."|>;
 operators=<|"origin"->"External gauge-invariant fragmentation operator definitions; computed change of variables and boundary/Fourier algebra below",
  "basis"->{Hhat3,HFNative},
  "Hhat_native_moment"->HoldComplete[Hhat3[z]==Inactive[Integrate][pSquared HC[z,pSquared]/Mh,d2p]],
  "Hhat_YZ_moment"->HoldComplete[HhatYZ[z]==Inactive[Integrate][pSquared HC[z,pSquared]/(2Mh),d2p]],
  "moment_ratio_derived"->Cancel[momentN/momentYZ],
  "historical_moment_bookkeeping"->HoldComplete[Hhat3[z]==2 HhatYZsameHC[z]],
  "native_basis_definition"->HoldComplete[{Hhat3[z]==2 HhatKangCovariant[z],HFNative[z,z1]==2 HFKangCovariant[z,z1]}],
  "basis_extension_reason"->"operator_completion.wl derives the same factor of two for Hhat and HF from the accepted TMD/state/spin normalization and full inverse projection; their ratio in matching is one. This supersedes the old HF=2HFYZ-by-definition argument. The source's literal D/link placement and printed YZ twist-three prefactors remain explicitly qualified in d16_projection_notes.md.",
  "EOM_native"->HoldComplete[HDNative[z,z1]==PV[1/(1/z-1/z1)]HFNative[z,z1]+DiracDelta[1/z-1/z1]Hhat3[z]],
  "EOM_literal_Kang_contact"->HoldComplete[DiracDelta[1/z-1/z1](z/z1)HhatKang[z1]],
  "imaginary_projection"->completion["projection"]["HFnative_from_K15"],
  "gauge_completion"->HoldComplete[iDperp[alpha,xi]+Inactive[Integrate][gS FalphaPlus[alpha,tRay],{tRay,xi,Infinity}]],
  "future_staples"->HoldComplete[WilsonLine[Infinity,eta].gS FalphaPlus[alpha,eta].WilsonLine[eta,xi].psi[xi]],
  "covariant_derivative_convention"->HoldComplete[Dperp==partialPerp+I gS APerp],
  "fourier_phase"->HoldComplete[Exp[I k2plus xi+I kgplus eta]],
  "future_ray"->ray,"regulated_PV"->pvReg,
  "position_boundary"->boundary,"retarded_boundary"->(boundary/.atrans[futureEndpoint]->0),
  "one_gluon_completion"->ward,
  "Ward_residual"->FullSimplify[(ward/.{Aalpha->qalpha,Aplus->qplus})+gS qalpha],
  "support_spectral_equations"->HoldComplete[{k1plus==Phplus+PXplus,kgplus==PYplus,k2plus==k1plus-kgplus,PXplus>=0,PYplus>=0}],
  "positive_ordered_branch"->HoldComplete[{u==zh/z,v==z/z1,zh<=z<=1,z1>=z,0<v<=1}],
  "complete_spectral_and_boundary_proof"->completion["spectral_support"],
  "crossed_support_qualification"->"Both spectral insertions now establish k>=1 and 0<w<k after the two pole matrix elements vanish, with k=1/z and w=1/z1. The equal-lightfront permutation and boundary assumptions are explicit; the old single-insertion equations alone were insufficient.",
  "diagonal_HF"->completion["physical_endpoint_class"]|>;
 jetVector=pJ{Sin[thetaJ],0,Cos[thetaJ]};
 hadronVector=z jetVector+jTheta{Cos[thetaJ],0,-Sin[thetaJ]}+jPhi{0,1,0};
 beamTransverseZ=FullSimplify[(Take[hadronVector,2].Take[jetVector,2])/(Take[jetVector,2].Take[jetVector,2]),pJ>0&&0<thetaJ<Pi];
 physicalZ=FullSimplify[(hadronVector.jetVector)/(jetVector.jetVector),pJ>0&&0<thetaJ<Pi];
 fractionDifference=FullSimplify[beamTransverseZ-physicalZ,pJ>0&&0<thetaJ<Pi];
 measurement=<|"process"->HoldComplete[e[ell]+p[protonMomentum,ST]->e[ellPrime]+jet[jetMomentum,hadronMomentum]+X],
  "recoil"->HoldComplete[qRecoilVector==ellPrimeTransverse+jetTransverse],
  "jet_clustering"->HoldComplete[{dij==Min[1/ptI^2,1/ptJ^2]((yi-yj)^2+DeltaPhi[i,j]^2)/R^2,diB==1/ptI^2}],
  "axis"->HoldComplete[jetMomentum==Total[constituentFourMomenta]],
  "physical_fragment_variables"->HoldComplete[{zh==(hadronThreeVector.jetThreeVector)/(jetThreeVector.jetThreeVector),
    jVector==hadronThreeVector-zh jetThreeVector}],
  "fraction_conversion_geometry"-><|"jet"->jetVector,"hadron"->hadronVector,
    "literal_beam_transverse_fraction"->beamTransverseZ,"native_axis_fraction"->physicalZ,
    "difference"->fractionDifference,"pT_jet"->pJ Sin[thetaJ],
    "power_scope"->"The literal beam-transverse fraction differs by jTheta cos(thetaJ)/pTjet. The native axis/light-cone fraction agrees only at leading power, not as an exact measured-variable identity."|>,
  "Collins_harmonic"->HoldComplete[Sin[phiS-phiH]],
  "independent_Fourier_phases"->HoldComplete[Exp[I qRecoilVector.bRecoilVector]Exp[I jVector.bFragmentVector/zh]],
  "hierarchy"->HoldComplete[{qRecoil/pTJet<<1,jHadron/(zh pTJet R)<<1,zh>0}],
  "paper_jT_literal_qualification"->"The ep prose prints pT^h cross pT^jet divided by |pT^jet|^2, which has no momentum dimension. We preserve that literal separately; the physical transverse vector is the orthogonal projection relative to the standard jet axis. This is an explicit interpretation, not an edit to the paper.",
  "finite_jet_scope"->"Replace inclusive J by the fragmenting-jet operator; intrinsic quark/gluon TMD matching remains inside it. The additional scalar finite conversion and its overlap proof belong to d18, not to the NLL statement in ep Eq18.",
  "Born_coupling"->normalization["normalizations"]["Born_squared_coupling"],
  "SIDIS_transport_map"->KeyTake[normalization,{"kinematics","normalizations"}]|>;
 defs=<|"process"->"ep_Collins","electron"->"unpolarized","proton"->"transverse",
  "jet_algorithm"->"anti-kt","jet_axis"->"standard_E_scheme","coupling"->"alpha_s/(2*pi)",
  "born_coupling"->"alpha_EM^2","sidis_commit"->"5062dcb2407594dafcc2f9f72800e96ff9e6d957",
  "operator_basis"->{"Hhat","HF"},"HF_diagonal"->"zero","rapidity_order"->"eta_then_epsilon",
  "radius_qualification"->"narrow_cone_derivation_R1_not_certified",
  "paper_limit"->"HF_zero_and_jet_finite_extension_zero","all_b"->"renormalized_symbolic_TMDs","small_b"->"local_OPE_only"|>;
 identities=<|"dz1_measure"->z1Jac,"PV_combined_measure"->pvMeasure,
  "delta_inverse_fraction"->deltaJac,"EOM_contact"->contact,
  "Fourier_rank0_relative"->rank0,"Collins_rank1_relative"->rank1|>;
 proofs=<|"measure"->z1Jac-1/z,"PV"->pvMeasure-1/(1-v),"delta"->deltaJac-z^2,
  "contact"->contact-1,"rank0"->rank0-z^-2,"rank1"->rank1-1/(2z^3),
  "moment"->Cancel[momentN/momentYZ]-2,"boundary"->(boundary/.atrans[futureEndpoint]->0),
  "Ward"->operators["Ward_residual"],"physical_axis_fraction"->physicalZ-z,
  "beam_transverse_fraction_map"->TrigExpand[fractionDifference-jTheta Cot[thetaJ]/pJ]|>;
 residuals=Map[FullSimplify[#,z>0&&0<v<1]&,proofs];
 NLOPut[<|"identities"->identities,"residuals"->residuals|>,"conversion-diagnostic.wl"];
 Gate["d16 native convention algebra",And@@(TrueQ[#===0]& /@ Values[residuals])];
 NLOPut[operators,"operators.wl"];NLOPut[spin,"projectors.wl"];
 NLOPut[measurement,"measurement.wl"];NLOPut[normalization,"retained_normalization_rederived.wl"];
 NLOPut[<|"identities"->identities,"residuals"->residuals|>,"conversion.wl"];
 report=Import[FileNameJoin[{$NLOProduction,"common","d16_operator_notes.md"}],"Text"];
 Export[FileNameJoin[{$NLOOutput,"OPERATORS_AND_MEASUREMENT.md"}],report,"Text"];
 NLOWritePacket[<|"definitions"->defs,"identities"->Map[NLOTree,identities],"independent_HF"->True,
  "review"-><|"operator_identification"->"operator_completion.wl derives the full native/Kang covariant projection and inverse density from actual spin/color/Fourier factors. Both native operators have factor two, so their matching ratio is one. Printed source alternatives and link-placement tensions remain qualified in the source notes.",
   "gauge_boundary"->"operator_completion.wl retains the finite-endpoint Wilson Taylor identity through g^2 in a free associative algebra and the exact transport-ODE proof before A_perp(+infinity)=0. The complete rank-one derivative identifies Hhat and has no independent tree HF coefficient.",
   "support_and_EOM"->"operator_completion.wl includes both spectral insertion arguments, Appendix-A boundary/derivative analysis and the actual regular F-to-F map. Generic contacts precede physical endpoint reduction; convergence and NLO subtraction qualifications are explicit. conversion.wl retains the unit EOM contact.",
   "finite_jet_scope"->"measurement.wl specifies anti-kt standard E-scheme, independent recoil/fragment Fourier variables and fragmenting-jet replacement. Finite overlap proof is delegated to d18 with narrow-cone radius qualification."|>|>];
 nodes={NLONode["source","definitions","production","common/d16_nlo.wls",{},"Native stage entry invokes candidate operator algebra."],
  NLONode["library","definitions","production","common/d16_operator_library.wl",{"source"},"Operator definitions and explicit Fourier, tensor and Jacobian calculation."],
  NLONode["completion_source","conversion","production","common/d16_operator_completion.wl",{"library"},"Joins freshly calculated projection, Wilson and spectral identities without importing historical coefficients."],
  NLONode["projection_source","projectors","production","common/d16_projection_normalization.wl",{},"Physical inverse projector, native/reference spin factors, coupling/field map and longitudinal Fourier measures."],
  NLONode["wilson_source","definitions","production","common/d16_wilson_taylor.wl",{},"Free noncommutative Wilson series through g^2 and exact endpoint-ODE identity before the boundary limit."],
  NLONode["spectral_source","definitions","production","common/d16_spectral_support.wl",{},"Both spectral support arguments, Appendix-A algebra, endpoint chain rule and regularity counterexamples."],
  NLONode["projection_notes","definitions","production","common/d16_projection_notes.md",{},"Literal source/state/link qualifications underlying the normalization map."],
  NLONode["spectral_notes","definitions","production","common/d16_spectral_support_notes.md",{},"Pinned source equations, boundary assumptions and domain/subtraction qualifications."],
  NLONode["accepted_operator_code","definitions","production","common/d13_collins_derivation.wl",{},"Unchanged accepted YZ/KPSY TMD and moment normalization identifies the native operator; no final coefficient is imported."],
  NLONode["completion","conversion","output","operator_completion.wl",{"completion_source","projection_source","wilson_source","spectral_source","projection_notes","spectral_notes","accepted_operator_code"},"Full calculated operator map and physical endpoint class consumed directly by d17 and d19."],
  NLONode["normalization_code","conversion","production","common/d14_convention_library.wl",{},"Accepted normalization DERIVATION CODE rerun unchanged in this stage."],
  NLONode["notes","definitions","production","common/d16_operator_notes.md",{},"Definitions, literal convention alternatives and support qualifications."],
  NLONode["retained_dependency","definitions","d15","native_observable.wl",{},"Actual retained input establishes the inherited observable checkpoint; coefficients are not copied as a new derivation."],
  NLONode["operators","definitions","output","operators.wl",{"library","notes","retained_dependency","completion"},"Gauge-completed independent HF operator and explicit endpoint/support algebra."],
  NLONode["projection","projectors","output","projectors.wl",{"library"},"Physical spin tensors and inherited D-dimensional continuation are displayed."],
  NLONode["measurement","measurement","output","measurement.wl",{"library","operators"},"Measured anti-kt E-scheme observable with separate recoil and fragmentation variables."],
  NLONode["normalization","conversion","output","retained_normalization_rederived.wl",{"normalization_code","library"},"Fresh execution of the accepted Fourier, moment and SIDIS convention derivation."],
  NLONode["conversion","conversion","output","conversion.wl",{"operators","projection","normalization"},"Calculated Jacobians, delta support, Fourier measures and exact residuals."],
  NLONode["packet","conversion","output","packet.wl",{"conversion","measurement"},"Transport export of the calculated identities with explicit definition origin."],
  NLONode["review","definitions","output","OPERATORS_AND_MEASUREMENT.md",{"notes","operators","projection","measurement","conversion"},"Scientific convention judgment remains separate from algebraic pass counts."]};
 NLOProvenance[nodes,{"packet","review"}];Exit[0]
];
