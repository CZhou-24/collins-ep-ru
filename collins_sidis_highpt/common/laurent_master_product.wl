(* Multiply an exact rational coefficient by an already evaluated master
   series without asking generic Series to differentiate its large closed
   expression. The rational quotient recurrence supplies and reconstructs every
   needed coefficient; saved-master depth is checked before multiplication. *)
HSLaurentMasterProduct[coefficient_,raw_,last_Integer]:=Module[
 {c,firstC,firstM,lastM,division,first,values,normal},
 If[coefficient===0,Return[<|"value"->0,"coefficients"-><||>,"quotient_checks"-><||>|>]];
 gate["native master has exact epsilon series",MatchQ[raw,_SeriesData]&&raw[[1]]===eps&&raw[[6]]===1];
 c=Together[coefficient];
 firstC=Exponent[Numerator[c],eps,Min]-Exponent[Denominator[c],eps,Min];
 firstM=raw[[4]];lastM=raw[[5]]-1;
 gate["master depth covers rational pole product",firstC+lastM>=last];
 division=HSRationalLaurent[c,eps,last-firstM];first=firstC+firstM;
 values=Association@Table[power->Total[KeyValueMap[Function[{ci,cv},
   If[firstM<=power-ci<=lastM,cv SeriesCoefficient[raw,power-ci],0]],division["coefficients"]]],{power,first,last}];
 normal=Total[KeyValueMap[(eps^#1 #2)&,values]];
 <|"value"->normal,"coefficients"->values,"quotient_checks"->division["checks"],
  "rational_valuation"->firstC,"master_minimum"->firstM,"master_available_through"->lastM,
  "needed_rational_through"->last-firstM|>];
