(* Leading-power invariant convolution geometry. Hard kernels supplied to
   these functions must be derived finite coefficients; this file supplies
   neither C1 nor a default value for a missing channel. u=Exp[etaJ]. *)
HSBreitHardInvariants[Q2_,xB_,x_,pJT_,u_,zJ_]:=Module[{qscale=Sqrt[Q2]},
 <|"s"->Q2(x/xB-1),"t"->-Q2-qscale pJT(u-1/u)/zJ,
   "w"->(x/xB)(Q2-qscale pJT/(u zJ))-Q2-qscale pJT(u-1/u)/zJ|>];
HSBreitConvolutionBounds[Q2_,xB_,pJT_,u_,zJ_]:=Module[{qscale=Sqrt[Q2]},
 <|"zJ_min"->pJT/qscale(1/u+xB u/(1-xB)),
   "x_min"->xB(Q2 zJ+qscale pJT(u-1/u))/(Q2 zJ-qscale pJT/u)|>];
HSInvariantPDFJetConvolution[integrand_,x_,zJ_,Q2_,xB_,pJT_,u_]:=With[
 {bounds=HSBreitConvolutionBounds[Q2,xB,pJT,u,zJ]},
 Inactive[Integrate][integrand/(x zJ^2),{zJ,bounds["zJ_min"],1},{x,bounds["x_min"],1}]];
(* Fhats include the archived hardNormalization. This linear conversion keeps
   that normalization; multiply by (2 Pi)^4 to recover the raw current tensor.
   Equality to the actual Born basis is checked separately. *)
HSUUPhotonFromFhats[f1_,f2_,xh_]:=<|"L"->f2/(2xh)-f1,"T"->2f1|>;
HSAzimuthAveragedLepton[L_,T_,Q2_,y_]:=Q2/y^2(4(1-y)L+(1+(1-y)^2)T);
HSConsistentAsymmetry[uu0_,uu1_,ut0_,ut1_,a_]:=
 ut0/uu0+a(ut1/uu0-ut0 uu1/uu0^2);
