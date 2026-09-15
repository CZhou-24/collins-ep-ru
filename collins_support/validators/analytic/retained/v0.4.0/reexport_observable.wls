(* Independent native-to-packet extraction of the assembled perturbative expressions. *)
c=Import[Environment["COLLINS_NLO_REEXPORT_CONTEXT"],"RawJSON"];
Get[c["encoder"]];
n=Get[c["packet"]];
keys={"observable","HF_integrand","ratio","paper_limit","scheme_variation"};
If[!AssociationQ[n] || !(And@@(AssociationQ[Lookup[n,#,Missing[]]]&/@keys)),Exit[1]];
out=AssociationMap[Function[k,Map[NLOTree,n[k]]],keys];
Export[c["output"],out,"RawJSON"];
Exit[0];
