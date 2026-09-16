(* Physical nonsingular real point: review an allowed tagged-antiquark channel.
   This is not its dimensionally regulated NLO coefficient. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];engine=FileNameJoin[{root,"collins_sidis_highpt"}];
out=FileNameJoin[{root,"collins_support","reports","sidis-highpt-001","antiquark-point-002"}];
If[DirectoryQ[out],Print["Refuse output reuse"];Exit[1]];CreateDirectory[out];
rt=Import[FileNameJoin[{root,"collins_ep_analytic_SIDIS","ru_runtime.json"}],"RawJSON"];
Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};Global`$FeynCalcStartupMessages=False;
Global`$FeynCalcDirectory=rt["feyncalc_root"];FeynCalc`$FeynArtsDirectory=rt["feynarts_root"];
Get[FileNameJoin[{rt["feyncalc_root"],"FeynCalc.m"}]];
FeynCalc`FCSetDiracGammaScheme["BMHV"];
Get[FileNameJoin[{engine,"common","spin_core.wl"}]];FCClearScalarProducts[];
vectors=<|p->{5,0,0,5},q->{0,0,0,-2},k1->{1,1,0,0},k2->{3/4,0,3/4,0},k3->{13/4,-1,-3/4,3},
 pinX->{0,1,0,0},pinY->{0,0,1,0},poutX->{0,0,0,-1},poutY->{0,0,1,0}|>;
keys=Keys[vectors];Do[With[{a=keys[[i]],b=keys[[j]],v=HSDot[vectors[keys[[i]]],vectors[keys[[j]]]]},
 SPD[a,b]=v;SP[a,b]=v;SPE[a,b]=0],{i,Length[keys]},{j,i,Length[keys]}];
file=FileNameJoin[{root,"SIDIS","Hqqbar","s01_result","s01_inputs","s01_result","real.wl"}];bank=Get[file];
amp=ExpandScalarProduct[FeynAmpDenominatorExplicit[Total[bank["amplitudes"]]]]/.{SMP["e"]->1,SMP["g_s"]->1};
contract[mode_,spin_,sin_,sout_]:=Module[{a=amp,x},If[mode=="Ppp",a=a/.Polarization[q,___]->p];
 x=HSTaggedSpinSum[a,a,spin,sin,sout];
 x=ChangeDimension[x,4];x=SUNSimplify[x,Explicit->True,SUNNToCACF->False]/.SUNN->3;
 If[mode=="Pg",x=-DoPolarizationSums[x,q,0,VirtualBoson->True]];
 Factor[ExpandScalarProduct[FeynAmpDenominatorExplicit[Contract[DiracSimplify[x,DiracTraceEvaluate->True]]]]/.D->4]];
results=<||>;
Do[Print["ANTIQUARK_POINT ",mode];xx=contract[mode,"T",pinX,poutX];yy=contract[mode,"T",pinY,poutY];
 AssociateTo[results,mode-><|"XX"->xx,"YY"->yy,"trace_moment"->Factor[(xx+yy)/2]|>];
 Put[results,FileNameJoin[{out,"spin_contractions.wl"}]],{mode,{"Pg","Ppp"}}];
moment=Factor[(2-2y+y^2)(results["Ppp"]["trace_moment"]/25-results["Pg"]["trace_moment"])+4(1-y)results["Ppp"]["trace_moment"]/25];
Put[<|"vectors"->vectors,"source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "input_sha256"->IntegerString[FileHash[file,"SHA256"],16,64],"spin_helper_sha256"->IntegerString[FileHash[FileNameJoin[{engine,"common","spin_core.wl"}],"SHA256"],16,64],
 "results"->results,"collins_trace_moment"->moment,"dimensionality"->4,
 "incoming_fields"->bank["incoming_fields"],"outgoing_fields"->bank["outgoing_fields"],"symmetry_weight_unapplied"->bank["symmetry_weight"],
 "qualification"->"One physical point; couplings and diagram charge assignments retained. Antiquark-density convention requires an independent charge-conjugation check; no NLO acceptance."|>,FileNameJoin[{out,"point.wl"}]];
Print["ANTIQUARK_POINT_MOMENT ",InputForm[moment]];If[!FreeQ[moment,_Pair|_DiracTrace|_DiracGamma|_Spinor|_SUNTF|$Failed|$Aborted],Exit[2]];Exit[0];
