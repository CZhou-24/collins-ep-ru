(* Full selected real-topology closure with all charge and spin projections.
   Neither archived numerator coefficients nor archived reductions replace the
   fresh Kira rules. Archived overlaps are checked only after fresh closure. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
mapdir=Environment["SIDIS_REAL_MAP"];work=Environment["SIDIS_REAL_KIRA"];out=Environment["SIDIS_REAL_CHECK_OUT"];
If[!And@@(StringQ/@{mapdir,work,out})||DirectoryQ[out],Print["Need map, Kira directory and unused output"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["REAL_REDUCTION_FAILED ",name];Exit[2]];
mapping=Get[FileNameJoin[{mapdir,"mapping.wl"}]];targets=mapping["targets"];
names=Sort[DeleteDuplicates[targets[[All,1]]]];heads=Symbol/@names;
toCut[x_]:=x/.(HoldPattern[head_[indices__Integer]]/;MemberQ[heads,head]):>CutIntegral[SymbolName[head],{indices}];
files=Sort[FileNames["kira_targets.m",FileNameJoin[{work,"results"}],Infinity]];
rules=toCut[DeleteDuplicates[Flatten[Get/@files]]]/.{q2->Q2,d->D};
closureFiles=Sort[FileNames["kira_closure_*.m",FileNameJoin[{work,"results"}],Infinity]];
closureRules=toCut[DeleteDuplicates[Flatten[Get/@closureFiles]]]/.{q2->Q2,d->D};
rules=Map[Function[rule,First[rule]->Factor[FixedPoint[(#/.closureRules)&,Last[rule],8]]],rules];
files=Join[files,closureFiles];
masterFile=FileNameJoin[{work,"tmp",Last[names],"masters"}];
explicitInventory=Environment["SIDIS_KIRA_MASTER_INVENTORY"];
If[StringQ[explicitInventory]&&StringLength[explicitInventory]>0,masterFile=explicitInventory];
declared=toCut[ToExpression/@StringCases[Import[masterFile,"Text"],RegularExpression["R[0-9]+\\[[0-9, -]+\\]"]]];
missing=Complement[targets,First/@rules];
unknown=Complement[DeleteDuplicates[Cases[Last/@rules,_CutIntegral,Infinity]],declared];
Put[<|"missing_target_rules"->missing,"undeclared_rhs_integrals"->unknown,"declared_masters"->declared|>,FileNameJoin[{out,"closure.wl"}]];
gate["every missing target is a declared master",Complement[missing,declared]==={}];
gate["all RHS integrals declared",unknown==={}];
rules=Join[rules,(#->#&/@missing)];gate["unique rules and all targets covered",DuplicateFreeQ[First/@rules]&&Complement[targets,First/@rules]==={}];
actualMasters=Union[missing,DeleteDuplicates[Cases[Last/@rules,_CutIntegral,Infinity]]];
gate["physical cuts retained in final masters",And@@(Take[#[[2]],2]==={1,1}&/@actualMasters)];
oldFile=FileNameJoin[{root,"SIDIS","common","s04_result","s04_result.wl"}];old=Get[oldFile];oldRules=old["Rules"];
covered=Intersection[targets,First/@oldRules];
comparison=Association[Table[ToString[target,InputForm]->Factor[Together[((target/.rules)/.oldRules)-(target/.oldRules)]],{target,covered}]];
Put[comparison,FileNameJoin[{out,"archive-comparison.wl"}]];
gate["covered reductions equal archived rules",And@@(#===0&/@Values[comparison])];
reductionValues=Association[rules];coefficients=<||>;reduced=<||>;
Do[Print["COLLECT_REAL ",component];
 coeffs=AssociationMap[Function[master,Factor[Together[Total[KeyValueMap[Function[{integral,c},c Coefficient[reductionValues[integral],master]],mapping["coefficients"][component]]]]]],actualMasters];
 value=Total[KeyValueMap[Times,coeffs]];
 AssociateTo[coefficients,component->coeffs];AssociateTo[reduced,component->value];
 Put[<|"component"->component,"coefficients"->coeffs,"reduced"->value|>,FileNameJoin[{out,component<>".wl"}]],{component,Keys[mapping["coefficients"]]}];
Put[<|"topology"->mapping["topology"],"fresh_rules"->rules,"targets"->targets,"fresh_final_masters"->actualMasters,
 "reduced_polarized_coefficients"->reduced,"master_coefficients"->coefficients,
 "tag_weight_unapplied"->mapping["tag_weight_unapplied"],"charge_weights"->mapping["charge_weights"],
 "archive_covered_target_residuals"->comparison,"archive_uncovered_targets"->Complement[targets,covered],
 "input_hashes"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,Join[{FileNameJoin[{mapdir,"mapping.wl"}],oldFile,masterFile},files]],
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "qualification"->"New polarized real topology reduction; cut master measure, endpoints and factorization remain required"|>,FileNameJoin[{out,"reduction.wl"}]];
Export[FileNameJoin[{out,"summary.json"}],<|"topology"->mapping["topology"],"targets"->Length[targets],"masters"->Length[actualMasters],
 "archive_comparisons"->Length[covered],"archive_uncovered"->Length[Complement[targets,covered]],"archive_residuals_zero"->And@@(#===0&/@Values[comparison]),
 "master_values_evaluated"->False|>,"RawJSON"];
Print["REAL_REDUCTION_COMPLETE ",Length[targets]," targets; ",Length[actualMasters]," masters"];Exit[0];
