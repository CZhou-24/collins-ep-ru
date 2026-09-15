Get[FileNameJoin[{DirectoryName[$InputFileName],"ru_stage.wl"}]];
Get[FileNameJoin[{$RUProduction,"common","ru_physics_helpers.wl"}]];
LoadFC[];
$RUPrefix="born_";
StagePut[x_,name_]:=RUPut[x,$RUPrefix<>name];
Get[FileNameJoin[{$RUProduction,"common","ru_born_generation.wl"}]];
$RUPrefix="real_";
Get[FileNameJoin[{$RUProduction,"common","ru_real_generation.wl"}]];
(* Continue from the regenerated current into the fixed-fraction operators.
   These files contain generating source only; all integration is later. *)
Get[FileNameJoin[{$RUProduction,"common","ru_tmd_generation.wl"}]];
Get[FileNameJoin[{$RUProduction,"common","ru_soft_generation.wl"}]];
freshReal=Get[RUPath["real_real_amplitudes.wl"]];
measuredTMD=RUTMDGenerate[freshReal];
RUPut[measuredTMD,"measured_tmd_operators.wl"];
measuredSoft=RUSoftGenerate[measuredTMD];
RUPut[measuredSoft,"measured_soft_operators.wl"];
Get[FileNameJoin[{$RUProduction,"common","ru_hf_generate.wl"}]];
measuredHF=RUHFGenerate[$RUContext];
RUPut[measuredHF,"measured_hf_operators.wl"];
(* Adapted SIDIS s02: solve the Gram matrix from defining scalar products. *)
basis={parent,null,emitted};
gram=Table[scalar[Min[i,j],Max[i,j]],{i,3},{j,3}];
vector[v_]:=Coefficient[Expand[v],#]& /@ basis;
dot[v_,q_]:=Expand[vector[v].gram.vector[q]];
defining={dot[parent,parent]==w,dot[null,null]==0,dot[parent,null]==w/2,
 dot[emitted,emitted]==c1,dot[parent-emitted,parent-emitted]==c2,
 dot[emitted-null,emitted-null]==c3};
solution=Solve[defining,DeleteDuplicates[Flatten[gram]]];
RUGate["unique cut Gram solution",Length[solution]===1];
gram=Factor[gram/.First[solution]];
RUGate["cut definitions reconstruct",And@@(TrueQ[Simplify[#/.First[solution]]]& /@ defining)];
geometry=<|"basis"->basis,"gram"->gram,"defining_equations"->defining,"solution"->First[solution],
 "cuts"->{c1,c2},"on_cuts"->{c1->0,c2->0},"gluon_fraction"->-c3/w,
 "quark_fraction"->1+c3/w,"dimension"->4-2 eps|>;
RUPut[geometry,"definitions.wl"];
RUPut[<|"BornUU"->huu,"BornUT"->hut,"splitting"->rawSplitting,"spin_transfer_real"->transReal,
 "pilot_parent"->parent,"pilot_emitted_gluon"->emitted,
 "measurement"->HoldComplete[z==1-2 emitted.null/w],
 "physical_domain"->HoldComplete[w>0&&0<z<1],
 "jet_bound_not_dropped"->HoldComplete[w<z (1-z) pT^2 R^2],
 "scope"->"The first pilot integrates the quark energy-fraction density of a two-body collinear cut. Full fixed-z TMD, rapidity, cone and HF sectors require their own measurement mappings; no inclusive moment is relabelled as those coefficients."|>,"projectors_measurement.wl"];
convs=Import[FileNameJoin[{$RUProduction,"provenance","CONVENTIONS_PACKET.json"}],"RawJSON"];
RUPut[<|"declared_conventions"->convs,"TMD_definitions"->measuredTMD,
 "soft_measurement_definitions"->measuredSoft,"HF_operator_normalization"->measuredHF["operator"],
 "cut_prescription"->HoldComplete[deltaPositive[x,e]==Theta[e]((x-I i0)^(-1)-(x+I i0)^(-1))/(2Pi I)],
 "scope"->"Source-defined polarized conventions and freshly executed operator/projector conversions; integration follows in r01-r06."|>,"conventions_evidence.wl"];
convs=Map[Append[#,"evidence"->"r00/conventions"]&,convs];
evidence=<|"r00/definitions"->RUEvidence["definitions.wl","definitions",{"source/r00"}],
 "r00/born"->RUEvidence["born_amplitudes.wl","amplitudes",{"r00/definitions"}],
 "r00/real"->RUEvidence["real_real_amplitudes.wl","amplitudes",{"r00/born"}],
 "r00/projectors"->RUEvidence["projectors_measurement.wl","projectors",{"r00/real"}],
 "r00/measurement"->RUEvidence["projectors_measurement.wl","measurement",{"r00/projectors"}],
 "r00/measured_tmd"->RUEvidence["measured_tmd_operators.wl","projectors",{"r00/real","r00/projectors"}],
 "r00/measured_soft"->RUEvidence["measured_soft_operators.wl","measurement",{"r00/measured_tmd"}],
 "r00/measured_hf"->RUEvidence["measured_hf_operators.wl","projectors",{"r00/real","r00/measured_tmd"}],
 "r00/conventions"->RUEvidence["conventions_evidence.wl","definitions",{"r00/measured_hf","r00/measured_soft"}]|>;
values=<|"r00/BornUU"->RUCertificate[huu,{}, {"beam_fqq"}],"r00/BornUT"->RUCertificate[hut,{}, {"beam_hqq"}]|>;
RUPut[<|"schema"->5,"stage"->"r00","values"->values,"evidence"->evidence,"jobs"->{},"conventions"->convs|>,"packet.wl"];
Print["R00_FRESH_AMPLITUDES_COMPLETE"];
