(* Focused arithmetic context from actual native master extractions. No tool
   receipt or completed workflow is synthesized by this helper. *)
$HistoryLength=0;cfg=Import[Environment["SIDIS_PACKET_MASTER_CONTEXT"],"RawJSON"];
target=cfg["output"];If[FileExistsQ[target],Exit[1]];known=<||>;
KeyValueMap[Function[{prefix,file},values=Get[file];
 If[!AssociationQ[values],Exit[2]];
 known=Join[known,Association[KeyValueMap[(prefix<>#1)->#2&,values]]]],cfg["masters"]];
Put[known,target];Print["PACKET_MASTER_CONTEXT_PREPARED ",Length[known]];Exit[0];
