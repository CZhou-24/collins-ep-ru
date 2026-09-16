$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
engine=FileNameJoin[{root,"collins_sidis_highpt"}];
base=FileNameJoin[{root,"collins_support","reports","sidis-highpt-001"}];If[StringQ[Environment["SIDIS_HIGHPT_REPORT_ROOT"]],base=Environment["SIDIS_HIGHPT_REPORT_ROOT"]];out=FileNameJoin[{base,"angular-002"}];
If[DirectoryQ[out],Print["Refuse output reuse"];Exit[1]];CreateDirectory[out];
run=Environment["SIDIS_BORN_RUN"];If[!StringQ[run]||!DirectoryQ[run],Print["SIDIS_BORN_RUN required"];Exit[1]];
file=FileNameJoin[{run,"common","r00_result","born_tensor_physical.wl"}];
Get[FileNameJoin[{engine,"common","angular_projection.wl"}]];
tensor=Get[file];result=HSAngularFromTensor[tensor];
Put[result,FileNameJoin[{out,"angular.wl"}]];
residuals=Join[Flatten[result["lepton"]["residuals"]],{result["hadron_azimuth_residual"],result["spin_reversal_residual"],result["moment_residual"]}];
Put[<|"input"->file,"input_sha256"->IntegerString[FileHash[file,"SHA256"],16,64],
 "code_sha256"->IntegerString[FileHash[FileNameJoin[{engine,"common","angular_projection.wl"}],"SHA256"],16,64],
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "residuals"->residuals|>,FileNameJoin[{out,"checks.wl"}]];
Print["ANGULAR_RESIDUALS ",InputForm[residuals]];
Print["BORN_COLLINS_MOMENT ",InputForm[result["Collins_moment_coefficient"]]];
If[!And@@(#===0&/@residuals),Exit[2]];Exit[0];
