(* Excluded quark channels: actual tagged spin traces with open photon
   structure. No contracted UU coefficient is used to infer a zero. *)
HSChannelOperators[files_Association]:=Module[{bank,prime,groups,rows=<||>,values,jz,op,constraint,solution,residual,zeros},
 bank=Get[files["Hqg"]];prime=Get[files["Hqqprime"]]["amplitudes"];
 groups=<|"Hqg_Born"->{bank["Born"],bank["Born"]},"Hqg_Real"->{bank["Real"],bank["Real"]},
  "Hqg_VirtualInterference"->{bank["Virtual"],bank["Born"]},"Hqqprime_Real"->{prime,prime}|>;
 KeyValueMap[Function[{key,amplitudes},Print["OPERATOR_ZERO ",key];
  If[!MatchQ[amplitudes,{_List,_List}],Print["INVALID_ZERO_AMPLITUDE_INPUT"];Abort[]];
  values=Table[Factor[DiracSimplify[HSTaggedSpinSum[amplitudes[[1,i]],amplitudes[[2,j]],"T",pinX,poutX],DiracTraceEvaluate->True]],
   {i,Length[amplitudes[[1]]]},{j,Length[amplitudes[[2]]]}];
  If[!And@@(#===0&/@Flatten[values]),Print["UNPROVED_CHANNEL_ZERO ",key];Abort[]];
  AssociateTo[rows,key->values]],groups];
 jz=DiagonalMatrix[{1/2,-1/2}];op={{g11,g12},{g21,g22}};
 constraint=jz.op-op.jz-2op;solution=Solve[Thread[Flatten[constraint]==0],Flatten[op]];
 If[Length[solution]!=1,Print["GLUON_OPERATOR_NOT_EXCLUDED"];Abort[]];
 residual=Simplify[op/.First[solution]];
 zeros=<|"Hqg"->Total[Flatten[Values[KeyTake[rows,{"Hqg_Born","Hqg_Real","Hqg_VirtualInterference"}]]]],
  "Hqqprime"->Total[Flatten[rows["Hqqprime_Real"]]],"Hgq"->Total[Flatten[residual]],"Hgg"->Total[Flatten[residual]]|>;
 <|"quark_traces"->rows,"quark_pair_counts"->Map[Length[Flatten[#]]&,rows],
 "gluon_commutator_equation"->constraint,"gluon_solution"->solution,"gluon_operator_residual"->residual,
 "zero_residuals"->zeros,"assumptions"->"Massless vector couplings; leading-twist forward collinear spin-half proton. BMHV odd-gamma traces vanish before photon contraction. No Hqqbar zero is asserted."|>];
