(* Native transport smoke only. Synthetic expressions, not physical coefficients. *)
c=Import[Environment["COLLINS_NLO_CONTEXT"],"RawJSON"];
Get[c["encoder"]];
n=<|"observable"-><|"UU0"->HUU f0 D0,"UT0"->HUT h0 C0,
 "UU1"->CF(1/3+Log[u]+PolyLog[2,v]),"UT1"->CF(Pi^2+u^(-1))|>,
 "HF_integrand"-><|"regular"->u v,"delta"->0,"D0"->0,"D1"->0|>,
 "ratio"-><|"A0"->N0/U0,"A1"->N1/U0-N0 U1/U0^2|>,
 "paper_limit"-><|"UU0"->HUU f0 D0,"UT0"->HUT h0 C0,"UU1"->0,"UT1"->0|>,
 "scheme_variation"-><|"UU"->kH+kB+kF+kS,"UT"->kH+kB+kF+kS|>|>;
Put[n,FileNameJoin[{c["output"],"NATIVE_OBSERVABLE.wl"}]];
d=AssociationMap[Function[k,Map[NLOTree,n[k]]],Keys[n]];
NLOWritePacket[d];
Exit[0];
