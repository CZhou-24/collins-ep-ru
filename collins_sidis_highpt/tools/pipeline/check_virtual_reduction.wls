(* Check the actual fresh targets, independent of Kira's exit status.
   Archived rules are a regression comparison, not fresh master evaluation. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
mapdir=Environment["SIDIS_VIRTUAL_MAP"];work=Environment["SIDIS_VIRTUAL_KIRA"];out=Environment["SIDIS_VIRTUAL_CHECK_OUT"];
If[!And@@(StringQ/@{mapdir,work,out})||DirectoryQ[out],Print["Need map, Kira directory and unused output"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["VIRTUAL_REDUCTION_FAILED ",name];Exit[2]];
mapping=Get[FileNameJoin[{mapdir,"mapping.wl"}]];targets=mapping["targets"];
names=Sort[DeleteDuplicates[targets[[All,1]]]];heads=Symbol/@names;
toGLI[x_]:=x/.(HoldPattern[head_[indices__Integer]]/;MemberQ[heads,head]):>GLI[SymbolName[head],{indices}];
files=Sort[FileNames["kira_targets.m",FileNameJoin[{work,"results"}],Infinity]];
rules=toGLI[DeleteDuplicates[Flatten[Get/@files]]]/.{q2->Q2,d->D};
closureFiles=Sort[FileNames["kira_closure_*.m",FileNameJoin[{work,"results"}],Infinity]];
closureRules=toGLI[DeleteDuplicates[Flatten[Get/@closureFiles]]]/.{q2->Q2,d->D};
rules=Map[Function[rule,First[rule]->Factor[FixedPoint[(#/.closureRules)&,Last[rule],8]]],rules];
files=Join[files,closureFiles];
masterFile=FileNameJoin[{work,"tmp",Last[names],"masters"}];
declared=toGLI[ToExpression/@StringCases[Import[masterFile,"Text"],RegularExpression["V[0-9]+\\[[0-9, -]+\\]"]]];
missing=Complement[targets,First/@rules];
unknown=Complement[DeleteDuplicates[Cases[Last/@rules,_GLI,Infinity]],declared];
Put[<|"target_count"->Length[targets],"rule_count"->Length[rules],"missing_target_rules"->missing,
 "undeclared_rhs_integrals"->unknown,"declared_masters"->declared|>,FileNameJoin[{out,"closure.wl"}]];
gate["every missing target is a declared master",Complement[missing,declared]==={}];
gate["all RHS integrals declared",unknown==={}];
rules=Join[rules,(#->#&/@missing)];gate["unique rules and all targets covered",DuplicateFreeQ[First/@rules]&&Complement[targets,First/@rules]==={}];
actualMasters=Union[missing,DeleteDuplicates[Cases[Last/@rules,_GLI,Infinity]]];
gate["rules fully reduced to masters",And@@(MemberQ[actualMasters,#]&/@Cases[(Last/@rules)/.rules,_GLI,Infinity])];
oldFile=FileNameJoin[{root,"SIDIS","common","s09_result","s09_result.wl"}];old=Get[oldFile];oldRules=old["Rules"];
covered=Intersection[targets,First/@oldRules];
comparison=Association[Table[ToString[target,InputForm]->Factor[Together[((target/.rules)/.oldRules)-(target/.oldRules)]],{target,covered}]];
Put[comparison,FileNameJoin[{out,"archive-comparison.wl"}]];
gate["covered reductions equal archived rules",And@@(#===0&/@Values[comparison])];
invariantMap={Q2->Q^2,s->Q^2 r,t->-Q^2(1+r)(1-z)};
(* Only scalar reduction coefficients are transformed; integral labels are fixed. *)
reductionValues=Association[Map[Function[rule,First[rule]->(Last[rule]/.invariantMap)],rules]];
groups=GroupBy[Values[mapping["rows"]],#["component"]&];
reduced=<||>;masterCoefficients=<||>;ward=<||>;
Do[Print["COLLECT_VIRTUAL ",component];
 coeffs=AssociationMap[Function[master,Factor[Together[Total[Map[Function[row,
  Total[KeyValueMap[Function[{integral,c},c Coefficient[reductionValues[integral],master]],row["canonical_coefficients"]]]],groups[component]]]]]],actualMasters];
 value=Total[KeyValueMap[Times,coeffs]];
 AssociateTo[reduced,component->value];AssociateTo[masterCoefficients,component->coeffs];
 If[StringContainsQ[component,"_W"],AssociateTo[ward,component->coeffs]];
 Put[<|"component"->component,"coefficients"->coeffs,"reduced"->value|>,FileNameJoin[{out,component<>".wl"}]],{component,Keys[groups]}];
wardResiduals=Flatten[Values/@Values[ward]];
Put[<|"fresh_rules"->rules,"targets"->targets,"fresh_final_masters"->actualMasters,
 "reduced_polarized_coefficients"->reduced,"master_coefficients"->masterCoefficients,"ward_residuals"->ward,
 "archive_covered_target_residuals"->comparison,"archive_uncovered_targets"->Complement[targets,covered],
 "archive_path"->oldFile,"input_hashes"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,Join[{FileNameJoin[{mapdir,"mapping.wl"}],oldFile,masterFile},files]],
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "qualification"->"Fresh polarized virtual numerator reduction before master measure, Hermitian conjugation, UV subtraction and factorization"|>,FileNameJoin[{out,"reduction.wl"}]];
Export[FileNameJoin[{out,"summary.json"}],<|"target_count"->Length[targets],"master_count"->Length[actualMasters],
 "archive_comparisons"->Length[covered],"archive_uncovered"->Length[Complement[targets,covered]],
 "archive_residuals_zero"->And@@(#===0&/@Values[comparison]),"ward_residuals_zero"->And@@(#===0&/@wardResiduals),
 "master_values_evaluated"->False|>,"RawJSON"];
gate["photon Ward identity after integration, per master",And@@(#===0&/@wardResiduals)];
Print["VIRTUAL_REDUCTION_COMPLETE ",Length[targets]," targets; ",Length[actualMasters]," masters"];Exit[0];
