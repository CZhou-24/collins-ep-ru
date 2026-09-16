(* Read actual native development exports for compact reporting. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
base=FileNameJoin[{root,"collins_support","reports","sidis-highpt-001"}];
If[StringQ[Environment["SIDIS_HIGHPT_REPORT_ROOT"]],base=Environment["SIDIS_HIGHPT_REPORT_ROOT"]];
target=FileNameJoin[{base,"diagnostic-summary.json"}];If[FileExistsQ[target],Print["Refuse output reuse"];Exit[1]];
inputHashes=<||>;
read[parts__]:=Module[{file=FileNameJoin[Join[{base},{parts}]],value},
 If[!FileExistsQ[file],Print["Missing current reproduction evidence: ",file];Exit[2]];
 AssociateTo[inputHashes,file->IntegerString[FileHash[file,"SHA256"],16,64]];
 value=Get[file];If[!AssociationQ[value],Print["Invalid native diagnostic association: ",file];Exit[2]];value];
text[x_]:=ToString[x,InputForm];
ndr=read["operator-scheme-002","ndr.wl"];bmhv=read["operator-scheme-002","bmhv.wl"];space=read["operator-scheme-002","spacelike.wl"];
op=<|"ndr_minus_literal_all_D"->Factor[ndr["averaged"]-2CF z/(1-z)],
 "ndr_minus_literal_through_eps1"->Normal[Series[(ndr["averaged"]-2CF z/(1-z))/.D->4-2eps,{eps,0,1}]],
 "outgoing_bmhv_minus_ndr"->Factor[bmhv["averaged"]-ndr["averaged"]],
 "outgoing_difference_epsilon_coefficient"->SeriesCoefficient[(bmhv["averaged"]-ndr["averaged"])/.D->4-2eps,{eps,0,1}],
 "spacelike_bmhv_minus_ndr"->Factor[space["BMHV"]-space["NDR"]]|>;
angular=read["angular-002","checks.wl"];fourier=read["fragmentation-001","checks.wl"];
partialFiles={FileNameJoin[{base,"real-distinct-assembly-001","distributions.wl"}],FileNameJoin[{base,"cut-master-depth-001","matched_masters.wl"}]};
partial=And@@(FileExistsQ/@partialFiles);
If[(AnyTrue[partialFiles,FileExistsQ]&&!partial)||(Environment["SIDIS_HIGHPT_PARTIAL_REAL"]==="1"&&!partial),
 Print["Incomplete current partial-real evidence"];Exit[2]];
If[Environment["SIDIS_HIGHPT_PARTIAL_REAL"]==="0"&&partial,Print["Unrequested partial-real evidence"];Exit[2]];
If[partial,dist=read["real-distinct-assembly-001","distributions.wl"];masters=read["cut-master-depth-001","matched_masters.wl"]];
hasAnti=FileExistsQ[FileNameJoin[{base,"antiquark-point-002","point.wl"}]];
If[hasAnti,anti=read["antiquark-point-002","point.wl"]];
Export[target,<|"report_root"->base,"partial_real_present"->partial,"antiquark_point_present"->hasAnti,
 "operator_differences"->Map[text,op],
 "operator_qualification"->"Diagnostic continuations: physical tagged-leg finite conversion is UNVERIFIED. The literal paper expression is not silently changed.",
 "angular_residuals"->(text/@angular["residuals"]),
 "fourier_residuals"->(text/@Lookup[fourier["gaussian_identity_checks"],"residual"]),
 "partial_real_endpoint_residuals"->If[partial,text/@Lookup[dist["endpoint_tests"],"residual"],{}],
 "partial_real_reconstruction"->If[partial,Map[text[#["ordinary_reconstruction_residual"]]&,dist["components"]],<||>],
 "partial_real_pole_coefficients"->If[partial,Map[text[Coefficient[Expand[#["Delta"]],eps,-1]]&,dist["components"]],<||>],
 "master_depth"->If[partial,Association[KeyValueMap[text[#1]->KeyTake[#2,{"class","coefficient_epsilon_minimum","coefficient_soft_minimum","required_through","available_class_through"}]&,masters["masters"]]],<||>],
 "antiquark_point_moment"->If[hasAnti,text[anti["collins_trace_moment"]],Null],
 "antiquark_point_qualification"->If[hasAnti,"Nc=3, physical D=4 point; common Q^2/y^2, symmetry, flux and phase factors unapplied. No full-dimensional coefficient.","NOT_RUN in this reproduction; no historical diagnostic was substituted."],
 "input_sha256"->inputHashes,
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64]|>,"RawJSON"];
Print["NATIVE_DIAGNOSTIC_SUMMARY_EXPORTED"];Exit[0];
