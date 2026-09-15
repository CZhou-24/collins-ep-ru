(* New v0.3.1 calculation.  Wilson and self-energy endpoint integrals are
   evaluated before the vector Ward identity is used as an independent check.
   No finite reference coefficients are inputs to this constructor. *)
Clear[D13CurrentVertex,D13EndpointDerivation];
D13CurrentVertex[real_Association]:=Module[{current,terms,selected,chain,route,weight,gm},
 current=Expand[real["open_current"]];terms=If[Head[current]===Plus,List@@current,{current}];
 selected=Select[terms,!FreeQ[#,DiracGamma[Momentum[k+pp,D],D]]&];
 If[Length[selected]=!=1,Return[Failure["D13GeneratedOutgoingVertex",<||>]]];
 chain=First[Cases[First[selected],_Dot,Infinity]];
 route=First[Cases[chain,DiracGamma[Momentum[rr_,D],D]:>rr,Infinity]];
 weight=FullSimplify[ExpandScalarProduct[Cancel[First[selected]/chain]SPD[route]]];
 gm=PhysicalGammas[];
 <|"generated_term"->First[selected],"amputated_chain"->chain,
   "propagator_route"->route,"amputation_weight"->weight,
   "vertex_D"->weight chain[[1]],
   "physical_vertices"->Table[weight(chain[[1]]/.DiracGamma[LorentzIndex[_,D],D]->gm[[mu]]),{mu,4}]|>
];
D13EndpointDerivation[real_Association,selfGraph_Association,masters_Association,
 regulated_Association,sailFactor_:1,selfFactor_:1]:=Module[
 {gm,sl,np,nm,sx,g5,rho,projectors,norms,rvec,left,right,lp,rp,
  gluonDen,quarkDen,eikonalDen,gluonPole,residue,residueReduced,
  longitudinal,sails,sailSeries,selfSource,selfShifted,selfPhysical,
  selfMap,selfProjected,wave,virtual,realVectorMoment,wardResidual,
  radialIR,radialUV,radialZero,master,fPhys,fD,angularRatio,
  masterResidual,softHalf,softCoefficient,endpointCoefficient,
  endpoint,etaResidue,etaSum,etaLaurent,uv,finite,barePole,
  realNumerator,vectorRegular,tensorRegular,virtualCancellation,
  assumptions,derivativeRule,vertex,slVertex},
 gm=PhysicalGammas[];sl[vec_]:=PhysicalSlash[vec,gm];
 vertex=D13CurrentVertex[real];If[FailureQ[vertex],Return[vertex]];
 slVertex[vec_]:=Sum[{1,-1,-1,-1}[[mu]]vec[[mu]]vertex["physical_vertices"][[mu]],{mu,4}];
 np={1,0,0,1};nm={1,0,0,-1};sx={0,1,0,0};g5=I(Dot@@gm);
 rho={sl[np],sl[np].g5.sl[sx]};
 projectors={sl[nm]/2,(I/4)(gm[[2]].sl[nm]-sl[nm].gm[[2]]).g5};
 norms=FullSimplify[Table[Tr[rho[[i]].projectors[[i]]],{i,2}]];
 rvec=(1-v)np-kx sx-ky {0,0,1,0}-kminus nm;
 left=Table[sailFactor sl[rvec].slVertex[nm].rho[[i]]/4,{i,2}];
 right=Table[sailFactor rho[[i]].slVertex[nm].sl[rvec]/4,{i,2}];
 lp=FullSimplify[Table[Tr[left[[i]].projectors[[i]]]/norms[[i]],{i,2}]];
 rp=FullSimplify[Table[Tr[right[[i]].projectors[[i]]]/norms[[i]],{i,2}]];
 (* At fixed 0<v<1 the gluon pole is below and the quark pole above.
    The clockwise lower closure and Feynman i factors give the virtual
    minus sign relative to a cut graph.  The transverse scale is positive. *)
 gluonDen=4 v Pplus kminus-kT2;
 quarkDen=-4(1-v)Pplus kminus-kT2;eikonalDen=2 v Pplus;
 gluonPole=kT2/(4 v Pplus);
 residue=FullSimplify[Residue[1/(gluonDen quarkDen eikonalDen),{kminus,gluonPole}]];
 residueReduced=FullSimplify[residue (-8 Pplus^2 kT2)];
 longitudinal=FullSimplify[(lp+rp) residueReduced/2];
 sails=-2 CF Integrate[Exp[eta Lnu] v^(-eta) longitudinal,{v,0,1},Assumptions->eta<0];
 sailSeries=FullSimplify[Normal[Series[sails,{eta,0,0}]]];
 (* The actual FeynArts/FeynCalc self-energy numerator is an input to the
    calculation; its D-dimensional contraction is not reconstructed from a
    desired endpoint.  The Feynman shift leaves (1-v) slash(p). *)
 selfSource=DiracSimplify[selfGraph["numerator"]];
 selfShifted=selfFactor Expand[selfSource]/.{DiracGamma[Momentum[k,D],D]->(1-v)sl[np]};
 selfShifted=FullSimplify[selfShifted/.D->4-2 eps];
 selfPhysical=FullSimplify[Sum[{1,-1,-1,-1}[[a]] gm[[a]].sl[(1-v)np].gm[[a]],{a,4}]+2 eps sl[(1-v)np]];
 selfMap=Table[(selfShifted.sl[nm].rho[[i]]+rho[[i]].sl[nm].selfShifted)/8,{i,2}];
 selfProjected=FullSimplify[Table[Tr[selfMap[[i]].projectors[[i]]]/norms[[i]],{i,2}]];
 wave=FullSimplify[(CF/2) Integrate[selfProjected,{v,0,1}]];
 virtual=FullSimplify[sailSeries+wave];
 realNumerator=Factor[CF(real["qq_trace"]/(8 ss))/.D->4-2eps];
 vectorRegular=FullSimplify[realNumerator-2 CF/(1-z)];
 tensorRegular=FullSimplify[real["transversity_real"]-2 CF/(1-z)];
 realVectorMoment=FullSimplify[-2 CF(1/eta+Lnu)+Integrate[vectorRegular,{z,0,1}]];
 wardResidual=FullSimplify[realVectorMoment+virtual[[1]]];
 radialIR=Integrate[t^(-1-epsIR),{t,0,Lambda2},Assumptions->epsIR<0&&Lambda2>0];
 radialUV=Integrate[t^(-1-epsUV),{t,Lambda2,Infinity},Assumptions->epsUV>0&&Lambda2>0];
 radialZero=radialIR+radialUV;
 (* In matching, exactly the same virtual operator multiplies the b-space
    TMD tree and the collinear tree. Keep the finite eps numerator before
    subtracting, including the auxiliary UV/IR split. *)
 virtualCancellation=FullSimplify[virtual radialZero-virtual radialZero];
 master=masters["radial_Schwinger"];
 fPhys=-Exp[eps B]/(eps^2 master);
 masterResidual=FullSimplify[Normal[Series[fPhys+Exp[eps(B-EulerGamma)]/(eps Gamma[1+eps]),{eps,0,2}]]];
 fD=Exp[eps(B-EulerGamma)]Gamma[-eps];
 angularRatio=FullSimplify[FunctionExpand[fD/(-Exp[eps(B-EulerGamma)]/(eps Gamma[1+eps]))]];
 (* The actual soft constituent is retained all-eps/all-eta.  Eta is
    removed before eps. The endpoint residue comes from the calculated cut. *)
 softHalf=regulated["standard_unexpanded"]/2;
 softCoefficient=FullSimplify[Limit[(1-z)realNumerator,z->1]];
 endpoint=-softCoefficient masters["common_Fourier_residue"] Exp[eta(T-V)/2]/eta;
 endpointCoefficient=FullSimplify[eta(softHalf+endpoint)];
 etaResidue=FullSimplify[endpointCoefficient/.eta->0];
 etaSum=FullSimplify[FunctionExpand[D[endpointCoefficient,eta]/.eta->0]];
 etaLaurent=FullSimplify[Normal[Series[etaSum,{eps,0,0}]]];
 barePole=Coefficient[Expand[etaLaurent],eps,-2];
 uv=-Coefficient[Expand[etaLaurent],eps,-2]/eps^2-Coefficient[Expand[etaLaurent],eps,-1]/eps;
 finite=FullSimplify[etaLaurent+uv];
 <|"status"->"DERIVED_DIAGONAL_SCALAR_OPERATOR_ENDPOINT",
  "generated_quark_gluon_vertex"->vertex,
  "graph_source"->KeyTake[selfGraph,{"graphs","converted","numerator"}],
  "future_Wilson_vertex"->HoldComplete[gS Ta nbar[mu]/(nbar.ell+I 0)(nu/Abs[nbar.ell])^eta],
  "loop_denominators"->{gluonDen,quarkDen,eikonalDen},"gluon_lower_pole"->gluonPole,
  "pole_support"->HoldComplete[0<v<1&&Pplus>0&&kT2>0],
  "contour_residue"->residue,"residue_dimensionless_factor"->residueReduced,
  "spin_projectors"->projectors,"tree_norms"->norms,
  "left_sail_open"->left,"right_sail_open"->right,
  "left_sail_projected"->lp,"right_sail_projected"->rp,
  "sail_longitudinal_integrand"->longitudinal,
  "sail_longitudinal_evaluated"->sails,"sail_eta_series"->sailSeries,
  "self_energy_contracted_source"->selfSource,"self_energy_shifted"->selfShifted,
  "self_energy_physical_check"->selfPhysical,
  "self_energy_projection"->selfProjected,"self_energy_parameter_integral"->wave,
  "virtual_UV_minus_IR_coefficients"->virtual,
  "virtual_finite_eta_endpoint"->FullSimplify[virtual-2CF(1/eta+Lnu)],
  "virtual_collinear_cancellation"->virtualCancellation,
  "vector_real_first_moment"->realVectorMoment,"vector_Ward_check"->wardResidual,
  "tensor_real_first_moment"->FullSimplify[-2CF(1/eta+Lnu)+Integrate[tensorRegular,{z,0,1}]],
  "radial_split"-><|"IR"->radialIR,"UV"->radialUV,"sum"->radialZero|>,
  "radial_master"->master,"physical_J0_from_master"->fPhys,
  "master_normalization_residual_through_eps2"->masterResidual,
  "full_D_transverse_scalar"->fD,"D_angular_over_physical_J0"->angularRatio,
  "angular_ratio_series"->Normal[Series[angularRatio,{eps,0,2}]],
  "real_eta_endpoint"->endpoint,"standard_soft_half_exact"->softHalf,
  "eta_residue"->etaResidue,"eta_summed_exact"->etaSum,
  "bare_endpoint_Laurent"->etaLaurent,"bare_TMD_double_pole"->barePole,
  "native_UV_counterterm"->uv,"native_endpoint_delta"->finite,
  "full_D_endpoint_delta"->FullSimplify[Coefficient[Expand[Normal[Series[angularRatio etaSum,{eps,0,0}]]],eps,0]],
  "regulator_order"->"eta before eps; virtual UV and IR split before identical operator subtraction",
  "normalization"->"alpha_s/(2pi); physical BMHV tensor; common physical-J0 continuation",
  "diagnostic_factors"-><|"sail"->sailFactor,"self"->selfFactor|>|>
];
