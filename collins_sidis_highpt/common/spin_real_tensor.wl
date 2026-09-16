(* Full photon/spin components before the Collins angular projection.
   Uses the physical tagged-leg BMHV geometry from spin_nlo.wl. *)
HSRealTensorPair[left_,right_,photons_List,spins_List,gluons_List,density_:"T",average_:True,ward_:None]:=Module[{aa,bb,x},
 If[Length[photons]=!=2||Length[spins]=!=2,Print["TENSOR_COMPONENT_ARITY"];Abort[]];
 aa=left/.Polarization[q,___]->photons[[1]];
 bb=right/.Polarization[q,___]->photons[[2]];
 If[ward=!=None,aa=aa/.Polarization[ward,___]->ward;bb=bb/.Polarization[ward,___]->ward];
 x=HSTaggedSpinSum[aa,bb,density,spins[[1]],spins[[2]]];
 x=SUNSimplify[x,Explicit->True,SUNNToCACF->False];
 Do[If[leg=!=ward,x=DoPolarizationSums[x,leg,p]],{leg,gluons}];
 x=Contract[DiracSimplify[x,DiracTraceEvaluate->True]];
 x=ExpandScalarProduct[FeynAmpDenominatorExplicit[x]];
 If[!FreeQ[x,_Pair|_Spinor|_DiracTrace|_DiracGamma|_SUNTF|_SUNTrace|_Real|$Failed|$Aborted],
  Print["REAL_TENSOR_NONSCALAR ",InputForm[DeleteDuplicates[Cases[x,_Pair,Infinity]]]];Abort[]];
 If[TrueQ[average],HSSphereAverage[x/$HSChargeSquared],HSOnShell[x/$HSChargeSquared]]];
HSRealHermitianPair[left_,right_,photons_List,spins_List,gluons_List,diagonal_:False,density_:"T"]:=Module[{a,b},
 a=HSRealTensorPair[left,right,photons,spins,gluons,density];
 If[TrueQ[diagonal],Return[a]];
 b=If[photons[[1]]===photons[[2]],a,HSRealTensorPair[left,right,Reverse[photons],spins,gluons,density]];
 Factor[a+ComplexExpand[Conjugate[b]]]];
