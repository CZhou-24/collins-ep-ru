(* Fresh D-dimensional UU contraction through the same tagged density routine
   used for Hqqbar UT, compared pair by pair with preserved independent UU
   contractions. This checks density normalization, charge removal and exchange
   signs; it is not a new reference for the polarized coefficient. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
engine=FileNameJoin[{root,"collins_sidis_highpt"}];out=Environment["SIDIS_HQQBAR_UU_OUT"];
If[!StringQ[out]||DirectoryQ[out],Exit[1]];CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["HQQBAR_UU_FAILED ",name];Exit[2]];
SetAttributes[bounded,HoldFirst];bounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,300,gate[label<>" timeout",False]],768*1024^2,gate[label<>" memory",False]];
rt=Import[FileNameJoin[{root,"collins_ep_analytic_SIDIS","ru_runtime.json"}],"RawJSON"];
Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};Global`$FeynCalcStartupMessages=False;
Global`$FeynCalcDirectory=rt["feyncalc_root"];FeynCalc`$FeynArtsDirectory=rt["feynarts_root"];
Get[FileNameJoin[{rt["feyncalc_root"],"FeynCalc.m"}]];FeynCalc`FCSetDiracGammaScheme["BMHV"];
core=FileNameJoin[{engine,"common","spin_core.wl"}];Get[core];
nlo=FileNameJoin[{engine,"common","spin_nlo.wl"}];Get[nlo];geometry=HSRealKinematics[];
open=FileNameJoin[{engine,"common","open_tensor_polynomial.wl"}];Get[open];
file=FileNameJoin[{root,"SIDIS","Hqqbar","s01_result","s01_inputs","s01_result","real.wl"}];bank=Get[file];
amps=bank["amplitudes"]/.{ee->1,eq->1,gs->1};referenceRoot=FileNameJoin[{root,"SIDIS","Hqqbar","s01_result","s01_inputs","s02_result"}];
openPhoton[amp_,index_]:=amp/.Momentum[Polarization[q,___],D]:>LorentzIndex[index,D];
contract[left_,right_,projection_]:=Module[{aa=left,bb=right,value},
 If[projection==="pp",aa=aa/.Polarization[q,___]->p;bb=bb/.Polarization[q,___]->p,
  aa=openPhoton[aa,hsMu];bb=openPhoton[bb,hsNu]];
 value=HSTaggedSpinSum[aa,bb,"U",pinX,poutX];
 If[projection==="g",value=value FCI[MTD[hsMu,hsNu]]];
 value=SUNSimplify[value,Explicit->True,SUNNToCACF->False];
 value=Contract[DiracSimplify[value,DiracTraceEvaluate->True]];
 value=ExpandScalarProduct[FeynAmpDenominatorExplicit[value]];
 gate["evaluated exact UU scalar",FreeQ[value,_Pair|_Spinor|_DiracTrace|_DiracGamma|_SUNTF|_SUNTrace|_Real|$Failed|$Aborted]];
 HSOnShell[value]];
rows=<||>;refs={};
Do[Print["HQQBAR_UU_PAIR ",i," ",j];key=ToString[i]<>"_"<>ToString[j];
 referenceFile=FileNameJoin[{referenceRoot,"real_"<>IntegerString[i,10,2]<>IntegerString[j,10,2]<>".wl"}];AppendTo[refs,referenceFile];
 reference=Get[referenceFile]/.{ee->1,eq->1,gs->1,Nc->SUNN};current=<||>;residuals=<||>;
 Do[value=bounded[contract[amps[[i]],amps[[j]],projection],"UU contraction"];
  If[i=!=j,value=value+HSRealRationalConjugate[value]];
  value=Factor[value/.Q->Sqrt[Q2]];
  residual=bounded[Factor[Together[value-reference[projection]]],"UU reference difference"];
  AssociateTo[current,projection->value];AssociateTo[residuals,projection->residual],{projection,{"g","pp"}}];
 row=<|"pair"->{i,j},"generated"->current,"reference"->reference,"residuals"->residuals,
  "reference_file"->referenceFile,"reference_sha256"->IntegerString[FileHash[referenceFile,"SHA256"],16,64]|>;
 Put[row,FileNameJoin[{out,"pair_"<>key<>".wl"}]];AssociateTo[rows,key->row];
 gate["dimensional pair UU normalization recovery",And@@(#===0&/@Values[residuals])];ClearSystemCache[],{i,Length[amps]},{j,i,Length[amps]}];
Put[<|"pairs"->rows,"geometry"->geometry,"symmetry_weight_unapplied"->bank["symmetry_weight"],
 "normalization"->"Common initial factor 1/(2 Nc); remove ee^2 eq^2 gs^4. Both metric and pp contractions retain D. Spectator weight remains outside the amplitude square.",
 "source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,
  Join[{file,core,nlo,open,$InputFileName},refs]],
 "qualification"->"Fresh UU recovery through production tagged-density code versus archived independent UU pairs; no polarized NLO reference imported"|>,FileNameJoin[{out,"normalization.wl"}]];
Print["HQQBAR_DIMENSIONAL_UU_RECOVERY_COMPLETE ",2Length[rows]];Exit[0];
