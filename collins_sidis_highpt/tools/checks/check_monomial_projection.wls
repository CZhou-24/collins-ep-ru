$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];engine=FileNameJoin[{root,"collins_sidis_highpt"}];
input=Environment["SIDIS_TEMPLATE_INPUT"];comparison=Environment["SIDIS_PAIR_COMPARISON"];pairKey=Environment["SIDIS_PAIR_KEY"];
out=Environment["SIDIS_MONOMIAL_OUT"];
If[!StringQ[input]||!FileExistsQ[input]||!StringQ[comparison]||!FileExistsQ[comparison]||!StringQ[out]||DirectoryQ[out],Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["MONOMIAL_CHECK_FAILED ",name];Exit[4]];
rt=Import[FileNameJoin[{root,"collins_ep_analytic_SIDIS","ru_runtime.json"}],"RawJSON"];
Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};Global`$FeynCalcStartupMessages=False;
Global`$FeynCalcDirectory=rt["feyncalc_root"];FeynCalc`$FeynArtsDirectory=rt["feynarts_root"];
Get[FileNameJoin[{rt["feyncalc_root"],"FeynCalc.m"}]];
helpers=FileNameJoin[{engine,"common",#}]&/@{"spin_core.wl","spin_nlo.wl","spin_tensor_template.wl","open_tensor_polynomial.wl","collins_monomial_projection.wl"};Get/@helpers;
record=Get[input];reference=Get[comparison];HSRealKinematics[];HSCollinsMonomialSetup[record["geometry"]];
result=<||>;checks=<||>;ij=ToExpression/@StringSplit[pairKey,"_"];
Do[Print["MONOMIAL_PAIR ",pairKey," ",component];
 value=MemoryConstrained[TimeConstrained[HSCollinsPolynomialProject[record["pairs"][pairKey],component],240,$Failed],640*1024^2,$Failed];
 If[!FreeQ[value,$Failed|_Failure],Put[value,FileNameJoin[{out,"failure.wl"}]];Exit[2]];
 If[ij[[1]]=!=ij[[2]],value=HSOnShell[value+HSRealRationalConjugate[value]]];
 value=Factor[PowerExpand[value/.Q->Sqrt[Q2]]];
 AssociateTo[result,component->value];AssociateTo[checks,component->Factor[Together[value-reference["Collins"][component]]]],
 {component,{"Collins_L","Collins_T"}}];
Put[<|"pair"->pairKey,"result"->result,"residuals"->checks,
 "input_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,{input,comparison}],
 "source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,Append[helpers,$InputFileName]]|>,FileNameJoin[{out,"comparison.wl"}]];
If[!And@@(#===0&/@Values[checks]),Exit[3]];Print["MONOMIAL_PROJECTION_EQUALITY_COMPLETE"];Exit[0];
