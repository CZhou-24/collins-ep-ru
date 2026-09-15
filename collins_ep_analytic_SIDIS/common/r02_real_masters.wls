Get[FileNameJoin[{DirectoryName[$InputFileName],"ru_stage.wl"}]];
Get[FileNameJoin[{$RUProduction,"common","ru_cut_helpers.wl"}]];
Get[FileNameJoin[{$RUProduction,"common","ru_measured_helpers.wl"}]];
reduction=Get[FileNameJoin[{$RUContext["inputs"]["r01"],"jobs","quark","reduction_certificate.wl"}]];
RUGate["actual cut master is the supported positive-energy volume",Sort[reduction["masters"]]===Sort[{R1[1,1,0]}]];
RUPut[reduction,"actual_reduction.wl"];
geometry=RUCutGeometry[];
(* Derive the unnormalized cut volume. Remove w^-eps by dimensional homogeneity.
   The explicit normalization below defines this pilot's MSbar scalar master;
   the physical measure is retained separately, not asserted to be a full TMD. *)
normalization=2 Pi^(-1+eps) Exp[EulerGamma eps];
prefactor=FullSimplify[(geometry["radial"] geometry["sphere"]/.w->1) normalization,Element[eps,Reals]];
dir=RUPath["jobs/quark"];CreateDirectory[dir,CreateIntermediateDirectories->True];
input=<|"CutVolume"-><|"order"->2,"terms"->{<|"tuple"->geometry["tuple"],"prefactor"->prefactor,"order"->2,"assumptions"->Element[eps,Reals]&&eps<0|>}|>|>;
Put[input,FileNameJoin[{dir,"euler_inputs.wl"}]];
RUPut[<|"geometry"->geometry,"Euler_input"->input,"actual_reduction"->reduction,"scale"->w^(-eps),
 "normalization"->normalization,"physical_measure"->HoldComplete[d^D r deltaPositive[r^2] deltaPositive[(p-r)^2]],
 "phase_space_2pi_factor"->(2 Pi)^(2-(4-2 eps)),"epsilon_depth"->2,"depth_reason"->"The reduced angular coefficient has one pole and the invariant-mass delta has one additional pole. The regular normalized master through eps^2 and angular coefficient through eps^1 therefore suffice for every finite pilot coefficient. No earlier master value is imported."|>,"cut_measure.wl"];
parents={"source/r02","tool/r01/quark/results/R1/kira_targets.m","tool/r01/quark/tmp/R1/masters","tool/r01/quark/reduction_certificate.wl","tool/r01/quark/reduction_audit.json"};
evidence=<|"r02/euler"->RUEvidence["jobs/quark/euler_inputs.wl","euler_inputs",parents],"r02/measure"->RUEvidence["cut_measure.wl","cut_measure",{"r02/euler"}]|>;
job=<|"id"->"quark","inputs"->{"euler_inputs.wl"},"outputs"->{"masters.wl","raw_results.wl","subtropica_execution.json"},"families"->{"R1"},"sectors"->{"beam_fqq","fragment_dqq"}|>;
measuredReduction=Get[FileNameJoin[{$RUContext["inputs"]["r01"],"jobs","measured","reduction_certificate.wl"}]];
RUGate["actual measured cut master inventory",measuredReduction["masters"]==={M[1,1,1]}];
measuredInput=RUMeasuredEulerInput[];
CreateDirectory[RUPath["jobs/measured"],CreateIntermediateDirectories->True];
RUPut[measuredInput,"jobs/measured/euler_inputs.wl"];
RUPut[<|"actual_reduction"->measuredReduction,"geometry"->RUMeasuredGeometry[],
 "Euler_input"->measuredInput,"all_fractions_retained"->{u,v,z},
 "order_reason"->"Fixed-radius sphere through eps^2: sufficient for measured endpoint/soft double poles. No old radial master or coefficient enters."|>,"measured_cut_measure.wl"];
AssociateTo[evidence,{"r02/measured_euler"->RUEvidence["jobs/measured/euler_inputs.wl","euler_inputs",
 {"source/r02","tool/r01/measured/results/M/kira_targets.m","tool/r01/measured/tmp/M/masters",
  "tool/r01/measured/reduction_certificate.wl","tool/r01/measured/reduction_audit.json"}],
 "r02/measured_measure"->RUEvidence["measured_cut_measure.wl","cut_measure",{"r02/measured_euler"}]}];
measuredJob=<|"id"->"measured","inputs"->{"euler_inputs.wl"},"outputs"->{"masters.wl","raw_results.wl","subtropica_execution.json"},"families"->{"M"},
 "sectors"->{"beam_fqq","beam_fqg","beam_hqq","fragment_dqq","fragment_dgq","fragment_collins","fragment_HF","recoil_soft","jet_UU","jet_UT"}|>;
RUPut[<|"schema"->5,"stage"->"r02","values"-><||>,"evidence"->evidence,"jobs"->{job,measuredJob}|>,"packet.wl"];
Print["R02_UNEVALUATED_POSITIVE_ENERGY_EULER_INPUT_READY"];
