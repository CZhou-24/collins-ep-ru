(* Replay a saved Wolfram expression packet independently of its JSON export. *)
c=Import[Environment["COLLINS_NLO_REEXPORT_CONTEXT"],"RawJSON"];
p=Get[c["packet"]];
If[!AssociationQ[p]||Lookup[p,"schema",0]=!=1,Print["invalid native packet"];Exit[1]];
Export[c["output"],p,"RawJSON"];
Exit[0];
