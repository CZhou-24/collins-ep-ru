(* Strict first-order operator assembly, with full two-fraction contacts. *)
Clear[D19Polynomial,D19UAction,D19HFAction,D19NLOStage];
D19Polynomial[hard_,soft_,jetU_,jetT_]:=Module[{uu,ut},
 uu=Expand[HUU (1+a hard)(1+a soft)(1+a jetU)(f0+a f1)(D0+a D1)];
 ut=Expand[HUT (1+a hard)(1+a soft)(1+a jetT)(h0+a h1)(C0+a C1)];
 <|"UU0"->Coefficient[uu,a,0],"UT0"->Coefficient[ut,a,0],
   "UU1"->Coefficient[uu,a,1],"UT1"->Coefficient[ut,a,1]|>];
D19UAction[part_String,expr_,lower_]:=Module[{endpoint=expr/.u->1},
 Switch[part,"regular",Inactive[Integrate][expr,{u,lower,1}],"delta",endpoint,
 "D0",Inactive[Integrate][(expr-endpoint)/(1-u),{u,lower,1}]+endpoint Log[1-lower],
 "D1",Inactive[Integrate][Log[1-u](expr-endpoint)/(1-u),{u,lower,1}]+endpoint Log[1-lower]^2/2]];
D19HFAction[kernel_Association,fraction_]:=Module[{phi,endpoint,derivative,test,parts},
 phi=HFNative[flavor,fraction/u,fraction/(u v),mu]/u;
 endpoint=phi/.v->1;derivative=D[phi,v]/.v->1;
 parts={"regular","delta","D0","D1"};
 Total[Table[
  test=Inactive[Integrate][(kernel[part]/.zh->fraction)(phi-endpoint-(v-1)derivative),{v,0,1}]+
    (kernel["v_delta_"<>part]/.zh->fraction)endpoint-
    (kernel["v_derivative_"<>part]/.zh->fraction)derivative;
  D19UAction[part,test,fraction],{part,parts}]]];
D19NLOStage[]:=Module[{paths,missing,p17,p18,p16,m,j,hardInput,operatorInput,base,bound,
 hard,soft,jetU,jetT,kernel,parts,observable,hf,ratio,paper,scheme,raw,packet,
 hashes,hash,bindings,localPolynomial,localHF,normalization,prefactor,recoil,
 rank0,rank1,scales,fullAllB,restricted,integrated,integratedRatio,
 domains,product,sourceNodes,nodes,checks,ratioExpansion,genericOnly,
 matching,fullMatching,fullBound,beamLogs,fragmentLogs,physicalKernel,scaleConversion,
 operatorCompletion,hfConsistency,localHFPhysical},
 Get[FileNameJoin[{$NLOProduction,"common","assembly_helpers.wl"}]];
 Get[FileNameJoin[{$NLOProduction,"common","d15_assembly_library.wl"}]];
 Get[FileNameJoin[{$NLOProduction,"common","d15_scoped_assembly.wl"}]];
 Get[FileNameJoin[{$NLOProduction,"common","d19_hf_consistency.wl"}]];
 paths=AssociationMap[FileNameJoin[{$NLOInputs[#],"packet.json"}]&,{"d17","d18"}];
 missing=Select[Normal[paths],!FileExistsQ[Last[#]]&];
 If[missing=!={},
  genericOnly=<|"status"->"BLOCKED_NO_ACTUAL_FINITE_INPUTS",
   "generic_first_order_constructor"->D19Polynomial[hardSymbol,softSymbol,jetUSymbol,jetTSymbol],
   "missing_upstream_files"->missing,"scope"->"Symbolic constructor only; no completed HF or finite-jet physics is claimed."|>;
  NLOPut[genericOnly,"partial_assembly.wl"];
  NLOJson[<|"status"->"BLOCKED","code"->"ACTUAL_FINITE_UPSTREAM_PACKET_ABSENT",
    "detail"->"d19 requires complete actual d17/d18 packets, including finite HF endpoint contacts. No oracle or homogeneous replacement is substituted.",
    "missing"->(Last/@missing)|>,"blocker.json"];Print["ACTUAL_FINITE_UPSTREAM_PACKET_ABSENT"];Exit[2]];
 p17=Import[paths["d17"],"RawJSON"];p18=Import[paths["d18"],"RawJSON"];
 m=p17["data"];j=p18["data"];
 If[!And@@(KeyExistsQ[m,#]& /@ {"finite","v_delta","v_derivative"}),
  NLOJson[<|"status"->"BLOCKED","code"->"FINITE_HF_CONTACTS_INCOMPLETE"|>,"blocker.json"];Exit[2]];
 hardInput=Get[FileNameJoin[{$NLOInputs["s07"],"hard.wl"}]];
 operatorInput=Get[FileNameJoin[{$NLOInputs["s11"],"operators.wl"}]];
 base=Get[FileNameJoin[{$NLOInputs["d15"],"native_observable.wl"}]];
 matching=Get[FileNameJoin[{$NLOInputs["d13"],"native_matching.wl"}]];
 hard=hardInput["h1"];soft=operatorInput["renormalized"]["soft"];
 jetU=NLODecode[j["UU"]["finite"]];jetT=NLODecode[j["UT"]["finite"]];
 parts={"regular","delta","D0","D1"};
 kernel=Join[AssociationMap[NLODecode[m["finite"][#]]&,parts],
   Association[Table[("v_delta_"<>part)->NLODecode[m["v_delta"]["finite"][part]],{part,parts}]],
   Association[Table[("v_derivative_"<>part)->NLODecode[m["v_derivative"]["finite"][part]],{part,parts}]]];
 operatorCompletion=Get[FileNameJoin[{$NLOInputs["d16"],"operator_completion.wl"}]];
 hfConsistency=D19HFConsistency[m,kernel,operatorCompletion];
 Gate["actual HF matching-scale and physical-contact identities",
  And@@(TrueQ[FullSimplify[#]===0]&/@Join[
   Values[hfConsistency["component_scale_residuals"]],
   Values[hfConsistency["canonical_conversion_residuals"]],
   Values[hfConsistency["endpoint_reduction_residuals"]],
   {hfConsistency["mapped_physical_contact_action"],
    hfConsistency["finite_HF_scheme_difference_at_order_a"]}])];
 NLOPut[hfConsistency,"hf_consistency.wl"];
 observable=D19Polynomial[hard,soft,jetU,jetT];
 hf=Association[KeyValueMap[Function[{key,value},key->HUT h0 value Which[
   StringStartsQ[key,"v_delta_"],HFend,StringStartsQ[key,"v_derivative_"],-HFderiv,True,HF0]],kernel]];
 ratioExpansion=Normal[Series[(N0+a N1)/(U0+a U1),{a,0,1}]];
 ratio=<|"A0"->Coefficient[ratioExpansion,a,0],"A1"->Coefficient[ratioExpansion,a,1]|>;
 paper=D19Polynomial[hard,soft,0,0];
 scheme=<|"UU"->HUU f0 D0(kH+kB+kF+kS),"UT"->HUT h0 C0(kH+kB+kF+kS)|>;
 (* Bind the same constructor to the current generated Born/TMD convolutions. *)
 bound=base["small_b_inputs"];
 scales=base["physical_rapidity_scales"];
 (* HF finite matching is at common mu. Use the retained derived full-scale
    coefficients and collinear fields at that same scale; retaining Hhat(mu_b)
    here and adding the full-scale HF coefficient would mix two OPE schemes. *)
 fullMatching=Join[matching,<|"coefficients"->matching["full_scale_coefficients"]|>];
 scaleConversion=D15MatchingScaleConsistency[matching,base["evolution_derivation"]];
 Gate["retained homogeneous scale-conversion coefficient identities",
  AssociationQ[scaleConversion]&&And@@(TrueQ[FullSimplify[#]===0]& /@
    Flatten[Values/@Values[scaleConversion["distribution_residuals"]]])];
 fullBound=D15BindNativeMatching[fullMatching]/.{muBeam->mu,muFragment->mu};
 beamLogs={B->Log[mu^2 bRecoil^2/(4Exp[-2EulerGamma])],T->Log[mu^2/scales["zeta_P"]]};
 fragmentLogs={B->Log[mu^2 bFragment^2/(4Exp[-2EulerGamma])],T->Log[mu^2/scales["zeta_J"]]};
 bound=Join[bound,AssociationMap[fullBound[#]/.beamLogs&,{"f0","f1","t0","t1"}],
   AssociationMap[fullBound[#]/.fragmentLogs&,{"d0","d1","c0","c1"}]];
 bindings={HUU->bound["HUU"],HUT->bound["HUT"],f0->bound["f0"],f1->bound["f1"],
   h0->bound["t0"],h1->bound["t1"],D0->bound["d0"],D1->bound["d1"],C0->bound["c0"],C1->bound["c1"]};
 localPolynomial=D19Polynomial[bound["hard"],bound["soft"],jetU/.r->Log[R^2],jetT/.r->Log[R^2]]/.bindings;
 physicalKernel=Map[#/.fragmentLogs&,kernel];
 localHF=bound["HUT"]bound["t0"]D19HFAction[physicalKernel,z];
 localHFPhysical=bound["HUT"]bound["t0"]
   (hfConsistency["physical_convolution"]/.fragmentLogs/.zh->z);
 normalization=base["normalization_derivation"];prefactor=normalization["native_prefactor_in_invariants"];
 p16=Import[FileNameJoin[{$NLOInputs["d16"],"packet.json"}],"RawJSON"];
 recoil=bRecoil BesselJ[0,qRecoil bRecoil]/(2Pi);
 rank0=bFragment BesselJ[0,jHadron bFragment/z]/(2Pi)*NLODecode[p16["data"]["identities"]["Fourier_rank0_relative"]];
 rank1=bFragment^2 BesselJ[1,jHadron bFragment/z]/(2Pi)*NLODecode[p16["data"]["identities"]["Collins_rank1_relative"]];
 fullAllB=<|"UU"->D15ChargeSum[prefactor bound["HUU"]
   Normal[Series[(1+a bound["hard"])(1+a(jetU/.r->Log[R^2])),{a,0,1}]]
   D15LinearIntegral[recoil rank0 TMDf1[flavor,x,bRecoil,mu,scales["zeta_P"]]
    TMDD1[flavor,z,bFragment,mu,scales["zeta_J"]]SoftBeamJet[bRecoil,Y,R,mu],
     {{bRecoil,0,Infinity},{bFragment,0,Infinity}}]],
  "UT"->D15ChargeSum[prefactor bound["HUT"]
   Normal[Series[(1+a bound["hard"])(1+a(jetT/.r->Log[R^2])),{a,0,1}]]
   D15LinearIntegral[recoil rank1 TMDh1[flavor,x,bRecoil,mu,scales["zeta_P"]]
    TMDCollinsScalar[flavor,z,bFragment,mu,scales["zeta_J"]]SoftBeamJet[bRecoil,Y,R,mu],
     {{bRecoil,0,Infinity},{bFragment,0,Infinity}}]]|>;
 (* All-b Collins TMD already contains HF physics. It is not augmented by
    the local HF OPE a second time. The local contribution below is separate. *)
 restricted=<|"UU0"->prefactor recoil rank0 localPolynomial["UU0"],
   "UU1"->prefactor recoil rank0 localPolynomial["UU1"],
   "UT0"->prefactor recoil rank1 localPolynomial["UT0"],
   "UT1"->prefactor recoil rank1(localPolynomial["UT1"]+localHFPhysical)|>;
 domains={{bRecoil,0,rhoOPE/LambdaQCD},{bFragment,0,rhoOPE/LambdaQCD}};
 integrated=Map[D15LinearIntegral[D15ChargeSum[#],domains]&,restricted];
 integratedRatio=ratio/.{U0->integrated["UU0"],U1->integrated["UU1"],N0->integrated["UT0"],N1->integrated["UT1"]};
 hash[path_]:=StringTrim[RunProcess[{$NLOCandidateContext["runtime"]["python"],
   FileNameJoin[{$NLOProduction,"common","nlo_packet_hash.py"}],path},"StandardOutput"]];
 hashes=Map[hash,paths];Gate["actual canonical packet hashes",And@@(StringLength[#]==64& /@ Values[hashes])];
 raw=<|"observable"->observable,"HF_integrand"->hf,"ratio"->ratio,
   "paper_limit"->paper,"scheme_variation"->scheme,
   "full_all_b_operator"->fullAllB,"local_small_b_integrands"->restricted,
   "local_HF_convolution"->localHF,"physical_local_HF_convolution"->localHFPhysical,
   "HF_matching_scale_and_physical_reduction"->hfConsistency,
   "common_integrated_coefficients"->integrated,
   "local_integrated_ratio"->integratedRatio,"actual_native_bindings"->bindings,
   "common_collinear_scale"->mu,"beam_log_binding"->beamLogs,"fragment_log_binding"->fragmentLogs,
   "paper_limit_scale_conversion"->scaleConversion,
   "paper_limit_conversion_scope"->"With HF and jet extension off, the actual 24 distribution differences vanish after F(mu_b)=F(mu)-a B P_full convolution F(mu) and the retained TMD evolution. By the same linear convolutions/integration this equates the two physical first-order products; it does not identify unconverted matrix elements at different scales.",
   "local_domain"->base["small_b_domain"],"ratio_domain"->HoldComplete[U0!=0],
   "all_b_scope"->"Renormalized symbolic TMD operators at all b; no local OPE extrapolation.",
   "HF_support_qualification"->"d16 establishes both spectral support arguments and the regular-map diagonal value/derivative identities. The generic twelve-component action is retained before the physical reduction in hf_consistency.wl. d16's diagonal and lower-fraction regularity domain and d17's common-regulator subtraction qualifications remain explicit.",
   "retained_paper_limit"->"HF and additional finite jet remainder off; comparison to retained native approximation only."|>;
 NLOPut[raw,"NATIVE_OBSERVABLE.wl"];
 NLOPut[<|"input_packet_hashes"->hashes,"kernel"->kernel,"jet"->{jetU,jetT},
   "hard"->hard,"soft"->soft,"bindings"->bindings|>,"consumed_coefficients.wl"];
 packet=Join[Map[Map[NLOTree,#]&,KeyTake[raw,{"observable","HF_integrand","ratio","paper_limit","scheme_variation"}]],
  <|"input_packet_hashes"->hashes,"fitted_inputs_evaluated"->False,
   "all_b_OPE_extrapolation"->False,"HF_independent"->True,
   "ratio_after_common_linear_integral"->True,"paper_limit_is_full_NLO"->False,"full_fixed_order_NLO"->False|>];
 NLOWritePacket[packet];
 nodes={NLONode["source","assembly","production","common/d19_nlo.wls",{},"Native assembly entry requires actual complete upstream finite packets."],
  NLONode["library","assembly","production","common/d19_assembly_library.wl",{"source"},"Strict product and common-linear-integral ratio constructor, including two-fraction contacts."],
  NLONode["HF_consistency_source","assembly","production","common/d19_hf_consistency.wl",{"library"},"Actual twelve-component HF scale cancellation, canonical conversion, generic contact action and subsequent physical reduction."],
  NLONode["hash_source","conversion","production","common/nlo_packet_hash.py",{},"Canonical identity of the consumed native packets; no physical calculation."],
  NLONode["HF_input","assembly","d17","packet.wl",{},"Actual new HF matching and endpoint coefficients, not reference formulas."],
  NLONode["jet_input","assembly","d18","packet.wl",{},"Actual new finite quark fragmenting-jet conversion."],
  NLONode["base_input","assembly","d15","native_observable.wl",{},"Retained Born/TMD bindings and physical normalization from the current run."],
  NLONode["matching_input","assembly","d13","native_matching.wl",{},"Retained derived full-scale diagonal and UU coefficients are bound at the same mu as new HF matching."],
  NLONode["hard_input","assembly","s07","hard.wl",{},"Current generated one-loop hard coefficient."],
  NLONode["soft_input","assembly","s11","operators.wl",{},"Current generated beam/jet soft allocation with independent recoil log."],
  NLONode["measure_input","conversion","d16","packet.wl",{},"Current physical Fourier and rank-one normalization identities."],
  NLONode["operator_completion_input","conversion","d16","operator_completion.wl",{},"Current full projection, Wilson Taylor identity and both spectral endpoint arguments, with domain qualifications."],
  NLONode["HF_consistency","assembly","output","hf_consistency.wl",{"HF_consistency_source","HF_input","operator_completion_input"},"Generated HF mixing-scale and endpoint-reduction residuals from the same actual inputs used in the observable."],
  NLONode["consumed","conversion","output","consumed_coefficients.wl",{"library","hash_source","HF_input","jet_input","base_input","matching_input","hard_input","soft_input"},"Exact coefficient binding and canonical upstream packet identities."],
  NLONode["observable","assembly","output","NATIVE_OBSERVABLE.wl",{"consumed","measure_input","HF_consistency"},"Native all-b operator and separate local OPE, same integration and strict ratio; physical HF reduction is derived after retaining all generic components."],
  NLONode["export","finite_export","output","packet.wl",{"observable"},"Exact coefficient maps independently reexportable by the immutable encoder."]};
 NLOProvenance[nodes,{"export"}];Exit[0]
];
