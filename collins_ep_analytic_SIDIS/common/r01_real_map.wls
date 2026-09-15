Get[FileNameJoin[{DirectoryName[$InputFileName],"ru_stage.wl"}]];
Get[FileNameJoin[{$RUProduction,"common","ru_cut_helpers.wl"}]];
Get[FileNameJoin[{$RUProduction,"common","ru_measured_helpers.wl"}]];
fresh=Get[FileNameJoin[{$RUContext["inputs"]["r00"],"real_real_amplitudes.wl"}]];
(* emitted r is the gluon, so z_quark=1+c3/w on the two physical cuts. *)
input=Factor[fresh["raw_splitting"]["qq"]/.z->1+c3/w];
rows=RUCutRows[input,c3,R1];
geom=RUCutGeometry[];
RUPut[<|"fresh_trace"->fresh["qq_trace"],"projected_numerator"->input,"rows"->rows,
 "reconstructed"->Total[(#[[2]] c3^(-#[[1,3]]))& /@ rows],
 "mapping"->HoldComplete[c3==(r-n)^2,z==1+c3/w],"no_integral_evaluated"->True|>,"integrands.wl"];
RUPut[<|"positive_cut_geometry"->geom,"support"->HoldComplete[w>0&&0<z<1],
 "cut_identity"->HoldComplete[deltaPositive[x,e]==Theta[e] ((x-I i0)^(-1)-(x+I i0)^(-1))/(2 Pi I)],
 "theta_not_a_cut"->HoldComplete[Theta[r0] Theta[Sqrt[w]-r0]],
 "measurement_delta"->HoldComplete[DiracDelta[z-1+2 n.r/w]],
 "pilot_measurement"->"The tested pilot is the full energy-fraction moment of the generated collinear quark numerator. The fixed-z delta is explicitly integrated over its physical 0<z<1 interval for this moment only.",
 "IBP_boundary_domain"->"Timelike parent w>0 and two positive-energy cuts. Angular endpoint and eikonal boundary vanish in a convergent Re(eps)<0 strip for unit uncut powers and continue meromorphically. Physical theta support is kept; no finite-cone or eta boundary is differentiated.",
 "not_a_complete_TMD_sector"->True,"jet_boundary_retained_for_future_map"->HoldComplete[w<z (1-z) pT^2 R^2]|>,"support.wl"];
RUPut[<|"on_shell_polynomials"->{c1,c2},"uncut"->c3,"phase_space"->HoldComplete[Integrate[DiracDelta[r^2] DiracDelta[(p-r)^2] Theta[r0] Theta[p0-r0] integrand,{r,RealSpace[4-2 eps]}]],"source"->"Fresh r00 spin projection plus SIDIS coordinate Laurent reconstruction"|>,"cut_mapping.wl"];
job=RUWriteCutJob[rows];
targets=(<|"powers"->#[[1]],"numerator"->RUExact[#[[2]]],"integrand"->RUExact[#[[2]]/(c1^#[[1,1]] c2^#[[1,2]] c3^#[[1,3]])]|>& /@ rows);
family=<|"id"->"R1","denominators"->(RUExact /@ {c1,c2,c3}),"cuts"->{0,1},"positive_energy"->True,"support_artifact"->"support.wl","targets"->targets|>;
evidence=<|"r01/map"->RUEvidence["cut_mapping.wl","cut_mapping",{"source/r01","r00/measurement"}],"r01/support"->RUEvidence["support.wl","support",{"r01/map"}],"r01/integrands"->RUEvidence["integrands.wl","integrands",{"r01/support","r00/real"}]|>;
tmd=Get[FileNameJoin[{$RUContext["inputs"]["r00"],"measured_tmd_operators.wl"}]];
hf=Get[FileNameJoin[{$RUContext["inputs"]["r00"],"measured_hf_operators.wl"}]];
soft=Get[FileNameJoin[{$RUContext["inputs"]["r00"],"measured_soft_operators.wl"}]];
measuredGeometry=RUMeasuredGeometry[];
softColor=tmd["collins"]["common_phase_coupling"]/2;
softWeights=soft["projectors"]["normalized_cut_weights"];
sectorNumerators=Join[tmd["kernels"],<|"fragment_HF"->hf["log_density_with_probe"],
 "recoil_soft"->2softColor softWeights[[1]],"jet_UU"->2softColor softWeights[[1]],
 "jet_UT"->2softColor softWeights[[2]]|>];
measuredRows=Join[RUMeasuredRows[1],Flatten[RUMeasuredRows/@Values[sectorNumerators],1],
 {{{1,1,2},1},{{1,2,1},1},{{2,1,1},1}}];
measuredJob=RUWriteMeasuredJob[measuredRows];
den=measuredGeometry["denominators"];
measuredTargets=(<|"powers"->#[[1]],"numerator"->RUExact[#[[2]]],
 "integrand"->RUExact[#[[2]]/Times@@(den^#[[1]])]|>&/@measuredRows);
measuredFamily=<|"id"->"M","denominators"->(RUExact/@den),"cuts"->{0,1,2},
 "positive_energy"->True,"support_artifact"->"measured_support.wl","targets"->measuredTargets|>;
RUPut[<|"geometry"->measuredGeometry,"HF_measurement_transport"->Get[FileNameJoin[{$RUContext["inputs"]["r00"],"hf","measurement_derivative_map.wl"}]],
 "physical_cut"->0,"measurement_cuts"->{1,2},"theta_not_cut"->HoldComplete[Theta[(k-u p)0]],
 "fractions_retained"->{u,v,z},"soft_specialization"->HoldComplete[u->0],
 "soft_positive_support"->HoldComplete[tau>0&&kPlus>0&&kMinus>0],
 "boundary_scope"->"Interior fixed fractions and tau only. No eta weight or cone theta is reduced. Endpoint, Fourier and rapidity operations follow the native scalar cut. Raised measurement cuts retain the separately verified derivative action."|>,"measured_support.wl"];
RUPut[<|"geometry"->measuredGeometry,"sector_numerators"->sectorNumerators,"rows"->measuredRows,
 "scalar_integrand_reconstruction"->Map[Function[num,num/Times@@den],sectorNumerators],
 "reconstruction_check"->"The protected exporter reconstructs each scalar target from the independently declared denominator list, integer powers and raw numerator. The operator-to-surface map is separately derived before this scalar representation.",
 "operator_phase_space"->HoldComplete[2(1-u)P[z,eps]deltaPositive[(k-u p)^2]
   DiracDelta[k.n-1]DiracDelta[-kT^2-tau]/tau],
 "dimensionful_factors"->"The normalized sphere removes 2(1-u), pi and MSbar factors as derived in r02. Restoring its tau^(-eps) density with 1/tau and the projected numerator yields the measured spectral function; tau is not integrated out in Kira.",
 "soft_projected_current"->soft,"HF_current"->hf|>,"measured_integrands.wl"];
AssociateTo[evidence,{"r01/measured_support"->RUEvidence["measured_support.wl","support",{"source/r01","r00/measured_hf","r00/measured_soft"}],
 "r01/measured_integrands"->RUEvidence["measured_integrands.wl","integrands",{"r01/measured_support","r00/measured_tmd"}]}];
RUPut[<|"schema"->5,"stage"->"r01","values"-><||>,"evidence"->evidence,"jobs"->{job,measuredJob},"families"->{family,measuredFamily}|>,"packet.wl"];
Print["R01_PHYSICAL_QUARK_MOMENT_JOBS_READY"];
