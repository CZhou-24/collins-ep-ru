(* Evaluate saved analytic exports at fresh verifier-selected coordinates.
   This executes Wolfram expressions and is not an adversarial sandbox. *)
$HistoryLength=0;$MaxExtraPrecision=1000;
c=Import[Environment["COLLINS_ANALYTIC_CONTEXT"],"RawJSON"];
If[StringQ[c["runtime"]["wolfram_init"]],Get[c["runtime"]["wolfram_init"]]];
fail[message_] := (Export[c["response"],<|"run_id"->c["run_id"],"status"->"FAIL","detail"->message|>,"RawJSON"];Quit[1]);
h=Check[Get[c["coefficients"]],fail["Cannot load hard coefficients"]];
p=Check[Get[c["soft_pilot"]],fail["Cannot load soft pilot"]];
bornUp=Check[Get[c["upstream_born"]],fail["Cannot load upstream Born tensors"]];
hardUp=Check[Get[c["upstream_hard"]],fail["Cannot load upstream hard matching"]];
If[!AssociationQ[bornUp] || !And@@(KeyExistsQ[bornUp,#]& /@ {"H_UU","H_UT"}) || !AssociationQ[hardUp] || !KeyExistsQ[hardUp,"h1"],fail["Missing upstream projected coefficients"]];
If[!AssociationQ[h] || Sort[Keys[h]]=!=Sort[{"H_UU","H_UT","h1"}],fail["Wrong hard coefficient keys"]];
If[!AssociationQ[p] || Sort[Keys[p]]=!=Sort[{"kernel","angular_primitive","prefactor","slice"}],fail["Wrong soft-pilot keys"]];
If[!MatchQ[p["slice"],_Function],fail["Soft slice must be a Function of R,Y,kmin,kmax,yJ"]];
SetAttributes[value,HoldAll];
value[expr_] := Module[{v},v=TimeConstrained[MemoryConstrained[N[expr,35],2*1024^3,$Failed],180,$Failed];
 If[!NumberQ[v] || !TrueQ[Im[v]==0] || !FreeQ[v,Indeterminate|_DirectedInfinity],fail["Nonfinite or unresolved exported value"]];N[Re[v]]];
rows=Map[Function[r,Module[{vals},
 vals=Switch[r["kind"],
 "hard",With[{rules={s->r["s"],t->r["t"],u->r["u"],L->r["L"],CF->r["CF"]}},Join[Map[value,(h/.rules)],<|"upstream_H_UU"->value[bornUp["H_UU"]/.rules],"upstream_H_UT"->value[bornUp["H_UT"]/.rules],"upstream_h1"->value[hardUp["h1"]/.rules]|>]],
 "soft_kernel",With[{rules={uSoft->r["u"],phiSoft->r["phi"],CF->r["CF"]}},<|"kernel"->value[p["kernel"]/.rules],"angular_derivative"->value[D[p["angular_primitive"],phiSoft]/.rules],"prefactor"->value[p["prefactor"]/.rules]|>],
 "soft_slice",<|"slice"->value[p["slice"][r["R"],r["Y"],r["kmin"],r["kmax"],r["yJ"]]]|>,
 _,fail["Unknown request"]];
 <|"id"->r["id"],"values"->vals|>
]],c["requests"]];
Export[c["response"],<|"run_id"->c["run_id"],"status"->"PASS","responses"->rows|>,"RawJSON"];
Quit[0];
