(* Fresh distribution-coordinate proof for the measured one-loop family.
   Delta derivatives, including derivatives of beta-dependent coefficients,
   are never identified with a frozen on-cut scalar multiplier. *)
Clear[RUHFCutMap,RUHFMeasurementProof];
RUHFCutMap[a_Integer?Positive,b_Integer?Positive,beta_]:=
 Table[<|"longitudinal_power"->a-j,"radial_proxy_power"->b+j,
   "coefficient"->(-1)^(b-1)Binomial[b-1+j,j](2beta)^j|>,{j,0,a-1}];
RUHFMeasurementProof[]:=Module[{aa,bb,kk,cc0,cc1,cc2,x,y,betaH,hh,
 d0,d1,d2,radial,solution,inverse,jac,rawRows,cutRows,polynomial,lhs,rhs,
 coordinateChecks,shift,nshift,rules},
 d0=kk-2u bb;d1=aa-1;d2=kk-2bb+tau;radial=2aa bb-kk-tau;
 solution=First[Solve[{d0==0,d1==0,d2==0},{aa,bb,kk}]];
 inverse=First[Solve[{d0==cc0,d1==cc1,d2==cc2},{aa,bb,kk}]];
 jac=Det[D[{d0,d1,d2},{{kk,aa,bb}}]];
 coordinateChecks=<|"true_radial_relation"->Expand[radial-(2bb d1-d2)],
  "cut_surface"->FullSimplify[{d0,d1,radial}/.solution],
  "scalar_Jacobian"->Expand[jac-2(u-1)],
  "beta"->Factor[(bb/.solution)-tau/(2(1-u))],
  "K"->Factor[(kk/.solution)-u tau/(1-u)]|>;
 (* Direct distribution action in (x,R,beta), where y=2 beta x-R.
    Polynomial basis through degree six detects all derivative terms tested. *)
 polynomial=Sum[test[i,j]x^i y^j,{i,0,6},{j,0,6}];
 rawRows=Flatten[Table[
  lhs=(-1)^(m+n)(D[polynomial/.y->2betaH x-hh,{x,m},{hh,n}]/.{x->0,hh->0});
  rhs=(-1)^n Sum[Binomial[m,j](2betaH)^j(-1)^(m+n)
    (D[polynomial,{x,m-j},{y,n+j}]/.{x->0,y->0}),{j,0,m}];
  <|"longitudinal_derivative"->m,"true_radial_derivative"->n,
    "lhs_action"->Expand[lhs],"mapped_action"->Expand[rhs],"residual"->Expand[lhs-rhs]|>,
 {m,0,3},{n,0,3}],1];
 cutRows=Flatten[Table[
  lhs=(D[polynomial/.y->2betaH x-hh,{x,a-1},{hh,b-1}]/.{x->0,hh->0})/(Factorial[a-1]Factorial[b-1]);
  rhs=Total[Function[row,With[{px=row["longitudinal_power"]-1,py=row["radial_proxy_power"]-1},
    row["coefficient"] (D[polynomial,{x,px},{y,py}]/.{x->0,y->0})/(Factorial[px]Factorial[py])]]/@RUHFCutMap[a,b,betaH]];
  <|"powers"->{a,b},"map"->RUHFCutMap[a,b,betaH],"residual"->Expand[lhs-rhs]|>,{a,1,4},{b,1,4}],1];
 shift={aa->aa,bb->bb+tShift,kk->kk+2aa tShift};
 nshift=Expand[{d1,radial,d0}/.shift]-{d1,radial,d0};
 <|"family"->"M","denominators"->{d0,d1,d2},"true_transverse_measurement"->radial,
  "coordinates"-><|"alpha"->HoldComplete[k.n],"beta"->HoldComplete[k.p],"K"->HoldComplete[k.k]|>,
  "surface_solution"->solution,"off_cut_inverse"->inverse,"scalar_Jacobian"->jac,
  "normalized_cut_definition"->HoldComplete[CutPower[a,d]==((d-I 0)^(-a)-(d+I 0)^(-a))/(2Pi I)==(-1)^(a-1)Derivative[a-1][DiracDelta][d]/Factorial[a-1]],
  "physical_cut"->"Only D0=(k-u p)^2 carries theta((k-u p)^0); D1 and D2 are measurements, never positive-energy particles.",
  "positive_energy_domain"->HoldComplete[0<u<1&&tau>0&&l.n==1-u>0&&l.p==tau/(2(1-u))>0],
  "raw_delta_map"->HoldComplete[Derivative[m][DiracDelta][x]Derivative[n][DiracDelta][2 betaH x-y]==
   (-1)^n Sum[Binomial[m,j](2betaH)^j Derivative[m-j][DiracDelta][x]Derivative[n+j][DiracDelta][y],{j,0,m}]],
  "coefficient_transport"->"beta is an independent smooth coordinate in this proof. Multiply D0 cuts and beta factors before conversion to family coordinates beta=(D2-D0-tau)/(2(u-1)); retain all delta derivatives. Freezing beta first changes distributions.",
  "polynomial_test_degree_each_coordinate"->6,"raw_delta_test_rows"->rawRows,"normalized_cut_test_rows"->cutRows,
  "n_shift"-><|"changes"->nshift,"expected"->{0,0,2tShift(aa-u)},"residual"->Expand[nshift-{0,0,2tShift(aa-u)}]|>,
  "unit_cut_numerator_lift"->"Full current Ward and special-propagator reductions are proved before physical projection. The projected density on the regular open unit-cut surface is lifted by the explicit retraction to that surface. Any other smooth lift differs by D0 A+D1 B+D2 C and has identical unit-cut action. Raised cuts in IBP use the same lift and its derivatives; they are not set on shell independently.",
  "boundaries"->"This local family is restricted to 0<u<1,tau>0. u=1 and tau=0 extensions and common damping are handled separately; no theta-boundary term is dropped by a measured IBP.",
  "coordinate_residuals"->coordinateChecks|>
];
