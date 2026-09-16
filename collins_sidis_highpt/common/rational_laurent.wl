(* Exact finite Laurent prefix of a rational function. Coefficients are derived
   by polynomial division at the expansion point and reconstructed individually.
   No numerical sampling or assumed pole cancellation enters the recurrence. *)
HSRationalLaurent[value_,variable_,last_Integer]:=Module[
 {rational,num,den,n0,d0,first,depth,coeff=<||>,checks=<||>,nv,dv,current},
 rational=Together[value];
 If[rational===0,Return[<|"coefficients"-><||>,"checks"-><||>,"valuation"->Infinity|>]];
 num=Numerator[rational];den=Denominator[rational];
 gate["Laurent input is a rational polynomial quotient",PolynomialQ[num,variable]&&PolynomialQ[den,variable]];
 n0=Exponent[num,variable,Min];d0=Exponent[den,variable,Min];first=n0-d0;depth=last-first;
 If[depth<0,Return[<|"coefficients"-><||>,"checks"-><||>,"valuation"->first|>]];
 Do[nv=Coefficient[num,variable,n0+j];
  dv=Total[Table[Coefficient[den,variable,d0+k]coeff[j-k],{k,1,j}]];
  current=Factor[Together[(nv-dv)/Coefficient[den,variable,d0]]];AssociateTo[coeff,j->current];
  AssociateTo[checks,j->Factor[Together[Coefficient[den,variable,d0]current+dv-nv]]];
  gate["Laurent quotient coefficient reconstruction",checks[j]===0],{j,0,depth}];
 <|"coefficients"->Association[KeyValueMap[(#1+first)->#2&,coeff]],"checks"->checks,"valuation"->first|>];
