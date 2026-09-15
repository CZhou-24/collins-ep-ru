(* Candidate-owned transport helper. Contains no physical coefficient. *)
Clear[NLOContext,NLOTree,NLOWritePacket];
NLOContext[]:=Import[Environment["COLLINS_NLO_CONTEXT"],"RawJSON"];
NLOTree[x_Integer]:=x;
NLOTree[x_Rational]:=ToString[Numerator[x],InputForm]<>"/"<>ToString[Denominator[x],InputForm];
NLOTree[Pi]:="pi";
NLOTree[x_Symbol]:=SymbolName[x];
NLOTree[x_Plus]:=Prepend[NLOTree/@(List@@x),"add"];
NLOTree[x_Times]:=Prepend[NLOTree/@(List@@x),"mul"];
NLOTree[Power[x_,p:(_Rational|_Integer)]]:={"pow",NLOTree[x],NLOTree[p]};
NLOTree[Log[x_]]:={"log",NLOTree[x]};
NLOTree[PolyLog[2,x_]]:={"li2",NLOTree[x]};
NLOTree[Zeta[n_Integer]]:={"zeta",n};
NLOTree[x_]:=(Print["unsupported expression transport: ",InputForm[x]];Exit[1]);
NLOWritePacket[data_Association]:=Module[{c=NLOContext[],p},
 p=<|"schema"->1,"stage"->c["stage"],"purpose"->"DERIVATION", "coupling"->"alpha_s/(2*pi)","data"->data|>;
 Put[p,FileNameJoin[{c["output"],"packet.wl"}]];
 Export[FileNameJoin[{c["output"],"packet.json"}],p,"RawJSON"];
];
