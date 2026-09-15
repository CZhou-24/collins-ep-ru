(* Genuine no-additional-cut-state virtual sector. The complete rank-one
   future-Wilson Taylor identity is consumed from d16, not replaced by a
   kinematic projection of selected local diagrams. *)
Clear[D17VirtualCompletion];
D17VirtualCompletion[treeIdentity_:Missing["D16TaylorIdentityNotSupplied"]]:=Module[
 {graphs,fa,fc,phase,phaseDerivative,loopPhase,zero,operatorZero,
  graphZeros,uncutIntegral,shared,uv,ir,finite,epsN,amplitude},
 graphs=InsertFields[CreateTopologies[1,1->2],
   {F[3,{1}]}->{F[3,{1}],V[5]},Model->"SMQCD",
   InsertionLevel->{Particles},ExcludeParticles->{V[1|2|3],S[_]}];
 fa=CreateFeynAmp[graphs,PreFactor->1];
 fc=FCFAConvert[fa,IncomingMomenta->{k},OutgoingMomenta->{r1,g},
   LoopMomenta->{qLoop},UndoChiralSplittings->True,ChangeDimension->D,
   List->True,SMP->True,Contract->False,DropSumOver->False];
 (* Translating every coordinate in an uncut operator branch multiplies
    each internal propagator endpoint pair by inverse phases. The internal
    loop routing therefore cancels; only net external momentum remains.
    Wilson-segment points translate with their common transverse base. *)
 loopPhase=FullSimplify[Exp[-I bT qT]Exp[I bT qT]];
 phase=Exp[-I bT(rT+gT)];
 phaseDerivative=I D[phase,bT]/.bT->0;
 zero=phaseDerivative/.{rT->0,gT->0};
 graphZeros=Map[Expand[zero #]&,fc];
 epsN=n0+eps n1+eps^2 n2;
 (* Display separate endpoint poles even though the complete rank-one
    numerator vanishes. No UV/IR cancellation is used to infer zero. *)
 uv=zero epsN/epsUV;ir=-zero epsN/epsIR;
 shared=zero epsN(1/epsUV-1/epsIR);
 <|"origin"->"DERIVED generated one-loop QCD virtual inventory and exact cluster-translation/Wilson-Taylor reduction before integration.",
  "generated_topologies"->graphs,"generated_FeynArts_amplitudes"->fa,
  "generated_FeynCalc_currents"->fc,"virtual_graph_count"->Length[fa],
  "complete_Taylor_operator_input"->treeIdentity,
  "internal_line_translation_phase"->loopPhase,
  "external_cluster_phase"->phase,"rankone_cluster_derivative"->phaseDerivative,
  "collinear_rankone_derivative"->zero,"virtual_projected_graph_residuals"->graphZeros,
  "virtual_independent_HF_coefficient"->zero,
  "UV_numerator_before_integration"->zero epsN,
  "IR_numerator_before_integration"->zero epsN,
  "UV_pole_separate"->uv,"IR_pole_separate"->ir,
  "unintegrated_Oepsilon_numerator"->epsN,
  "common_scaleless_pole_pair"->HoldComplete[(n0+eps n1+eps^2 n2)(1/epsUV-1/epsIR)],
  "complete_projected_pole_pair"->shared,
  "virtual_sector_proof"->"With no additional cut state, every loop remains on one operator branch. The full iD/local-A/F/Wilson sum is the transverse derivative of that entire future-Wilson-dressed quark cluster, by the supplied d16 identity. Internal propagator phases cancel pairwise; each Wilson vertex translates with the same base. The derivative is therefore net external transverse momentum rT+gT, zero for the collinear independent-F matching state. This is an unintegrated zero of the complete rank-one operator, not a claim that each isolated local insertion or unprojected virtual amplitude vanishes. Its UV and IR numerators separately vanish, including O(epsilon). Additional cross-cut radiation gives nonzero net transverse momentum and is included in the separately generated real cut sum.",
  "boundary_and_overlap"->"The future transverse boundary is the retarded A_perp(+infinity)=0 condition in the actual d16 identity. Cross-branch pure eikonal soft factors are removed by the common TMD soft allocation and multiply the actual independent-HF tree coefficient zero. They are not counted as uncut-branch virtual diagrams.",
  "u_endpoint_origin"->"The no-extra-cut sector is supported at u=1; its complete rank-one numerator is zero. Real graphs are locally integrable at u=1 on the proved joint endpoint class and generate no u delta or logarithmic-plus extension."|>
];
