(* Reused generating transforms; see provenance/soft. No old evaluated radial input. *)
(* Executed integral reductions. Theta boundaries and analytic rapidity
   indices stay outside the integer-index radial Kira family. *)
RUSoftReductionChain[]:=Module[{a,b,dd,t,u,delta,aa,rr,yy,rad,lambda,kappa,
 betaValue,laplaceValue,gaussianValue,besselValue,stdJac,stdIntegrand,
 stdValue,coneValue,injetValue,jac,parameterPowers,tIntegral,globalValue,
 globalSpecial,stdRegular,globalRegular},
 betaValue=Integrate[u^(a-1) (1-u)^(b-1),{u,0,1},Assumptions->a>0&&b>0];
 laplaceValue=Integrate[t^(delta-1) Exp[-aa t],{t,0,Infinity},Assumptions->delta>0&&aa>0];
 gaussianValue=Integrate[Exp[-t rr^2],{rr,-Infinity,Infinity},Assumptions->t>0];
 besselValue=Integrate[t^(delta-1) BesselJ[0,2 Sqrt[aa t]],{t,0,Infinity},
                      Assumptions->aa>0&&0<delta<1/4];
 RUGate["executed Euler, Laplace, Gaussian and physical-azimuth integrals",
      FreeQ[{betaValue,laplaceValue,gaussianValue,besselValue},_Integrate|$Failed]];
 (* u=exp(-2y), 2 sinh(y)=(1-u)/sqrt(u). Reversing endpoints makes the
    absolute Jacobian positive. Both rapidity hemispheres are retained. *)
 stdJac=-2 D[-Log[u]/2,u];
 stdIntegrand=PowerExpand[((1-u)/Sqrt[u])^(-eta)] stdJac;
 RUGate["standard rapidity change of variable",FullSimplify[
       stdIntegrand-u^(eta/2-1) (1-u)^(-eta),0<u<1&&0<eta<1]===0];
 stdValue=betaValue/.{a->eta/2,b->1-eta};
 (* Two-center integral: lambda=t u, kappa=t(1-u), determinant t;
    complete the square at w=(1-u)e and integrate the normalized Gaussian.
    The t integral then leaves the beta integral with exchanged indices. *)
 jac=Abs[Det[{{D[t u,t],D[t u,u]},{D[t (1-u),t],D[t (1-u),u]}}]];
 jac=FullSimplify[jac,t>0];
 parameterPowers=FullSimplify[(t u)^(a-1) (t (1-u))^(b-1) jac
                (gaussianValue/Sqrt[Pi])^dd, t>0&&0<u<1];
 tIntegral=laplaceValue/.{delta->a+b-dd/2,aa->u (1-u)};
 globalValue=FullSimplify[Gamma[a+b-dd/2]/(Gamma[a] Gamma[b])
                         (betaValue/.{a->dd/2-b,b->dd/2-a})];
 globalSpecial=globalValue/.{a->eta/2-eps,b->1,dd->2-2 eps};
 globalSpecial=globalSpecial/.Gamma[q_]:>Gamma[Expand[q]];
 (* Apply Gamma recurrence BEFORE reflection/simplification: eta Gamma[eta/2]
    is 2 Gamma[1+eta/2]. This removes only a removable singularity and makes
    the eta-first derivative evaluable without 0 times ComplexInfinity. *)
 stdRegular=Cancel[eta (stdValue/.Gamma[eta/2]->2 Gamma[1+eta/2]/eta)];
 globalRegular=Cancel[eta (globalSpecial/.Gamma[eta/2]->2 Gamma[1+eta/2]/eta)];
 RUGate["regularized rapidity factors equal executed integrals",
      FullSimplify[stdRegular-eta stdValue]===0&&
      FullSimplify[globalRegular-eta globalSpecial]===0];
 coneValue=Integrate[2 rr^(-1-2 eps),{rr,rad,Infinity},Assumptions->rad>0&&eps>0];
 injetValue=Integrate[Exp[-eta yy],{yy,-g/2,Infinity},Assumptions->eta>0&&Element[g,Reals]];
 RUGate["executed cone and jet-local rapidity integrations",FreeQ[{coneValue,injetValue},_Integrate|$Failed]];
 <|"Euler_integrand"->u^(a-1) (1-u)^(b-1),"Euler_evaluated"->betaValue,
   "Euler_domain"->HoldComplete[a>0&&b>0],
   "Laplace_integrand"->t^(delta-1) Exp[-aa t],"Laplace_evaluated"->laplaceValue,
   "Gaussian_evaluated"->gaussianValue,
   "physical_azimuth_integrand"->t^(delta-1) BesselJ[0,2 Sqrt[aa t]],
   "physical_azimuth_evaluated"->besselValue,
   "physical_azimuth_domain"->"A>0, 0<delta<1/4 for absolute convergence; analytic continuation in delta=-eps-eta/2 afterwards.",
   "radial_gamma_ratio"->FullSimplify[besselValue/.{aa->1,delta->-eps-eta/2}],
   "standard_original"->HoldComplete[2 Integrate[(2 Sinh[yy])^(-eta),{yy,0,Infinity}]],
   "standard_substitution"->HoldComplete[u==Exp[-2 yy]],
   "standard_Jacobian"->stdJac,"standard_parameter_integrand"->stdIntegrand,
   "standard_rapidity_evaluated"->stdValue,"standard_domain"->"0<Re(eta)<1",
   "eta_standard_regular"->stdRegular,
   "global_original"->HoldComplete[Integrate[(w.w)^(-a) ((w-e).(w-e))^(-b),{w,EuclideanSpace[dd]}]/Pi^(dd/2)],
   "global_indices"->{a->eta/2-eps,b->1,dd->2-2 eps},
   "global_Schwinger"->HoldComplete[lambda^(a-1) kappa^(b-1) Exp[-lambda w.w-kappa (w-e).(w-e)]/(Gamma[a] Gamma[b])],
   "global_square_completion"->HoldComplete[lambda w.w+kappa (w-e).(w-e)==t (w-(1-u)e).(w-(1-u)e)+t u(1-u)],
   "global_parameter_Jacobian"->jac,"global_parameter_powers"->parameterPowers,
   "global_scale_integral_evaluated"->tIntegral,
   "global_beta_integrand"->u^(dd/2-b-1) (1-u)^(dd/2-a-1),
   "global_general_evaluated"->globalValue,
   "global_angular_evaluated"->globalSpecial,
   "eta_global_regular"->globalRegular,
   "rapidity_regularization_identity"->HoldComplete[eta Gamma[eta/2]==2 Gamma[1+eta/2]],
   "global_domain"->"a,b>0, d/2-a>0, d/2-b>0, a+b-d/2>0. Here eps<0 and 0<eta<2; the scalar integrals admit meromorphic continuation afterwards.",
   "narrow_cone_step"->"Expand cosh(y-Y)-cos(phi) and the E-scheme anti-kt boundary locally to rho^2/2 and rho>R; retain this approximation only in cone sectors.",
   "cone_original"->2 rr^(-1-2 eps),"cone_lower_boundary"->rad,
   "cone_evaluated"->coneValue,"cone_log_evaluated"->FullSimplify[coneValue/.rad->Exp[r/2],Element[r,Reals]],
   "cone_domain"->"Re(eps)>0 for the out-of-cone angular integral alone; continue its evaluated meromorphic result before multiplying the separately regulated radial integral.",
   "injet_original"->Exp[-eta yy],"injet_lower_boundary"->-g/2,
   "injet_rapidity_evaluated"->injetValue,"injet_domain"->"Re(eta)>0, real g",
   "continuation_order"->"Evaluate each factor in its own nonempty convergence domain, continue Beta/Gamma functions, expand eta first at fixed noninteger eps, cancel unexpanded eta residues, and only then expand eps. Kira never differentiates a cone boundary."|>
];
