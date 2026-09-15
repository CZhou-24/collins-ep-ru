(* SIDIS s12 projective Feynman/Euler construction and s18 valuation,
   adapted to the actual ordinary ep virtual reduction. Evaluation belongs
   exclusively to the validator's native_subtropica.wls. *)
Get[FileNameJoin[{DirectoryName[$InputFileName],"ru_virtual_io.wl"}]];RUvBegin["r05"];
RUvLoadFC[];
mapping=Get[RUvInput["r04","virtual_map.wl"]];
certificate=Get[RUvInput["r04","jobs/virtual/reduction_certificate.wl"]];
rules=certificate["rules"]/.{d->D,q2->Q2};masters=certificate["masters"];
reduced=Factor[mapping["target_expression"]/.rules];
openReduced=Factor[mapping["open_current"]/.rules];
RUvGate["independent open-line and projected reductions agree",Factor[openReduced-reduced]===0];
RUvGate["independent IBP divergences reduce to zero",And@@(TrueQ[Factor[#/.rules]===0]& /@mapping["independent_IBP_divergences"])];
(* The ordinary massless vector form factor has one-scale bubble masters.
   Preserve any unsupported native inventory instead of loading an answer. *)
RUvPut[<|"certificate"->certificate,"rules"->rules,"masters"->masters,
 "reduced_current"->reduced,"open_reduced_current"->openReduced|>,"reduction_binding.wl"];
RUvGate["supported actual unit-index bubble master",masters==={V[0,1,1]}];
FCClearScalarProducts[];SPD[p]=0;SPD[pout]=0;SPD[p,pout]=Q2/2;
representation=FCFeynmanParametrize[FAD[ell+p,ell+pout],{ell},Names->x,
 FCReplaceD->{D->4-2 eps},FeynmanIntegralPrefactor->"Unity",FCFeynmanPrepare->True];
textbook=FCFeynmanParametrize[FAD[ell+p,ell+pout],{ell},Names->x,
 FCReplaceD->{D->4-2 eps},FeynmanIntegralPrefactor->"Textbook"];
RUvGate["unevaluated fresh bubble parameter representation",ListQ[representation]&&Length[representation]>=3&&
 FreeQ[Take[representation,3],_FCFeynmanParametrize|_Pair|ell|$Failed|$Aborted]];
{integrand,prefactor,parameters}=Take[representation,3];
RUvGate["two projective bubble parameters",Length[parameters]===2];
assumptions=Q2>0&&scale>0&&Element[eps,Reals]&&And@@(#>0& /@parameters);
RUvGate["projective measure homogeneity",FullSimplify[(integrand/.Thread[parameters->scale parameters])scale^2/integrand==1,assumptions]];
coefficient=Factor[(reduced/V[0,1,1])/.D->4-2 eps];
valuation=With[{rat=Together[coefficient]},Exponent[Numerator[rat],eps,Min]-Exponent[Denominator[rat],eps,Min]];
order=Max[0,-valuation];RUvGate["native order interface is sufficient",IntegerQ[order]&&order<=4];
gauge=Last[parameters]->1;
tuple={prefactor,integrand/.gauge/.Q2->1/.First[parameters]->xx,{xx},{}};
(* SIDIS integrates unnormalized d^D ell. We retain that exact tuple and
   explicitly convert its result to B=e^(gamma_E eps) I/(i pi^(D/2)).
   This is an invertible measure conversion, not a replacement master. *)
conversion=Exp[EulerGamma eps]/(I Pi^(2-eps));
measureConversion=FullSimplify[(4 Pi alphaS (Exp[EulerGamma]/(4 Pi))^eps)/(2 Pi)^(4-2 eps)/conversion/(alphaS/(4 Pi)),Element[eps,Reals]];
RUvGate["SIDIS measure and MSbar coupling reproduce the generated loop phase",measureConversion===I];
job=RUvPath["jobs/virtual"];CreateDirectory[job,CreateIntermediateDirectories->True];
euler=<|"B"-><|"order"->order,"terms"->{<|"tuple"->tuple,
 "prefactor"->conversion,"order"->order,"assumptions"->Element[eps,Reals]|>}|>|>;
Put[euler,FileNameJoin[{job,"euler_inputs.wl"}]];
(* Local subtraction data from the same Feynman polynomial: only its
   pole and constant moments are required to identify the IR poles of
   a coefficient with a simple epsilon pole. No finite current/master
   answer is evaluated by this operation. *)
unitSimplexIntegrand=FullSimplify[(integrand/.{parameters[[1]]->y,parameters[[2]]->1-y,Q2->1}),0<y<1&&Element[eps,Reals]];
simplexExponent=Factor[D[unitSimplexIntegrand,eps]/.eps->0];
poleResidue=Integrate[unitSimplexIntegrand/.eps->0,{y,0,1}];
constantMoment=Integrate[simplexExponent,{y,0,1}];
RUvGate["independent local Euler subtraction moments are explicit",FreeQ[{poleResidue,constantMoment},_Integrate|_Real|$Failed]];
poleModel=poleResidue/eps+constantMoment;
localPole=Total[Table[Coefficient[RUvLaurent[coefficient Exp[eps LQ]poleModel],eps,j]eps^j,{j,-2,-1}]];
RUvPut[<|"master"->V[0,1,1],"representation"->representation,"textbook"->textbook,
 "gauge"->gauge,"tuple"->tuple,"normalized_measure_factor"->conversion,
 "normalized_master_definition"->"B=e^(EulerGamma eps)/(i Pi^(2-eps)) Integral d^(4-2eps)ell/[(ell+p)^2+i0][(ell+pout)^2+i0], Q2=1",
 "coefficient"->coefficient,"valuation"->valuation,"required_order"->order,
 "scale_restoration"->Exp[eps LQ],"scale_definition"->HoldComplete[LQ==Log[muBar^2/Q2]],
 "bare_strong_coupling"->HoldComplete[gsBare^2==4 Pi alphaS muBar^(2 eps)(Exp[EulerGamma]/(4 Pi))^eps],
 "SIDIS_loop_measure"->HoldComplete[1/(2 Pi)^(4-2 eps)],
 "coupling_measure_conversion"->measureConversion,
 "generated_phase_conversion"->"The factor I from loop measure and bare coupling multiplies the generated loop/tree ratio. r04 loop_prefactor already contains exactly this I; its normalized value is the color factor, so no phase is silently dropped.",
 "net_phase_and_measure_identity"->(measureConversion/I),
 "simplex_integrand"->unitSimplexIntegrand,"simplex_first_regulator_derivative"->simplexExponent,
 "local_pole_residue"->poleResidue,"local_constant_moment"->constantMoment,
 "local_IR_pole_prediction_without_color"->localPole,
 "local_subtraction_scope"->"Only the local pole part is identified analytically from the Feynman-parameter endpoint moments. All integrated current coefficients, including the finite remainder, consume the actual validator-evaluated master.",
 "conditions"->Q2>0,"continuation"->"Spacelike Feynman +i0; the sole chord invariant is Q2>0 and the Euler polynomial is positive. No timelike discontinuity is introduced."|>,"master_derivation.wl"];
RUvPut[<|"schema"->5,"stage"->"r05","values"-><||>,
 "jobs"->{<|"id"->"virtual","inputs"->{"euler_inputs.wl"},
 "outputs"->{"masters.wl","raw_results.wl","subtropica_execution.json"},"families"->{"V"},"sectors"->{"hard_virtual"}|>},
 "evidence"-><|
 "r05/reduction_binding"->RUvEvidence["reduction_binding.wl","euler_inputs",{"source/r05","r04/loop_mapping","tool/r04/virtual/reduction_certificate.wl","tool/r04/virtual/reduction_audit.json","tool/r04/virtual/results/V/kira_targets.m","tool/r04/virtual/results/V/masters.final"}],
 "r05/master_derivation"->RUvEvidence["master_derivation.wl","continuation",{"r05/reduction_binding"}],
 "r05/euler_inputs"->RUvEvidence["jobs/virtual/euler_inputs.wl","euler_inputs",{"r05/master_derivation"}]|>|>,"packet.wl"];
Print["R05_EULER_INPUTS_COMPLETE"];Quit[0];
