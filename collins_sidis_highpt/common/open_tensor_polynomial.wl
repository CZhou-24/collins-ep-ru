(* An open photon/spin tensor is a polynomial in projector scalar products.
   Collect its rational invariant coefficients separately. This preserves the
   tensor and avoids factoring a large polynomial in all projector variables. *)
HSOpenTensorCollect[expression_,variables_List]:=Module[{rows,reduced},
 gate["open tensor is polynomial in projector scalar products",PolynomialQ[expression,variables]];
 rows=CoefficientRules[expression,variables];
 reduced=Map[Function[row,First[row]->Factor[Together[Last[row]]]],rows];
 Total[Map[Function[row,Last[row]Times@@MapThread[Power,{variables,First[row]}]],reduced]]];

(* All invariant/projector variables in these real-emission templates are real.
   Conjugation of their rational field fixes the generators and conjugates the
   exact complex coefficients. Avoid ComplexExpand expanding the denominator
   into real and imaginary parts before it can use this fact. *)
HSRealRationalConjugate[expression_]:=Module[{rational,num,den,variables},
 rational=Together[expression];num=Numerator[rational];den=Denominator[rational];
 variables=Variables[{num,den}];
 gate["tree tensor lies in rational field of real scalar variables",
  And@@(MatchQ[#,_Symbol]&/@variables)&&PolynomialQ[num,variables]&&PolynomialQ[den,variables]&&FreeQ[expression,_Real]];
 expression/.number_Complex:>Conjugate[number]];
