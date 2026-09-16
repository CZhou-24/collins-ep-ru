$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
engine=FileNameJoin[{root,"collins_sidis_highpt"}];out=Environment["SIDIS_UU_IMPORT_OUT"];
If[!StringQ[out]||DirectoryQ[out],Print["Need unused SIDIS_UU_IMPORT_OUT"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
helpers=FileNameJoin[{engine,"common",#}]&/@{"observable_convolution.wl","uu_import.wl"};Get/@helpers;
projectFile=FileNameJoin[{engine,"project.json"}];project=Import[projectFile,"RawJSON"];
records=<||>;checks=<||>;files={};
Do[Print["IMPORT_UU_CHANNEL ",channel];
 source=project["sources"][project["channels"][channel]["uu_source"]];
 file=FileNameJoin[{root,"SIDIS",source["path"]}];AppendTo[files,file];
 hash=IntegerString[FileHash[file,"SHA256"],16,64];
 If[hash=!=source["sha256"],Print["UU_SOURCE_HASH_MISMATCH ",channel];Exit[2]];
 record=MemoryConstrained[TimeConstrained[HSImportUUChannel[channel,file],300,$Failed],768*1024^2,$Failed];
 If[!AssociationQ[record],Put[record,FileNameJoin[{out,channel<>"_failure.wl"}]];Exit[3]];
 AssociateTo[records,channel->record];Put[record,FileNameJoin[{out,channel<>".wl"}]];
 AssociateTo[checks,channel-><|"finite"->record["finite_exact_expression"],
  "coupling_reconstruction"->And@@(#===0&/@Values[record["coupling_reconstruction_residuals"]])|>];
 If[!And@@Values[checks[channel]],Put[checks,FileNameJoin[{out,"failure.wl"}]];Exit[4]],
 {channel,Keys[project["channels"]]}];
Put[<|"channels"->records,"checks"->checks,
 "source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,Join[helpers,{projectFile,$InputFileName},files]],
 "qualification"->"Six-channel inclusive UU import and explicit scalar conversion; jet/TMD convolution and UT completion remain separate"|>,FileNameJoin[{out,"uu-channels.wl"}]];
Print["UU_SIX_CHANNEL_IMPORT_COMPLETE"];Exit[0];
