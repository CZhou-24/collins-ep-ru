(* Replay implementation-supplied identities in a separate Wolfram process.
   Truth of these identities does not establish their scientific completeness. *)
$HistoryLength=0;$MaxExtraPrecision=2000;
c=Import[Environment["COLLINS_ANALYTIC_CONTEXT"],"RawJSON"];
If[StringQ[c["runtime"]["wolfram_init"]],Get[c["runtime"]["wolfram_init"]]];
fail[message_] := (Export[c["proof_report"],<|"run_id"->c["run_id"],"stage"->c["stage"],"status"->"FAIL","detail"->message|>,"RawJSON"];Quit[1]);
p=Check[Get[c["proof_file"]],fail["Cannot load proof packet"]];
If[!AssociationQ[p] || Sort[Keys[p]] =!= Sort[c["proof_ids"]],fail["Missing or extra proof IDs"]];
results=AssociationMap[Function[id,Module[{entry,lhs,rhs,assumptions,residual,ok},
 entry=p[id];
 If[!AssociationQ[entry] || Sort[Keys[entry]] =!= Sort[{"lhs","rhs","assumptions"}],fail["Malformed identity: "<>id]];
 If[!MatchQ[entry["lhs"],_HoldComplete] || !MatchQ[entry["rhs"],_HoldComplete],fail["Identity sides must be HoldComplete expressions"]];
 assumptions=entry["assumptions"];
 If[TrueQ[FullSimplify[assumptions]===False],fail["Empty assumptions"]];
 lhs=ReleaseHold[entry["lhs"]];rhs=ReleaseHold[entry["rhs"]];
 residual=TimeConstrained[MemoryConstrained[FullSimplify[lhs-rhs,Assumptions->assumptions],2*1024^3,$Failed],120,$Failed];
 ok=Flatten[{residual}]=!={} && FreeQ[residual,$Failed|$Aborted|Indeterminate|_DirectedInfinity|_Integrate|_NIntegrate|_SeriesData|_Limit] && And@@(TrueQ[#===0]& /@ Flatten[{residual}]);
 If[!TrueQ[ok],fail["Nonzero, unresolved, or resource-limited identity: "<>id]];
 <|"zero"->True|>
]],c["proof_ids"]];
Export[c["proof_report"],<|"run_id"->c["run_id"],"stage"->c["stage"],"status"->"PASS","proof_ids"->Keys[results],"scope"->"Replayed supplied identities; statement completeness needs source review"|>,"RawJSON"];
Quit[0];
