(* Linear Collins projection in the open-tensor polynomial basis. Expensive
   angular moments are computed once per monomial, rather than after combining
   the full kinematic numerator. No tensor coefficient is dropped. *)
ClearAll[HSCollinsMonomialSetup,HSCollinsMonomialMoment,HSCollinsPolynomialProject];
HSCollinsMonomialSetup[geometry_Association]:=Module[{rows,replacement},
 Clear[HSCollinsMonomialMoment];
 $HSCollinsMonomialVariables=Join[First/@geometry["projector_dot_rows"],{hsHat}];
 rows=geometry["projector_dot_rows"];
 $HSCollinsProjectionDefinitions=<|"Collins_L"->{{{phL,phL},{pinX,poutX}},{{phL,phL},{pinY,poutY}}},
  "Collins_T"->{{{phX,phX},{pinX,poutX}},{{phY,phY},{pinX,poutX}},{{phX,phX},{pinY,poutY}},{{phY,phY},{pinY,poutY}}}|>;
 $HSCollinsMonomialRules=Map[Function[definitions,Map[Function[definition,
  replacement={hsIn->definition[[2,1]],hsOut->definition[[2,2]],hsA->definition[[1,1]],hsB->definition[[1,2]]};
  Join[(#[[1]]->HSOnShell[HSDot[$HSVectors[#[[2]]/.replacement],$HSVectors[#[[3]]/.replacement]]])&/@rows,
   {hsHat->FCI[SPE[k2,k2]]}]],definitions]],$HSCollinsProjectionDefinitions];
 HSCollinsMonomialMoment[powers_List,component_String]:=HSCollinsMonomialMoment[powers,component]=Module[
  {monomial=Times@@MapThread[Power,{$HSCollinsMonomialVariables,powers}]},
   HSSphereAverage[Total[(monomial/.#)&/@$HSCollinsMonomialRules[component]]/2]];
 ];
HSCollinsPolynomialProject[tensor_,component_String]:=Module[{rational,num,den,rows,result},
 rational=Together[tensor];num=Numerator[rational];den=Denominator[rational];
 If[!FreeQ[den,Alternatives@@$HSCollinsMonomialVariables]||!PolynomialQ[num,$HSCollinsMonomialVariables],
  Return[Failure["NotOpenTensorPolynomial",<||>]]];
 rows=CoefficientRules[num,$HSCollinsMonomialVariables];
 result=Total[(Last[#]/.Q2->Q^2)HSCollinsMonomialMoment[First[#],component]&/@rows]/(den/.Q2->Q^2);
 HSOnShell[result]];
