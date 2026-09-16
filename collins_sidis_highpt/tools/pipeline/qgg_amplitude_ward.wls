(* Gluon Ward identities at the open amplitude level. A vanishing amplitude
   precedes every physical spin/photon projection and does not rely on a UU
   square. Both actual generated gluon legs are checked. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];engine=FileNameJoin[{root,"collins_sidis_highpt"}];
out=Environment["SIDIS_QGG_WARD_OUT"];If[!StringQ[out]||DirectoryQ[out],Exit[1]];CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["QGG_AMPLITUDE_WARD_FAILED ",name];Exit[2]];
SetAttributes[bounded,HoldFirst];bounded[value_,label_]:=CheckAbort[MemoryConstrained[TimeConstrained[value,240,gate[label<>" timeout",False]],768*1024^2,gate[label<>" memory",False]],gate[label<>" native abort",False]];
rt=Import[FileNameJoin[{root,"collins_ep_analytic_SIDIS","ru_runtime.json"}],"RawJSON"];
Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};Global`$FeynCalcStartupMessages=False;
Global`$FeynCalcDirectory=rt["feyncalc_root"];FeynCalc`$FeynArtsDirectory=rt["feynarts_root"];
Get[FileNameJoin[{rt["feyncalc_root"],"FeynCalc.m"}]];FeynCalc`FCSetDiracGammaScheme["BMHV"];
helpers=FileNameJoin[{engine,"common",#}]&/@{"spin_core.wl","spin_nlo.wl"};Get/@helpers;geometry=HSRealKinematics[];
file=FileNameJoin[{root,"SIDIS","Hqq","s01_result","s01_inputs","s01_result.wl"}];bank=Get[file];
amps=bank["RealQGG"]/.{SMP["e"]->1,SMP["g_s"]->1};rows=<||>;
Do[Print["OPEN_GLUON_WARD ",leg];
 wardAmplitudes=amps/.Polarization[leg,___]->leg;
 (* No observed spin direction or gamma5 prescription is changed. The only
    momentum replacement is exact momentum conservation for the spectator. *)
 simplified=Table[bounded[DiracSimplify[ExpandScalarProduct[FeynAmpDenominatorExplicit[
   wardAmplitudes[[index]]]/.Momentum[k3,dim___]:>Momentum[p+q-k1-k2,dim]]],"on-shell diagram simplification"],{index,Length[amps]}];
 value=bounded[SUNSimplify[Total[simplified],Explicit->True,SUNNToCACF->False],"color Ward sum"];
 value=bounded[DiracOrder[DiracSimplify[Contract[value]]],"open spinor Ward sum and Clifford ordering"];
 (* Keep the remaining polarization label k3 intact while applying momentum
    conservation to its scalar products. This is epsilon3.k3=0, not an extra
    axial gauge choice or an observed-spin specialization. *)
 transversality=HoldPattern[Pair[Momentum[p,dim___],Momentum[Polarization[k3,args___],dim___]]]:>
  Pair[Momentum[k1,dim],Momentum[Polarization[k3,args],dim]]+
  Pair[Momentum[k2,dim],Momentum[Polarization[k3,args],dim]]-
  Pair[Momentum[q,dim],Momentum[Polarization[k3,args],dim]];
 value=value/.transversality;
 structures=DeleteDuplicates[Cases[value,_Dot|_SUNTF|_Pair,Infinity]];
 value=bounded[Collect[value,structures,Factor[Together[#]]&],"rational coefficient cancellation"];
 beforeTransverse=value;
 spectator=First[Complement[{k2,k3},{leg}]];
 transverseRule=With[{momentum=spectator},HoldPattern[
   Pair[Momentum[momentum,D],Momentum[Polarization[momentum,args___],D]]]:>0];
 value=value/.transverseRule;
 Put[<|"original_replaced_amplitudes"->wardAmplitudes,"on_shell_diagrams"->simplified,
  "before_spectator_transversality"->beforeTransverse,"spectator_transversality"->transverseRule,
  "transversality_meaning"->"The remaining on-shell gluon has physical transverse polarization, epsilon(k).k=0; no photon or spin projection imposed.",
  "residual"->value|>,FileNameJoin[{out,ToString[leg]<>".wl"}]];
 AssociateTo[rows,ToString[leg]->value];gate["open gluon Ward amplitude",value===0],{leg,{k2,k3}}];
Put[<|"residuals"->rows,"geometry"->geometry,"source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,
 Join[{file,$InputFileName},helpers]],"qualification"->"Exact open-amplitude gauge identity for both gluons; distinct from imported historical UU Ward evidence"|>,FileNameJoin[{out,"ward.wl"}]];
Print["OPEN_GLUON_WARD_COMPLETE"];Exit[0];
