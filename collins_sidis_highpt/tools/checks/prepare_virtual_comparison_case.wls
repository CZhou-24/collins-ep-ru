(* Mutate copied saved residuals for interface rejection tests only.
   This is not a master-dependency probe or a new physical calculation. *)
$HistoryLength=0;
cfg=Import[Environment["SIDIS_REVIEW_CASE_CONTEXT"],"RawJSON"];
Do[
 file=FileNameJoin[{cfg["output"],"linear-"<>label,"certificates.wl"}];
 record=Get[file];residuals=record["comparison_residuals"];
 key="11_LL_m2"<>If[label==="generic","","_"<>label];
 Switch[cfg["case"],
  "nonzero",AssociateTo[residuals,key->1/7],
  "missing",If[label==="generic",residuals=KeyDrop[residuals,key]],
  "extra",If[label==="generic",AssociateTo[residuals,"unexpected"->0]]];
 AssociateTo[record,"comparison_residuals"->residuals];Put[record,file],
 {label,{"generic","plus","minus"}}];
Exit[0];
