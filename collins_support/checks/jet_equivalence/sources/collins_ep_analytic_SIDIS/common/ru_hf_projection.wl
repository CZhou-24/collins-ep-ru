(* v0.5.1 fresh HF generating source; exact pre-use identity in provenance/hf/COLLINS_REUSE_PLAN.json. No archived output or radial library is loaded. *)
(* Definition-level Clifford/Fourier normalization. No reference kernel or
   archived output is consumed. See d16_projection_notes.md for literal-source
   qualifications. The physical external spin plane has two components. *)
Clear[D16ProjectionNormalization];
D16ProjectionNormalization[gammaMatrices_:Automatic]:=Module[
 {gm,id,zz,pauli,metric,slash,sigma,p,n,ea,nativeProjector,sourceProjector,
  nativeDensity,ass,tmdN,tmdK,tmdSolution,rawDerivative,rankOneTrace,
  nativeMoment,sourceMoment,momentFactor,trialF,nativeF,sourceF,factorF,
  nativeDual,sourceDual,longJac,nativeInverse,sourceInverse,nativeParent,
  sourceParent,nativeParentDensity,sourceParentDensity,basisFactor,
  raw2015,rawColor,projection2015,source2015,fieldMap,
  checks,residuals,passed,transport,lam,color,bar,mirrorAction},
 id=IdentityMatrix[2];zz=ConstantArray[0,{2,2}];
 pauli={{{0,1},{1,0}},{{0,-I},{I,0}},{{1,0},{0,-1}}};
 gm=If[gammaMatrices===Automatic,
   Prepend[Table[ArrayFlatten[{{zz,pauli[[j]]},{-pauli[[j]],zz}}],{j,3}],DiagonalMatrix[{1,1,-1,-1}]],gammaMatrices];
 If[Dimensions[gm]=!={4,4,4},Return[Failure["GammaMatrixShape",<|"expected"->{4,4,4},"actual"->Dimensions[gm]|>]]];
 metric={1,-1,-1,-1};slash[x_]:=Sum[metric[[j]]x[[j]]gm[[j]],{j,4}];
 sigma[x_,y_]:=I(slash[x].slash[y]-slash[y].slash[x])/2;
 bar[x_]:=gm[[1]].ConjugateTranspose[x].gm[[1]];
 p={1,0,0,1}/Sqrt[2];n={1,0,0,-1}/Sqrt[2];ea={{0,1,0,0},{0,0,1,0}};
 nativeProjector=Table[sigma[ea[[j]],n],{j,2}];
 sourceProjector=Table[I gm[[j+1]].slash[n],{j,2}];
 nativeDensity=Table[I gm[[j+1]].slash[p],{j,2}];
 ass=Global`z>0&&Global`z1>0&&Global`zh>0&&Global`Mh>0&&Global`kt2>0&&
   0<Global`u<1&&0<Global`v<1&&Global`Phplus>0&&
   Element[{Global`c,Global`HN,Global`HK,Global`HFN,Global`HFK,Global`HR,Global`HI,
    Global`DN,Global`DK,Global`HCN,Global`HCK,Global`KR,Global`KI,Global`CR,Global`CI},Reals];
 (* B is one common color-averaged cut matrix. Native follows the accepted
    YZ/KPSY definition B/z. Kang's explicit suppressed spin average gives
    B/(2z). The tensor decompositions are the same, with coefficient 1/2. *)
 tmdN=(Global`DN slash[p]+Global`HCN sigma[Global`px ea[[1]]+Global`py ea[[2]],p]/Global`Mh)/2;
 tmdK=(Global`DK slash[p]+Global`HCK sigma[Global`px ea[[1]]+Global`py ea[[2]],p]/Global`Mh)/2;
 tmdSolution=Solve[Thread[Flatten[tmdN-2tmdK]==0],{Global`DN,Global`HCN}];
 (* Rotational moment: integral p_i p_j HC/M=delta_ij HN/2.
    Decomposition 1/2, p=-zk, d2p=z2 d2k and the Fourier derivative give
    integral k_i B(k)=-sigma(e_i,p) HN/(4z2)=iD_N^i B in the stated phase. *)
 rawDerivative=Table[-sigma[ea[[j]],p]Global`HN/(4Global`z^2),{j,2}];
 rankOneTrace=Sum[Tr[nativeProjector[[j]].rawDerivative[[j]]],{j,2}];
 nativeMoment=FullSimplify[Global`z^2 rankOneTrace/2,ass];
 sourceMoment=FullSimplify[Global`z^2/4 Sum[Tr[sourceProjector[[j]].(-rawDerivative[[j]])],{j,2}],ass];
 momentFactor=Cancel[nativeMoment/sourceMoment];
 (* The same independent upper F insertion and physical dual tensor fix
    its normalization. This is not an equation setting HF to Hhat. *)
 trialF=Global`c nativeDensity;
 nativeF=FullSimplify[Global`z Global`z1/2 Sum[Tr[nativeProjector[[j]].trialF[[j]]],{j,2}],ass];
 sourceF=FullSimplify[Global`z Global`z1/4 Sum[Tr[sourceProjector[[j]].(-trialF[[j]])],{j,2}],ass];
 factorF=Cancel[nativeF/sourceF];basisFactor=Cancel[momentFactor/factorF];
 nativeDual=First[Solve[nativeF==Global`HFN,Global`c]];
 sourceDual=First[Solve[sourceF==Global`HFK,Global`c]];
 longJac=FullSimplify[Det[D[{Global`Phplus/Global`z,Global`Phplus/Global`z1},{{Global`z,Global`z1}}]],ass];
 (* One F-to-A inverse plus momentum and the longitudinal Jacobian. The
    inverse-fraction PV itself is transported separately by d16/d17. *)
 nativeInverse=FullSimplify[longJac*(Global`c/.nativeDual)/Global`HFN/Global`Phplus,ass];
 sourceInverse=FullSimplify[longJac*(Global`c/.sourceDual)/Global`HFK/Global`Phplus,ass];
 (* The defining h.c./2 is Re. After that operation the native/Kang
    projected parent factors are z_h^2/2 and z_h^2/4. Distinct conjugate
    graph placements are d17's responsibility; no mirror factor is here. *)
 nativeParent=Global`zh^2/2;sourceParent=Global`zh^2/4;
 nativeParentDensity=FullSimplify[nativeParent Sqrt[Global`kt2]nativeInverse(Global`z Global`z1^2)/.
   {Global`Phplus->Global`zh,Global`z->Global`zh/Global`u,Global`z1->Global`zh/(Global`u Global`v)},ass];
 sourceParentDensity=FullSimplify[sourceParent Sqrt[Global`kt2]sourceInverse(Global`z Global`z1^2)/.
   {Global`Phplus->Global`zh,Global`z->Global`zh/Global`u,Global`z1->Global`zh/(Global`u Global`v)},ass];
 (* 1512.07233v2 Eqs14,16 define the complex ig m.F correlator.
    lambda=Phplus xi, mu=Phplus eta, m=n/Phplus gives DeltaF=Phplus C.
    The physical i sigma tensor selects Im H_FU, with no guessed factor. *)
 raw2015=Table[(Global`Mh/Global`z)I/2(slash[Global`Phplus p].gm[[j+1]]-gm[[j+1]].slash[Global`Phplus p])I(Global`HR+I Global`HI),{j,2}];
 rawColor=raw2015/Global`Phplus;
 projection2015=FullSimplify[Global`z Global`z1/2 ComplexExpand[Re[Sum[Tr[nativeProjector[[j]].rawColor[[j]]],{j,2}]]],ass];
 source2015=FullSimplify[Global`z Global`z1/4 ComplexExpand[Re[Sum[Tr[sourceProjector[[j]].(-rawColor[[j]])],{j,2}]]],ass];
 (* D_N=partial+ig A_N; W_N(b,a)=P exp[-ig integral_a^b A_N].
    D_R=partial-ig A_R, A_R=-A_N, W_R=P exp[+ig integral A_R].
    These COVARIANT transports coincide. Kang's printed minus-sign L with
    its displayed placement is a separate literal-source qualification. *)
 fieldMap=<|"connection"->Expand[(-I Global`g Global`AR)/.Global`AR->-Global`AN]-I Global`g Global`AN,
   "field_linear"->Expand[(Global`dMuARnu-Global`dNuARmu)/.{Global`dMuARnu->-Global`dMuANnu,Global`dNuARmu->-Global`dNuANmu}]+Global`dMuANnu-Global`dNuANmu,
   "field_commutator"->Expand[(-I Global`g Global`commAR)/.Global`commAR->Global`commAN]+I Global`g Global`commAN,
   "covariant_transport_exponent"->Expand[(I Global`g Global`intAR)/.Global`intAR->-Global`intAN]+I Global`g Global`intAN,
   "projected_index_orientation"->(-Global`PN)(-Global`FN)-Global`PN Global`FN|>;
 mirrorAction=ComplexExpand[((Global`KR+I Global`KI)(Global`CR+I Global`CI)+
   Conjugate[(Global`KR+I Global`KI)(Global`CR+I Global`CI)])/2];
 transport=Expand[Global`kappaH(Global`Kdiag Global`HN/Global`kappaH+Global`Kmix Global`HFN/Global`kappaF)];
 lam={{{0,1,0},{1,0,0},{0,0,0}},{{0,-I,0},{I,0,0},{0,0,0}},DiagonalMatrix[{1,-1,0}],
   {{0,0,1},{0,0,0},{1,0,0}},{{0,0,-I},{0,0,0},{I,0,0}},{{0,0,0},{0,0,1},{0,1,0}},
   {{0,0,0},{0,0,-I},{0,I,0}},DiagonalMatrix[{1,1,-2}]/Sqrt[3]}/2;
 color=<|"generators"->lam,"trace"->Table[Tr[lam[[j]].lam[[k]]],{j,8},{k,8}],
   "Casimir"->Sum[lam[[j]].lam[[j]],{j,8}],
   "crossed"->Table[Sum[lam[[j]].lam[[k]].lam[[j]],{j,8}],{k,8}],
   "commutator"->Table[Sum[lam[[j]].(lam[[j]].lam[[k]]-lam[[k]].lam[[j]]),{j,8}],{k,8}]|>;
 checks=<|"clifford"->Flatten[Table[gm[[j]].gm[[k]]+gm[[k]].gm[[j]]-2metric[[j]]KroneckerDelta[j,k]IdentityMatrix[4],{j,4},{k,4}]],
   "TMD_same_raw_matrix"->Flatten[(tmdN-2tmdK)/.First[tmdSolution]],
   "tensor_sign"->Flatten[nativeProjector+sourceProjector],
   "physical_dual_gram"->Flatten[Table[Tr[nativeProjector[[j]].nativeDensity[[k]]],{j,2},{k,2}]-4IdentityMatrix[2]],
   "tensor_Dirac_hermiticity"->Flatten[Table[bar[nativeDensity[[j]]]-nativeDensity[[j]],{j,2}]],
   "native_moment"->nativeMoment-Global`HN,"Kang_moment"->sourceMoment-Global`HN/2,
   "moment_factor"->momentFactor-2,"native_F"->nativeF-4Global`z Global`z1 Global`c,
   "Kang_F"->sourceF-2Global`z Global`z1 Global`c,"F_factor"->factorF-2,
   "basis_transport"->basisFactor-1,
   "longitudinal_jacobian"->longJac-Global`Phplus^2/(Global`z^2 Global`z1^2),
   "native_inverse_density"->nativeInverse-Global`Phplus/(4Global`z^3 Global`z1^3),
   "Kang_inverse_density"->sourceInverse-Global`Phplus/(2Global`z^3 Global`z1^3),
   "native_parent_density"->nativeParentDensity-Global`u^3 Global`v Sqrt[Global`kt2]/8,
   "parent_density_invariance"->nativeParentDensity-sourceParentDensity,
   "native_K15_map"->projection2015-4Global`Mh Global`z1 Global`HI,
   "Kang_K15_map"->source2015-2Global`Mh Global`z1 Global`HI,
   "h_c_real_projection"->mirrorAction-(Global`KR Global`CR-Global`KI Global`CI),
   "field_link_map"->Values[fieldMap],"color_trace"->Flatten[color["trace"]-IdentityMatrix[8]/2],
   "color_Casimir"->Flatten[color["Casimir"]-4IdentityMatrix[3]/3],
   "color_crossed"->Flatten[color["crossed"]+lam/6],"color_commutator"->Flatten[color["commutator"]-3lam/2]|>;
 residuals=Map[FullSimplify[#,ass]&,checks];
 passed=Map[And@@(TrueQ[#===0]&/@Flatten[{#}])&,residuals];
 If[!And@@Values[passed],Return[Failure["ProjectionNormalizationIdentity",<|"checks"->passed,"residuals"->residuals|>]]];
 <|"origin"->"Actual physical Clifford, inverse projector, Fourier/Jacobian and color algebra from accepted native YZ/KPSY TMD normalization; external operator definitions are explicit inputs, not derived QCD dynamics.",
   "physical_basis"-><|"metric"->metric,"p"->p,"n"->n,"transverse"->ea,"gamma"->gm|>,
   "raw_TMD_definition"->HoldComplete[{DeltaNative==ColorAveragedCutB/z,DeltaKang==ColorAveragedCutB/(2z)}],
   "TMD_decompositions"->{tmdN,tmdK},"TMD_solution"->tmdSolution,
   "raw_derivative_from_TMD_moment"->rawDerivative,"native_projector"->nativeProjector,
   "Kang_projector"->sourceProjector,"native_moment_projection"->nativeMoment,
   "Kang_moment_projection"->sourceMoment,"native_moment_over_Kang"->momentFactor,
   "native_F_projection"->nativeF,"Kang_F_projection"->sourceF,
   "native_F_over_Kang"->factorF,"native_basis_factor"->basisFactor,
   "native_inverse_projector"->nativeDual,"Kang_inverse_projector"->sourceDual,
   "longitudinal_Jacobian"->longJac,"native_inverse_density"->nativeInverse,
   "Kang_inverse_density"->sourceInverse,"native_parent"->nativeParent,"Kang_parent"->sourceParent,
   "parent_and_density"->nativeParentDensity,"Kang_parent_and_density"->sourceParentDensity,
   "conjugate_projection"->mirrorAction,"mirror_scope"->"Defining h.c./2 is Re; actual distinct diagram mirrors must be calculated in d17 and counted once. No graph-mirror factor occurs in parent_and_density.",
   "K15_raw_matrix"->raw2015,"K15_coordinate_converted_matrix"->rawColor,
   "HFnative_from_K15"->projection2015,"HFKang_from_K15"->source2015,
   "K15_function_identification"->HoldComplete[HI==Im[H_FU[z,z1]]],
   "basis_transport_general"->transport,"field_link_map"->fieldMap,
   "covariant_link_definition"->HoldComplete[{DNative==partial+I g AN,DReference==partial-I g AR,AR==-AN,
    WNative[b,a]==PathOrderedExp[-I g LineIntegral[AN,{a,b}]],WReference[b,a]==PathOrderedExp[I g LineIntegral[AR,{a,b}]]}],
   "literal_link_qualification"->"Kang prints a minus-sign L and places L before psi. With the printed D=partial-igA this is not the covariant transporter in the endpoint convention displayed here. Reading L as reverse/dagger also requires exchanging the displayed placements; the literal is preserved, not silently repaired.",
   "literal_YZ_qualification"->"The accepted TMD/moment definitions fix this map. The printed YZ/KPSY upper-index twist-three prefactors are not silently identified with these inverse projectors; see d16_projection_notes.md.",
   "state_assumption"->"Identical color-averaged cut-state sums and quark/antiquark assignment; no undocumented state renormalization, extra Nc divisor or hadron-spin average.",
   "color_algebra"->color,"residuals"->residuals,"checks"->passed|>
];
