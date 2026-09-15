(* Collins-specific strict first-order algebra. Kernel symbols below are explicit
   unresolved inputs, never substituted from the accepted engine or its exports. *)
RUFormalFirstOrder[bornUU_,bornUT_,hard_]:=Module[{uu,ut,ratio,direct},
 uu=Expand[Normal[Series[bornUU(1+a hard)(f0+a f1)(d0+a d1)(1+a soft1),{a,0,1}]]];
 ut=Expand[Normal[Series[bornUT(1+a hard)(h0+a h1)(c0+a c1)(1+a soft1),{a,0,1}]]];
 ratio=Normal[Series[ut/uu,{a,0,1}]];
 direct=bornUT h0 c0/(bornUU f0 d0)+a bornUT/(bornUU f0 d0)(h1 c0+h0 c1-h0 c0(f1/f0+d1/d0));
 <|"UU"->uu,"UT"->ut,"ratio"->ratio,"ratio_direct"->direct,
 "ratio_identity_residual"->Factor[Together[ratio-direct]],
 "assumptions"->HoldComplete[bornUU f0 d0!=0],
 "kernel_status"->"f1,d1,h1,c1,soft1 stand for renormalized convolution coefficients still requiring the measured RU integrations; they are not supplied by the inclusive quark pilot.",
 "physical_HF_contacts"->HoldComplete[contact0 Phi[1]-contact1 PhiPrime[1]],
 "physical_class"->HoldComplete[Phi[1]==0&&PhiPrime[1]==0],
 "generic_contacts_status"->"Undetermined; no generic zero coefficients assigned.",
 "Fourier_measures"->HoldComplete[Integrate[bq bh/(4 Pi^2 zh^2) BesselJ[0,bq qT] BesselJ[0,bh jT/zh] Soft[bq] BeamUU[bq] FragmentUU[bh],{bq,0,Infinity},{bh,0,Infinity}],Integrate[bq bh^2/(8 Pi^2 zh^3) BesselJ[0,bq qT] BesselJ[1,bh jT/zh] Soft[bq] BeamUT[bq] CollinsScalar[bh],{bq,0,Infinity},{bh,0,Infinity}]],
 "Fourier_status"->"Declared accepted comparison convention only; direct RU operator-measure conversion and Collins moment normalization remain uncompleted."|>];
