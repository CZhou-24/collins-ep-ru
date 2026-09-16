(* Preserve literal archived denominator factors in normalization certificates.
   Canonical factoring can change two signs and hide a direct cancellation from
   a downstream expression engine. Values and dependencies are unchanged. *)
ClearAll[HSAlignMasterDenominators];
HSAlignMasterDenominators[packet_Association,nominal_Association,actual_Association]:=Module[
 {values=packet["values"],nodes=<||>,proofs=<||>,row,term,ref,old,den,ratio,new,residual,
  factors,denFactors,previousRef,previousValue,nodeID,index,computed},
 Do[If[StringContainsQ[key,"/normalized_"],
  row=values[key];If[Length[row["terms"]]=!=1,Print["NORMALIZER_ARITY_FAILED"];Abort[]];
  term=First[row["terms"]];ref=term["ref"];
  If[!KeyExistsQ[nominal,ref],Print["NOMINAL_MASTER_MISSING ",ref];Abort[]];
  If[!KeyExistsQ[actual,ref],Print["ACTUAL_MASTER_MISSING ",ref];Abort[]];
  old=term["factor"]/.RUExact[x_]:>x;
  factors=If[Head[nominal[ref]]===Times,List@@nominal[ref],{nominal[ref]}];
  denFactors=Map[Function[f,If[Head[f]===Power&&NumberQ[f[[2]]]&&TrueQ[f[[2]]<0],f[[1]]^(-f[[2]]),Nothing]],factors];
  den=Times@@denFactors;ratio=Factor[old/den];
  If[NumberQ[ratio],
   new=ratio den;residual=Expand[old-new];
   If[residual=!=0,Print["NORMALIZER_SHAPE_RECONSTRUCTION_FAILED ",key];Abort[]];
   previousRef=ref;previousValue=actual[ref];index=0;
   Do[index++;nodeID=packet["stage"]<>"/denominator_factor_"<>
      IntegerString[Hash[{ref,row["sectors"],denFactors,index},"SHA256"],16,64];
    computed=Factor[factor previousValue];
    AssociateTo[nodes,nodeID-><|"constant"->RUExact[0],
      "terms"->{<|"ref"->previousRef,"factor"->RUExact[factor]|>},"value"->RUExact[computed],
      "eta_order"->row["eta_order"],"eps_order"->row["eps_order"],"sectors"->row["sectors"]|>];
    previousRef=nodeID;previousValue=computed,{factor,denFactors}];
   AssociateTo[values,key->Join[row,<|"terms"->{<|"ref"->previousRef,"factor"->RUExact[ratio]|>}|>]];
   AssociateTo[proofs,key-><|"residual"->residual,"literal_denominator_factors"->denFactors,
     "factor_nodes"->Length[denFactors],"fixed_ratio"->ratio|>]]],
  {key,Keys[values]}];
 <|"packet"->Join[packet,<|"values"->Join[nodes,values]|>],"proofs"->proofs,
  "factor_nodes"->Length[nodes],
  "qualification"->"Exact factor-shape conversion from fixed nominal archived master denominators. No actual probe value selects the formula. Original constants, values, orders, references and physical basis remain unchanged."|>];
