$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
base=FileNameJoin[{root,"collins_support","reports","sidis-highpt-001"}];If[StringQ[Environment["SIDIS_HIGHPT_REPORT_ROOT"]],base=Environment["SIDIS_HIGHPT_REPORT_ROOT"]];out=FileNameJoin[{base,"real-ward-001"}];
If[DirectoryQ[out],Print["Refuse output reuse"];Exit[1]];CreateDirectory[out];
map=Get[FileNameJoin[{base,"real-map-001","mapping.wl"}]];degrees=map["charge_degree_by_diagram"];
groups=<|0->{},1->{},2->{}|>;hashes=<||>;
Do[file=FileNameJoin[{base,"real-pilot-001","PhotonWard_"<>ToString[i]<>"_"<>ToString[j]<>".wl"}];
 value=Get[file]["value"];degree=degrees[[i]]+degrees[[j]];
 AssociateTo[groups,degree->Append[groups[degree],value]];
 AssociateTo[hashes,file->IntegerString[FileHash[file,"SHA256"],16,64]],{i,4},{j,i,4}];
residuals=Map[Factor[Together[Total[#]]]&,groups];
Put[<|"independent_charge_ward_residuals"->residuals,"pair_hashes"->hashes,
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "qualification"->"Hqq RealDistinct, fixed physical Y,Yprime only; does not check missing spin components or real topologies."|>,FileNameJoin[{out,"residuals.wl"}]];
Export[FileNameJoin[{out,"summary.json"}],<|"residuals"->Association[KeyValueMap[ToString[#1]->ToString[#2,InputForm]&,residuals]],
 "pair_count"->10,"scope"->"Hqq RealDistinct Y,Yprime; separate eq^2, eq*eqprime, eqprime^2 structures"|>,"RawJSON"];
Print["REAL_WARD_RESIDUALS ",InputForm[residuals]];If[!And@@(#===0&/@Values[residuals]),Exit[2]];Exit[0];
