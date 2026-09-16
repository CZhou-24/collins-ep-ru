(* Execute the reusable distribution action functions with independent
   regulated polynomial tests and exact physical coordinate identities. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
engine=FileNameJoin[{root,"collins_sidis_highpt"}];out=Environment["SIDIS_ACTION_CHECK_OUT"];
If[!StringQ[out]||DirectoryQ[out],Print["Need unused SIDIS_ACTION_CHECK_OUT"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
files=FileNameJoin[{engine,"common",#}]&/@{"observable_convolution.wl","observable_distribution_actions.wl"};
Get/@files;
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed"->name|>,FileNameJoin[{out,"failure.wl"}]];Exit[2]];
geometry=HSBreitWCoordinates[Q2,xB,pJT,u,zJ,ww];
original=HSBreitHardInvariants[Q2,xB,x,pJT,u,zJ];
checks=<|"w_reconstruction"->Factor[(original["w"]/.x->geometry["x"])-ww],
 "jacobian"->Factor[D[geometry["x"],ww]/geometry["x"]-geometry["dx_over_x"]],
 "upper_x"->Factor[(geometry["x"]/.ww->geometry["B"])-1],
 "lower_x"->Factor[geometry["x0"]-HSBreitConvolutionBounds[Q2,xB,pJT,u,zJ]["x_min"]],
 "lower_jet_B_zero"->Factor[geometry["B"]/.zJ->HSBreitConvolutionBounds[Q2,xB,pJT,u,zJ]["zJ_min"]]|>;
zeroTests=<||>;oneTests=<||>;
Do[
 test=ww^n;canonical=HSDistributionZeroAction[<|"Delta"->0,"L0"->1,"L1"->0,"Regular"->0|>,test,ww,B];
 actual=Activate[canonical];reference=If[n===0,0,B^n/n];
 AssociateTo[zeroTests,"L0_"<>ToString[n]->FullSimplify[actual-reference,B>0]];
 canonical=HSDistributionZeroAction[<|"Delta"->0,"L0"->0,"L1"->1,"Regular"->0|>,test,ww,B];
 actual=Activate[canonical];reference=If[n===0,0,-B^n/n^2];
 AssociateTo[zeroTests,"L1_"<>ToString[n]->FullSimplify[actual-reference,B>0]],{n,0,3}];
Do[
 test=zz^n;canonical=HSDistributionOneAction[<|"delta"->0,"plus0"->1,"plus1"->0,"regular"->0|>,test,zz,lower];
 actual=FullSimplify[Activate[canonical],0<lower<1];
 regulated=Integrate[zz^n/(1-zz),{zz,lower,1-cut},Assumptions->0<lower<1&&0<cut<1-lower,GenerateConditions->False]+Log[cut];
 reference=Limit[regulated,cut->0,Direction->"FromAbove"];
 AssociateTo[oneTests,"D0_"<>ToString[n]->FullSimplify[actual-reference,0<lower<1]],{n,0,3}];
Put[<|"geometry"->geometry,"coordinate_residuals"->checks,"zero_endpoint_tests"->zeroTests,"one_endpoint_tests"->oneTests,
 "definition"->"Hard Ln on [0,B] with B=w(x=1,zJ); jet Dn on [0,1] truncated at its derived physical lower bound",
 "source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,Append[files,$InputFileName]],
 "qualification"->"Convolution geometry and distribution actions only; actual finite hard coefficients still required"|>,FileNameJoin[{out,"actions.wl"}]];
gate["all exact action and geometry checks",And@@(#===0&/@Join[Values[checks],Values[zeroTests],Values[oneTests]])];
Print["OBSERVABLE_ACTION_CHECKS_COMPLETE ",Length[checks]+Length[zeroTests]+Length[oneTests]];Exit[0];
