(* Photon completeness and Collins angular extraction, before reducing to F1/F2.
   All three angles are independent in the coefficient-defining Fourier moment.
   phi is the lepton-plane azimuth in production-plane coordinates: phi=-phiJ. *)
HSLeptonDensity[]:=Module[{metric=DiagonalMatrix[{1,-1,-1,-1}],ell,ellp,qv,lten},
 qv={0,0,0,-Q};ell={Q(2-y)/(2y),Q kap Cos[phi]/y,Q kap Sin[phi]/y,-Q/2};ellp=ell-qv;
 lten=2(Outer[Times,ell,ellp]+Outer[Times,ellp,ell]-metric Q^2/2);
 <|"incoming"->ell,"outgoing"->ellp,"tensor_contravariant"->lten,
  "basis_density"->lten[[1;;3,1;;3]],
  "residuals"->{Expand[ell.metric.ell]//TrigReduce,Expand[ellp.metric.ellp]//TrigReduce,
    Expand[lten.metric.qv]//TrigReduce}/.kap^2->1-y//Simplify|>];
HSAngularFromTensor[tensor_Association]:=Module[{lep,rho,labels={"L","X","Y"},uu,tt,spin,analyzer,ut,reduce,average,traceMoment},
 reduce[x_]:=Factor[TrigReduce[Expand[x]]/.kap^2->1-y];
 average[x_,angle_]:=reduce[Integrate[TrigReduce[Expand[x]],{angle,0,2Pi}]/(2Pi)];
 lep=HSLeptonDensity[];rho=lep["basis_density"];
 uu=reduce[Sum[rho[[a,b]]tensor["UU_"<>labels[[a]]<>labels[[b]]],{a,3},{b,3}]];
 tt=Table[reduce[Sum[rho[[a,b]]tensor["T"<>ToString[i]<>ToString[j]<>"_"<>labels[[a]]<>labels[[b]]],{a,3},{b,3}]],{i,2},{j,2}];
 spin={Cos[phiS],Sin[phiS]};analyzer={-Sin[phih],Cos[phih]}jT/(zh Mh);
 ut=reduce[spin.tt.analyzer];
 traceMoment=average[Tr[tt]/2,phi];
 <|"lepton"->lep,"UU_resolved"->uu,"spin_transfer_resolved"->tt,"UT_resolved"->ut,
 "UU_azimuth_average"->average[uu,phi],"Collins_moment_coefficient"->traceMoment,
 "moment_definition"->HoldComplete[2 Integrate[Sin[phiS-phih]UT,{phi,0,2Pi},{phiS,0,2Pi},{phih,0,2Pi}]/(2Pi)^3],
 "hadron_azimuth_residual"->average[ut,phih],
 "spin_reversal_residual"->reduce[(ut/.phiS->phiS+Pi)+ut],
 "moment_residual"->reduce[average[average[average[2Sin[phiS-phih]ut,phih],phiS],phi]-jT/(zh Mh)traceMoment],
 "assumptions"->HoldComplete[0<y<1&&kap>0&&kap^2==1-y&&zh>0&&Mh>0&&jT>=0],
 "qualification"->"Coefficient-defining Fourier projection averages phi, phiS and phih independently. A fixed laboratory spin azimuth with phiS dependent on phiJ is a different integration and is not silently substituted."|>];
