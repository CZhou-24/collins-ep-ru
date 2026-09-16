(* Packet for actual contraction/mapping or reduction/master-definition stages.
   Native tool execution and receipts remain owned by the installed validator. *)
$HistoryLength=0;ctx=Import[Environment["SIDIS_HIGHPT_CONTEXT"],"RawJSON"];
engine=ctx["production"];root=DirectoryName[engine];out=ctx["output"];sid=ctx["stage"];
Get[FileNameJoin[{root,"collins_support","validators","analytic","native_io.wl"}]];
values=<||>;evidence=<||>;jobs={};familyRows={};
putval[key_,value_,sectors_:{"Hqq"}]:=AssociateTo[values,sid<>"/"<>key->
 <|"constant"->RUExact[value],"terms"->{},"value"->RUExact[value],"eta_order"->0,"eps_order"->0,"sectors"->sectors|>];
ev[key_,file_,role_,parents_]:=AssociateTo[evidence,sid<>"/"<>key-><|"path"->file,"role"->role,"parents"->parents|>];
topologies={"RealQGG","RealSame","RealDistinct","Hqqbar"};
gate[name_,condition_]:=If[!TrueQ[condition],Print["NATIVE_PACKET_FAILED ",name];Exit[2]];
If[sid==="r01",
 geometry=Get[ctx["saved_inputs"]["real_geometry"]["resolved"]];
 Put[<|"geometry"->geometry,"support"->HoldComplete[Q2>0&&s>w>0&&-Q2-s+w<t< -Q2 w/s],
  "physical_cuts"->geometry["CutEnergyConditions"],"tagged_particle"->k1|>,FileNameJoin[{out,"support.wl"}]];
 ev["support","support.wl","support",{"source/r01","r00/definitions","input/real_geometry"}];
 maps=AssociationMap[Get[FileNameJoin[{out,#<>"-map","mapping.wl"}]]&,topologies];
 Do[amplitudeID=If[topology==="Hqqbar","Hqqbar_amplitudes","Hqq_amplitudes"];
  If[topology==="RealQGG",
   qggInput=FileNameJoin[{ctx["inputs"]["r00"],"RealQGG-templates","templates.wl"}];
   qggProjection=FileNameJoin[{ctx["inputs"]["r00"],"RealQGG-projected","projection.wl"}];
   Put[<|"fresh_input_stage"->"r00","templates"->qggInput,"projection"->qggProjection,
    "input_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,{qggInput,qggProjection}],
    "qualification"->"Input binding to this same physical run's fresh qgg preparation; no archived or cached tensor is substituted."|>,
    FileNameJoin[{out,"RealQGG-template-input.wl"}]];
   ev["RealQGGTemplates","RealQGG-template-input.wl","integrands",{"source/r01","r00/preparationDriver"}],
   ev[topology<>"Templates",topology<>"-templates/templates.wl","integrands",{"source/r01","r00/tensor","input/"<>amplitudeID}]];
  ev[topology<>"Map",topology<>"-map/mapping.wl","cut_mapping",{"r01/"<>topology<>"Templates","r01/support"}];
  sectors={If[topology==="Hqqbar","Hqqbar","Hqq"]};
  KeyValueMap[putval[topology<>"Ward"<>#1,#2,sectors]&,maps[topology]["ward_residuals"]];
  KeyValueMap[putval[#1<>"Reconstruction",#2,sectors]&,maps[topology]["reconstruction_residuals"]],{topology,topologies}];
 ward=Get[FileNameJoin[{out,"qgg-gluon-ward","ward.wl"}]];
 ev["qggGluonWard","qgg-gluon-ward/ward.wl","integrands",{"r01/RealQGGTemplates"}];
 (* Full open-amplitude expressions remain native evidence; each calculated
    scalar zero is transported after the complete Clifford/color cancellation. *)
 KeyValueMap[putval["qggGluonWard"<>#1,#2]&,ward["residuals"]];
 targets=Union@@(#["targets"]&/@Values[maps]);
 Do[data=geometry["Families"][family];ds=data["Propagators"];
  rows=Select[targets,#[[1]]===family&];
  AppendTo[familyRows,<|"id"->family,"denominators"->(RUExact/@ds),"cuts"->(data["CutPositions"]-1),
   "positive_energy"->True,"support_artifact"->"support.wl",
   "targets"->Table[<|"powers"->target[[2]],"numerator"->RUExact[1],
    "integrand"->RUExact[Times@@MapThread[Power,{ds,-target[[2]]}]]|>,{target,rows}]|>],
  {family,Sort[DeleteDuplicates[targets[[All,1]]]]}];
 jobs=Import[FileNameJoin[{out,"jobs.json"}],"RawJSON"]
];
If[sid==="r04",
 mapping=Get[FileNameJoin[{out,"map","mapping.wl"}]];
 geometry=Get[ctx["saved_inputs"]["virtual_geometry"]["resolved"]];
 basis={p,q,k1,ell};gram={{0,(Q2+s)/2,(Q2+s+t)/2,loopP},
  {(Q2+s)/2,-Q2,-(Q2+t)/2,loopQ},{(Q2+s+t)/2,-(Q2+t)/2,0,loopK},{loopP,loopQ,loopK,loop2}};
 coords[x_]:=Coefficient[Expand[x],#]&/@basis;
 ev["templates","templates/templates.wl","integrands",{"source/r04","r00/tensor","input/Hqq_amplitudes"}];
 ev["mapping","map/mapping.wl","loop_mapping",{"r04/templates","input/virtual_geometry","input/virtual_topologies"}];
 KeyValueMap[putval["reconstruction"<>#1,#2["reconstruction_residual"]]&,mapping["rows"]];
 targets=mapping["targets"];
 Do[data=geometry["Families"][family];ds=MapThread[Factor[coords[#1].gram.coords[#1]-#2]&,
   {data["PropagatorMomenta"],data["PropagatorMassesSquared"]}];
  rows=Select[targets,#[[1]]===family&];
  AppendTo[familyRows,<|"id"->family,"denominators"->(RUExact/@ds),"cuts"->{},
   "targets"->Table[<|"powers"->target[[2]],"numerator"->RUExact[1],
    "integrand"->RUExact[Times@@MapThread[Power,{ds,-target[[2]]}]]|>,{target,rows}]|>],
  {family,Sort[DeleteDuplicates[targets[[All,1]]]]}];
 jobs=Import[FileNameJoin[{out,"jobs.json"}],"RawJSON"]
];
If[sid==="r02",
 portable=Get[ctx["saved_inputs"]["portable_real_masters"]["resolved"]];
 Do[reduction=Get[FileNameJoin[{out,topology<>"-reduction","reduction.wl"}]];
  gate["actual real masters in selected bank",And@@(KeyExistsQ[portable["series"],#[[1]]<>"_"<>StringRiffle[ToString/@#[[2]],"_"]<>"_ordinary"]&/@reduction["fresh_final_masters"])];
  ev[topology<>"Reduction",topology<>"-reduction/reduction.wl","master_inputs",
   {"source/r02","r01/"<>topology<>"Map","tool/r01/real/reduction_certificate.wl","input/portable_real_masters"}];
  index=1;KeyValueMap[putval[topology<>"Archive"<>ToString[index++],#2,{If[topology==="Hqqbar","Hqqbar","Hqq"]}]&,
   reduction["archive_covered_target_residuals"]],{topology,topologies}];
 Put[<|"selected_master_series"->portable["series"],"branch_views"->portable["branch_views"],
  "reconstruction_residuals"->portable["reconstruction_residuals"],"measure"->portable["measure"]|>,FileNameJoin[{out,"master-definitions.wl"}]];
 ev["definitions","master-definitions.wl","master_inputs",Join[{"source/r02","input/portable_real_masters","input/real_master_basis"},("r02/"<>#<>"Reduction"&/@topologies)]]
];
If[sid==="r05",
 reduction=Get[FileNameJoin[{out,"reduction","reduction.wl"}]];
 portable=Get[ctx["saved_inputs"]["portable_virtual_masters"]["resolved"]];
 gate["actual virtual masters in selected bank",And@@(KeyExistsQ[portable["masters"],#[[1]]<>"_"<>StringRiffle[ToString/@#[[2]],"_"]]&/@reduction["fresh_final_masters"])];
 ev["reduction","reduction/reduction.wl","master_inputs",{"source/r05","r04/mapping","tool/r04/virtual/reduction_certificate.wl","input/portable_virtual_masters"}];
 Put[<|"masters"->portable["masters"],"branch_records"->portable["branch_records"],
  "reconstruction_residuals"->portable["reconstruction_residuals"]|>,FileNameJoin[{out,"master-continuation.wl"}]];
 ev["continuation","master-continuation.wl","continuation",{"r05/reduction","input/portable_virtual_masters","input/virtual_master_basis"}];
 index=1;KeyValueMap[putval["archive"<>ToString[index++],#2]&,reduction["archive_covered_target_residuals"]]
];
If[sid==="r03",
 Do[linear=Get[FileNameJoin[{out,topology<>"-linear","certificates.wl"}]];
  shared=Intersection[Keys[values],Keys[linear["values"]]];
  gate["shared real normalization certificates are identical",And@@(values[#]===linear["values"][#]&/@shared)];
  values=Join[values,linear["values"]];
  ev[topology<>"Distributions",topology<>"-linear/certificates.wl","distributions",
   {"source/r03","r02/"<>topology<>"Reduction","r02/definitions","tool/r02/cut/masters.wl"}],{topology,topologies}];
 ev["realCoefficients","RealQGG-linear/certificates.wl","real_coefficients",("r03/"<>#<>"Distributions"&/@topologies)];
 ev["outgoingCollinear","outgoing-collinear/comparison.wl","subtractions",{"source/r03","r01/RealQGGTemplates","r00/tensor"}];
 ev["incomingCollinear","incoming-collinear/comparison.wl","subtractions",{"source/r03","r01/RealQGGTemplates","r00/tensor"}];
 ev["taggedOperator","tagged-operator/embedding.wl","subtractions",{"source/r03"}];
 ev["virtualOperator","virtual-operator/operator-virtual.wl","subtractions",{"source/r03"}];
 ev["scheme","scheme-match/scheme.wl","subtractions",{"r03/outgoingCollinear","r03/incomingCollinear","r03/taggedOperator","r03/virtualOperator"}];
 ev["subtractions","subtractions/subtractions.wl","subtractions",{"r03/scheme","r00/tensor"}];
 outgoing=Get[FileNameJoin[{out,"outgoing-collinear","comparison.wl"}]];
 incoming=Get[FileNameJoin[{out,"incoming-collinear","comparison.wl"}]];
 KeyValueMap[putval["outgoingCollinear"<>#1,#2["physical_daughter_residual"]]&,outgoing["checks"]];
 KeyValueMap[Function[{component,row},putval["incomingCollinear"<>component,row["operator_match_residual"]];
  KeyValueMap[putval["incomingStronger"<>component<>StringReplace[#1,"-"->"m"],#2]&,
   KeyDrop[row["summed_poles"],"-2"]]],incoming["checks"]];
 subtraction=Get[FileNameJoin[{out,"subtractions","subtractions.wl"}]];
 Do[expression=subtraction["MS_counterterms"][component][side][dist]/.t->sign omega-s;
  Do[putval["CT_"<>component<>"_"<>side<>"_"<>If[sign===1,"plus","minus"]<>"_"<>dist<>"_"<>If[n<0,"m"<>ToString[-n],"p"<>ToString[n]],
    Coefficient[Expand[expression],eps,n]],{n,{-1,0}}],
  {component,Keys[subtraction["MS_counterterms"]]},{side,{"PDF","FF"}},{sign,{1,-1}},{dist,{"Delta","L0","Regular"}}]
];
If[sid==="r06",
 Do[linear=Get[FileNameJoin[{out,"linear-"<>label,"certificates.wl"}]];
  shared=Intersection[Keys[values],Keys[linear["values"]]];
  gate["shared virtual normalization certificates are identical",And@@(values[#]===linear["values"][#]&/@shared)];
  values=Join[values,linear["values"]];
  (* Export the actual saved comparisons, including nonzero probe responses.
     The existing validator enforces zero for nominal runs, not this producer. *)
  comparisonKeys=Flatten[Table[component<>"_"<>power<>If[label==="generic","","_"<>label],
    {component,{"11_LL","11_XX","11_YY","22_LL","22_XX","22_YY"}},{power,{"m2","m1","p0"}}]];
  gate["complete virtual comparison inventory",
    AssociationQ[linear["comparison_residuals"]]&&Sort[Keys[linear["comparison_residuals"]]]===Sort[comparisonKeys]];
  KeyValueMap[putval["virtualComparison_"<>label<>"_"<>#1,#2]&,linear["comparison_residuals"]];
  ev["linear"<>label,"linear-"<>label<>"/certificates.wl","virtual_coefficients",
   {"source/r06","r05/reduction","r05/continuation","tool/r05/virtual/masters.wl","r06/UV"}],{label,{"generic","plus","minus"}}];
 ev["UV","uv/uv.wl","uv_subtraction",{"source/r06","r04/mapping","r00/tensor"}];
 ev["directSeries","direct-virtual/virtual.wl","virtual_coefficients",{"r06/UV","r05/reduction","r05/continuation"}];
 uvRecord=Get[FileNameJoin[{out,"uv","uv.wl"}]];
 KeyValueMap[putval["UV_"<>#1,#2["UV_cancellation_residual"]]&,uvRecord["components"]]
];
gate["this emitter implements the requested stage",MemberQ[{"r01","r02","r03","r04","r05","r06"},sid]];
ev["driver","native-driver.json",Switch[sid,"r02"|"r05","master_inputs","r03","real_coefficients","r06","virtual_coefficients",_,"integrands"],{"source/"<>sid}];
packet=<|"schema"->5,"stage"->sid,"values"->values,"evidence"->evidence,"jobs"->jobs|>;
If[MemberQ[{"r01","r04"},sid],AssociateTo[packet,"families"->familyRows]];
Put[packet,FileNameJoin[{out,"packet.wl"}]];
Print["NATIVE_MAPPING_PACKET_COMPLETE ",sid];Exit[0];
