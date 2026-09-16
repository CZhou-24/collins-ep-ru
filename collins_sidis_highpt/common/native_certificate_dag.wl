(* Exact common-subexpression graph for polynomial linear factors. It changes
   only arithmetic representation, never values, truncation or dependencies.
   The imported-master normalization rows themselves stay unchanged. *)
ClearAll[HSCertificateDAG];
HSCertificateDAG[packet_Association,masters_Association]:=Module[
 {values=packet["values"],result=<||>,known,proofs=<||>,nodes=<||>,certificate,
  factors,expanded,pieces,numeric,monomial,nodeID,node,terms,weights,proof,
  record,ref,sectorKey,originalIDs=Keys[packet["values"]]},
 known=Join[masters,Map[#["value"]/.RUExact[x_]:>x&,values]];
 Do[certificate=values[id];terms={};factors=<||>;
  Do[ref=term["ref"];factor=term["factor"]/.RUExact[x_]:>x;
   expanded=Expand[factor];
   If[StringStartsQ[ref,"master/"]||StringContainsQ[id,"/denominator_factor_"]||Head[expanded]=!=Plus||!FreeQ[factor,eps|eta],
    AppendTo[terms,term],
    pieces=List@@expanded;weights={};
    Do[{numeric,monomial}=If[Head[piece]===Times&&NumberQ[First[piece]],
       {First[piece],Rest[piece]},{If[NumberQ[piece],piece,1],If[NumberQ[piece],1,piece]}];
     If[monomial===1,AppendTo[terms,<|"ref"->ref,"factor"->RUExact[numeric]|>],
      sectorKey=StringRiffle[certificate["sectors"],"_"];
      nodeID=packet["stage"]<>"/polynomial_node_"<>IntegerString[Hash[{ref,monomial,sectorKey},"SHA256"],16,64];
      node=<|"constant"->RUExact[0],"terms"->{<|"ref"->ref,"factor"->RUExact[monomial]|>},
       "value"->RUExact[Factor[monomial known[ref]]],
       "eta_order"->certificate["eta_order"],"eps_order"->certificate["eps_order"],"sectors"->certificate["sectors"]|>;
      If[KeyExistsQ[nodes,nodeID]&&nodes[nodeID]=!=node,Print["CERTIFICATE_NODE_COLLISION"];Abort[]];
      AssociateTo[nodes,nodeID->node];AppendTo[terms,<|"ref"->nodeID,"factor"->RUExact[numeric]|>]];
     AppendTo[weights,numeric monomial],{piece,pieces}];
    proof=Expand[factor-Total[weights]];
    If[proof=!=0,Print["CERTIFICATE_FACTOR_RECONSTRUCTION_FAILED ",id];Abort[]];
    AssociateTo[factors,ref->proof]],{term,certificate["terms"]}];
  (* Equal graph leaves are collected so each linear reference is unique. *)
  terms=KeyValueMap[<|"ref"->#1,"factor"->RUExact[Total[#2]]|>&,
   GroupBy[terms,#["ref"]&,((#["factor"]/.RUExact[x_]:>x)&/@#)&]];
  AssociateTo[result,id->Join[certificate,<|"terms"->terms|>]];
  AssociateTo[proofs,id->factors],{id,originalIDs}];
 record=Join[packet,<|"values"->Join[nodes,result]|>];
 <|"packet"->record,"factor_reconstruction_residuals"->proofs,
  "original_certificates"->Length[values],"shared_polynomial_nodes"->Length[nodes],
  "qualification"->"Exact distributive-law factor decomposition with shared monomial products. Original constants, values, orders and export IDs remain unchanged. Native checker still verifies every product, sum and expansion depth."|>];
