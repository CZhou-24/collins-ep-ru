(* Focused scalar transport of actual master-dependent hard assembly recipes. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
contextFile=Environment["SIDIS_HARD_BASIS_CONTEXT"];cfg=Import[contextFile,"RawJSON"];out=cfg["output"];
If[DirectoryQ[out],Exit[1]];CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["HARD_BASIS_FAILED ",name];Exit[2]];
helpers=FileNameJoin[{root,"collins_sidis_highpt","common",#<>".wl"}]&/@{"native_linear","transcendental_basis","native_basis_linear","positive_log_basis"};Get/@helpers;
Get[FileNameJoin[{root,"collins_support","validators","analytic","native_io.wl"}]];
real=Get[cfg["real_basis"]];virtual=Get[cfg["virtual_basis"]];
known=Join[HSBasisKnown[real,"master/r02/cut/"],HSBasisKnown[virtual,"master/r05/virtual/"]];
rebind[row_]:=HSLinearAdd[{HSBasisRebind[HSLinearCreate[row["constant"],KeySelect[row["terms"],StringStartsQ[#,"master/r02/"]&]],real,"master/r02/cut/"],
 HSBasisRebind[HSLinearCreate[0,KeySelect[row["terms"],StringStartsQ[#,"master/r05/"]&]],virtual,"master/r05/virtual/"]}];
values=<||>;basis=<||>;recipes=<||>;proofs=<||>;zeroRows=<||>;
Do[record=Get[file];label=FileBaseName[file];sign=If[StringContainsQ[label,"_minus_"],-1,1];
 conditions=Q2>0&&s>w>0&&omega>0&&B>0&&muR>0&&muPDF>0&&muFF>0&&SUNN>1&&
  -Q2-s+w<sign omega-s< -Q2 w/s&&Element[Nf,Integers]&&Nf>=1;
 row=rebind[record["recipe"]];
 Do[scalar=HSLinearMap[Function[x,HSPositiveLogCanonical[Coefficient[Expand[x],eps,n],conditions]],row];
  id="r07/"<>label<>"_"<>If[n<0,"m"<>ToString[-n],"p"<>ToString[n]];
  split=HSBasisCertificates[id,scalar,known,{If[StringStartsQ[label,"Hqqbar"],"Hqqbar","Hqq"]},known];
  values=Join[values,split["values"]];AssociateTo[basis,id->split["basis"]];recipes=Join[recipes,split["recipes"]];
  AssociateTo[proofs,id->split["reconstruction_residuals"]];
  If[n<0,KeyValueMap[AssociateTo[zeroRows,#1->Factor[#2]]&,split["scalar_values"]]];
  Print["HARD_BASIS_ROW ",id," ",Length[split["values"]]],{n,{-2,-1,0}}],{file,cfg["files"]}];
Put[<|"schema"->5,"stage"->"r07","values"->values,"evidence"-><||>,"jobs"->{}|>,FileNameJoin[{out,"packet.wl"}]];
Put[known,FileNameJoin[{out,"masters.wl"}]];
Put[<|"basis"->basis,"recipes"->recipes,"reconstruction_residuals"->proofs,"pole_coefficients"->zeroRows,
 "positive_log_conversions"->$HSPositiveLogEvidence,
 "source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,Join[helpers,{contextFile,$InputFileName,cfg["real_basis"],cfg["virtual_basis"]},cfg["files"]]]|>,FileNameJoin[{out,"basis.wl"}]];
Export[FileNameJoin[{out,"native-summary.json"}],<|"coefficients"->Length[values],"pole_coefficients"->Length[zeroRows],
 "zero_pole_coefficients"->Count[Values[zeroRows],0],"log_conversions"->Length[$HSPositiveLogEvidence]|>,"RawJSON"];
Print["HARD_BASIS_PREPARED ",Length[values]];Exit[0];
