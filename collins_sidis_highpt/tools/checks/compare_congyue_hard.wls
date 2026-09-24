#!/usr/bin/env wolframscript
(* Independent comparison of our inclusive polarized hard coefficients (before
   any jet/TMD matching) against Congyue's SIDIS_HighPT_TT_HardCoefficients.

   Congyue's files are comparison INPUTS only. No coefficient of ours is
   replaced, and no tolerance or convention is tuned to force agreement.

   Derived conversions (see the accompanying report):
     variables   Q2, x, z, w with s=Q2(1-x)/x, W=Q2(1-x)(1-z)(1-w)/x,
                 t=W-Q2(1-z)/x; our distribution variable is W, theirs is w.
     endpoint    A=Q2(1-x)(1-z)/x is the upper limit of W; our plus scale B->A,
                 so Log[W/B]=Log[1-w] and [1/W]_+ dW = [1/(1-w)]_+ dw.
     photon      our transverse component is the SUM over the two physical
                 photon polarizations, Congyue's is the AVERAGE: kappa_T=2.
     couplings   our hard has eq^2 gs^(2n) stripped;
                 LO  = aS   16 Pi^3 eq^2 Born_D4,
                 NLO = aS^2 64 Pi^4 eq^2 finite_candidate, aS=alphas/(2 Pi).
     flavor      otherChargeMoment_n = Sum_f e_f^n - e_q^n with the external
                 quark up-type: nU eU^n + nD eD^n - eU^n; Nf = nU+nD.
     scales      muR->Sqrt[muR2], muPDF->Sqrt[muF2], muFF->Sqrt[muD2].
     Jacobian    Delta and plus coefficients: ours = A*kappa*theirs.
                 Interior density: ours(dW) = kappa*theirs(dw).
     Delta and plus coefficients are read at W->0 (w->1), which also fixes t.

   Environment:
     SIDIS_CONGYUE_PACKAGE    extracted package directory
     SIDIS_NATIVE_HARD_INPUT  our native-hard.wl
     SIDIS_COMPARE_OUT        unused output directory
     SIDIS_COMPARE_SYMBOLIC   "false" skips the symbolic pass (default "true")
     SIDIS_COMPARE_TIMEOUT    seconds per individual symbolic simplification (default 180)
*)
$HistoryLength=0;
pkg=Environment["SIDIS_CONGYUE_PACKAGE"];nativeFile=Environment["SIDIS_NATIVE_HARD_INPUT"];
out=Environment["SIDIS_COMPARE_OUT"];
doSymbolic=Environment["SIDIS_COMPARE_SYMBOLIC"]=!="false";
tmo=If[StringQ[Environment["SIDIS_COMPARE_TIMEOUT"]]&&StringLength[Environment["SIDIS_COMPARE_TIMEOUT"]]>0,
  ToExpression[Environment["SIDIS_COMPARE_TIMEOUT"]],180];
If[!StringQ[out]||DirectoryQ[out]||!StringQ[pkg]||!DirectoryQ[pkg]||!StringQ[nativeFile]||!FileExistsQ[nativeFile],
  Print["Need package directory, native hard input and an unused output directory"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
prec=60;

native=Get[nativeFile];hard=native["hard"];bornD4=native["Born_D4"];
cong=<|"LO_qq"->Get[FileNameJoin[{pkg,"LO","q-q","Results.wl"}]],
       "NLO_qq"->Get[FileNameJoin[{pkg,"NLO","q-q","Results.wl"}]],
       "NLO_qqb"->Get[FileNameJoin[{pkg,"NLO","q-qb","Results.wl"}]]|>;

AA=Q2 (1-x)(1-z)/x;
sX=Q2 (1-x)/x;
wX=Q2 (1-x)(1-z)(1-w)/x;
tX=wX-Q2 (1-z)/x;
aS=\[Alpha]s/(2 Pi);
kappa=<|"T"->2,"L"->1|>;
comp=<|"T"->1,"L"->2|>;
flavorRules={Global`otherChargeMoment2->nU eU^2+nD eD^2-eU^2,
             Global`otherChargeMoment1->nU eU+nD eD-eU,
             Global`otherChargeMoment[2]->nU eU^2+nD eD^2-eU^2,
             Global`otherChargeMoment[1]->nU eU+nD eD-eU,
             Global`eq2->eU^2,Global`eq->eU,Global`Nf->nU+nD};
physicsRules=Join[{Global`SUNN->CA,FeynCalc`SUNN->CA,Global`CF->(CA^2-1)/(2 CA),
  Global`muR->Sqrt[muR2],Global`muPDF->Sqrt[muF2],Global`muFF->Sqrt[muD2],Global`mu->Sqrt[muR2]},flavorRules];
oursSub[sign_]:=Join[{Global`B->AA,Global`omega->sign (tX+sX),Global`s->sX,Global`t->tX,Global`w->wX},physicsRules];

ourFinite[ch_,pol_,sign_,dist_]:=hard[ch]["Collins_"<>pol<>"_"<>ToString[sign]]["finite_candidate"][dist];
(* coefficients restored to absolute normalization, in Congyue variables *)
oursNLO[ch_,pol_,sign_,dist_]:=aS^2 64 Pi^4 eU^2 (ourFinite[ch,pol,sign,dist]/.oursSub[sign]);
oursLOdelta[pol_]:=aS 16 Pi^3 eU^2 (bornD4["Collins_"<>pol]/.physicsRules);
(* our interior density in dW, restored *)
oursInteriorW[ch_,pol_,sign_]:=(oursNLO[ch,pol,sign,"Regular"]+
  oursNLO[ch,pol,sign,"L0"]/wX+Log[wX/AA] oursNLO[ch,pol,sign,"L1"]/wX);

cDelta[rec_,pol_]:=With[{v=rec["Coefficients"][0]["DeltaCoefficient"]},If[v===0,0,v[[comp[pol]]]]];
cReg[rec_,pol_]:=With[{v=rec["Coefficients"][0]["RegularCoefficient"]},If[v===0,0,v[[comp[pol]]]]];
cPlus[rec_,pol_,n_]:=With[{p=rec["Coefficients"][0]["PlusCoefficients"]},
  If[KeyExistsQ[p,n],With[{v=p[n]},If[v===0,0,v[[comp[pol]]]]],0]];
cInteriorW[rec_,pol_]:=cReg[rec,pol]+Total[Table[cPlus[rec,pol,n] Log[1-w]^n/(1-w),{n,0,2}]];

scales={Q2->1,muR2->2,muF2->3,muD2->5,CA->3,CF->4/3,eU->2/3,eD->-1/3,nU->2,nD->3,\[Alpha]s->1/5};
altScales={Q2->7/2,muR2->7/2,muF2->7/2,muD2->7/2,CA->3,CF->4/3,eU->2/3,eD->-1/3,nU->2,nD->3,\[Alpha]s->1/5};
chan=<|"Hqq"->"NLO_qq","Hqqbar"->"NLO_qqb"|>;

rows={};
push[a_]:=(AppendTo[rows,a];
 Print[StringPadRight[a["comparison"],40],StringPadRight[a["point"],30],
  "  ours=",StringPadRight[If[NumberQ[a["ours"]],ToString[NumberForm[N[a["ours"],10],10]],ToString[a["ours"]]],26],
  "  theirs=",StringPadRight[If[NumberQ[a["theirs"]],ToString[NumberForm[N[a["theirs"],10],10]],ToString[a["theirs"]]],26],
  "  rel=",StringPadRight[If[NumberQ[a["relative_difference"]],ToString[ScientificForm[N[a["relative_difference"],3]]],ToString[a["relative_difference"]]],14],
  "  ",a["verdict"]]);
relDiff[a_,b_]:=Which[!NumberQ[a]||!NumberQ[b],"UNRESOLVED",
  Abs[a]+Abs[b]==0,0,True,Abs[a-b]/Max[Abs[a],Abs[b]]];
verdict[a_,b_,r_]:=Which[r==="UNRESOLVED","UNRESOLVED (non-numeric)",
  a==0&&b==0,"BOTH ZERO",r<10^-40,"NUMERICAL AGREEMENT",r<10^-12,"NUMERICAL AGREEMENT (reduced precision)",
  True,"DISCREPANCY"];
record[label_,ptlabel_,o_,th_]:=Module[{r=relDiff[o,th]},
  push[<|"comparison"->label,"point"->ptlabel,"ours"->o,"theirs"->th,
    "relative_difference"->r,"verdict"->verdict[o,th,r],"kind"->"numerical"|>]];
(* Harmless precision messages must not be read as a failed evaluation; only a
   value that is not a number counts as unresolved, and its leftover symbols
   are reported. *)
ev[e_,rules_]:=Module[{v},v=Quiet[N[e/.rules,prec]];
  If[NumberQ[v]&&FreeQ[v,Indeterminate|ComplexInfinity|_DirectedInfinity],v,
   "UNRESOLVED:"<>ToString[Take[DeleteDuplicates[Cases[v,y_Symbol/;Context[y]=!="System`",Infinity]],UpTo[6]]]]];

(* -------- points -------- *)
(* endpoint points: Delta / plus coefficients live at W->0 (w->1); branch = Sign[z-x] *)
endpointPts={<|"l"->"x=1/3,z=2/5 (x<z)","x"->1/3,"z"->2/5,"sc"->scales|>,
 <|"l"->"x=1/2,z=1/3 (x>z)","x"->1/2,"z"->1/3,"sc"->scales|>,
 <|"l"->"x=1/4,z=3/5 (x<z)","x"->1/4,"z"->3/5,"sc"->scales|>,
 <|"l"->"x=7/10,z=1/5 (x>z)","x"->7/10,"z"->1/5,"sc"->scales|>,
 <|"l"->"x=1/3,z=2/5 equal scales","x"->1/3,"z"->2/5,"sc"->altScales|>};
(* interior points: 0<w<1, branch = Sign[t+s] *)
interiorPts={<|"l"->"x=1/3,z=2/5,w=3/4","x"->1/3,"z"->2/5,"w"->3/4,"sc"->scales|>,
 <|"l"->"x=1/2,z=1/3,w=3/4","x"->1/2,"z"->1/3,"w"->3/4,"sc"->scales|>,
 <|"l"->"x=1/4,z=3/5,w=1/5","x"->1/4,"z"->3/5,"w"->1/5,"sc"->scales|>,
 <|"l"->"x=3/5,z=1/4,w=9/10","x"->3/5,"z"->1/4,"w"->9/10,"sc"->scales|>,
 <|"l"->"x=7/10,z=1/5,w=1/2","x"->7/10,"z"->1/5,"w"->1/2,"sc"->scales|>,
 <|"l"->"x=z=2/5,w=3/4 (removable)","x"->2/5,"z"->2/5,"w"->3/4,"sc"->scales|>,
 <|"l"->"x=z=1/2,w=3/5 (removable)","x"->1/2,"z"->1/2,"w"->3/5,"sc"->scales|>,
 <|"l"->"x=z=1/2,w=3/5 eq scales","x"->1/2,"z"->1/2,"w"->3/5,"sc"->altScales|>};

Print["================ NUMERICAL COMPARISON ================"];
Print["rule: Delta/plus  ours = A*kappa_pol*theirs (read at W->0);  interior ours(dW) = kappa_pol*theirs(dw)"];
Print[];Print["---- LO q-q, delta coefficient ----"];
Do[Do[rl=Join[p["sc"],{x->p["x"],z->p["z"]}];
  record["LO q-q Delta "<>pol,p["l"],ev[oursLOdelta[pol],rl],ev[AA kappa[pol] cDelta[cong["LO_qq"],pol],rl]],
 {p,endpointPts}],{pol,{"T","L"}}];

Print[];Print["---- NLO delta and plus coefficients (at W->0) ----"];
Do[Do[Do[
  sgn=If[p["z"]>p["x"],1,-1];
  rl=Join[p["sc"],{x->p["x"],z->p["z"],w->1}];
  Do[record[ch<>" NLO "<>dk<>" "<>pol<>" br"<>ToString[sgn],p["l"],
     ev[oursNLO[ch,pol,sgn,dk],rl],
     ev[AA kappa[pol] If[dk==="Delta",cDelta[cong[chan[ch]],pol],cPlus[cong[chan[ch]],pol,If[dk==="L0",0,1]]],rl]],
   {dk,{"Delta","L0","L1"}}],
 {p,endpointPts}],{pol,{"T","L"}}],{ch,{"Hqq","Hqqbar"}}];

Print[];Print["---- NLO interior density (0<w<1) ----"];
Do[Do[Do[
  rl=Join[p["sc"],{x->p["x"],z->p["z"],w->p["w"]}];
  tps=N[(tX+sX)/.rl,30];sgn=If[tps>0,1,-1];
  record[ch<>" NLO interior "<>pol<>" br"<>ToString[sgn],p["l"],
    ev[oursInteriorW[ch,pol,sgn],rl],ev[kappa[pol] cInteriorW[cong[chan[ch]],pol],rl]],
 {p,interiorPts}],{pol,{"T","L"}}],{ch,{"Hqq","Hqqbar"}}];

(* -------- removable branch boundary x=z: two-sided limit of the delta coefficient -------- *)
Print[];Print["---- removable boundary x=z: our two branches vs Congyue at x=z ----"];
Do[Do[Do[
  base=p["sc"];zz=p["z"];
  thv=ev[AA kappa[pol] If[dk==="Delta",cDelta[cong["NLO_qq"],pol],cPlus[cong["NLO_qq"],pol,If[dk==="L0",0,1]]],
         Join[base,{x->zz,z->zz,w->1}]];
  Do[Module[{o6,o10,e6,e10,ratio},
    o6=ev[oursNLO["Hqq",pol,-sgn,dk],Join[base,{x->zz+sgn 10^-6,z->zz,w->1}]];
    o10=ev[oursNLO["Hqq",pol,-sgn,dk],Join[base,{x->zz+sgn 10^-10,z->zz,w->1}]];
    e6=If[NumberQ[o6]&&NumberQ[thv],Abs[o6-thv],"UNRESOLVED"];
    e10=If[NumberQ[o10]&&NumberQ[thv],Abs[o10-thv],"UNRESOLVED"];
    ratio=If[NumberQ[e6]&&NumberQ[e10]&&e10>0,e6/e10,"UNRESOLVED"];
    push[<|"comparison"->"Hqq NLO "<>dk<>" "<>pol<>" br"<>ToString[-sgn]<>" x=z limit",
      "point"->"x=z"<>If[sgn>0,"+","-"]<>"d, z="<>ToString[zz,InputForm],"ours"->o10,"theirs"->thv,
      "relative_difference"->If[NumberQ[e10]&&NumberQ[thv]&&thv=!=0,e10/Abs[thv],"UNRESOLVED"],
      (* A coefficient independent of x is already exact at any offset, so the
         error ratio is undefined; that is agreement, not an unresolved row. *)
      "verdict"->Which[!NumberQ[e6]||!NumberQ[e10],"UNRESOLVED (non-numeric)",
        e6==0&&e10==0,"EXACT AT BOUNDARY (offset-independent)",
        !NumberQ[ratio],"UNRESOLVED (non-numeric)",
        ratio>3000,"REMOVABLE-LIMIT CONVERGENCE",ratio>30,"REMOVABLE-LIMIT CONVERGENCE (slow)",
        True,"NO CONVERGENCE"],"kind"->"one-sided limit",
      "error_at_1e-6"->e6,"error_at_1e-10"->e10,"error_ratio"->ratio|>]],
    {sgn,{1,-1}}],
 {p,{<|"z"->2/5,"sc"->scales|>,<|"z"->1/2,"sc"->scales|>}}],{dk,{"Delta","L0","L1"}}],{pol,{"T"}}];

(* -------- distribution action on smooth test functions -------- *)
Print[];Print["---- distribution action on smooth test functions, w in (1/10,1) (endpoint-conversion test) ----"];
(* Sours[t] = Delta_o t(1) + Int_0^1 dw { A*interiorW(w)*t(w) - [L0_o(0)+L1_o(0)Log[1-w]] t(1)/(1-w) }
   must equal A*kappa*SC[t] with SC Congyue's own plus-prescription action. *)
tests={<|"l"->"t=1","f"->Function[ww,1]|>,<|"l"->"t=w","f"->Function[ww,ww]|>,
  <|"l"->"t=Exp[w]","f"->Function[ww,Exp[ww]]|>};
wp=20;
(* The substituted integrands are cached per channel/component/point: the cost
   is substituting the kinematics into the large expressions, not the quadrature
   points. Eight digits is more than this endpoint-convention test needs. *)
(* The action test probes the w->1 endpoint, where the delta and plus structure
   lives. The opposite end w->0 is the zero-transverse-momentum limit: the
   interior carries a 1/(s t + Q2 W) pole there on both sides, so the w integral
   converges at neither implementation and that end is outside both scopes. The
   integrand identity is pointwise in w, so restricting both sides to the same
   sub-range (wLow,1) still tests the endpoint conversion exactly. *)
wLow=1/10;
quad[g_]:=NIntegrate[g[ww],{ww,wLow,1},WorkingPrecision->wp,MaxRecursion->10,
  PrecisionGoal->8,AccuracyGoal->8,Method->{"GlobalAdaptive","SymbolicProcessing"->0}];
oursPieces[ch_,pol_,p_]:=oursPieces[ch,pol,p]=Module[{base=p["sc"],fixed,sgnE,rl0},
 sgnE=If[p["z"]>p["x"],1,-1];fixed=Join[base,{x->p["x"],z->p["z"]}];
 rl0=Join[fixed,{w->1}];
 <|"delta"->ev[oursNLO[ch,pol,sgnE,"Delta"],rl0],
   "l0"->ev[oursNLO[ch,pol,sgnE,"L0"],rl0],
   "l1"->ev[oursNLO[ch,pol,sgnE,"L1"],rl0],
   "A"->N[AA/.fixed,wp+15],
   "interior"->Association@Table[sg->Quiet[N[oursInteriorW[ch,pol,sg]/.fixed,wp+15]],{sg,{1,-1}}],
   "branch"->Quiet[N[(tX+sX)/.fixed,wp+15]]|>];
theirsPieces[ch_,pol_,p_]:=theirsPieces[ch,pol,p]=Module[{base=p["sc"],fixed},
 fixed=Join[base,{x->p["x"],z->p["z"]}];
 <|"delta"->ev[cDelta[cong[chan[ch]],pol],fixed],
   "plus"->Table[ev[cPlus[cong[chan[ch]],pol,n],fixed],{n,0,1}],
   "A"->N[AA/.fixed,wp+15],
   "reg"->Quiet[N[cReg[cong[chan[ch]],pol]/.fixed,wp+15]]|>];
actionOurs[ch_,pol_,p_,f_]:=Module[{q=oursPieces[ch,pol,p],g},
 If[!AllTrue[{q["delta"],q["l0"],q["l1"]},NumberQ],Return["UNRESOLVED"]];
 g[ww_?NumericQ]:=Module[{sg,iw},
   sg=If[N[q["branch"]/.w->ww,20]>0,1,-1];
   iw=Quiet[N[q["interior"][sg]/.w->ww,wp]];
   If[!NumberQ[iw],Return[Indeterminate]];
   q["A"] iw f[ww]-(q["l0"]+q["l1"] Log[1-ww]) f[1]/(1-ww)];
 q["delta"] f[1]+quad[g]];
actionTheirs[ch_,pol_,p_,f_]:=Module[{q=theirsPieces[ch,pol,p],g},
 If[!AllTrue[Join[{q["delta"]},q["plus"]],NumberQ],Return["UNRESOLVED"]];
 g[ww_?NumericQ]:=Module[{rv},rv=Quiet[N[q["reg"]/.w->ww,wp]];
   If[!NumberQ[rv],Return[Indeterminate]];
   rv f[ww]+Sum[q["plus"][[n+1]] Log[1-ww]^n/(1-ww)(f[ww]-f[1]),{n,0,1}]];
 q["A"] kappa[pol](q["delta"] f[1]+quad[g])];
actionPts={<|"l"->"x=1/3,z=2/5","x"->1/3,"z"->2/5,"sc"->scales|>};
Do[Do[Do[Do[
  o=TimeConstrained[Quiet[actionOurs[ch,pol,p,tf["f"]]],tmo,"TIMEOUT"];
  th=TimeConstrained[Quiet[actionTheirs[ch,pol,p,tf["f"]]],tmo,"TIMEOUT"];
  record[ch<>" action "<>pol<>" "<>tf["l"],p["l"],o,th],
 {tf,tests}],{p,actionPts}],{pol,{"T","L"}}],{ch,{"Hqqbar","Hqq"}}];

(* -------- residual symbol audit -------- *)
Print[];Print["---- residual free symbols after conversion ----"];
known={Q2,x,z,w,CA,eU,eD,nU,nD,muR2,muF2,muD2,\[Alpha]s};
audit[label_,e_]:=Module[{syms},
  syms=Complement[DeleteDuplicates[Cases[e,s_Symbol/;(Context[s]=!="System`"),Infinity]],known];
  Print["  ",StringPadRight[label,42],If[syms==={},"none",ToString[syms]]];
  <|"expression"->label,"residual_symbols"->ToString[syms]|>];
auditRows={};
Do[AppendTo[auditRows,audit["ours "<>ch<>" "<>pol<>" "<>dk<>" br1",
   oursNLO[ch,pol,1,dk]]],{ch,{"Hqq","Hqqbar"}},{pol,{"T"}},{dk,{"Delta","L0","L1","Regular"}}];
Do[AppendTo[auditRows,audit["congyue "<>ch<>" "<>pol<>" Delta",cDelta[cong[chan[ch]],pol]]],
  {ch,{"Hqq","Hqqbar"}},{pol,{"T"}}];
AppendTo[auditRows,audit["congyue Hqq T Plus[0]",cPlus[cong["NLO_qq"],"T",0]]];
AppendTo[auditRows,audit["congyue Hqq T Plus[1]",cPlus[cong["NLO_qq"],"T",1]]];
Print["  EulerGamma coefficient in Congyue Hqq T Delta: ",
  InputForm[TimeConstrained[Simplify[Coefficient[cDelta[cong["NLO_qq"],"T"],EulerGamma]],tmo,"TIMEOUT"]]];

Put[<|"rows"->rows,"symbol_audit"->auditRows|>,FileNameJoin[{out,"numerical-comparison.wl"}]];
Print[];
Print["NUMERICAL_ROWS ",Length[rows]];
Do[Print["  ",StringPadRight[v,34],Length[Select[rows,#["verdict"]===v&]]],
 {v,DeleteDuplicates[#["verdict"]&/@rows]}];
Print["COMPARE_NUMERIC_COMPLETE"];
Exit[0];
