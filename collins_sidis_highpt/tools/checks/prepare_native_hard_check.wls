(* Focused transport and actual pole/scale coefficient inventory. This is not
   an official workflow or a substitute for its fresh pair/probe campaign. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
contextFile=Environment["SIDIS_NATIVE_HARD_CHECK_CONTEXT"];cfg=Import[contextFile,"RawJSON"];out=cfg["output"];
If[DirectoryQ[out],Exit[1]];CreateDirectory[out,CreateIntermediateDirectories->True];record=Get[cfg["input"]];
masters=Join[Association[KeyValueMap[("master/r02/cut/"<>#1)->#2&,Get[cfg["real_evaluated"]]]],
 Association[KeyValueMap[("master/r05/virtual/"<>#1)->#2&,Get[cfg["virtual_evaluated"]]]]];
Put[masters,FileNameJoin[{out,"masters.wl"}]];
Put[<|"schema"->5,"stage"->"r07","values"->record["values"],"evidence"-><||>,"jobs"->{}|>,FileNameJoin[{out,"packet.wl"}]];
rows=<||>;Do[ids=Keys[record["basis"][key]];computed=Factor/@Lookup[record["scalar_values"],ids];
 AssociateTo[rows,key-><|"coefficient_ids"->ids,"coefficients"->Length[ids],
  "zero_coefficients"->Count[computed,0],"nonzero_ids"->Pick[ids,(#=!=0&/@computed)]|>],
 {key,Select[Keys[record["basis"]],StringContainsQ[#,"_scale_"]||StringEndsQ[#,"_m1"]||StringEndsQ[#,"_m2"]&]}];
Export[FileNameJoin[{out,"native-summary.json"}],<|"rows"->rows,"certificates"->Length[record["values"]],
 "pole_scale_coefficients"->Total[Lookup[Values[rows],"coefficients"]],
 "zero_pole_scale_coefficients"->Total[Lookup[Values[rows],"zero_coefficients"]],
 "source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,{contextFile,$InputFileName,cfg["input"],cfg["real_evaluated"],cfg["virtual_evaluated"]}],
 "qualification"->"Native exact coefficient inventory; protected Python transport/precision checking remains separate"|>,"RawJSON"];
Print["NATIVE_HARD_FOCUSED_CHECK_PREPARED ",Length[record["values"]]];Exit[0];
