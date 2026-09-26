(* Imported one-loop semi-inclusive standard-axis TMD FJF matching.
   Primary source arXiv:2311.00672v2 Sec.3.1.2, literal source/snippets
   retained under references/. This import is not a DIS hard derivation.
   D0,D1 are [1/(1-z)]_+,[log(1-z)/(1-z)]_+ on [0,1]. *)
ClearAll[HSJetMatching,HSJetCanonical,HSJetDistributionAction];
HSJetMatching["U","q","q",z_,L_]:=(
 CF delta1[-L^2/2-3L/2+Pi^2/12]+L CF ((1+z^2)D0+3delta1[1]/2)
 -2CF(1+z^2)D1-CF(1-z));
HSJetMatching["U","q","g",z_,L_]:=CF((L-2Log[1-z])(1+(1-z)^2)/z-z);
HSJetMatching["U","g","q",z_,L_]:=TF((L-2Log[1-z])(z^2+(1-z)^2)-2z(1-z));
HSJetMatching["U","g","g",z_,L_]:=(
 delta1[-CA L^2/2-beta0 L/2+CA Pi^2/12]
 +L(2CA(z D0+(1-z)/z+z(1-z))+beta0 delta1[1]/2)
 -4CA(1-z+z^2)^2 D1/z);
HSJetMatching["T","q","q",z_,L_]:=
 L CF(2z D0+3delta1[1]/2)+CF(-4z D1+delta1[-3L/2-L^2/2+Pi^2/12]);
HSJetCanonical[expression_,z_]:=Module[{v=Expand[expression/.delta1[c_]:>c dd],c0,c1,reg},
 c0=Coefficient[v,D0];c1=Coefficient[v,D1];
 reg=v/.{D0->0,D1->0,dd->0};
 <|"delta"->Factor[Coefficient[v,dd]],"plus0"->Factor[c0/.z->1],
 "plus1"->Factor[c1/.z->1],
 "regular"->Factor[reg+(c0-(c0/.z->1))/(1-z)+(c1-(c1/.z->1))Log[1-z]/(1-z)]|>];
HSJetDistributionAction[c_,test_,z_]:=c["delta"](test/.z->1)
 +Inactive[Integrate][c["plus0"](test-(test/.z->1))/(1-z)
 +c["plus1"]Log[1-z](test-(test/.z->1))/(1-z)+c["regular"]test,{z,0,1}];
(* Coefficient expansion only. Nonperturbative PDFs/TMDs remain symbolic;
   this operator never fills in a missing hard C1 with a model value. *)
HSTruncateHardJet[c0_,c1_,j0_,j1_,a_]:=Normal[Series[(a c0+a^2 c1)(j0+a j1),{a,0,2}]];
