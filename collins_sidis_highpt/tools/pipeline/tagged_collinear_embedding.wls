(* Independent collinear trace with the observed daughter physical.
   This diagnostic does not declare a process-level finite counterterm. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
out=Environment["SIDIS_COLLINEAR_OUT"];
If[!StringQ[out]||DirectoryQ[out],Print["Supply unused SIDIS_COLLINEAR_OUT"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
rt=Import[FileNameJoin[{root,"collins_ep_analytic_SIDIS","ru_runtime.json"}],"RawJSON"];
Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};Global`$FeynCalcStartupMessages=False;
Global`$FeynCalcDirectory=rt["feyncalc_root"];FeynCalc`$FeynArtsDirectory=rt["feynarts_root"];
Get[FileNameJoin[{rt["feyncalc_root"],"FeynCalc.m"}]];
FCClearScalarProducts[];
(* P=hh+v, hh is observed and physical; n is lightlike and physical.
   n.P=1, n.hh=z, P^2=m2; hh.s=0, v.s=P.s=aa.
   Parent spin is projected by s-aa n; nslash eliminates its n component.
   v_perp^2=-(1-z)m2/z, relative to hh and n. *)
keys={n,hh,v,pp,sspin};
gram={{0,z,1-z,1,0},{z,0,m2/2,m2/2,0},{1-z,m2/2,0,m2/2,aa},
 {1,m2/2,m2/2,m2,aa},{0,0,aa,aa,-1}};
radial=m2(1-z)/z;ehat=-radial+aa^2+bb^2;
Do[With[{a=keys[[i]],b=keys[[j]],g=gram[[i,j]],hv=If[MemberQ[{v,pp},keys[[i]]]&&MemberQ[{v,pp},keys[[j]]],ehat,0]},
 SPD[a,b]=g;SPE[a,b]=hv;SP[a,b]=g-hv],{i,5},{j,i,5}];
pol=-MTD[al,be]+(FVD[v,al]FVD[n,be]+FVD[n,al]FVD[v,be])/(1-z);
sphere[x_]:=Module[{num=Numerator[Together[x]],den=Denominator[Together[x]]},
 If[!FreeQ[den,aa|bb]||!PolynomialQ[num,{aa,bb}],Print["Unexpected angular denominator"];Exit[2]];
 Factor[Total[KeyValueMap[Function[{powers,coef},If[AnyTrue[powers,OddQ],0,
 coef radial^(Total[powers]/2)Times@@(Pochhammer[1/2,#/2]&/@powers)/Pochhammer[(D-2)/2,Total[powers]/2]]],
 Association[CoefficientRules[num,{aa,bb}]]]]/den]];
raw[scheme_]:=Module[{sin,sout},FCSetDiracGammaScheme[scheme];
 sin=If[scheme==="NDR",GSD[sspin]-aa GSD[n],GS[sspin]-aa GS[n]];
 sout=If[scheme==="NDR",GSD[sspin],GS[sspin]];
 Factor[CF Contract[DiracSimplify[DiracTrace[GSD[n].GA[5].sin.GSD[pp].GAD[be].GSD[hh].GA[5].sout.GAD[al].GSD[pp]]pol,DiracTraceEvaluate->True]]/(8m2)]];
nr=raw["NDR"];br=raw["BMHV"];na=sphere[nr];ba=sphere[br];
If[!FreeQ[{nr,br,na,ba},_Pair|_DiracTrace|_DiracGamma|$Failed|$Aborted],Print["Unevaluated trace"];Exit[3]];
diff=Factor[ba-na];literal=2CF z/(1-z);
geometry=<|"gramD"->gram,"hat_squared"->ehat,"radial_squared"->radial,
 "tagged_hat_residual"->FCI[SPE[hh,hh]],"momentum_conservation_gram_residuals"->FCI[Table[SPD[pp,x]-SPD[hh,x]-SPD[v,x],{x,keys}]],
 "parent_spin_orthogonality"->FCI[SPD[pp,sspin]-aa SPD[pp,n]],
 "daughter_spin_orthogonality"->FCI[SPD[hh,sspin]]|>;
result=<|"geometry"->geometry,"NDR_unaveraged"->nr,"BMHV_unaveraged"->br,
 "NDR"->na,"BMHV"->ba,"BMHV_minus_NDR"->diff,
 "difference_epsilon"->Series[diff/.D->4-2eps,{eps,0,2}],
 "NDR_minus_literal"->Factor[na-literal],"BMHV_minus_literal"->Factor[ba-literal],
 "literal_reference"->literal,"source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "qualification"->"Fixed physical daughter collinear trace. Relation to complete hard real amplitude, measured phase space and renormalized fragmentation operator is not yet established."|>;
Put[result,FileNameJoin[{out,"embedding.wl"}]];
Print["NDR ",InputForm[na]," BMHV ",InputForm[ba]," DIFFERENCE ",InputForm[diff]];
Exit[0];
