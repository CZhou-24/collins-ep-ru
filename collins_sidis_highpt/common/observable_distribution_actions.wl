(* Explicit action of the measured hard and jet distributions. No hard
   coefficient, flavor weight or nonperturbative function is supplied here.
   This implements the convolution measure dx/x dzJ/zJ^2. *)
ClearAll[HSBreitWCoordinates,HSDistributionZeroAction,HSDistributionOneAction,
 HSBreitHardAction,HSBreitBornJetAction];

HSBreitWCoordinates[Q2_,xB_,pJT_,u_,zJ_,ww_]:=Module[
 {qscale=Sqrt[Q2],slope,offset,xx},
 slope=(Q2-qscale pJT/(u zJ))/xB;
 offset=-Q2-qscale pJT(u-1/u)/zJ;
 xx=(ww-offset)/slope;
 <|"x"->xx,"x0"->(-offset)/slope,"s"->Q2(xx/xB-1),
   "t"->offset,"w"->ww,"B"->slope+offset,"dw_dx"->slope,
   "dx_over_x"->1/(slope xx)|>];

(* coefficient functions include their full smooth w dependence and test
   weight; B is independent of w. Ln=[log^n(w/B)/w]_+ on [0,B]. *)
HSDistributionZeroAction[coefficients_Association,test_,ww_,upper_]:=Module[
 {weighted,delta,regular,plus0,plus1},
 weighted=Map[# test&,coefficients];
 delta=weighted["Delta"]/.ww->0;
 regular=Inactive[Integrate][weighted["Regular"],{ww,0,upper}];
 plus0=Inactive[Integrate][(weighted["L0"]-(weighted["L0"]/.ww->0))/ww,{ww,0,upper}];
 plus1=Inactive[Integrate][Log[ww/upper](weighted["L1"]-(weighted["L1"]/.ww->0))/ww,{ww,0,upper}];
 delta+regular+plus0+plus1];

(* Dn=[log^n(1-z)/(1-z)]_+ is defined on [0,1]. The lower-bound terms
   are required when the physical test function has support z>=lower. *)
HSDistributionOneAction[coefficients_Association,test_,zz_,lower_]:=Module[
 {weighted,atOne},weighted=Map[# test&,coefficients];
 atOne=Map[(#/.zz->1)&,KeyTake[weighted,{"delta","plus0","plus1"}]];
 atOne["delta"]+atOne["plus0"]Log[1-lower]+atOne["plus1"]Log[1-lower]^2/2+
 Inactive[Integrate][weighted["regular"]+
  (weighted["plus0"]-atOne["plus0"])/(1-zz)+
  Log[1-zz](weighted["plus1"]-atOne["plus1"])/(1-zz),{zz,lower,1}]];

(* Supply evaluated hard distributions in symbols {s,t,w,B}, and a PDF
   expression in x. This is C1*J0: zJ is fixed at one by the tree jet. *)
HSBreitHardAction[hard_Association,pdf_,xx_,ww_,Q2_,xB_,pJT_,u_]:=Module[
 {geometry,rules,coefficients,weight},
 geometry=HSBreitWCoordinates[Q2,xB,pJT,u,1,ww];
 rules={s->geometry["s"],t->geometry["t"],w->ww,B->geometry["B"]};
 coefficients=Map[#/.rules&,hard];
 weight=(pdf/.xx->geometry["x"])geometry["dx_over_x"];
 HSDistributionZeroAction[coefficients,weight,ww,geometry["B"]]];

(* This is C0*J1. Integrate the Born delta(w) exactly before applying the
   jet distribution. jet coefficients are canonical functions of zz. *)
HSBreitBornJetAction[born_,jet_Association,pdf_,xx_,zz_,Q2_,xB_,pJT_,u_]:=Module[
 {geometry,lower,weight},
 geometry=HSBreitWCoordinates[Q2,xB,pJT,u,zz,0];
 lower=HSBreitConvolutionBounds[Q2,xB,pJT,u,zz]["zJ_min"];
 weight=(born/.{s->geometry["s"],t->geometry["t"],w->0})
  (pdf/.xx->geometry["x0"])geometry["dx_over_x"]/zz^2;
 HSDistributionOneAction[jet,weight,zz,lower]];
