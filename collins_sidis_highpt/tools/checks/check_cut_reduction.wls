(* Verify fresh partial-sector Kira closure and compare covered targets with
   the archived scalar reduction. Imported reduction equality is not a new
   master evaluation. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
base=FileNameJoin[{root,"collins_support","reports","sidis-highpt-001"}];If[StringQ[Environment["SIDIS_HIGHPT_REPORT_ROOT"]],base=Environment["SIDIS_HIGHPT_REPORT_ROOT"]];
out=FileNameJoin[{base,"real-kira-check-001"}];If[DirectoryQ[out],Print["Refuse output reuse"];Exit[1]];CreateDirectory[out];
mapping=Get[FileNameJoin[{base,"real-map-001","mapping.wl"}]];
work=FileNameJoin[{base,"real-kira-001"}];
names=Sort[DeleteDuplicates[mapping["targets"][[All,1]]]];heads=Symbol/@names;
toCut[x_]:=x/.(HoldPattern[h_[indices__Integer]]/;MemberQ[heads,h]):>CutIntegral[SymbolName[h],{indices}];
files=Sort[FileNames["kira_targets.m",FileNameJoin[{work,"results"}],Infinity]];
rules=toCut[DeleteDuplicates[Flatten[Get/@files]]]/.{q2->Q2,d->D};
masterFile=FileNameJoin[{work,"tmp",Last[names],"masters"}];
masters=toCut[ToExpression/@StringCases[Import[masterFile,"Text"],RegularExpression["R[0-9]+\\[[0-9, -]+\\]"]]];
targets=mapping["targets"];missing=Complement[targets,First/@rules];
gate[name_,condition_]:=If[!TrueQ[condition],Print["CUT_REDUCTION_FAILURE ",name];Exit[2]];
gate["missing targets are declared masters",Complement[missing,masters]==={}];
rules=Join[rules,(#->#&/@missing)];
gate["all targets covered",Complement[targets,First/@rules]==={}];
gate["unique reduction rules",DuplicateFreeQ[First/@rules]];
gate["native final master closure",Complement[DeleteDuplicates[Cases[Last/@rules,_CutIntegral,Infinity]],masters]==={}];
gate["positive-energy cuts retained",And@@(Take[#[[2]],2]==={1,1}&/@masters)];
reduced=Map[Function[rows,Factor[Total[KeyValueMap[Function[{target,c},c(target/.rules)],rows]]]],mapping["coefficients"]];
oldFile=FileNameJoin[{root,"SIDIS","common","s04_result","s04_result.wl"}];old=Get[oldFile];
oldRules=old["Rules"];covered=Intersection[targets,First/@oldRules];
comparison=Association[Table[ToString[target,InputForm]->Factor[Together[((target/.rules)/.oldRules)-(target/.oldRules)]],{target,covered}]];
gate["covered target equality with archived reduction",And@@(#===0&/@Values[comparison])];
Put[<|"fresh_rules"->rules,"fresh_final_masters"->masters,"targets"->targets,"reduced_polarized_coefficients"->reduced,
 "archived_reduction_path"->oldFile,"archived_reduction_sha256"->IntegerString[FileHash[oldFile,"SHA256"],16,64],
 "archive_covered_target_residuals"->comparison,"archive_uncovered_targets"->Complement[targets,covered],
 "fresh_rule_hashes"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,files],
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "qualification"->"Partial RealDistinct Y,Yprime; all geometry/support and scheme qualifications still apply. No finite NLO assembly."|>,FileNameJoin[{out,"reduction.wl"}]];
Export[FileNameJoin[{out,"summary.json"}],<|"target_count"->Length[targets],"final_master_count"->Length[masters],
 "covered_archive_targets"->Length[covered],"uncovered_archive_targets"->Length[Complement[targets,covered]],
 "archive_difference_residuals"->(ToString[#,InputForm]&/@comparison),"masters"->(ToString[#,InputForm]&/@masters),
 "scope"->"partial real-sector development only","master_values_evaluated"->False|>,"RawJSON"];
Print["PARTIAL_KIRA_CLOSURE_PASS ",Length[targets]," targets, ",Length[masters]," final masters; archived comparisons ",Length[covered]];Exit[0];
