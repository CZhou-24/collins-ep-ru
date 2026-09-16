(* BMHV loop contractions with physical tagged external states. The component
   orthogonal to span(p,q,k1) is integrated over D-3 dimensions, not set to zero. *)
HSVirtualKinematics[]:=Module[{ep,ek,kz,le,lx,lz,lv,bar0,keys},
 HSBornKinematics[];ep=$HSVectors[p][[1]];ek=$HSVectors[k1][[1]];kz=$HSVectors[k1][[4]];
 lz=loopQ/Q;le=loopP/ep+lz;lx=(ek le-kz lz-loopK)/(Q h);
 lv={le,lx,-ny,lz};bar0=HSOnShell[HSDot[lv,lv]/.ny->0];
 $HSRealPerp=HSOnShell[loop2-bar0];
 SP[ell,ell]=HSOnShell[bar0-ny^2];SPD[ell,ell]=loop2;SPE[ell,ell]=HSOnShell[loop2-bar0+ny^2];
 keys=Keys[$HSVectors];
 Do[With[{a=key,value=HSOnShell[HSDot[lv,$HSVectors[key]]]},SP[ell,a]=value;SPD[ell,a]=value;SPE[ell,a]=0],{key,keys}];
 <|"loop_vector4"->lv,"loop_hat_squared"->FCI[SPE[ell,ell]],"residual_transverse_squared"->$HSRealPerp,
 "dimension"->D-3,"invariant_residuals"->(HSOnShell/@FCI[{SPD[ell,p]-loopP,SPD[ell,q]-loopQ,SPD[ell,k1]-loopK}]),
 "angular_average"->HoldComplete[ny^(2j):>(-$HSRealPerp)^j Pochhammer[1/2,j]/Pochhammer[(D-3)/2,j]]|>];
HSVirtualTensor[loop_,born_,photons_List,spins_List,density_:"T"]:=Module[{aa,bb,x},
 aa=loop/.Polarization[q,___]->photons[[1]];bb=born/.Polarization[q,___]->photons[[2]];
 x=HSTaggedSpinSum[aa,bb,density,spins[[1]],spins[[2]]];
 x=SUNSimplify[x,Explicit->True,SUNNToCACF->False];
 x=DoPolarizationSums[x,k2,p];
 x=Contract[DiracSimplify[x,DiracTraceEvaluate->True]];
 x=ExpandScalarProduct[FeynAmpDenominatorExplicit[x]];
 If[!FreeQ[x,_Pair|_Spinor|_DiracTrace|_DiracGamma|_SUNTF|_SUNTrace|_Real|$Failed|$Aborted],
  Print["VIRTUAL_NONSCALAR ",InputForm[DeleteDuplicates[Cases[x,_Pair,Infinity]]]];Abort[]];
 HSSphereAverage[x/$HSChargeSquared]];
HSVirtualMap[value_,topology_]:=Module[{variables={loop2,loopP,loopQ,loopK},coords={v1,v2,v3,v4},props,rules,expr,num,den,powers,constant,rows,residual},
 If[value===0,Return[<|"coefficients"-><||>,"targets"->{},"reconstruction_residual"->0,"topology"->topology|>]];
 props=HSOnShell[ExpandScalarProduct[1/FeynAmpDenominatorExplicit[#]]]&/@topology[[2]];
 rules=Solve[Thread[props==coords],variables];
 If[Length[rules]=!=1,Print["VIRTUAL_INCOMPLETE_BASIS"];Abort[]];
 expr=Together[value/.First[rules]];num=Expand[Numerator[expr]];den=Factor[Denominator[expr]];
 powers=Exponent[den,#]&/@coords;constant=Cancel[den/Times@@MapThread[Power,{coords,powers}]];
 If[!PolynomialQ[num,coords]||!FreeQ[constant,Alternatives@@coords],Print["VIRTUAL_NONLAURENT_MAP"];Abort[]];
 rows=Association[(GLI[topology[[1]],powers-First[#]]->HSOnShell[Last[#]/constant])&/@CoefficientRules[num,coords]];
 residual=HSOnShell[value-Total[KeyValueMap[Function[{integral,c},c Times@@MapThread[Power,{props,-integral[[2]]}]],rows]]];
 If[residual=!=0,Print["VIRTUAL_RECONSTRUCTION_FAILED ",InputForm[residual]];Abort[]];
 <|"coefficients"->rows,"targets"->Keys[rows],"reconstruction_residual"->residual,"topology"->topology|>];
