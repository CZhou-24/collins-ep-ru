(* Summarize executed hard-coefficient checks without rerunning a derivation. *)
$HistoryLength=0;hqqFile=Environment["SIDIS_HQQ_ASSEMBLY_INPUT"];barFile=Environment["SIDIS_HQQBAR_ASSEMBLY_INPUT"];
out=Environment["SIDIS_HARD_SUMMARY_OUT"];
If[!StringQ[out]||DirectoryQ[out]||!And@@(FileExistsQ/@{hqqFile,barFile}),Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];hqq=Get[hqqFile];bar=Get[barFile];rows={};
KeyValueMap[Function[{component,record},Do[poles=record["poles"][dist];scales=record["scale_residuals"][dist];
 AppendTo[rows,<|"channel"->"Hqq","component_branch"->component,"distribution"->dist,
  "pole_residuals"->Association[KeyValueMap[ToString[#1]->ToString[#2,InputForm]&,poles]],
  "pole_count"->Length[poles],"all_poles_zero"->And@@(#===0&/@Values[poles]),
  "scale_residuals"->Map[ToString[#,InputForm]&,scales],"all_scales_zero"->And@@(#===0&/@Values[scales]),
  "finite_expression_sha256"->IntegerString[Hash[ToString[record["finite_candidate"][dist],InputForm],"SHA256"],16,64]|>],
 {dist,{"Delta","L0","L1","Regular"}}]],hqq["Hqq"]];
barChecks=Association[KeyValueMap[#1-><|"pole_count"->Length[#2["poles"]],
 "all_poles_zero"->And@@(#===0&/@Values[#2["poles"]]),"scale_zero"->(#2["scale_residual"]===0)|>&,bar["Hqqbar"]]];
summary=<|"scope"->"Executed finite hard assembly on the two open branches; common boundary and full measured observable are separate",
 "Hqq_rows"->rows,"Hqq_distribution_coefficients"->Length[rows],"Hqq_pole_coefficients_checked"->Total[Lookup[rows,"pole_count"]],
 "Hqq_scale_checks"->Total[Length/@Lookup[rows,"scale_residuals"]],
 "Hqqbar"->barChecks,"Hqqbar_endpoint_checks"->Length[bar["endpoint_residuals"]],
 "Hqqbar_all_endpoint_residuals_zero"->And@@(#===0&/@Values[bar["endpoint_residuals"]]),
 "input_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,{hqqFile,barFile,$InputFileName}],
 "full_native_campaign"->"NOT_RUN","independent_physics_review"->"PENDING"|>;
Export[FileNameJoin[{out,"summary.json"}],summary,"RawJSON"];
Print["HARD_CHECK_SUMMARY_COMPLETE"];Exit[0];
