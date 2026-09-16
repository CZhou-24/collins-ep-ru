(* Focused serialization test on saved packets. No contraction or integration. *)
$HistoryLength=0;
cfg=Import[Environment["SIDIS_REVIEW_PACKET_CONTEXT"],"RawJSON"];
Get[FileNameJoin[{cfg["repo"],"collins_support","validators","analytic","native_io.wl"}]];
packet=Get[cfg["packet"]];original=Get[cfg["original_packet"]];
keys=Select[Keys[packet["values"]],StringStartsQ[#,"r06/virtualComparison_"]&];
If[Sort[keys]=!=Sort[cfg["expected_keys"]],Print["Wrong added identity inventory"];Exit[2]];
If[KeyDrop[packet["values"],keys]=!=original["values"],Print["Original values changed"];Exit[2]];
If[KeyDrop[packet,"values"]=!=KeyDrop[original,"values"],Print["Original packet metadata changed"];Exit[2]];
Put[<|"schema"->5,"stage"->"r06","values"->KeyTake[packet["values"],keys],
  "evidence"-><||>,"jobs"->{}|>,cfg["focused_packet"]];
Export[cfg["summary"],<|"original_values_unchanged"->True,
  "original_packet_metadata_unchanged"->True,"additional_values"->Length[keys]|>,"RawJSON"];
Exit[0];
