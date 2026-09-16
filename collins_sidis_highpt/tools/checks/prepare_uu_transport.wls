$HistoryLength=0;input=Environment["SIDIS_UU_SCALAR_INPUT"];out=Environment["SIDIS_UU_TRANSPORT_OUT"];
If[DirectoryQ[out],Exit[1]];CreateDirectory[out,CreateIntermediateDirectories->True];record=Get[input];
Put[<|"schema"->5,"stage"->"r07","values"->record["values"],"evidence"-><||>,"jobs"->{}|>,FileNameJoin[{out,"packet.wl"}]];
Put[<||>,FileNameJoin[{out,"masters.wl"}]];Put[record["literal_reference_candidates"],FileNameJoin[{out,"reference-candidates.wl"}]];
Print["UU_TRANSPORT_PREPARED ",Length[record["values"]]];Exit[0];
