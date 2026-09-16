$HistoryLength=0;
root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
Get[FileNameJoin[{root,"collins_support","validators","analytic","native_io.wl"}]];
src=FileNameJoin[{root,"SIDIS","Hqq","s01_result","s01_inputs","s02_result.wl"}];
data=Get[src];
equations=Association@Table[key-><|"value"->RUExact[data[key]],
 "source_url"->"local:SIDIS/Hqq/s01_result/s01_inputs/s02_result.wl",
 "location"->key,
 "transcription"->"Exact native extraction of the archived unpolarized contraction; no new producing output loaded. Original D,Q2,s,t,SUNN notation is retained.",
 "independence"->"unpolarized_SIDIS"|>,{key,{"BornPg","BornPpp"}}];
dest=FileNameJoin[{root,"collins_sidis_highpt","references","uu_born_archived.json"}];
If[FileExistsQ[dest],Print["Refuse reference overwrite"];Exit[1]];
Export[dest,RUEncode[<|"source_sha256"->IntegerString[FileHash[src,"SHA256"],16,64],"equations"->equations|>],"RawJSON"];
Print["ARCHIVED_UU_REFERENCE_EXTRACTED"];Exit[0];
