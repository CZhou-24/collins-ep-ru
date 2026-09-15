(* Native D-dimensional cut operator projections. Read no reference packet.
   Color and propagator normalization match s10's actual generated cut graphs.
   The Born collinear trace is an operator projection, not a finite endpoint. *)
Clear[D13ProjectionDerivation];
D13ProjectionDerivation[upstreamReal_Association,upstreamProjection_Association,
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
 numerator=Cancel[(1-z) p0["qq"]];
 transNumerator=Cancel[(1-z) p0["transversity"]];
 (* Conserved vector-current first moment determines the virtual collinear
    pole. It does not determine a finite virtual matching constant. *)
 ward=-Integrate[(numerator-(numerator/.z->1))/(1-z),{z,0,1}];
 virtualEndpoint=Lookup[upstreamProjection,"native_virtual_endpoint",{ward,upstreamProjection["UV_endpoint_weights"][[2]]}];
 split=<|"qq"->D13Canonical[numerator,0,virtualEndpoint[[1]]],
   "qg"->D13Canonical[0,p0["qg"],0],"gq"->D13Canonical[0,p0["gq"],0],
   "transversity"->D13Canonical[transNumerator,0,virtualEndpoint[[2]]]|>;
 residuals=<|"qq_trace_vs_s10"->Factor[qqTrace-upstreamReal["qq_trace"]],
   "qg_trace_vs_s10"->Factor[qgTrace-upstreamReal["qg_trace"]],
   "transversity_physical_vs_s10"->Factor[transPhysical-(Expand[upstreamReal["transversity_trace"]]/.aa^2->z (1-z) ss/2)],
   "vector_Ward_endpoint_vs_s11"->Factor[ward-upstreamProjection["UV_endpoint_weights"][[1]]],
   "spin_scalar_endpoint_vs_s11"->Factor[upstreamProjection["UV_endpoint_weights"][[1]]-upstreamProjection["UV_endpoint_weights"][[2]]],
   "Ddimensional_spin_evanescent_average"->Factor[transPhysical-(transPhysical/.D->4)]|>;
 tests={1,z,z^2};
 distributionMoments=Table[split[key]["delta"] (test/.z->1)+Integrate[
   split[key]["D0"] (test-(test/.z->1))/(1-z)+split[key]["regular"] test,{z,0,1}],
   {key,{"qq","transversity"}},{test,tests}];
 denominatorMoments=Table[If[key=="qq",virtualEndpoint[[1]],virtualEndpoint[[2]]] (test/.z->1)+Integrate[
   ((If[key=="qq",numerator,transNumerator] test)-((If[key=="qq",numerator,transNumerator] test)/.z->1))/(1-z),{z,0,1}],
   {key,{"qq","transversity"}},{test,tests}];
 <|"status"->"DERIVED_PROJECTIONS_AND_LO_SPLITTING_ONLY",
   "diagnostic_projector_factors"-><|"qq"->quarkProjectorFactor,"qg"->gluonProjectorFactor|>,
   "dimension"->HoldComplete[D==4-2 eps],
   "qq_open"->HoldComplete[DiracTrace[GSD[n].GSD[Q].GAD[be].GSD[h].GAD[al].GSD[Q]]],
   "qg_open"->HoldComplete[DiracTrace[GSD[h].GAD[al].GSD[v].GAD[be]]],
   "qq_gluon_polarization"->pol,"qg_gluon_projector"->projector,
   "qq_trace"->qqTrace,"qg_trace"->qgTrace,
   "transversity_open"->transOpen,"transversity_gluon_polarization"->spinPol,
   "transversity_D_trace"->transTrace,"transversity_physical_average"->transPhysical,
   "transversity_Dminus2_average_kernel"->transDimAverage,
   "Dminus2_minus_physical_average"->evanescentDifference,
   "Dminus2_minus_physical_average_series"->Normal[Series[evanescentDifference/.D->4-2 eps,{eps,0,2}]],
   "physical_azimuth_rule"->HoldComplete[aa^2->z (1-z) ss/2],
   "projection_normalizations"-><|"qq"->8 ss,"qg"->2 ss (D-2),"transversity"->8 ss|>,
   "color_factors"-><|"quark"->CF,"gluon"->TR|>,
   "D_dimensional_kernels"->raw,"epsilon0"->p0,"epsilon1"->p1,
   "vector_Ward_endpoint"->ward,"splitting_canonical"->split,
   "native_virtual_endpoint"->virtualEndpoint,
   "upstream_residuals"->residuals,
   "test_functions"->tests,"canonical_distribution_moments"->distributionMoments,
   "denominator_plus_moments"->denominatorMoments,
   "distribution_identity_residual"->FullSimplify[distributionMoments-denominatorMoments],
   "limitations"->{"Finite virtual endpoints are not fixed by vector Ward normalization.",
     "The transversity trace does not define the T-odd twist-three Collins operator.",
     "Physical BMHV transverse projection still requires a complete finite operator scheme map."}|>
];
