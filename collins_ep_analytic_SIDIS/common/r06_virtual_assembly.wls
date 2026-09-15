(* Actual fresh Kira/SubTropica contraction. SIDIS s19 measure, Hermitian
   interference and explicit scaleless UV/IR ledger; accepted Collins s07
   generating numerator supplies the process-specific conserved-current map. *)
Get[FileNameJoin[{DirectoryName[$InputFileName],"ru_virtual_io.wl"}]];RUvBegin["r06"];
RUvLoadFC[];
integ=Get[RUvInput["r04","integrands.wl"]];
selfData=Get[RUvInput["r04","generated_self_energy.wl"]];
map=Get[RUvInput["r04","virtual_map.wl"]];
derivation=Get[RUvInput["r05","master_derivation.wl"]];
masters=Get[RUvInput["r05","jobs/virtual/masters.wl"]];
RUvGate["actual normalized ordinary bubble is present",AssociationQ[masters]&&KeyExistsQ[masters,"B"]];
color=integ["loop_prefactor"];coefficient=derivation["coefficient"];
(* The current has at most a double pole; retain exactly the scale orders
   that can contribute through the finite term and transport a polynomial. *)
factor=color Normal[Series[Exp[eps LQ],{eps,0,2}]]coefficient;
bubble=masters["B"];
bare=RUvLaurent[factor bubble];
RUvGate["master contraction resolved",FreeQ[bare,_V|_STIntegrate|_Integrate|_PaVe|_Real|$Failed|$Aborted]];
(* Large-loop angular projection is performed on this run's generated
   numerator. The logarithmic residue multiplies the local bubble pole,
   whose unit residue is independently bound to the Euler simplex in r05. *)
uvLeading=integ["projected_numerator"]/.{
 Pair[Momentum[ell,D],Momentum[p,D]]Pair[Momentum[ell,D],Momentum[pout,D]]->Q2 ell2/(2 D),
 Pair[Momentum[ell,D],Momentum[ell,D]]->ell2,
 Pair[Momentum[ell,D],Momentum[p,D]]->0,
 Pair[Momentum[ell,D],Momentum[pout,D]]->0};
vertexUV=Factor[(Coefficient[uvLeading,ell2]/.D->4)derivation["local_pole_residue"]];
selfNumerator=DiracSimplify[selfData["numerator"]/.selfData["bubble_exchange_average"]];
selfUV=Factor[(selfNumerator/FCI[GSD[p]]/.D->4)derivation["local_pole_residue"]];
RUvGate["fresh vertex and external-leg UV residues cancel",vertexUV+selfUV===0];
vertexSplit=bare+color vertexUV(1/epsUV-1/eps);
selfSplit=color selfUV(1/epsUV-1/eps);
renormalized=Expand[vertexSplit+selfSplit];
localIR=color derivation["local_IR_pole_prediction_without_color"];
actualIR=Total[Table[Coefficient[bare,eps,j]eps^j,{j,-2,-1}]];
irResidual=Expand[actualIR-localIR];
hard=Expand[renormalized-localIR];
If[!TrueQ[$RUvContext["validation_probe"]],
 RUvGate["actual integrated poles equal independently fixed local current subtraction",irResidual===0];
 RUvGate["finite conserved-current matching",FreeQ[hard,eps|epsUV]],
 Print["VALIDATION_PROBE: retaining diagnostic uncancelled poles with unchanged subtraction recipe"]];
values=<|
 "r06/virtual_bare"->RUvCert[0,{RUvTerm["master/r05/virtual/B",factor]},bare],
 "r06/vertex_uv"->RUvCert[color vertexUV/epsUV,{},color vertexUV/epsUV],
 "r06/self_uv"->RUvCert[color selfUV/epsUV,{},color selfUV/epsUV],
 "r06/virtual_vertex_separated"->RUvCert[color vertexUV(1/epsUV-1/eps),{RUvTerm["r06/virtual_bare",1]},vertexSplit],
 "r06/virtual_self_separated"->RUvCert[selfSplit,{},selfSplit],
 "r06/virtual_uv_separated"->RUvCert[0,{RUvTerm["r06/virtual_vertex_separated",1],RUvTerm["r06/virtual_self_separated",1]},renormalized],
 "r06/virtual_ir_subtraction"->RUvCert[localIR,{},localIR],
 "r06/hard"->RUvCert[0,{RUvTerm["r06/virtual_uv_separated",1],RUvTerm["r06/virtual_ir_subtraction",-1]},hard],
 (* Exact dummy-log conversion into the accepted comparison notation.
    Recontract the SAME native bubble with LQ renamed L, including the
    independently fixed subtraction. No evaluated hard answer enters. *)
 "r06/hard_comparison"->RUvCert[-localIR/.LQ->L,
   {RUvTerm["master/r05/virtual/B",factor/.LQ->L]},hard/.LQ->L]
|>;
RUvPut[<|"master"->bubble,"master_id"->"master/r05/virtual/B","coefficient"->coefficient,
 "loop_color_from_generated_tree_ratio"->color,"scale_factor"->Exp[eps LQ],
 "bare_coefficient_alpha_s_over_4pi"->bare,"SIDIS_measure_conversion"->derivation["coupling_measure_conversion"],
 "spacelike_assumptions"->Q2>0,"Hermitian_current_interference"->2 hard,
 "hard_function_convention"->"Amplitude = 1 + alpha_s/(4 Pi) hard; squared H = 1 + alpha_s/(2 Pi) hard. The same open vector-current coefficient multiplies both Born UU and UT tensors.",
 "shared_projector_qualification"->"The D-dimensional open-line reduction is shared with accepted Collins generation. A direct new amplitude/helicity comparison is required separately; retained checks do not establish new acceptance."|>,"virtual_contraction.wl"];
RUvPut[<|"projected_large_loop_numerator"->uvLeading,"vertex_UV_residue"->color vertexUV,
 "generated_self_energy_numerator"->selfNumerator,"self_UV_residue"->color selfUV,
 "vertex_separated"->vertexSplit,"self_separated"->selfSplit,
 "UV_sum"->color(vertexUV+selfUV)/epsUV,"common_regulator_renormalized"->renormalized,
 "local_IR_subtraction"->localIR,"actual_integrated_IR_poles"->actualIR,"IR_residual"->irResidual,
 "finite_current"->hard,"validation_probe"->$RUvContext["validation_probe"],
 "UV_IR_origin"->"The massless on-shell self-energy is scaleless: its UV residue is the generated gamma-chain exchange average times the local bubble residue, and its IR residue has opposite sign. Vertex UV originates in the actual large-loop angular projection. They cancel separately from the remaining current IR poles.",
 "counterterm_allocation"->"Conserved electromagnetic quark current has no independent UV counterterm. Born carries no g_s; strong coupling renormalization first changes the relative two-loop term. The EFT current subtraction is purely its local poles; no finite adjustment is made.",
 "subtraction_dependency"->"Local pole counterterm is derived in r05 from the unmutated Euler integrand, not recomputed from a mutated master. Dependency probes therefore preserve the recipe and expose uncancelled poles."|>,"uv_ir_ledger.wl"];
RUvPut[<|"schema"->5,"stage"->"r06","values"->values,"jobs"->{},
 "evidence"-><|
 "r06/virtual_contraction"->RUvEvidence["virtual_contraction.wl","virtual_coefficients",{"source/r06","r05/master_derivation","tool/r05/virtual/masters.wl","tool/r05/virtual/raw_results.wl","tool/r05/virtual/subtropica_execution.json"}],
 "r06/uv_ir_ledger"->RUvEvidence["uv_ir_ledger.wl","uv_subtraction",{"r06/virtual_contraction","r04/generated_self_energy","r04/integrands"}]|>|>,"packet.wl"];
Print["R06_VIRTUAL_ASSEMBLY_COMPLETE ",InputForm[hard]];Quit[0];
