(* Independent one-loop transversity-operator Dirac numerators. This tests the
   virtual endpoint that a real x<1 splitting limit does not determine.
   Gamma=slash(n) gamma5 slash(S), rho=slash(p) gamma5 slash(S), p.n=1.
   The complete scalar integrals and operator subtraction are separate. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
out=Environment["SIDIS_OPERATOR_VIRTUAL_OUT"];
If[!StringQ[out]||DirectoryQ[out],Print["Need unused operator output"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
rt=Import[FileNameJoin[{root,"collins_ep_analytic_SIDIS","ru_runtime.json"}],"RawJSON"];
Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};Global`$FeynCalcStartupMessages=False;
Global`$FeynCalcDirectory=rt["feyncalc_root"];FeynCalc`$FeynArtsDirectory=rt["feynarts_root"];
Get[FileNameJoin[{rt["feyncalc_root"],"FeynCalc.m"}]];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["OPERATOR_VIRTUAL_FAILED ",name];Exit[2]];
FCClearScalarProducts[];keys={p,n,ell,spin};
gram={{0,1,lp,0},{1,0,ln,0},{lp,ln,l2,ls},{0,0,ls,-1}};
Do[With[{a=keys[[i]],b=keys[[j]],g=gram[[i,j]],hat=If[i===3&&j===3,lhat,0]},
 SPD[a,b]=g;SPE[a,b]=hat;SP[a,b]=g-hat],{i,4},{j,i,4}];
scalar[x_]:=Factor[Together[Contract[DiracSimplify[x,DiracTraceEvaluate->True]]]];
traces=<||>;
Do[FCSetDiracGammaScheme[scheme];sp=If[scheme==="NDR",GSD[spin],GS[spin]];
 nn=If[scheme==="NDR",GSD[n],GS[n]];rho=GSD[p].GA[5].sp;vertex=nn.GA[5].sp;
 values=<|"Born"->scalar[DiracTrace[rho.vertex]],
  "vertex"->scalar[DiracTrace[rho.GAD[al].(GSD[p]-GSD[ell]).vertex.(GSD[p]-GSD[ell]).GAD[al]]],
  "Wilson_left"->scalar[DiracTrace[rho.vertex.(GSD[p]-GSD[ell]).nn]],
  "Wilson_right"->scalar[DiracTrace[rho.nn.(GSD[p]-GSD[ell]).vertex]],
  "UV_angular_vertex"->scalar[DiracTrace[rho.GAD[al].GAD[be].vertex.GAD[be].GAD[al]]]/D|>;
 gate["all operator traces evaluated exactly",FreeQ[values,_DiracTrace|_DiracGamma|_Pair|_Real|$Aborted|$Failed]];
 AssociateTo[traces,scheme->values],{scheme,{"BMHV","NDR"}}];
differences=AssociationMap[Factor[traces["BMHV"][#]-traces["NDR"][#]]&,Keys[traces["BMHV"]]];
transverse=l2-2lp ln;
averageRules={ls^2->-transverse/(D-2),lhat->(D-4)transverse/(D-2)};
averaged=Map[Factor[Expand[#]/.averageRules]&,differences];
series=Map[Series[#/.D->4-2eps,{eps,0,2}]&,averaged];
reference=FileNameJoin[{root,"collins_sidis_highpt","references","hep-ph-9706511v2","source","transvnlo.tex"}];
Put[<|"traces"->traces,"differences"->differences,"azimuth_averaged_differences"->averaged,
 "epsilon_differences"->series,"gramD"->gram,"loop_hat_squared"->lhat,
 "angular_rules"->averageRules,"transverse_dimension"->D-2,
 "operator_definition"->HoldComplete[GammaT==slash[n].gamma5.slash[spin]],
 "density_definition"->HoldComplete[rhoT==slash[p].gamma5.slash[spin]],
 "UV_angular_definition"->HoldComplete[Average[ell[mu]ell[nu]]==l2 metricD[mu,nu]/D],
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "reference_sha256"->IntegerString[FileHash[reference,"SHA256"],16,64],
 "reference_location"->"hep-ph/9706511v2 Sec.3 density and CFP projector; signs reordered by anticommuting physical gamma5 and transverse slash",
 "qualification"->"Virtual-operator numerator and UV angular diagnostics only. A finite operator-conversion conclusion also requires its scalar UV/IR definition and real endpoint assembly."|>,FileNameJoin[{out,"operator-virtual.wl"}]];
Print["OPERATOR_VIRTUAL_NUMERATORS_COMPLETE ",InputForm[averaged]];Exit[0];
