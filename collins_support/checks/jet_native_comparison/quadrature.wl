(* Exact inner integration of the selected physical-class HF test, followed
   by high-precision one-dimensional quadrature. Never modifies its kernel.
   The domain guard deliberately rejects any denominator beyond this test. *)
ncInnerCounter=0;
ncOneIntegral[f_,range_List]:=NIntegrate[Evaluate[Factor[Cancel[f]]],range,
 WorkingPrecision->ncWP,AccuracyGoal->40,PrecisionGoal->40,MaxRecursion->30,
 Method->{"GlobalAdaptive","SymbolicProcessing"->0}];
ncTwoIntegral[f_,outer_List,inner_List]:=Module[
 {rat=Together[f],num,den,q,rem,xv=outer[[1]],yv=inner[[1]],lo=outer[[2]],
  a0,a1,primitive,integrated,label,sample},
 ncInnerCounter++;label="HF_inner/"<>ToString[ncInnerCounter];
 num=Numerator[rat];den=Denominator[rat];
 If[inner[[2]]=!=0||inner[[3]]=!=1||Exponent[den,yv]=!=1,
  Print["UNSUPPORTED_HF_TEST_INNER_DOMAIN ",InputForm[{inner,den}]];Exit[3]];
 {q,rem}=PolynomialQuotientRemainder[num,den,yv];
 a0=den/.yv->0;a1=Coefficient[den,yv];
 If[!TrueQ[Cancel[a1+xv a0]===0],Print["UNEXPECTED_HF_INNER_POLE"];Exit[3]];
 primitive=Sum[Coefficient[q,yv,k]yv^(k+1)/(k+1),{k,0,Max[0,Exponent[q,yv]]}]+
  rem/a1 Log[1-xv yv];
 integrated=Factor[Together[primitive/.yv->1]];
 ncExact[label<>"/primitive","HF_test_integration",Cancel[D[primitive,yv]-f],0,
  "Exact primitive of the actual saved kernel times the chosen physical-class HF input; 0<u<1, 0<v<1."];
 Do[sample={(1+lo)/2,(1+3lo)/4}[[i]];
  ncNumerical[label<>"/sample"<>ToString[i],"HF_test_integration",
  integrated/.xv->sample,ncOneIntegral[f/.xv->sample,inner],
  "Independent high-precision v quadrature checks the analytic inner integral."],
 {i,1,2}];
 AssociateTo[ncDetails,label-><|"original_integrand"->f,"canceled_integrand"->Factor[rat],
  "inner_primitive"->primitive,"integrated_inner"->integrated,"outer_domain"->outer,"inner_domain"->inner|>];
 Print[label," OUTER_QUADRATURE"];
 ncOneIntegral[integrated,outer]
];
ncNumericIntegrals[expr_]:=expr/.{
 Inactive[Integrate][f_,outer_List,inner_List]:>ncTwoIntegral[f,outer,inner],
 Inactive[Integrate][f_,range_List]:>ncOneIntegral[f,range]};
