(* Weighted polynomial quotient recurrence for a rational large-loop series.
   loop2 has weight 2; loopP,Q,K have weight 1. This avoids general Series
   expanding repeated rational denominators before collecting loop degree. *)
HSUVHomogeneous[value_,lastPower_:4]:=Module[
 {variables={loop2,loopP,loopQ,loopK},weights={2,1,1,1},rational,num,den,nrows,drows,
  ndegree,ddegree,first,depth,ncoeff,dcoeff,coeff=<||>,residuals=<||>,nv,dv,current,check},
 rational=Together[value];If[rational===0,Return[<|"rows"-><||>,"residuals"-><||>|>]];
 num=Numerator[rational];den=Denominator[rational];
 gate["UV integrand is a rational polynomial quotient",PolynomialQ[num,variables]&&PolynomialQ[den,variables]];
 nrows=CoefficientRules[num,variables];drows=CoefficientRules[den,variables];
 ndegree=Max[(First[#].weights)&/@nrows];ddegree=Max[(First[#].weights)&/@drows];
 first=ddegree-ndegree;depth=lastPower-first;
 If[depth<0,Return[<|"rows"-><||>,"residuals"-><||>,"first_power"->first|>]];
 ncoeff=GroupBy[nrows,ndegree-First[#].weights&,Total[(Last[#]Times@@MapThread[Power,{variables,First[#]}])&/@#]&];
 dcoeff=GroupBy[drows,ddegree-First[#].weights&,Total[(Last[#]Times@@MapThread[Power,{variables,First[#]}])&/@#]&];
 gate["nonzero leading UV denominator",Lookup[dcoeff,0,0]=!=0];
 Do[nv=Lookup[ncoeff,j,0];dv=Total[Table[Lookup[dcoeff,k,0]coeff[j-k],{k,1,j}]];
  current=Factor[Together[(nv-dv)/dcoeff[0]]];AssociateTo[coeff,j->current];
  check=Factor[Together[dcoeff[0]current+dv-nv]];AssociateTo[residuals,j->check];
  gate["UV quotient recurrence reconstructs each coefficient",check===0],{j,0,depth}];
 <|"rows"->Association[KeyValueMap[(#1+first)->#2&,coeff]],"residuals"->residuals,
  "numerator_weight"->ndegree,"denominator_weight"->ddegree,"first_power"->first|>];
