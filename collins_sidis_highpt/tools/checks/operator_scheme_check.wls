(* Separate universal collinear diagnostic: retain angular and evanescent terms.
   This does not substitute for process-specific NLO subtraction. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
base=FileNameJoin[{root,"collins_support","reports","sidis-highpt-001"}];If[StringQ[Environment["SIDIS_HIGHPT_REPORT_ROOT"]],base=Environment["SIDIS_HIGHPT_REPORT_ROOT"]];out=FileNameJoin[{base,"operator-scheme-002"}];
If[DirectoryQ[out],Print["Refuse output reuse"];Exit[1]];CreateDirectory[out];
rt=Import[FileNameJoin[{root,"collins_ep_analytic_SIDIS","ru_runtime.json"}],"RawJSON"];
Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};Global`$FeynCalcStartupMessages=False;
Global`$FeynCalcDirectory=rt["feyncalc_root"];FeynCalc`$FeynArtsDirectory=rt["feynarts_root"];
Get[FileNameJoin[{rt["feyncalc_root"],"FeynCalc.m"}]];
FCClearScalarProducts[];
keys={n,hh,v,pp,sspin};
gram={{0,z,1-z,1,0},{z,0,m2/2,m2/2,aa},{1-z,m2/2,0,m2/2,-aa},{1,m2/2,m2/2,m2,0},{0,aa,-aa,0,-1}};
Do[With[{a=keys[[i]],b=keys[[j]],g=gram[[i,j]]},SPD[a,b]=g],{i,5},{j,i,5}];
pol=-MTD[al,be]+(FVD[v,al]FVD[n,be]+FVD[n,al]FVD[v,be])/(1-z);
FCSetDiracGammaScheme["NDR"];
rawNDR=Factor[CF Contract[DiracSimplify[DiracTrace[GSD[n].GA[5].GSD[sspin].GSD[pp].GAD[be].GSD[hh].GA[5].(GSD[sspin]-aa/z GSD[n]).GAD[al].GSD[pp]]pol,DiracTraceEvaluate->True]]/(8m2)];
averageNDR=Factor[rawNDR/.aa^2->z(1-z)m2/(D-2)];
Put[<|"unaveraged"->rawNDR,"averaged"->averageNDR,"reference_x_less_1"->2CF z/(1-z),
 "difference"->Factor[averageNDR-2CF z/(1-z)]|>,FileNameJoin[{out,"ndr.wl"}]];
Print["NDR ",InputForm[averageNDR]];
FCSetDiracGammaScheme["BMHV"];
ehat=-z(1-z)m2+aa^2+bb^2;
Do[With[{a=keys[[i]],b=keys[[j]],g=gram[[i,j]],hv=If[MemberQ[{hh,v},keys[[i]]]&&MemberQ[{hh,v},keys[[j]]],If[i==j,ehat,-ehat],0]},
 SPE[a,b]=hv;SP[a,b]=g-hv],{i,5},{j,i,5}];
rawBMHV=Factor[CF Contract[DiracSimplify[DiracTrace[GSD[n].GA[5].GS[sspin].GSD[pp].GAD[be].GSD[hh].GA[5].(GS[sspin]-aa/z GS[n]).GAD[al].GSD[pp]]pol,DiracTraceEvaluate->True]]/(8m2)];
sphere[x_]:=Module[{num=Numerator[Together[x]],den=Denominator[Together[x]]},
 If[!FreeQ[den,aa|bb]||!PolynomialQ[num,{aa,bb}],Print["Unexpected angular rational function"];Exit[2]];
 Factor[Total[KeyValueMap[Function[{powers,coef},If[AnyTrue[powers,OddQ],0,
  coef (z(1-z)m2)^(Total[powers]/2) Times@@(Pochhammer[1/2,#/2]&/@powers)/Pochhammer[(D-2)/2,Total[powers]/2]]],Association[CoefficientRules[num,{aa,bb}]]]]/den]];
averageBMHV=sphere[rawBMHV];difference=Factor[averageBMHV-averageNDR];
Put[<|"unaveraged"->rawBMHV,"averaged"->averageBMHV,"difference_from_ndr"->difference,
 "difference_laurent"->Series[difference/.D->4-2eps,{eps,0,2}],
 "average_rule"->HoldComplete[aa^(2i)bb^(2j):>(z(1-z)m2)^(i+j)Pochhammer[1/2,i]Pochhammer[1/2,j]/Pochhammer[(D-2)/2,i+j]],
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "scope"->"Timelike collinear operator diagnostic; no DIS finite matching certified"|>,FileNameJoin[{out,"bmhv.wl"}]];
Print["BMHV ",InputForm[averageBMHV]," DIFFERENCE ",InputForm[difference]];
If[!FreeQ[{rawNDR,rawBMHV},_DiracTrace|_DiracGamma|_Pair|$Failed|$Aborted],Exit[3]];
(* Independent spacelike CFP arrangement: p on shell, k^2=ks<0,
   v=p-k on shell, n.k=x, p.n=1. Ref. hep-ph/9706511v2 Sec.3. *)
FCClearScalarProducts[];keys={n,pi,kk,v,sspin};
gram={{0,1,x,1-x,0},{1,0,ks/2,-ks/2,0},{x,ks/2,ks,-ks/2,aa},{1-x,-ks/2,-ks/2,0,-aa},{0,0,aa,-aa,-1}};
Do[With[{a=keys[[i]],b=keys[[j]],g=gram[[i,j]]},SPD[a,b]=g],{i,5},{j,i,5}];
pol=-MTD[al,be]+(FVD[v,al]FVD[n,be]+FVD[n,al]FVD[v,be])/(1-x);
FCSetDiracGammaScheme["NDR"];
spaceUU=Factor[Contract[DiracSimplify[DiracTrace[GSD[n].GSD[kk].GAD[be].GSD[pi].GAD[al].GSD[kk]]pol,DiracTraceEvaluate->True]]];
spaceT=Factor[Contract[DiracSimplify[DiracTrace[GSD[n].GA[5].GSD[sspin].GSD[kk].GAD[be].GSD[pi].GA[5].GSD[sspin].GAD[al].GSD[kk]]pol,DiracTraceEvaluate->True]]];
spaceTavg=Factor[spaceT/.aa^2->-ks(1-x)/(D-2)];
norm=Factor[(CF(1+x^2)/(1-x))/(spaceUU/.D->4)];
spaceNDR=Factor[norm spaceTavg];
FCSetDiracGammaScheme["BMHV"];ehat=ks(1-x)+aa^2+bb^2;
Do[With[{a=keys[[i]],b=keys[[j]],g=gram[[i,j]],hv=If[MemberQ[{kk,v},keys[[i]]]&&MemberQ[{kk,v},keys[[j]]],If[i==j,ehat,-ehat],0]},
 SPE[a,b]=hv;SP[a,b]=g-hv],{i,5},{j,i,5}];
spaceTBMHV=Factor[Contract[DiracSimplify[DiracTrace[GSD[n].GA[5].GS[sspin].GSD[kk].GAD[be].GSD[pi].GA[5].GS[sspin].GAD[al].GSD[kk]]pol,DiracTraceEvaluate->True]]];
spaceBMHV=Factor[norm(sphere[spaceTBMHV]/.{z(1-z)m2->-ks(1-x)})];
(* sphere is polynomial linear here; replace its radial scale by the
   spacelike radius before evaluating to avoid factoring-rule ambiguity. *)
spaceBMHV=Factor[norm Total[KeyValueMap[Function[{powers,coef},If[AnyTrue[powers,OddQ],0,
 coef(-ks(1-x))^(Total[powers]/2)Times@@(Pochhammer[1/2,#/2]&/@powers)/Pochhammer[(D-2)/2,Total[powers]/2]]],
 Association[CoefficientRules[Numerator[Together[spaceTBMHV]],{aa,bb}]]]]/Denominator[Together[spaceTBMHV]]];
Put[<|"UU_trace"->spaceUU,"T_trace_ndr"->spaceT,"T_trace_bmhv"->spaceTBMHV,
 "normalization_from_UU_tree"->norm,"normalized_UU"->Factor[norm spaceUU],
 "NDR"->spaceNDR,"BMHV"->spaceBMHV,"NDR_minus_reference"->Factor[spaceNDR-2CF x/(1-x)],
 "BMHV_minus_NDR"->Factor[spaceBMHV-spaceNDR],
 "BMHV_minus_NDR_laurent"->Series[(spaceBMHV-spaceNDR)/.D->4-2eps,{eps,0,2}],
 "assumptions"->HoldComplete[ks<0&&0<x<1],"note"->"The common normalization is fixed by the UU tree splitting, never by fitting the UT trace."|>,FileNameJoin[{out,"spacelike.wl"}]];
Print["SPACE UU ",InputForm[Factor[norm spaceUU]]," NDR ",InputForm[spaceNDR]," BMHV ",InputForm[spaceBMHV]];Exit[0];
