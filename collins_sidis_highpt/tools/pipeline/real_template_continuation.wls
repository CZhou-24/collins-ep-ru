(* Build the actual full tagged-spin real tensor once per diagram pair. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];engine=FileNameJoin[{root,"collins_sidis_highpt"}];
out=Environment["SIDIS_REAL_OUT"];topology=Environment["SIDIS_REAL_TOPOLOGY"];
If[!StringQ[out]||DirectoryQ[out],Print["Supply unused SIDIS_REAL_OUT"];Exit[1]];
If[!MemberQ[{"RealDistinct","RealSame","RealQGG","Hqqbar"},topology],Print["Invalid topology"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
rt=Import[FileNameJoin[{root,"collins_ep_analytic_SIDIS","ru_runtime.json"}],"RawJSON"];
Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};Global`$FeynCalcStartupMessages=False;
Global`$FeynCalcDirectory=rt["feyncalc_root"];FeynCalc`$FeynArtsDirectory=rt["feynarts_root"];
Get[FileNameJoin[{rt["feyncalc_root"],"FeynCalc.m"}]];
FeynCalc`FCSetDiracGammaScheme["BMHV"];
Get[FileNameJoin[{engine,"common","spin_core.wl"}]];
Get[FileNameJoin[{engine,"common","spin_nlo.wl"}]];
Get[FileNameJoin[{engine,"common","spin_tensor_template.wl"}]];
normfile=FileNameJoin[{root,"SIDIS","Hqq","s01_result","s01_inputs","s02_result.wl"}];$HSChargeSquared=Get[normfile]["ModelChargeSquared"];
If[topology==="Hqqbar",file=FileNameJoin[{root,"SIDIS","Hqqbar","s01_result","s01_inputs","s01_result","real.wl"}];bank=Get[file];
 amps=bank["amplitudes"]/.{ee->1,eq->1,gs->1};$HSChargeSquared=1;weight=bank["symmetry_weight"],
 file=FileNameJoin[{root,"SIDIS","Hqq","s01_result","s01_inputs","s01_result.wl"}];bank=Get[file];amps=bank[topology];
 species=bank["OutgoingSpecies"][topology];weight=Count[species,bank["ObservedSpecies"]]/Times@@(Factorial/@Values[Counts[species]])];
amps=amps/.{SMP["e"]->1,SMP["g_s"]->1};gluons=If[topology==="RealQGG",{k2,k3},{}];
templateGeometry=HSRealTemplateGeometry[];
hash[p_]:=IntegerString[FileHash[p,"SHA256"],16,64];
sources=AssociationMap[hash,{file,normfile,$InputFileName,FileNameJoin[{engine,"common","spin_core.wl"}],FileNameJoin[{engine,"common","spin_nlo.wl"}],FileNameJoin[{engine,"common","spin_tensor_template.wl"}]}];
pairs=Flatten[Table[{i,j},{i,Length[amps]},{j,i,Length[amps]}],1];requested=Environment["SIDIS_REAL_PAIRS"];
(* Put the observed-quark k1||k2 emission pairs first, without dropping any
   finite-region diagram pair from the default full topology calculation. *)
If[topology==="RealQGG",pairs=Join[{{1,1},{1,8},{8,8}},Complement[pairs,{{1,1},{1,8},{8,8}}]]];
If[StringQ[requested]&&StringLength[requested]>0,pairs=(ToExpression/@StringSplit[#,"_"]&/@StringSplit[requested,","])];
If[!And@@(MatchQ[#,{_Integer,_Integer}]&&1<=#[[1]]<=#[[2]]<=Length[amps]&/@pairs),Print["Invalid pair selection"];Exit[2]];
Put[<|"sources"->sources,"topology"->topology,"template_geometry"->templateGeometry,"pairs_requested"->pairs,
 "tag_weight_unapplied"->weight,"couplings_removed"->"eq^2 gs^4","gamma5_scheme"->FCGetDiracGammaScheme[],
 "qualification"->"Actual D-dimensional open photon/spin tensor; unintegrated and unsubtracted"|>,FileNameJoin[{out,"inputs.wl"}]];
rows=<||>;
Do[{i,j}=pair;Print["REAL_TEMPLATE ",topology," ",i," ",j];
 value=CheckAbort[TimeConstrained[HSRealTemplatePair[amps[[i]],amps[[j]],gluons],1800,$Aborted],$Aborted];
 If[value===$Aborted,Print["TEMPLATE_CONTRACTION_ABORTED"];Exit[3]];
 key=ToString[i]<>"_"<>ToString[j];AssociateTo[rows,key->value];
 Put[<|"value"->value,"pair"->pair,"topology"->topology,"geometry"->templateGeometry,"sources"->sources|>,FileNameJoin[{out,key<>".wl"}]],{pair,pairs}];
Put[<|"pairs"->rows,"geometry"->templateGeometry,"sources"->sources,"topology"->topology,"tag_weight_unapplied"->weight|>,FileNameJoin[{out,"templates.wl"}]];
Print["REAL_TEMPLATES_COMPLETE ",Length[rows]];Exit[0];
