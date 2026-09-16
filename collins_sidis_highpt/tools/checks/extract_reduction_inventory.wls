(* Read names/counts from actual completed maps and reductions. This inventory
   declares checks; it contains no expected coefficient or acceptance claim. *)
$HistoryLength=0;cfg=Import[Environment["SIDIS_REDUCTION_INVENTORY_CONTEXT"],"RawJSON"];
out=cfg["output"];If[FileExistsQ[out],Exit[1]];
real=Map[Get,cfg["real"]];virtual=Get[cfg["virtual"]];mapping=Get[cfg["virtual_map"]];
files=Join[Values[cfg["real"]],{cfg["virtual"],cfg["virtual_map"],$InputFileName}];
exported=Export[out,<|"real_overlap_counts"->(Length[#["archive_covered_target_residuals"]]&/@real),
 "real_target_counts"->(Length[#["targets"]]&/@real),
 "virtual_components"->Keys[mapping["rows"]],
 "virtual_overlap_count"->Length[virtual["archive_covered_target_residuals"]],
 "source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,files],
 "qualification"->"Declaration inventory read from development maps and reductions, not a fresh native workflow or an acceptance result."|>,"RawJSON"];
If[!StringQ[exported],Print["REDUCTION_INVENTORY_EXPORT_FAILED"];Exit[2]];
Print["REDUCTION_INVENTORY_EXTRACTED"];Exit[0];
