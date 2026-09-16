(* Derive Laurent certificates from the actual reduced one-loop coefficients.
   Portable archived master values retain their explicit real/imaginary branch
   selection. This script performs no new integral evaluation. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
input=Environment["SIDIS_VIRTUAL_ASSEMBLY_INPUT"];portableFile=Environment["SIDIS_VIRTUAL_PORTABLE_INPUT"];
out=Environment["SIDIS_VIRTUAL_LINEAR_OUT"];
If[!StringQ[out]||DirectoryQ[out]||!And@@(StringQ[#]&&FileExistsQ[#]&/@{input,portableFile}),Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,condition_]:=If[!TrueQ[condition],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["VIRTUAL_LINEAR_FAILED ",name];Exit[2]];
helpers=FileNameJoin[{root,"collins_sidis_highpt","common",#}]&/@{"rational_laurent.wl","native_linear.wl","transcendental_basis.wl","native_compact_basis_linear.wl"};Get/@helpers;
Get[FileNameJoin[{root,"collins_support","validators","analytic","native_io.wl"}]];
record=Get[input];portable=Get[portableFile];
evaluatedFile=Environment["SIDIS_EVALUATED_VIRTUAL_MASTERS"];
compareDirect=Environment["SIDIS_LINEAR_CHECK_COMPARISON"]=!="false";
branchText=Environment["SIDIS_VIRTUAL_BRANCH"];
branch=If[MemberQ[{"1","-1"},branchText],ToExpression[branchText],0];
branchSuffix=Switch[branch,1,"_plus",-1,"_minus",_,""];
coordinateRules=Join[{mu->muR},If[branch===0,{}, {t->branch omega-s}]];
uvFile=FileNameJoin[{root,"SIDIS","common","s14_result","s14_result.wl"}];uv=Get[uvFile];
basisFile=Environment["SIDIS_MASTER_BASIS_INPUT"];useBasis=StringQ[basisFile]&&StringLength[basisFile]>0;
If[useBasis,basisBank=Get[basisFile]];basisRecords=<||>;
evaluated=If[StringQ[evaluatedFile]&&StringLength[evaluatedFile]>0,Get[evaluatedFile],portable["values"]];
If[useBasis,
 basisKnown=Association[KeyValueMap[("master/r05/virtual/"<>#1)->#2&,evaluated]];
 reconstructed=HSBasisOriginal[basisBank,evaluated];
 (* Unselected saved entries occur only with identically zero weights. Every
    nonzero recipe factor is required to rebind to an imported basis selector. *)
 evaluated=Join[portable["values"],reconstructed]];
known=Association[KeyValueMap[("master/r05/virtual/"<>#1)->#2&,evaluated]];
recipes=<||>;certificates=<||>;residuals=<||>;physical=(record["physical_conditions"]/.coordinateRules)&&If[branch===0,True,omega>0];
reduce[value_]:=Module[{v=Refine[value,physical],atoms},
 atoms=DeleteDuplicates[Cases[v,_Log|_PolyLog,Infinity]];Collect[Expand[v],atoms,Factor]];
suffix[power_]:=If[power<0,"m"<>ToString[-power],"p"<>ToString[power]];
Do[Print["VIRTUAL_LINEAR_COMPONENT ",component];
 bareTerms=Association@Table[power-><||>,{power,-2,0}];
 KeyValueMap[Function[{master,coefficient},
  id=master[[1]]<>"_"<>StringRiffle[ToString/@master[[2]],"_"];
  metadata=portable["masters"][id];
  c=coefficient/.D->4-2eps/.coordinateRules;
  cr=ComplexExpand[Re[c]];ci=ComplexExpand[Im[c]];
  gate["rational coefficient real/imaginary reconstruction",Factor[c-cr-I ci]===0];
  Do[factor=2 If[part==="Re",cr,-ci];
   Do[If[factor=!=0,
    needed=-masterPower;
    product=Normal[Series[(record["measure"]/.coordinateRules)factor,{eps,0,Max[0,needed]}]];
    Do[weight=reduce[Coefficient[Expand[product],eps,power-masterPower]];
     key="master/r05/virtual/"<>id<>"_"<>part<>"_"<>suffix[masterPower]<>branchSuffix;
     gate["every selected coefficient exists",KeyExistsQ[known,key]];
     AssociateTo[bareTerms,power->Append[bareTerms[power],key->weight]],{power,-2,0}]],
    {masterPower,metadata["minimum_power"],metadata["available_through"]}],{part,{"Re","Im"}}]],record["coefficients"][component]];
 dimensionalBorn=record["UV_checks"][component]["dimensional_Born"];
 counterterm=Normal[Series[record["UV_checks"][component]["coupling_UV"]uv["MSPole"]dimensionalBorn,{eps,0,0}]]/.coordinateRules;
 Do[key=component<>"_"<>suffix[power]<>branchSuffix;
  row=HSLinearCreate[reduce[Coefficient[Expand[counterterm],eps,power]],bareTerms[power]];
  value=reduce[HSLinearEvaluate[row,known]];
  expected=record["Laurent"][component][ToString[power]]/.coordinateRules;
  residual=reduce[value-expected];
  If[residual=!=0,residual=TimeConstrained[FullSimplify[residual,physical],120,residual]];
  AssociateTo[recipes,key->row];AssociateTo[residuals,key->residual];
  If[useBasis,
   split=HSBasisCertificates["r06/"<>key,HSBasisRebind[row,basisBank,"master/r05/virtual/"],basisKnown,{"Hqq"},HSBasisKnown[basisBank,"master/r05/virtual/"]];
   certificates=Join[certificates,split["values"]];AssociateTo[basisRecords,"r06/"<>key->KeyDrop[split,"values"]],
   AssociateTo[certificates,"r06/"<>key->HSLinearCertificate[row,known,{"Hqq"}]]],{power,-2,0}];
 Put[<|"recipes"->recipes,"comparison_residuals"->residuals|>,FileNameJoin[{out,"checkpoint.wl"}]],
 {component,Keys[record["coefficients"]]}];
Put[<|"recipes"->recipes,"values"->certificates,"comparison_residuals"->residuals,
 "source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,Join[{input,portableFile,uvFile,$InputFileName},helpers,
  If[StringQ[evaluatedFile]&&StringLength[evaluatedFile]>0,{evaluatedFile},{}],If[useBasis,{basisFile},{}]]],
 "basis_records"->basisRecords,"coordinate_rules"->coordinateRules,"branch"->branch,
 "qualification"->"Exact linear decomposition versus the direct complex-series assembly, with explicit branch coordinate and renormalization-scale symbol conversion; archived master values reused, not newly integrated; no native stage acceptance asserted"|>,FileNameJoin[{out,"certificates.wl"}]];
If[compareDirect,gate["all 18 Laurent coefficients agree with direct assembly",And@@(#===0&/@Values[residuals])]];
Print["VIRTUAL_LINEAR_CERTIFICATES_COMPLETE ",Length[recipes]];Exit[0];
