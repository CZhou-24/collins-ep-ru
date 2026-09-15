(* Fresh gauge-completed HF producing chain. The only dependencies are
   generating/operator sources enumerated before reuse, and the shared NEW
   measured native master supplied later by r02/r03. No old radial answer. *)
$RUHFCommon=DirectoryName[$InputFileName];
Scan[Get[FileNameJoin[{$RUHFCommon,#}]]&,{
 "ru_hf_projection.wl","ru_hf_wilson.wl","ru_hf_operator.wl",
 "ru_hf_cut.wl","ru_hf_gauge.wl","ru_hf_endpoint.wl",
 "ru_hf_virtual.wl","ru_hf_measurement.wl","ru_hf_angular.wl"}];
Clear[RUHFGenerate,RUHFGenerateBody,RUHFGate,RUHFPut,RUHFZeroQ];
RUHFGate[label_,value_]:=If[!TrueQ[value],Print["HF_FAIL: ",label];Quit[1]];
RUHFZeroQ[value_]:=And@@(TrueQ[Factor[#]===0]&/@Flatten[{value}]);
RUHFPut[value_,dir_,name_]:=Put[value,FileNameJoin[{dir,name}]];
(* Earlier Born source uses Global`g for its gamma-matrix array. HF uses g
   for a coherent-gluon momentum. Dynamic scoping preserves the caller's
   bindings and keeps the whole generating/current/projection chain coherent.
   A native Abort must never escape as an apparent successful script exit. *)
RUHFGenerate[ctx_Association]:=Block[{Global`g,Global`k,Global`l,Global`p,Global`n,
 Global`r0,Global`r1,Global`e,Global`eL,Global`eG,Global`u,Global`v,Global`kt2,
 Global`mu,Global`nu,Global`al,Global`be,Global`rho,Global`si,Global`lambda,Global`tHat},
 CheckAbort[RUHFGenerateBody[ctx],Print["HF_FAIL: native evaluation aborted"];Quit[1]]];
RUHFGenerateBody[ctx_Association]:=Module[{dir,op,map,generated,gauge,primary,independent,
 regulated,virtual,traceChecks,checks,norm,colors,primaryD,independentD,pv,
 density,endpoint,delta,packet,left,right,both,surface,probe,angular},
 dir=FileNameJoin[{ctx["output"],"hf"}];
 If[!DirectoryQ[dir],CreateDirectory[dir,CreateIntermediateDirectories->True]];
 Print["HF: actual operator inverse projection and future-Wilson Taylor identity"];
 op=RUHFOperator[];RUHFGate["operator generation",AssociationQ[op]];
 RUHFPut[op,dir,"operator.wl"];
 RUHFGate["operator residuals",RUHFZeroQ[Values[op["residuals"]]]];
 map=RUHFMeasurementProof[];RUHFPut[map,dir,"measurement_derivative_map.wl"];
 RUHFGate["measurement coordinate and raised-cut test-function proof",
  RUHFZeroQ[Join[Values[map["coordinate_residuals"]],
    Lookup[map["raw_delta_test_rows"],"residual"],Lookup[map["normalized_cut_test_rows"],"residual"],{map["n_shift"]["residual"]}]]];
 Print["HF: fresh FeynArts q to qgg skeletons and open Wilson current"];
 generated=D17GeneratedGraphs[];RUHFPut[generated,dir,"generated_graphs.wl"];
 RUHFGate["three actual real skeletons",generated["graph_count"]===3];
 gauge=D17GaugeCompletion[generated];RUHFPut[gauge,dir,"gauge_completion.wl"];
 Print["HF: D-dimensional FeynCalc and independent Clifford conjugate cuts"];
 primary=D17PrimaryCut[generated];RUHFPut[primary,dir,"primary_cut.wl"];
 independent=D17IndependentCut[];RUHFPut[independent,dir,"independent_cut.wl"];
 regulated=D17PrimaryCut[generated,"physical",lambda];RUHFPut[regulated,dir,"regulated_cut.wl"];
 traceChecks=AssociationMap[Factor[primary["D_traces"][#]-independent["D_traces"][#]]&,{"a","b","c"}];
 RUHFGate["fresh physical, hat and conjugate traces",RUHFZeroQ[Join[Values[traceChecks],
  independent["lightfront_residuals"],Values[independent["conjugate_cut_residuals"]]]]];
 (* The physical scalar cut Jacobian is kept separate from operator/graph
    factors. Multiplication by kt2 converts the density to d(kt2)/kt2.
    The shared native M111 angular master supplies the remaining sphere. *)
 norm=<|"parent_and_inverse_F_density"->op["parent_and_density"],
  "common_parent_propagators"->primary["common_parent_propagators"],
  "physical_cut_Jacobian"->primary["cut_jacobian"],"log_radial_measure"->kt2|>;
 colors[tr_Association]:=CF tr["a"]+(CF-CA/2)tr["b"]-CA tr["c"]/2;
 left=Factor[Times@@Values[norm]colors[primary["D_traces"]]];
 right=Factor[Times@@Values[norm]colors[independent["conjugate_cut_D_traces"]]];
 both=Factor[left+right];
 pv=Cancel[(-D[z/v,v]/(z/v)^2)/(1/z-1/(z/v))];
 primaryD=Factor[both/.D->4-2eps];
 independentD=Factor[Times@@Values[norm](colors[independent["D_traces"]]+
   colors[independent["conjugate_cut_D_traces"]])/.D->4-2eps];
 density=Factor[primaryD pv];
 RUHFGate["log-radial density scalar homogeneity",FreeQ[density,kt2]];
 endpoint=D17EndpointCompletion[regulated,2 (Times@@Values[norm]),both pv];
 RUHFPut[endpoint,dir,"regulated_endpoint_action.wl"];
 Print["HF: fresh virtual inventory and whole-branch rank-one zero"];
 virtual=D17VirtualCompletion[op];RUHFPut[virtual,dir,"virtual_completion.wl"];
 checks=Join[traceChecks,<|"generated_vertex"->primary["generated_vertex_routing_residual"],
  "independent_D_density"->Factor[primaryD-independentD],"inverse_fraction_measure"->Factor[pv-1/(1-v)],
  "endpoint_damping_limit"->endpoint["damping_zero_D_density_residual"],
  "joint_endpoint_decomposition"->endpoint["joint_endpoint_decomposition"]["residual"],
  "virtual_independent_HF"->virtual["virtual_independent_HF_coefficient"],
  "virtual_UV_numerator"->virtual["UV_numerator_before_integration"],
  "virtual_IR_numerator"->virtual["IR_numerator_before_integration"]|>];
 RUHFGate["gauge, regulated endpoint and virtual identities",RUHFZeroQ[Join[Values[checks],
  Values[gauge["unprojected_Ward_residuals"]],Values[gauge["emitted_hat_Ward_residuals"]],
  {gauge["open_axial_minus_covariant_Wilson_residual"],gauge["triple_longitudinal_h_residual"],
   gauge["special_propagator_split_residual"],gauge["transverse_F_projection_of_leading_piece"],
   gauge["regulated_parent_Ward_remainder_identity"]},virtual["virtual_projected_graph_residuals"]]]];
 Print["HF: independent full-D momentum tensor and ordered rank-one angular continuation"];
 angular=RUHFAngularProof[generated,density,norm];RUHFPut[angular,dir,"angular_continuation.wl"];
 (* Probe is upstream of native master multiplication and epsilon expansion.
    The wrapper owns decoding the validator's exact transport tree. *)
 delta=Lookup[ctx,"HF_epsilon_delta",0];
 packet=<|"status"->"FRESH_GENERATED_MEASURED_HF_DENSITY_REQUIRES_NEW_NATIVE_MASTER",
  "operator"->op,"measurement"->map,"normalization_factors"->norm,"angular_continuation"->angular,
  "left_log_density_before_PV"->left,"right_log_density_before_PV"->right,
  "D_numerator_before_PV"->primaryD,"independent_D_numerator_before_PV"->independentD,
  "inverse_fraction_measure"->pv,"log_density"->density,
  "epsilon_probe"->delta,"log_density_with_probe"->Expand[density+eps delta],
  "mixing_numerator"->Factor[density/.eps->0],
  "epsilon_numerator"->Factor[SeriesCoefficient[density,{eps,0,1}]],
  "scalar_native_dependency"->"M111 fixed(u,tau) cut sphere, actual new Kira identity and validator-owned SubTropica Euler value; no old radial master",
  "native_normalization_contract"->"Multiply log_density by measured_normalization=e^(EulerGamma eps)/Gamma[1-eps] obtained from the actual measured sphere. The cut Jacobian and physical rank-one operator factors are already displayed in normalization_factors. The subsequent analytic Fourier transform retains the specified physical-J0 continuation.",
  "fixed_tau_measure"->HoldComplete[dTau tau^(-1-eps)],
  "fraction_measure"->HoldComplete[Integrate[du/u Integrate[dv/(1-v) HF[zh/u,zh/(u v)],{v,0,1}],{u,zh,1}]],
  "generic_v_delta"->Missing["GenericContactUndetermined"],"generic_v_derivative"->Missing["GenericContactUndetermined"],
  "physical_contact_representative"-><|"v_delta"->0,"v_derivative"->0,
   "scope"->"Only on the operator-derived uniformly derivative-flat physical class; not a generic distribution identity."|>,
  "u_endpoint_origin"->virtual["u_endpoint_origin"],"checks"->checks,
  "scope"->"Complete generating/operator sum under the retained BMHV physical-two-plane continuation, source spectral assumptions and common-regulator physical endpoint class. No closed twist-three evolution or full ep NLO certification."|>;
 RUHFPut[packet,dir,"generated_density.wl"];packet
];
