(* Focused transport test artifacts; not a workflow receipt or acceptance run. *)
$HistoryLength=0;input=Environment["SIDIS_LINEAR_INPUT"];masterFile=Environment["SIDIS_PORTABLE_INPUT"];
out=Environment["SIDIS_LINEAR_TRANSPORT_OUT"];sid=Environment["SIDIS_LINEAR_STAGE"];job=Environment["SIDIS_LINEAR_JOB"];
If[!StringQ[out]||DirectoryQ[out]||!And@@(FileExistsQ/@{input,masterFile}),Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
record=Get[input];master=Get[masterFile];
Put[<|"schema"->5,"stage"->If[sid==="r02","r03","r06"],"values"->record["values"],"evidence"-><||>,"jobs"->{}|>,FileNameJoin[{out,"packet.wl"}]];
Put[Association[KeyValueMap[("master/"<>sid<>"/"<>job<>"/"<>#1)->#2&,master["values"]]],FileNameJoin[{out,"masters.wl"}]];
Export[FileNameJoin[{out,"source-identities.json"}],AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,{input,masterFile,$InputFileName}],"RawJSON"];
Print["LINEAR_TRANSPORT_INPUTS_PREPARED"];Exit[0];
