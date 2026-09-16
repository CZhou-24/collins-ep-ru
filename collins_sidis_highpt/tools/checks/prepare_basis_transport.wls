(* Focused exact transport of actual r03/r06 recipes in master-function bases. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
contextFile=Environment["SIDIS_BASIS_TRANSPORT_CONTEXT"];cfg=Import[contextFile,"RawJSON"];out=cfg["output"];
If[DirectoryQ[out],Exit[1]];CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["BASIS_TRANSPORT_FAILED ",name];Exit[2]];
helpers=FileNameJoin[{root,"collins_sidis_highpt","common",#<>".wl"}]&/@{"native_linear","transcendental_basis","native_basis_linear"};Get/@helpers;
Get[FileNameJoin[{root,"collins_support","validators","analytic","native_io.wl"}]];
bank=Get[cfg["bank"]];record=Get[cfg["recipes"]];prefix=cfg["prefix"];
known=HSBasisKnown[bank,prefix];values=<||>;basis=<||>;recipes=<||>;proofs=<||>;
Do[row=HSBasisRebind[record["recipes"][key],bank,prefix];
 powers=Union[Flatten[Table[If[factor===0,{},Range[Exponent[Expand[factor],eps,Min],Exponent[Expand[factor],eps]]],
   {factor,Join[{row["constant"]},Values[row["terms"]]]}]],{0}];
 Do[scalar=HSLinearMap[Function[x,Coefficient[Expand[x],eps,n]],row];
  id=cfg["stage"]<>"/"<>key<>"_"<>If[n<0,"m"<>ToString[-n],"p"<>ToString[n]];
  result=HSBasisCertificates[id,scalar,known,{cfg["channel"]}];
  values=Join[values,result["values"]];AssociateTo[basis,id->result["basis"]];
  recipes=Join[recipes,result["recipes"]];AssociateTo[proofs,id->result["reconstruction_residuals"]],{n,powers}];
 Print["BASIS_TRANSPORT ",key," ",Length[values]],{key,Keys[record["recipes"]]}];
Put[<|"schema"->5,"stage"->cfg["stage"],"values"->values,"evidence"-><||>,"jobs"->{}|>,FileNameJoin[{out,"packet.wl"}]];
Put[known,FileNameJoin[{out,"masters.wl"}]];
Put[<|"basis"->basis,"recipes"->recipes,"reconstruction_residuals"->proofs,
 "source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,Join[helpers,{contextFile,$InputFileName,cfg["bank"],cfg["recipes"]}]]|>,FileNameJoin[{out,"basis.wl"}]];
Print["BASIS_TRANSPORT_PREPARED ",Length[values]];Exit[0];
