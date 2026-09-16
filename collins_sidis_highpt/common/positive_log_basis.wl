(* Logarithm product rules only after explicit positive-factor proofs. Original
   arguments, signs and exact reconstruction checks are retained. No complex
   branch is changed with an unconditional PowerExpand. *)
ClearAll[HSPositiveLogCanonical,HSPositiveLogRule];
$HSPositiveLogEvidence=<||>;
HSPositiveLogRule[arg_,conditions_]:=HSPositiveLogRule[arg,conditions]=Module[
 {rational=Cancel[arg],factors,positive={},sign=1,number=1,f,p,proof,value,residual},
 factors=Join[FactorList[Numerator[rational]],({#[[1]],-#[[2]]}&/@FactorList[Denominator[rational]])];
 Do[{f,p}=entry;
  If[NumberQ[f]&&Element[f,Rationals],
   sign*=Sign[f]^p;number*=Abs[f]^p,
   proof=FullSimplify[f>0,conditions];
   If[!TrueQ[proof],proof=FullSimplify[f<0,conditions];
    If[TrueQ[proof],f=-f;sign*=(-1)^p,
     Return[Log[arg]]]];
   AppendTo[positive,{f,p}]],{entry,factors}];
 If[sign=!=1,Return[Log[arg]]];
 value=Total[(#[[2]]Log[#[[1]]])&/@Join[positive,FactorInteger[number]]];
 residual=FullSimplify[arg-number Times@@((#[[1]]^#[[2]])&/@positive),conditions];
 gate["positive logarithm factorization reconstructs",residual===0];
 AssociateTo[$HSPositiveLogEvidence,ToString[{arg,conditions},InputForm]->
  <|"original"->Log[arg],"converted"->value,"conditions"->conditions,
   "positive_factors"->positive,"rational_factor"->number,"factorization_residual"->residual,
   "identity"->"Real logarithm of a product of proved positive factors is the sum of their real logarithms."|>];
 value];
HSPositiveLogCanonical[value_,conditions_]:=value/.Log[arg_]:>HSPositiveLogRule[arg,conditions];
