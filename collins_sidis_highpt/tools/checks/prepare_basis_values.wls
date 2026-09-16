$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
out=Environment["SIDIS_BASIS_VALUES_OUT"];If[!StringQ[out]||DirectoryQ[out],Exit[1]];CreateDirectory[out,CreateIntermediateDirectories->True];
identities=<||>;Do[file=FileNameJoin[{root,"collins_sidis_highpt","inputs",kind<>"-master-basis.wl"}];record=Get[file];
Put[record["values"],FileNameJoin[{out,kind<>".wl"}]];
AssociateTo[identities,kind-><|"source"->file,"sha256"->IntegerString[FileHash[file,"SHA256"],16,64],"selections"->Length[record["values"]]|>],{kind,{"real","virtual"}}];
Export[FileNameJoin[{out,"identities.json"}],identities,"RawJSON"];Print["FOCUSED_MASTER_VALUES_PREPARED; NOT_AN_OFFICIAL_IMPORT_RECEIPT"];Exit[0];
