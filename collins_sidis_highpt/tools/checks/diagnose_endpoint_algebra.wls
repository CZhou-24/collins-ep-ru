(* Isolate the actual endpoint reconstruction residual before changing any
   master, tensor, counterterm or reference. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
input=Environment["SIDIS_ENDPOINT_SOFT_INPUT"];out=Environment["SIDIS_ENDPOINT_DIAGNOSTIC_OUT"];
If[!StringQ[input]||!FileExistsQ[input]||!StringQ[out]||DirectoryQ[out],Exit[1]];CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,test_]:=If[!TrueQ[test],Print["ENDPOINT_DIAGNOSTIC_FAILED ",name];Exit[2]];
SetAttributes[bounded,HoldFirst];bounded[value_,label_]:=TimeConstrained[value,120,gate[label<>" timeout",False]];
helper=FileNameJoin[{root,"collins_sidis_highpt","common","cut_distribution.wl"}];Get[helper];
record=Get[input];ends=Select[record["combined"],#[[2]]===-1&&Last[#]=!=0&];
assumptions=Q2>0&&s>0&&omega>0&&B>0&&w>0&&-Q2-s<omega-s<0&&SUNN>1&&Nc>1;
plus=Table[reduce[Total[laurentProduct[#[[3]],B^(-#[[1]]eps)(Coefficient[logKernel,ellLog,n]/.{kap->#[[1]],ep->eps}),0]&/@ends],assumptions],{n,0,2}];
ordinarySoft=Total[laurentProduct[#[[3]],w^(-1-#[[1]]eps),0]&/@ends];
raw=reduce[plus[[1]]/w+plus[[2]]Log[w/B]/w-ordinarySoft,assumptions];
Put[<|"plus"->plus,"ordinary_soft"->ordinarySoft,"raw_reconstruction_residual"->raw,"assumptions"->assumptions|>,FileNameJoin[{out,"raw.wl"}]];
converted=bounded[FullSimplify[raw,assumptions],"exact residual simplification"];
Put[<|"raw_reconstruction_residual"->raw,"simplified_residual"->converted,"assumptions"->assumptions,
 "positive_log_identity"->FullSimplify[Log[w/B]-Log[w]+Log[B],B>0&&w>0],
 "source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,{input,helper,$InputFileName}],
 "qualification"->"Isolated algebra of actual regulated endpoint coefficients; does not change the tensor or evaluate a missing master"|>,FileNameJoin[{out,"diagnosis.wl"}]];
Print["ENDPOINT_DIAGNOSTIC_RESIDUAL ",InputForm[converted]];Exit[If[converted===0,0,3]];
