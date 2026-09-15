Get[FileNameJoin[{DirectoryName[$InputFileName],"ru_stage.wl"}]];
Get[FileNameJoin[{$RUProduction,"common","ru_tmd_assembly.wl"}]];
Get[FileNameJoin[{$RUProduction,"common","ru_soft_transforms.wl"}]];
Get[FileNameJoin[{$RUProduction,"common","ru_soft_assembly.wl"}]];
Get[FileNameJoin[{$RUProduction,"common","ru_hf_assembly.wl"}]];
RUHFZeroQ[x_]:=And@@(RUZero/@Flatten[{x}]);
map=Get[FileNameJoin[{$RUContext["inputs"]["r01"],"integrands.wl"}]];
reduction=Get[FileNameJoin[{$RUContext["inputs"]["r01"],"jobs","quark","reduction_certificate.wl"}]];
masters=Get[FileNameJoin[{$RUContext["inputs"]["r02"],"jobs","quark","masters.wl"}]];
RUGate["fresh supported nonzero cut volume",AssociationQ[masters]&&KeyExistsQ[masters,"CutVolume"]&&masters["CutVolume"]=!=0];
(* SIDIS s11 contraction: actual fresh numerator coefficients times actual rules. *)
unreduced=Total[(#[[2]] Apply[R1,#[[1]]])& /@ map["rows"]];
reduced=Factor[unreduced/.reduction["rules"]/.d->4-2 eps];
ratio=Factor[reduced/.R1[1,1,0]->1];
RUGate["no unreduced target survives",FreeQ[ratio,_R1]];
master=masters["CutVolume"];
angular=Expand[Normal[Series[ratio master,{eps,0,1}]]];
(* SIDIS s17 endpoint distribution algorithm, now on t=w/W in [0,1].
   Only this pilot's inclusive collinear invariant-mass distribution is formed.
   The actual anti-kt z-dependent bound and TMD Fourier transform are NOT replaced
   by this interval. They are absent from this pilot packet; the measured sector packet below derives them separately. *)
scale=Normal[Series[Exp[eps Lmass],{eps,0,4}]];
values=<|"r03/quark_angular_bare"->RUCertificate[0,{RURecord["master/r02/quark/CutVolume",ratio,master]},{"beam_fqq","fragment_dqq"},1]|>;
Do[
 factor=Switch[k,"delta",-scale/eps,"D0",scale,"D1",-eps scale,"regular",0];
 AssociateTo[values,"r03/mass_"<>k->RUCertificate[0,{RURecord["r03/quark_angular_bare",factor,angular]},{"beam_fqq","fragment_dqq"}]],
 {k,{"delta","D0","D1"}}];
AssociateTo[values,"r03/mass_regular"->RUCertificate[0,{}, {"beam_fqq","fragment_dqq"}]];
RUPut[<|"unreduced"->unreduced,"actual_reduction"->reduction,"reduced"->reduced,"ratio"->ratio,"master"->master,"angular_bare"->angular,"value_nodes"->values,
 "route_status"->"Physical nonzero quark moment pilot; not complete measured TMD/cone/HF sectors."|>,"real_coefficients.wl"];
RUPut[<|"identity"->HoldComplete[t^(-1-eps)==-DiracDelta[t]/eps+PlusDistribution[1/t]-eps PlusDistribution[Log[t]/t]+O[eps]^2],
 "interval"->{0,1},"test_space"->"Smooth f with f(t)-f(0)=O(t); analytic continuation from Re(eps)<0.",
 "derivation"->HoldComplete[Integrate[t^(-1-eps) f[t],{t,0,1}]==-f[0]/eps+Integrate[t^(-1-eps) (f[t]-f[0]),{t,0,1}]],
 "scale"->HoldComplete[Lmass==Log[mu^2/W]],"bare_coefficients"->values|>,"distributions.wl"];
RUPut[<|"allocation"->"Bare endpoint Laurent coefficients are preserved. Their finite Laurent parts are well-defined pilot coefficients, not renormalized beam/fragmenting-jet matching.",
 "finite_parts"->Map[Function[node,Coefficient[Expand[node["value"]/.RUExact[x_]:>x],eps,0]],values],
 "not_supplied_by_this_inclusive_pilot"->{"fixed-z TMD Fourier integration","rapidity/soft overlap","anti-kt z-dependent cone boundary","HF two-fraction operator cuts","collinear/UV subtraction into every measured operator"},
 "validation_probe"->$RUContext["validation_probe"],"no_poles_silently_removed"->True|>,"subtractions.wl"];
evidence=<|"r03/distributions"->RUEvidence["distributions.wl","distributions",{"source/r03","r02/measure","tool/r02/quark/masters.wl","tool/r02/quark/raw_results.wl","tool/r02/quark/subtropica_execution.json"}],
 "r03/subtractions"->RUEvidence["subtractions.wl","subtractions",{"r03/distributions"}],"r03/coefficients"->RUEvidence["real_coefficients.wl","real_coefficients",{"r03/subtractions","r01/integrands"}]|>;
measuredReduction=Get[FileNameJoin[{$RUContext["inputs"]["r01"],"jobs","measured","reduction_certificate.wl"}]];
measuredMasters=Get[FileNameJoin[{$RUContext["inputs"]["r02"],"jobs","measured","masters.wl"}]];
measuredRatio=Factor[(M[1,1,1]/.measuredReduction["rules"])/M[1,1,1]/.d->4-2eps];
RUGate["actual complete M map contracts without residual integrals",FreeQ[measuredRatio,_M]];
sphere=measuredMasters["FixedRadiusSphere"];
measuredSectors={"beam_fqq","beam_fqg","beam_hqq","fragment_dqq","fragment_dgq","fragment_collins","fragment_HF","recoil_soft","jet_UU","jet_UT"};
AssociateTo[values,"r03/measured_normalization"->RUCertificate[0,
 {RURecord["master/r02/measured/FixedRadiusSphere",measuredRatio,sphere]},measuredSectors,2]];
consumedSphere=values["r03/measured_normalization"]["value"]/.RUExact[x_]:>x;
tmdGenerated=Get[FileNameJoin[{$RUContext["inputs"]["r00"],"measured_tmd_operators.wl"}]];
softGenerated=Get[FileNameJoin[{$RUContext["inputs"]["r00"],"measured_soft_operators.wl"}]];
hfGenerated=Get[FileNameJoin[{$RUContext["inputs"]["r00"],"measured_hf_operators.wl"}]];
mappedIntegrands=Get[FileNameJoin[{$RUContext["inputs"]["r01"],"measured_integrands.wl"}]];
mappedNumerators=mappedIntegrands["sector_numerators"];
tmdGenerated=Join[tmdGenerated,<|"kernels"->KeyTake[mappedNumerators,Keys[tmdGenerated["kernels"]]]|>];
hfGenerated=Join[hfGenerated,<|"log_density_with_probe"->mappedNumerators["fragment_HF"]|>];
RUGate["mapped physical soft spin weights coincide",
 RUZero[mappedNumerators["recoil_soft"]-mappedNumerators["jet_UU"]]&&
 RUZero[mappedNumerators["jet_UU"]-mappedNumerators["jet_UT"]]];
softFactors=RUSoftFactors[]/.CF->mappedNumerators["recoil_soft"]/2;
softResult=RUSoftCoefficientAssembly[softFactors,"r03/measured_normalization",consumedSphere,softGenerated];
tmdResult=RUTMDCoefficientAssembly[tmdGenerated,softFactors,"r03/measured_normalization",consumedSphere];
hfResult=RUHFCoefficientAssembly[hfGenerated,"r03/measured_normalization",consumedSphere];
values=Join[values,softResult["values"],tmdResult["values"],hfResult["values"]];
RUPut[<|"actual_reduction"->measuredReduction,"scalar_target"->M[1,1,1],"contraction_ratio"->measuredRatio,
 "evaluated_sphere"->sphere,"consumed_sphere"->consumedSphere,
 "tmd"->tmdResult,"soft"->softResult,"HF"->hfResult,
 "probe"->$RUContext["validation_probe"]|>,"measured_coefficients.wl"];
RUPut[<|"tmd"->tmdResult["subtractions"],"soft_bare"->softResult["recoil_bare"],
 "soft_UV"->softResult["recoil_UV"],"HF"->hfResult["named_distributions"],
 "order"->"Physical endpoint action/common damping; eta before eps; explicit local collinear/UV subtraction. Probe poles remain diagnostic."|>,"measured_subtractions.wl"];
AssociateTo[evidence,{"r03/measured_coefficients"->RUEvidence["measured_coefficients.wl","real_coefficients",
 {"source/r03","r01/measured_integrands","r02/measured_measure","tool/r02/measured/masters.wl",
  "tool/r02/measured/raw_results.wl","tool/r02/measured/subtropica_execution.json"}],
 "r03/measured_subtractions"->RUEvidence["measured_subtractions.wl","subtractions",{"r03/measured_coefficients"}]}];
RUPut[<|"schema"->5,"stage"->"r03","values"->values,"evidence"->evidence,"jobs"->{},
 "integrated_values"->{"r03/quark_angular_bare","r03/measured_normalization"}|>,"packet.wl"];
Print["R03_BARE_QUARK_MOMENT_AND_MEASURED_SECTOR_COEFFICIENTS_COMPLETE"];
