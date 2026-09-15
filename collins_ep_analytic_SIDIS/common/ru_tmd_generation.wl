(* v0.5.1 measured native route. Source algorithms enumerated and preserved in
 provenance/measured/SOURCE_PREUSE.json BEFORE adaptation. Only open matrix
 generation, exact D-dimensional contraction and operator normalization copied;
 no old radial/Euler/Gamma backend or finite coefficient packet is executed. *)
Clear[RUTMDCurrentVertex,RUTMDProjection,RUTMDCollinsCut,RUTMDBeamProjection,
 RUTMDVirtualOperatorProof,RUTMDGenerate];
RUTMDCurrentVertex[real_Association]:=Module[{current,terms,selected,chain,route,weight,gm},
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
RUTMDProjection[upstreamReal_Association,
 quarkProjectorFactor_:1,gluonProjectorFactor_:1]:=Module[
 {pol,projector,qqTrace,qgTrace,qq,qg,gq,transTrace,transPhysical,trans,
  spinPol,transOpen,raw,p0,p1,ward,split,numerator,transNumerator,residuals,
  tests,distributionMoments,denominatorMoments,epsilonTrace,assumptions,transDimAverage,evanescentDifference,virtualEndpoint},
 FCClearScalarProducts[];
 SPD[n]=0;SPD[h]=0;SPD[v]=0;SPD[h,n]=z;SPD[v,n]=1-z;
 SPD[h,v]=ss/2;SPD[Q]=ss;SPD[Q,n]=1;SPD[Q,h]=ss/2;SPD[Q,v]=ss/2;
 pol=-MTD[al,be]+(FVD[v,al] FVD[n,be]+FVD[n,al] FVD[v,be])/(1-z);
 projector=-MTD[al,be]+FVD[Q,al] FVD[n,be]+FVD[n,al] FVD[Q,be]-ss FVD[n,al] FVD[n,be];
 qqTrace=Contract[DiracSimplify[DiracTrace[(quarkProjectorFactor GSD[n]).GSD[Q].GAD[be].GSD[h].GAD[al].GSD[Q]] pol,DiracTraceEvaluate->True]];
 qgTrace=Contract[DiracSimplify[DiracTrace[GSD[h].GAD[al].GSD[v].GAD[be]],DiracTraceEvaluate->True] (gluonProjectorFactor projector)];
 qq=Factor[CF qqTrace/(8 ss)/.D->4-2 eps];
 qg=Factor[TR qgTrace/(2 ss (D-2))/.D->4-2 eps];
 gq=Factor[qq/.z->1-z];
 (* BMHV: external spin and its epsilon tensor are physical. Internal gluon
    metric/vertices remain D-dimensional until the contracted trace is done. *)
 FCClearScalarProducts[];
 SP[n]=0;SP[h]=0;SP[v]=0;SP[h,n]=z;SP[v,n]=1-z;SP[h,v]=ss/2;
 SP[Q]=ss;SP[Q,n]=1;SP[Q,h]=ss/2;SP[Q,v]=ss/2;
 SP[S]=-1;SP[n,S]=0;SP[Q,S]=0;SP[h,S]=aa;SP[v,S]=-aa;
 spinPol=-MTD[al,be]+(FV[v,al] FV[n,be]+FV[n,al] FV[v,be])/(1-z);
 transOpen=HoldComplete[DiracTrace[GS[n].GA[5].GS[S].GS[Q].GAD[be].GS[h].GA[5].(GS[S]-aa/z GS[n]).GAD[al].GS[Q]]];
 transTrace=Contract[DiracSimplify[ReleaseHold[transOpen] spinPol,DiracTraceEvaluate->True]];
 (* <(h.S)^2> = kperp^2/2 in the declared physical transverse projection.
    The D-dimensional loop/cut radial integration is kept separate. *)
 transPhysical=Factor[Expand[transTrace]/.aa^2->z (1-z) ss/2];
 trans=Factor[CF transPhysical/(8 ss)/.D->4-2 eps];
 transDimAverage=Factor[CF (Expand[transTrace]/.aa^2->z (1-z) ss/(D-2))/(8 ss)];
 evanescentDifference=Factor[transDimAverage-CF transPhysical/(8 ss)];
 raw=<|"qq"->qq,"qg"->qg,"gq"->gq,"transversity"->trans|>;
 p0=Map[Factor[#/.eps->0]&,raw];
 p1=Map[Factor[SeriesCoefficient[#,{eps,0,1}]]&,raw];
 <|"D_dimensional_kernels"->raw,"epsilon0"->p0,"epsilon1"->p1,
 "qq_open"->HoldComplete[DiracTrace[GSD[n].GSD[Q].GAD[be].GSD[h].GAD[al].GSD[Q]] pol],
 "qg_open"->HoldComplete[DiracTrace[GSD[h].GAD[al].GSD[v].GAD[be]]projector],
 "qq_trace"->qqTrace,"qg_trace"->qgTrace,"transversity_open"->transOpen,
 "transversity_D_trace"->transTrace,"transversity_physical_average"->transPhysical,
 "Dminus2_average"->transDimAverage,"Dminus2_minus_physical"->evanescentDifference,
 "angular_difference_eps_series"->Normal[Series[evanescentDifference/.D->4-2eps,{eps,0,2}]],
 "angular_difference_local_finite"->Coefficient[Normal[Series[-(evanescentDifference/.D->4-2eps)/eps,{eps,0,0}]],eps,0],
 "physical_azimuth_rule"->HoldComplete[aa^2->z(1-z)ss/2],
 "source_qq_residual"->Factor[qqTrace-upstreamReal["qq_trace"]],
 "source_qg_residual"->Factor[qgTrace-upstreamReal["qg_trace"]],
 "scope"->"Fresh D-dimensional fixed-fraction projections; physical BMHV external spin. No integrated coefficient or endpoint imported."|>
];
RUTMDCollinsCut[real_Association,
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
 vertex=RUTMDCurrentVertex[real];If[FailureQ[vertex],Return[vertex]];
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
 <|"D_dimensional_kernel"->epsKernel,"epsilon0"->Factor[epsKernel/.eps->0],
 "epsilon1"->Factor[SeriesCoefficient[epsKernel,{eps,0,1}]],
 "generated_vertex"->vertex,"fresh_graph_presence"->graphPresence,
 "future_ray_integral"->rayIntegral,"covariant_vertex"->covariantVertex,
 "field_strength_vertex"->fieldVertex,"completed_vertex"->completedVertex,
 "gauge_contact_Ward_residual"->contactWard,
 "gauge_contact_lightcone"->FullSimplify[completedVertex/.Aplus->0],
 "position_contact"->positionContact,
 "retarded_boundary_contact"->FullSimplify[positionContact/.aTransverse[infinityEndpoint]->0],
 "kinematics"-><|"r"->rvec,"k"->kvec,"cut_gluon"->lvec,"cut_jacobian"->phase|>,
 "derivative_open_tensors"->{tx,ty},"derivative_cut"->derivative,
 "intrinsic_EOM_density"->intrinsicDensity,"intrinsic_cut"->intrinsic,
 "combined_cut"->combined,"UU_same_graph_cut"->uu,
 "EOM_constraints"->eomEquations,"EOM_solution"->eomSolution,
 "left_EOM_residual"->eomLeft,"right_EOM_residual"->eomRight,
 "density_normalizations"-><|"UU"->densityU,"derivative"->densityDerivative,
 "measure"->measureRatio,"UU_parent"->parentU,"Collins_parent"->parentVector|>,
 "common_phase_coupling"->commonFactor,"UU_normalization_residual"->normalizationResidual,
 "cut_to_M"->HoldComplete[{Rplus==u Kplus,kt^2==tau}],
 "operator_basis"->HoldComplete[HD[z1,z2]==PV[1/(1/z1-1/z2)]HF[z1,z2]+DiracDelta[1/z1-1/z2]Hhat[z1]],
 "scope"->"Homogeneous derivative plus intrinsic EOM cut only. Independent HF cuts are supplied separately; no transversity replacement and no old Fourier/backend evaluation."|>
];

(* Independent spacelike beam routing. Incoming p is on shell, emitted l is
   the sole cut particle, and active q=p-l is spacelike. This is not an
   identification of the timelike parent propagator with a beam propagator. *)
RUTMDBeamProjection[real_Association]:=Module[{pol,gpol,qq,qg,spinpol,trans,
 qqOpen,qgOpen,transOpen,physical,raw,colorQ,colorG,kinematics},
 FCClearScalarProducts[];
 SPD[p]=0;SPD[n]=0;SPD[p,n]=1;SPD[l]=0;SPD[l,n]=1-z;
 SPD[p,l]=tau/(2(1-z));SPD[q]=-tau/(1-z);SPD[q,n]=z;
 SPD[q,p]=-tau/(2(1-z));SPD[q,l]=tau/(2(1-z));
 pol=-MTD[al,be]+(FVD[l,al]FVD[n,be]+FVD[n,al]FVD[l,be])/(1-z);
 gpol=-MTD[al,be]+FVD[p,al]FVD[n,be]+FVD[n,al]FVD[p,be];
 qqOpen=DiracTrace[GSD[n].GSD[q].GAD[be].GSD[p].GAD[al].GSD[q]]pol;
 qgOpen=DiracTrace[GSD[n].GSD[q].GAD[be].GSD[l].GAD[al].GSD[q]]gpol;
 qq=Factor[Contract[DiracSimplify[qqOpen,DiracTraceEvaluate->True]]];
 qg=Factor[Contract[DiracSimplify[qgOpen,DiracTraceEvaluate->True]]];
 colorQ=4real["averages"]["eq"];colorG=4real["averages"]["eg"];
 FCClearScalarProducts[];
 SP[p]=0;SP[n]=0;SP[p,n]=1;SP[l]=0;SP[l,n]=1-z;
 SP[p,l]=tau/(2(1-z));SP[q]=-tau/(1-z);SP[q,n]=z;
 SP[q,p]=-tau/(2(1-z));SP[q,l]=tau/(2(1-z));
 SP[S]=-1;SP[S,p]=0;SP[S,n]=0;SP[S,l]=aa;SP[S,q]=-aa;
 spinpol=-MTD[al,be]+(FV[l,al]FV[n,be]+FV[n,al]FV[l,be])/(1-z);
 transOpen=DiracTrace[GS[n].GA[5].GS[S].GS[q].GAD[be].GS[p].GA[5].GS[S].GAD[al].GS[q]]spinpol;
 trans=Factor[Contract[DiracSimplify[transOpen,DiracTraceEvaluate->True]]];
 physical=Factor[Expand[trans]/.aa^2->tau/2];
 raw=<|"qq"->Factor[colorQ qq(1-z)/(8tau)/.D->4-2eps],
 "qg"->Factor[colorG qg(1-z)/(4tau(D-2))/.D->4-2eps],
 "transversity"->Factor[colorQ physical(1-z)/(8tau)/.D->4-2eps]|>;
 <|"D_dimensional_kernels"->raw,"open_qq"->qqOpen,"open_qg"->qgOpen,
 "open_transversity"->transOpen,"D_traces"->{qq,qg,trans},
 "physical_transverse_average"->physical,"emitted_gluon_polarization"->pol,
 "Dminus2_minus_physical"->Factor[colorQ(Expand[trans]/.aa^2->tau/(D-2))(1-z)/(8tau)-colorQ physical(1-z)/(8tau)],
 "incoming_gluon_average_projector"->gpol/(D-2),
 "crossing_source"->KeyTake[real,{"open_current","routes","crossing","averages"}],
 "cut_geometry"->HoldComplete[{l==k-z p,q==p-l,q==(1+z)p-k,l^2==0,
   l.n==1-z,l.p==tau/(2(1-z)),q.n==z,q^2==-tau/(1-z)}],
 "physical_Jacobian"->1/(2(1-z)),"active_propagators"->(1-z)^2/tau^2,
 "normalization"-><|"radial_log_weight"->tau,"quark_spin_and_operator"->1/4,
 "gluon_spin_and_operator"->1/(2(D-2)),"generated_color"->{colorQ,colorG}|>,
 "sign_prescription"->"The active beam propagator is spacelike. Its two cut-side propagators multiply to +(1-z)^2/tau^2; the physical emitted delta and Jacobian stay positive. No timelike propagator sign is silently crossed.",
 "BMHV"->"Physical external S, physical two-plane aa^2=tau/2; emitted/internal gamma and gluon metric remain D-dimensional until contraction."|>
];

(* Open virtual operator proof. The same full regulated integrand appears in
   the TMD and collinear matrix elements, so its matching cancellation is
   performed BEFORE integration. The following longitudinal projections
   also verify the separate local vector endpoint; they do not replace the
   actual r04-r06 native virtual integration route. *)
RUTMDVirtualOperatorProof[real_Association]:=Module[{gm,sl,np,nm,sx,g5,rho,
 projectors,norms,rvec,left,right,lp,rp,source,selfPhysical,selfMatrix,selfMap,
 selfProjected,weight,sails,wave,total,finiteEndpoint,qq,res,ward,gd,qd,ed,
 pole,residue,longitudinal,vertex,commonVirtual,selfOdd},
 gm=PhysicalGammas[];sl[vec_]:=PhysicalSlash[vec,gm];
 np={1,0,0,1};nm={1,0,0,-1};sx={0,1,0,0};g5=I(Dot@@gm);
 rho={sl[np],sl[np].g5.sl[sx]};
 projectors={sl[nm]/2,(I/4)(gm[[2]].sl[nm]-sl[nm].gm[[2]]).g5};
 norms=FullSimplify[Table[Tr[rho[[j]].projectors[[j]]],{j,2}]];
 vertex=RUTMDCurrentVertex[real];weight=vertex["amputation_weight"]^2;
 rvec=(1-v)np-kx sx-ky{0,0,1,0}-kminus nm;
 left=Table[weight sl[rvec].sl[nm].rho[[j]]/4,{j,2}];
 right=Table[weight rho[[j]].sl[nm].sl[rvec]/4,{j,2}];
 lp=FullSimplify[Table[Tr[left[[j]].projectors[[j]]]/norms[[j]],{j,2}]];
 rp=FullSimplify[Table[Tr[right[[j]].projectors[[j]]]/norms[[j]],{j,2}]];
 (* Native D-dimensional gamma contraction, independently checked using
    the physical Clifford matrices plus their exact hat-space term. *)
 source=DiracSimplify[weight(1-v)GAD[mu].GSD[p].GAD[mu]];
 selfMatrix=source/.DiracGamma[Momentum[p,D],D]->sl[np];
 selfMatrix=FullSimplify[selfMatrix/.D->4-2eps];
 selfPhysical=FullSimplify[weight(Sum[{1,-1,-1,-1}[[a]]gm[[a]].sl[(1-v)np].gm[[a]],{a,4}]+2eps sl[(1-v)np])];
 RUGate["fresh virtual self contraction equals independent Clifford hats",And@@(RUZero/@Flatten[selfMatrix-selfPhysical])];
 selfMap=Table[(selfMatrix.sl[nm].rho[[j]]+rho[[j]].sl[nm].selfMatrix)/8,{j,2}];
 selfProjected=FullSimplify[Table[Tr[selfMap[[j]].projectors[[j]]]/norms[[j]],{j,2}]];
 gd=4v Pplus kminus-kT2;qd=-4(1-v)Pplus kminus-kT2;ed=2v Pplus;
 pole=kT2/(4v Pplus);residue=FullSimplify[Residue[1/(gd qd ed),{kminus,pole}]];
 longitudinal=FullSimplify[(lp+rp)residue(-8Pplus^2 kT2)/2];
 sails=-2CF Integrate[Exp[eta Lnu]v^(-eta)longitudinal,{v,0,1},Assumptions->eta<0];
 wave=CF/2 Integrate[selfProjected,{v,0,1}];
 total=FullSimplify[Normal[Series[sails,{eta,0,0}]]+wave];
 finiteEndpoint=FullSimplify[total-2CF(1/eta+Lnu)];
 qq=Factor[CF real["qq_trace"]/(8ss)/.D->4-2eps];
 res=FullSimplify[Limit[(1-z)qq,z->1]];
 ward=FullSimplify[-res(1/eta+Lnu)+Integrate[qq-res/(1-z),{z,0,1}]+total[[1]]];
 RUGate["independently projected virtual scalar endpoint obeys vector Ward",ward===0];
 selfOdd=DiracSimplify[-weight GAD[mu].GSD[loopMomentum].GAD[mu]];
 commonVirtual=<|
  "left_sail"-><|"open_projected_matrix"->left,
   "denominators"->({gd,qd,ed}/.Pplus->1),
   "rational_integrand"->left/(gd qd ed/.Pplus->1),
   "rapidity_weight"->Exp[eta Lnu]v^(-eta)|>,
  "right_sail"-><|"open_projected_matrix"->right,
   "denominators"->({gd,qd,ed}/.Pplus->1),
   "rational_integrand"->right/(gd qd ed/.Pplus->1),
   "rapidity_weight"->Exp[eta Lnu]v^(-eta)|>,
  "self_energy"-><|"shifted_D_even_numerator"->source,"shifted_D_odd_numerator"->selfOdd,
   "both_leg_open_matrix"->selfMap,
   "combined_denominator"->(ellSquared+v(1-v)externalVirtuality+I i0)^2,
   "on_shell_even_integrand"->selfMap/(ellSquared+I i0)^2,
   "parameter_interval"->{0,1},"external_virtuality"->0,
   "odd_term_prescription"->"The displayed shifted odd loop numerator integrates to zero only on the complete translation-invariant dimensional domain; retain the UV/IR distinction in the even scaleless integral."|>,
  "normalized_sail_routing"-><|"incoming"->np,"virtual_quark"->rvec,
   "gluon"->np-rvec,"external_lightcone_scale"->1|>,
  "scale_scope"->"Open matrix blocks use Pplus=1 by positive longitudinal rescaling; the general positive Pplus denominators and contour Jacobian are exported separately."|>;
 <|"generated_quark_gluon_vertex"->vertex,"projectors"->projectors,"norms"->norms,
 "left_sail_open"->left,"right_sail_open"->right,"left_projected"->lp,"right_projected"->rp,
 "self_D_open_contraction"->source,"self_Clifford_check"->selfPhysical,
 "self_projected"->selfProjected,"virtual_denominators"->{gd,qd,ed},
 "gluon_lower_pole"->pole,"virtual_contour_residue"->residue,
 "sail_longitudinal_integrand"->longitudinal,"sail_evaluated"->sails,
 "wave_longitudinal_evaluated"->wave,"virtual_UV_minus_IR_coefficients"->total,
 "native_virtual_endpoint"->finiteEndpoint,"vector_Ward_residual"->ward,
 "common_virtual_integrand"->commonVirtual,
 "matching_cancellation_before_integration"->HoldComplete[TMDTree CommonVirtualBare-CollinearTree CommonVirtualBare==0],
 "IR_UV_scope"->"The equality uses identical tree tensors, regulator and on-shell routing before integration; UV and IR of the scaleless common integral are kept distinct. The displayed finite local endpoint is a longitudinal numerator result, not an imported final matching coefficient."|>
];

RUTMDGenerate[real_Association]:=Module[{projection,beam,collins,operatorVirtual,kernels},
 projection=RUTMDProjection[real];beam=RUTMDBeamProjection[real];collins=RUTMDCollinsCut[real];
 operatorVirtual=RUTMDVirtualOperatorProof[real];
 RUGate["fresh fixed-fraction projection agrees with generated unpolarized traces",
  RUZero[projection["source_qq_residual"]]&&RUZero[projection["source_qg_residual"]]];
 RUGate["derivative Collins cut has actual generated vertex and EOM normalization",
  TrueQ[collins["fresh_graph_presence"]]&&RUZero[collins["UU_normalization_residual"]]&&
  And@@(RUZero/@Flatten[{collins["left_EOM_residual"],collins["right_EOM_residual"]}])];
 RUGate["independent spacelike beam and timelike fragment projections agree",
  And@@(RUZero[beam["D_dimensional_kernels"][#]-projection["D_dimensional_kernels"][#]]&/@{"qq","qg","transversity"})];
 kernels=<|"beam_fqq"->beam["D_dimensional_kernels"]["qq"],
 "beam_fqg"->beam["D_dimensional_kernels"]["qg"],
 "beam_hqq"->beam["D_dimensional_kernels"]["transversity"],
 "fragment_dqq"->projection["D_dimensional_kernels"]["qq"],
 "fragment_dgq"->projection["D_dimensional_kernels"]["gq"],
 "fragment_collins"->collins["D_dimensional_kernel"]|>;
 <|"projection"->projection,"beam"->beam,"collins"->collins,
 "operator_virtual"->operatorVirtual,"kernels"->kernels,
 "no_cut_or_loop_master_evaluated"->True,
 "crossing"->HoldComplete[P_gq[z]==P_qq[1-z]],
 "fixed_fraction_scope"->"Kernel variable z remains symbolic before measurement, reduction and Fourier transform."|>
];
