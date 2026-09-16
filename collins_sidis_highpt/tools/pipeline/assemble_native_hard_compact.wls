(* Evaluate the actual affine hard recipes using this run's imported masters.
   Each exported scalar is a coefficient in a displayed exact function basis.
   Pole/scale identities are calculated, never supplied as literal zeros. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
contextFile=Environment["SIDIS_NATIVE_HARD_CONTEXT"];cfg=Import[contextFile,"RawJSON"];out=cfg["output"];
If[DirectoryQ[out],Exit[1]];CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["NATIVE_HARD_FAILED ",name];Exit[2]];
helpers=FileNameJoin[{root,"collins_sidis_highpt","common",#<>".wl"}]&/@{"native_linear","transcendental_basis","native_compact_basis_linear","positive_log_basis"};Get/@helpers;
Get[FileNameJoin[{root,"collins_support","validators","analytic","native_io.wl"}]];
real=Get[cfg["real_basis"]];virtual=Get[cfg["virtual_basis"]];record=Get[cfg["recipes"]];
nominal=Join[HSBasisKnown[real,"master/r02/cut/"],HSBasisKnown[virtual,"master/r05/virtual/"]];
actualFile[file_,prefix_]:=Association[KeyValueMap[(prefix<>#1)->#2&,Get[file]]];
known=Join[actualFile[cfg["real_evaluated"],"master/r02/cut/"],actualFile[cfg["virtual_evaluated"],"master/r05/virtual/"]];
gate["evaluated master selectors match the declared basis",Sort[Keys[known]]===Sort[Keys[nominal]]];
rebind[row_]:=HSLinearAdd[{HSBasisRebind[HSLinearCreate[row["constant"],KeySelect[row["terms"],StringStartsQ[#,"master/r02/"]&]],real,"master/r02/cut/"],
 HSBasisRebind[HSLinearCreate[0,KeySelect[row["terms"],StringStartsQ[#,"master/r05/"]&]],virtual,"master/r05/virtual/"]}];
values=<||>;basis=<||>;recipes=<||>;reconstructed=<||>;scalarValues=<||>;normalizations=<||>;proofs=<||>;
Do[sign=If[StringContainsQ[id,"_minus_"],-1,1];channel=If[StringStartsQ[id,"r07/Hqqbar_"],"Hqqbar","Hqq"];
 conditions=Q2>0&&s>w>0&&omega>0&&B>0&&muR>0&&muPDF>0&&muFF>0&&SUNN>1&&
  -Q2-s+w<sign omega-s< -Q2 w/s&&Element[Nf,Integers]&&Nf>=1;
 scalar=HSLinearMap[Function[x,HSPositiveLogCanonical[x,conditions]],rebind[record["recipes"][id]]];
 split=HSBasisCertificates[id,scalar,known,{channel},nominal];
 values=Join[values,split["values"]];AssociateTo[basis,id->split["basis"]];recipes=Join[recipes,split["recipes"]];
 scalarValues=Join[scalarValues,split["scalar_values"]];normalizations=Join[normalizations,split["master_numerator_normalizations"]];
 AssociateTo[proofs,id->split["reconstruction_residuals"]];
 AssociateTo[reconstructed,id->Total[KeyValueMap[Factor[split["scalar_values"][#1]]#2&,split["basis"]]]];
 Put[<|"basis"->split["basis"],"scalar_values"->split["scalar_values"],"expression"->reconstructed[id]|>,
  FileNameJoin[{out,StringDrop[id,4]<>".wl"}]];
 Print["NATIVE_HARD_BASIS ",id," ",Length[split["basis"]]],{id,Keys[record["recipes"]]}];
hard=Association@Table[channel->Association[Flatten[Table[
 (component<>"_"<>ToString[sign])-><|"finite_candidate"->Association@Table[dist->
  reconstructed["r07/"<>channel<>"_"<>component<>"_"<>If[sign===1,"plus","minus"]<>"_"<>dist<>"_p0"],
   {dist,{"Delta","L0","L1","Regular"}}]|>,{component,{"Collins_L","Collins_T"}},{sign,{1,-1}}],1]],
 {channel,{"Hqq","Hqqbar"}}];
Put[<|"values"->values,"basis"->basis,"recipes"->recipes,"scalar_values"->scalarValues,
 "reconstructed"->reconstructed,"hard"->hard,"Born_D4"->record["Born_D4"],
 "reconstruction_residuals"->proofs,"master_numerator_normalizations"->normalizations,
 "positive_log_conversions"->$HSPositiveLogEvidence,
 "source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,Join[helpers,{contextFile,$InputFileName},Lookup[cfg,
  {"recipes","real_basis","virtual_basis","real_evaluated","virtual_evaluated"}]]],
 "qualification"->"Exact actual-master-dependent open-branch hard coefficients. Common-boundary and hadronic assembly are separate. Scalar basis includes explicitly displayed positive-domain logarithm conversions and fixed archived-master denominator normalizations; no physics or validator tolerance is adjusted."|>,FileNameJoin[{out,"native-hard.wl"}]];
Print["NATIVE_HARD_BASIS_COMPLETE ",Length[values]];Exit[0];
