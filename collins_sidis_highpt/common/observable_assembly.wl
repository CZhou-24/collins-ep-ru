(* Assemble the named azimuthally averaged Collins moment only after actual
   finite hard banks have been supplied. No missing hard coefficient has a
   default. Scalar coefficient exports retain their separate branch labels. *)
ClearAll[HSPhysicalBranch,HSPhotonDistribution,HSBornMeasurementAction,
 HSUUHardBank,HSUTHardBank,HSFlavorSum,HSJetFlavorSum,HSTMDInput,
 HSBuildChannelObservable];
HSPhysicalBranch[branches_Association]:=Piecewise[{
 {branches[1]/.omega->s+t,s+t>0},{branches[-1]/.omega->-s-t,s+t<0}},branches[0]];
HSPhotonDistribution[bank_Association,Q2_,y_]:=Association@Table[
 dist->HSAzimuthAveragedLepton[bank[dist]["L"],bank[dist]["T"],Q2,y],
 {dist,{"Delta","L0","L1","Regular"}}];
HSBornMeasurementAction[born_,pdf_,xx_,Q2_,xB_,pJT_,u_]:=Module[{geometry},
 geometry=HSBreitWCoordinates[Q2,xB,pJT,u,1,0];
 (born/.{s->geometry["s"],t->geometry["t"],w->0})
  (pdf/.xx->geometry["x0"])geometry["dx_over_x"]];

HSUUHardBank[channel_,imported_Association]:=Module[{record=imported[channel],leading,nlo},
 leading=record["LO"];
 If[AssociationQ[leading],
  nlo=Association@Table[dist->Association@Table[pol->HSPhysicalBranch[
    Association@Table[sign->record["NLO"][sign][dist][pol],{sign,{1,-1,0}}]],
    {pol,{"L","T"}}],{dist,{"Delta","L0","L1","Regular"}}],
  nlo=record["NLO"]["ordinary"]];
 <|"LO"->leading,"NLO"->nlo|>];

(* Strip-to-a conversion: gs^2=8 Pi^2 a, Born cut phase=2 Pi delta(w).
   The NLO real/virtual phase is already in the hard input. *)
HSUTHardBank["Hqq",hard_Association,boundary_Association,antiquark_Association]:=Module[{leading,nlo},
 leading=Association@Table[pol->16Pi^3 eq^2 hard["Born_D4"]["Collins_"<>pol],{pol,{"L","T"}}];
 nlo=Association@Table[dist->Association@Table[pol->64Pi^4 eq^2 HSPhysicalBranch[
   Join[Association@Table[sign->hard["Hqq"]["Collins_"<>pol<>"_"<>ToString[sign]]["finite_candidate"][dist],{sign,{1,-1}}],
    <|0->boundary["boundary"]["Collins_"<>pol]["finite"][dist]|>]],{pol,{"L","T"}}],{dist,{"Delta","L0","L1","Regular"}}];
 <|"LO"->leading,"NLO"->nlo|>];
HSUTHardBank["Hqqbar",hard_Association,boundary_Association,antiquark_Association]:=
 <|"LO"->Missing["NoBornHardChannel"],"NLO"->Association@Table[dist->Association@Table[
  pol->64Pi^4 eq^2 antiquark["Hqqbar"]["Collins_"<>pol][dist],{pol,{"L","T"}}],{dist,{"Delta","L0","L1","Regular"}}]|>;

HSFlavorSum["Hgg",value_,nf_]:=value;
HSFlavorSum["Hqqprime",value_,nf_]:=Inactive[Sum][value,{i,1,nf},{sigma,{-1,1}},{j,1,nf},{tau,{-1,1}}];
HSFlavorSum[channel_,value_,nf_]:=Inactive[Sum][value,{i,1,nf},{sigma,{-1,1}}];
HSJetFlavorSum[parent_,child_,value_,nf_]:=If[parent==="g"&&ListQ[child],
 Inactive[Sum][value,{j,1,nf},{tau,{-1,1}}],value];
HSTMDInput["U",flavor_,zh_,jT_,Mh_,mu_,zeta_]:=
 HSInverseMoment[Function[bb,D1Tilde[flavor,zh,bb,mu,zeta]],0,zh,jT,Mh];
HSTMDInput["T",flavor_,zh_,jT_,Mh_,mu_,zeta_]:=
 (jT/(zh Mh))HSInverseMoment[Function[bb,H1perpTilde1[flavor,zh,bb,mu,zeta]],1,zh,jT,Mh];

HSBuildChannelObservable[channel_,sector_,bank_Association,parameters_Association]:=Module[
 {nf=parameters["Nf"],Q2=parameters["Q2"],xB=parameters["xB"],pJT=parameters["pJT"],u=parameters["u"],
  y=parameters["y"],zh=parameters["zh"],jT=parameters["jT"],Mh=parameters["Mh"],R=parameters["R"],mu=parameters["mu"],
  route,incoming,parent,weight,flavorRules,scaleRules,lo,nlo,pdf,tmd,leading=0,hardCorrection,jetCorrection=0,jetRows={},
  jetRoute,child,jet,jetAction,hardAction,born,L,xx,ww,zz},
 route=First[If[sector==="U",HSUUFlavorRoutes[channel],HSUTFlavorRoutes[channel]]];
 {incoming,parent,weight}=route;flavorRules=HSFlavorRules[channel,incoming,parent,nf];
 scaleRules={Global`mu->mu,mu2->mu^2,muR->mu,muPDF->mu,muFF->mu,
  SUNN->Nc,FeynCalc`SUNN->Nc,CF->(Nc^2-1)/(2Nc),CA->Nc,TF->1/2,beta0->(11Nc-2nf)/3,Nf->nf};
 lo=bank["LO"]/.flavorRules/.scaleRules;nlo=bank["NLO"]/.flavorRules/.scaleRules;
 pdf=If[sector==="U",f1[incoming,xx,mu],h1[incoming,xx,mu]];
 tmd=HSTMDInput[sector,parent,zh,jT,Mh,mu,(pJT R)^2];
 hardAction=HSBreitHardAction[HSPhotonDistribution[nlo,Q2,y],pdf,xx,ww,Q2,xB,pJT,u];
 hardCorrection=HSFlavorSum[channel,weight tmd hardAction,nf];
 If[AssociationQ[lo],
  born=HSAzimuthAveragedLepton[lo["L"],lo["T"],Q2,y];
  leading=HSFlavorSum[channel,weight tmd HSBornMeasurementAction[born,pdf,xx,Q2,xB,pJT,u],nf];
  L=Log[mu^2/(pJT R)^2];
  Do[child=jetRoute[[1]];jet=HSJetCanonical[HSJetMatching[sector,HSFlavorKind[parent],HSFlavorKind[child],zz,L],zz]/.scaleRules;
   jetAction=HSBreitBornJetAction[born,jet,pdf,xx,zz,Q2,xB,pJT,u];
   AppendTo[jetRows,HSJetFlavorSum[parent,child,weight jetRoute[[2]] HSTMDInput[sector,child,zh,jT,Mh,mu,(pJT R)^2]jetAction,nf]],
   {jetRoute,HSJetFlavorRoutes[sector,parent]}];
  jetCorrection=HSFlavorSum[channel,Total[jetRows],nf]];
 <|"LO"->leading,"hard_NLO"->hardCorrection,"Born_times_jet_NLO"->jetCorrection,
  "NLO"->hardCorrection+jetCorrection,"flavor_route"->route,"flavor_rules"->flavorRules,
  "common_scale_map"->scaleRules,"TMD_input"->tmd|>];
