(* Physical external spin bases with D-dimensional unresolved momenta.
   The residual (D-3)-sphere is averaged before scalar integral mapping.
   No epsilon terms of that angular average are discarded. *)
HSRealKinematics[]:=Module[{pv,qv,kv,rv,keys,values,ep,ek,kz,ez,rx,rz,ehat,perp},
 FCClearScalarProducts[];
 ep=(Q^2+s)/(2Q);kz=-(Q^2+t)/(2Q);
 ek=kz+Q(Q^2+s+t-w)/(Q^2+s);
 $HSConstraint=h^2-(ek^2-kz^2);
 pv={ep,0,0,ep};qv={0,0,0,-Q};kv={ek,h,0,kz};
 rz=(w+a+b)/(2Q);ez=rz-a/(2ep);rx=(ek ez-kz rz-b/2)/h;
 rv={ez,rx,-ny,rz};
 $HSRealPerp=HSOnShell[-HSDot[rv,rv]/.ny->0];
 ehat=HSOnShell[-HSDot[rv,rv]];
 $HSVectors=<|p->pv,q->qv,k1->kv,k2->rv,k3->pv+qv-kv-rv,
  pinX->{0,1,0,0},pinY->{0,0,1,0},poutX->{0,kz/ek,0,-h/ek},poutY->{0,0,1,0},
  phL->{1,0,0,0},phX->{0,1,0,0},phY->{0,0,1,0}|>;
 keys=Keys[$HSVectors];values=Values[$HSVectors];
 Do[With[{aa=keys[[i]],bb=keys[[j]],value=HSOnShell[HSDot[values[[i]],values[[j]]]],
    hatvalue=If[MemberQ[{k2,k3},keys[[i]]]&&MemberQ[{k2,k3},keys[[j]]],
      If[keys[[i]]===keys[[j]],ehat,-ehat],0]},
   SP[aa,bb]=value;SPE[aa,bb]=hatvalue;SPD[aa,bb]=HSOnShell[value+hatvalue]],
  {i,Length[keys]},{j,i,Length[keys]}];
 <|"vectors4"->$HSVectors,"evanescent_k2_squared"->ehat,"residual_perp_squared"->$HSRealPerp,
  "cut_residuals"->{SPD[k2,k2],SPD[k3,k3],HSOnShell[2SPD[k2,k3]-w]},
  "invariant_residuals"->{HSOnShell[2SPD[p,k2]+a],HSOnShell[2SPD[k1,k2]-b]},
  "external_constraint"->$HSConstraint,
  "physical_cuts"->HoldComplete[k2energy>0&&k3energy>0],
  "unresolved_dimension"->D-3|>];
HSSphereAverage[expr_]:=Module[{v=Together[expr],num,den,degree},
 num=Numerator[v];den=Denominator[v];
 If[!FreeQ[den,ny]||!PolynomialQ[num,ny],Print["NLO_ANGULAR_NUMERATOR_NOT_POLYNOMIAL"];Abort[]];
 degree=Exponent[num,ny];
 HSOnShell[Sum[Coefficient[num,ny,2j](-$HSRealPerp)^j Pochhammer[1/2,j]/Pochhammer[(D-3)/2,j],
  {j,0,Floor[degree/2]}]/den]];
HSPhysicalPhoton[x_]:=x/.Momentum[Polarization[q,args___],D]:>Momentum[Polarization[q,args]];
HSRealPair[left_,right_,mode_,spinIn_,spinOut_,gluons_List,ward_:None]:=Module[{aa=left,bb=right,x},
 Switch[mode,"Ppp",aa=aa/.Polarization[q,___]->p;bb=bb/.Polarization[q,___]->p,
  "PhotonWard",aa=aa/.Polarization[q,___]->q;bb=bb/.Polarization[q,___]->q,
  "Pg",aa=HSPhysicalPhoton[aa];bb=HSPhysicalPhoton[bb],
  _,Print["Unknown NLO photon contraction"];Abort[]];
 If[ward=!=None,aa=aa/.Polarization[ward,___]->ward;bb=bb/.Polarization[ward,___]->ward];
 x=HSTaggedSpinSum[aa,bb,"T",spinIn,spinOut];
 x=SUNSimplify[x,Explicit->True,SUNNToCACF->False];
 If[mode=="Pg",x=-DoPolarizationSums[x,q,0,VirtualBoson->True]];
 Do[If[leg=!=ward,x=DoPolarizationSums[x,leg,p]],{leg,gluons}];
 x=Contract[DiracSimplify[x,DiracTraceEvaluate->True]];
 x=ExpandScalarProduct[FeynAmpDenominatorExplicit[x]];
 If[!FreeQ[x,_Pair|_Spinor|_DiracTrace|_DiracGamma|_SUNTF|_Real|$Failed|$Aborted],
  Print["NLO_NONSCALAR_CONTRACTION ",InputForm[DeleteDuplicates[Cases[x,_Pair,Infinity]]]];Abort[]];
 HSSphereAverage[x/$HSChargeSquared]];
