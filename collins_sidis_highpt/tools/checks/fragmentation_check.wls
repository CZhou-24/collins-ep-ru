$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
engine=FileNameJoin[{root,"collins_sidis_highpt"}];base=FileNameJoin[{root,"collins_support","reports","sidis-highpt-001"}];If[StringQ[Environment["SIDIS_HIGHPT_REPORT_ROOT"]],base=Environment["SIDIS_HIGHPT_REPORT_ROOT"]];out=FileNameJoin[{base,"fragmentation-001"}];
If[DirectoryQ[out],Print["Refuse output reuse"];Exit[1]];CreateDirectory[out];
Get[FileNameJoin[{engine,"common","fragmentation.wl"}]];
$Assumptions=beta>0&&zh>0&&Mh>0&&b>0&&j>0;
rows=Table[forward=FullSimplify[Activate[HSTMDMoment[Function[k,h0 Exp[-beta k^2]],n,zh,b,Mh]]];
 inverse=FullSimplify[Activate[HSInverseMoment[Function[bb,Evaluate[forward/.b->bb]],n,zh,j,Mh]]];
 <|"n"->n,"analytic_test_input"->h0 Exp[-beta j^2],"forward_transform"->forward,"inverse_transform"->inverse,
 "residual"->FullSimplify[inverse-h0 Exp[-beta j^2]]|>,{n,0,1}];
order=Expand[HSNLOProduct[c0,c1,j0,j1,a]-(a c0 j0+a^2(c1 j0+c0 j1))];
analyzer=HSCollinsAnalyzer[phih,j,zh,Mh];azimuth=Integrate[analyzer,{phih,0,2Pi}];
Put[<|"gaussian_identity_checks"->rows,"order_residual"->order,"unweighted_azimuth_residual"->azimuth,
 "qualification"->"The Gaussian is an analytic test function, not a model fit or chosen physical fragmentation input.",
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "helper_sha256"->IntegerString[FileHash[FileNameJoin[{engine,"common","fragmentation.wl"}],"SHA256"],16,64]|>,FileNameJoin[{out,"checks.wl"}]];
Print["FRAGMENTATION_RESIDUALS ",InputForm[Join[Lookup[rows,"residual"],{order},azimuth]]];
If[!And@@(#===0&/@Join[Lookup[rows,"residual"],{order},azimuth]),Exit[2]];Exit[0];
