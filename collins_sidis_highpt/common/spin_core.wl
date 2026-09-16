(* Tagged external density matrices are inserted before spin information is lost. *)
HSLoadFC[rt_]:=(Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};
 Global`$FeynCalcStartupMessages=False;Global`$FeynCalcDirectory=rt["feyncalc_root"];
 FeynCalc`$FeynArtsDirectory=rt["feynarts_root"];
 Get[FileNameJoin[{rt["feyncalc_root"],"FeynCalc.m"}]];
 FeynArts`$FAVerbose=0;FeynCalc`FCSetDiracGammaScheme["BMHV"]);
HSDot[v_,w_]:=v.DiagonalMatrix[{1,-1,-1,-1}].w;
HSOnShell[x_]:=Module[{n,d,v=Together[x]},n=Numerator[v];d=Denominator[v];
 Factor[PolynomialRemainder[n,$HSConstraint,h]/PolynomialRemainder[d,$HSConstraint,h]]];
HSBornKinematics[]:=Module[{pv,qv,kv,keys,values},FCClearScalarProducts[];
 $HSConstraint=h^2-r z(1-z);
 pv={Q(1+r)/2,0,0,Q(1+r)/2};qv={0,0,0,-Q};
 kv={Q(r+(1-r)z)/2,Q h,0,Q(r-(1+r)z)/2};
 $HSVectors=<|p->pv,q->qv,k1->kv,k2->pv+qv-kv,
  pinX->{0,1,0,0},pinY->{0,0,1,0},
  poutX->{0,kv[[4]]/kv[[1]],0,-kv[[2]]/kv[[1]]},poutY->{0,0,1,0},
  phL->{1,0,0,0},phX->{0,1,0,0},phY->{0,0,1,0}|>;
 keys=Keys[$HSVectors];values=Values[$HSVectors];
 Do[With[{aa=keys[[i]],bb=keys[[j]],value=HSOnShell[HSDot[values[[i]],values[[j]]]]},
  SPD[aa,bb]=value;SP[aa,bb]=value;SPE[aa,bb]=0],{i,Length[keys]},{j,i,Length[keys]}];
 $HSVectors];
HSMarkTaggedSpinors[x_]:=x/.{
 Spinor[Momentum[p,D],mass_,sign_]:>Spinor[Momentum[hsIncomingTag,D],mass,sign],
 Spinor[Momentum[k1,D],mass_,sign_]:>Spinor[Momentum[hsObservedTag,D],mass,sign],
 Spinor[-Momentum[k1,D],mass_,sign_]:>Spinor[-Momentum[hsObservedTag,D],mass,sign]};
(* Only the artificial tags introduced inside Spinor heads can acquire spin
   projectors. Numerator occurrences of slash(p), slash(k1), and spectator
   spinors are untouched. The final common initial factor is 1/(2 Nc). *)
HSDensity[mode_,momentum_,spin_]:=Switch[mode,
 "U",GSD[momentum],"T",GSD[momentum].GA[5].GS[spin],
 "F",(GSD[momentum]+GSD[momentum].GA[5].GS[spin])/2,
 _,Print["Unknown density mode"];Abort[]];
HSTaggedSpinSum[left_,right_,mode_,sin_,sout_]:=Module[{square},
 square=FermionSpinSum[HSMarkTaggedSpinors[left] ComplexConjugate[HSMarkTaggedSpinors[right]],ExtraFactor->1/(2SUNN)];
 square/.{
 DiracGamma[Momentum[hsIncomingTag,D],D]:>HSDensity[mode,p,sin],
 DiracGamma[Momentum[hsObservedTag,D],D]:>HSDensity[mode,k1,sout]}];
HSContractScalar[x_]:=Module[{ans,color},
 ans=SUNSimplify[x,Explicit->True,SUNNToCACF->False];
 ans=Factor[ExpandScalarProduct[FeynAmpDenominatorExplicit[Contract[DiracSimplify[ans,DiracTraceEvaluate->True]]]]];
 If[!FreeQ[ans,_Pair|_Spinor|_DiracTrace|_DiracGamma|_SUNTF|_Real|$Failed|$Aborted],
  Print["NONSCALAR_OR_INEXACT_CONTRACTION"];Abort[]];
 ans=HSOnShell[ans];color=(SUNN^2-1)/(2SUNN);
 If[FreeQ[Cancel[ans/color],SUNN],Factor[Cancel[ans/color]CF],ans]];
HSBornContraction[amp_,mode_,photonA_,photonB_,sin_:pinX,sout_:poutX,gluonWard_:False]:=Module[{a,b,x},
 a=amp/.Polarization[q,___]->photonA;b=amp/.Polarization[q,___]->photonB;
 If[gluonWard,a=a/.Polarization[k2,___]->k2;b=b/.Polarization[k2,___]->k2];
 x=HSTaggedSpinSum[a,b,mode,sin,sout];
 If[!gluonWard,x=DoPolarizationSums[x,k2,p]];
 HSContractScalar[x/$HSChargeSquared]];
HSBornUUInvariant[amp_,projector_]:=Module[{a=amp,b=amp,x},
 If[projector=="Ppp",a=a/.Polarization[q,___]->p;b=b/.Polarization[q,___]->p];
 x=HSTaggedSpinSum[a,b,"U",pinX,poutX];
 If[projector=="Pg",x=-DoPolarizationSums[x,q,0,VirtualBoson->True]];
 x=DoPolarizationSums[x,k2,p];HSContractScalar[x/$HSChargeSquared]];
