(* Fresh evaluation of actual upstream Wolfram packets. Cooperative environment;
   this script is not an adversarial Wolfram sandbox. No reference formulas. *)
$HistoryLength=0;$MaxExtraPrecision=1000;
c=Import[Environment["COLLINS_ANALYTIC_CONTEXT"],"RawJSON"];
If[StringQ[c["runtime"]["wolfram_init"]],Get[c["runtime"]["wolfram_init"]]];
fail[s_] := (Export[c["response"],<|"run_id"->c["run_id"],"status"->"FAIL","detail"->s|>,"RawJSON"];Quit[1]);
packets=Map[Get,c["packets"]];
If[!TrueQ[And@@(AssociationQ /@ Values[packets])],fail["A required packet is not an Association"]];
Clear[val];val[x_] := Module[{v=TimeConstrained[MemoryConstrained[N[x,35],2*1024^3,$Failed],240,$Failed]},
 If[!NumberQ[v] || !TrueQ[Im[v]==0] || !FreeQ[v,Indeterminate|_DirectedInfinity],fail["Unresolved/nonfinite value"]];N[Re[v]]];
at[tree_,path_] := Fold[If[IntegerQ[#2],#1[[#2]],#1[#2]]&,tree,path];
rows=Map[Function[r,Module[{x,rules,result},
 result=Switch[r["kind"],
  "coefficient",rules=KeyValueMap[Symbol["Global`"<>#1]->#2&,r["point"]];
    x=at[packets[r["source"]],r["path"]];<|"value"->val[x/.rules]|>,
  "real",Map[val,packets["real"][r["channel"]][r]],
  "primitive",<|"value"->val[packets["primitives"]["RadialDifference"][r]]|>,
  "scales",Map[val,packets["operators"]["Scales"][r]],
  "gaussian",Map[val,packets["assembly"]["GaussianFold"][r]],
  _,fail["Unknown request"]];
 If[!AssociationQ[result],fail["Evaluator did not return an Association"]];
 <|"id"->r["id"],"values"->result|>
]],c["requests"]];
Export[c["response"],<|"run_id"->c["run_id"],"status"->"PASS","responses"->rows|>,"RawJSON"];Quit[0];
