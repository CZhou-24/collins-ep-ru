(* Exact overlap of the generic and rational-recurrence multiplication routes.
   Compare only outputs that actually completed in the preserved generic run. *)
$HistoryLength=0;
oldDirectory=Environment["SIDIS_OLD_ENDPOINT_DIR"];newDirectory=Environment["SIDIS_NEW_ENDPOINT_DIR"];
oldMasterDirectory=Environment["SIDIS_OLD_MASTER_DIR"];newMasterDirectory=Environment["SIDIS_NEW_MASTER_DIR"];
out=Environment["SIDIS_ENDPOINT_OVERLAP_OUT"];
If[!StringQ[out]||DirectoryQ[out],Exit[1]];CreateDirectory[out,CreateIntermediateDirectories->True];
assumptions=Q2>0&&s>w>0&&omega>0&&B>0&&SUNN>1&&Nc>1;
checks=<||>;files={};
Do[oldFile=FileNameJoin[{oldDirectory,"RealQGG_Collins_L_charge0_branch_"<>ToString[sign]<>".wl"}];
 newFile=FileNameJoin[{newDirectory,"RealQGG_Collins_L_charge0_branch_"<>ToString[sign]<>".wl"}];
 If[!And@@(FileExistsQ/@{oldFile,newFile}),Exit[2]];files=Join[files,{oldFile,newFile}];old=Get[oldFile];new=Get[newFile];
 Do[residual=TimeConstrained[FullSimplify[old[dist]-new[dist],assumptions&&-Q2-s<sign omega-s<0],120,$Failed];
  AssociateTo[checks,ToString[sign]<>"_"<>dist->residual],{dist,{"Delta","L0","L1","Regular"}}],{sign,{1,-1}}];
oldFile=FileNameJoin[{oldMasterDirectory,"RealQGG_Collins_L_charge0.wl"}];newFile=FileNameJoin[{newMasterDirectory,"RealQGG_Collins_L_charge0.wl"}];
If[!And@@(FileExistsQ/@{oldFile,newFile}),Exit[2]];files=Join[files,{oldFile,newFile}];
residual=TimeConstrained[FullSimplify[Get[oldFile]["ordinary"]-Get[newFile]["ordinary"],Q2>0&&s>w>0&&w-Q2-s<t< -Q2 w/s&&SUNN>1],120,$Failed];
AssociateTo[checks,"ordinary_master_product"->residual];
Put[<|"residuals"->checks,"source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,Append[files,$InputFileName]],
 "qualification"->"Exact completed-prefix overlap of two multiplication algorithms; transverse coefficients separately carry quotient-reconstruction and endpoint-action evidence"|>,FileNameJoin[{out,"comparison.wl"}]];
Print["ENDPOINT_OVERLAP ",InputForm[checks]];Exit[If[And@@(#===0&/@Values[checks]),0,3]];
