(* Project the completed physical-tagged tensor, then map its actual integrands.
   Flavor/charge sectors stay separate. No unpolarized coefficient is substituted. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];engine=FileNameJoin[{root,"collins_sidis_highpt"}];
input=Environment["SIDIS_TEMPLATE_INPUT"];out=Environment["SIDIS_MAP_OUT"];
If[!StringQ[input]||!FileExistsQ[input]||!StringQ[out]||DirectoryQ[out],Print["Need native templates and unused output"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
rt=Import[FileNameJoin[{root,"collins_ep_analytic_SIDIS","ru_runtime.json"}],"RawJSON"];
Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};Global`$FeynCalcStartupMessages=False;
Global`$FeynCalcDirectory=rt["feyncalc_root"];FeynCalc`$FeynArtsDirectory=rt["feynarts_root"];
Get[FileNameJoin[{rt["feyncalc_root"],"FeynCalc.m"}]];
Get[FileNameJoin[{engine,"common","spin_core.wl"}]];
Get[FileNameJoin[{engine,"common","spin_nlo.wl"}]];
Get[FileNameJoin[{engine,"common","spin_tensor_template.wl"}]];
Get[FileNameJoin[{engine,"common","real_families.wl"}]];
record=Get[input];templateGeometry=record["geometry"];topology=record["topology"];
pairValues=record["pairs"];pairKeys=Keys[pairValues];
ampfile=FileNameJoin[{root,"SIDIS","Hqq","s01_result","s01_inputs","s01_result.wl"}];bank=Get[ampfile];
degrees=ConstantArray[0,If[topology==="Hqqbar",8,Length[bank[topology]]]];
If[topology==="RealDistinct",
 photonDegree[amplitude_]:=Module[{chains,ends,dd},
  chains=Cases[amplitude,chain_Dot/;!FreeQ[chain,Polarization[q,___]],{0,Infinity}];ends=({First[#],Last[#]}&/@chains);
  dd=DeleteDuplicates[Map[Function[e,Which[
   !FreeQ[e,Spinor[Momentum[p,D],___]]&&!FreeQ[e,Spinor[Momentum[k1,D],___]],0,
   !FreeQ[e,Spinor[Momentum[k2,D],___]]&&!FreeQ[e,Spinor[-Momentum[k3,D],___]],1,True,Missing["UnknownPhotonLine",e]]],ends]];
  gate["unique photon charge line",Length[dd]===1&&FreeQ[dd,_Missing]];First[dd]];
 degrees=photonDegree/@bank["RealDistinct"]];
expectedPairs=Flatten[Table[ToString[i]<>"_"<>ToString[j],{i,Length[degrees]},{j,i,Length[degrees]}]];
gate["all requested topology diagram pairs present",Sort[pairKeys]===Sort[expectedPairs]];
grouped=GroupBy[pairKeys,Function[key,Total[degrees[[ToExpression/@StringSplit[key,"_"]]]]]];
nativeGeometry=HSRealKinematics[];
(* The two unobserved cut momenta are integrated over the complete, symmetric
   positive-energy phase space. This is a change of dummy integration variables,
   even for different final-state particle labels; it adds no symmetry factor.
   Retain each original integrand and prove the discarded part exchange-odd. *)
exchange={a->t-w-a,b->s-w-b,ny->-ny};
exchangeChecks=<|"k2_to_k3"->(HSOnShell/@(($HSVectors[k2]/.exchange)-$HSVectors[k3])),
 "k3_to_k2"->(HSOnShell/@(($HSVectors[k3]/.exchange)-$HSVectors[k2])),
 "residual_sphere"->HSOnShell[($HSRealPerp/.exchange)-$HSRealPerp],
 "involution"->(Factor/@((({a,b}/.exchange)/.exchange)-{a,b})),
 "scalar_jacobian"->Det[Table[D[({a,b}/.exchange)[[i]],coordinate],{i,2},{coordinate,{a,b}}]]|>;
gate["cut exchange and angular measure geometry",Flatten[Values[KeyDrop[exchangeChecks,"scalar_jacobian"]]]===ConstantArray[0,11]&&exchangeChecks["scalar_jacobian"]===1];
Put[<|"rules"->exchange,"checks"->exchangeChecks,
 "measure"->HoldComplete[Integrate[f[k2,k3] deltaPlus[k2^2] deltaPlus[k3^2] deltaD[P-k2-k3],{k2,allD},{k3,allD}]],
 "domain_map"->"k2 <-> k3 exchanges both positive-energy cuts; total momentum, tagged k1 and all external vectors fixed. Unit absolute Jacobian. Residual-sphere ny reflection preserves normalized angular measure.",
 "qualification"->"Equality under complete unresolved phase-space integration, not pointwise equality; original tag weights remain unapplied"|>,FileNameJoin[{out,"exchange-proof.wl"}]];
geometryFile=FileNameJoin[{root,"SIDIS","common","s02_result","s02_result.wl"}];HSCutFamilySetup[Get[geometryFile]];
ph=<|"LL"->{phL,phL},"XX"->{phX,phX},"YY"->{phY,phY},"WW"->{q,q}|>;
spins=<|"11"->{pinX,poutX},"22"->{pinY,poutY}|>;
projectorRows=templateGeometry["projector_dot_rows"];
templateExchange=Join[exchange,Map[Function[row,With[{swapped=row[[{2,3}]]/.{k2->k3,k3->k2}},
 row[[1]]->First[SelectFirst[projectorRows,#[[{2,3}]]===swapped&]]]],projectorRows]];
coefficients=<||>;integrands=<||>;originalTemplates=<||>;exchangeResiduals=<||>;ward=<||>;targets={};
Do[sumTemplate=Total[Map[Function[key,With[{ij=ToExpression/@StringSplit[key,"_"]},
 If[ij[[1]]===ij[[2]],pairValues[key],pairValues[key]+ComplexExpand[Conjugate[pairValues[key]]]]]],grouped[charge]]];
 Print["SYMMETRIZE_OPEN_TENSOR charge ",charge];
 originalTemplate=Factor[Together[sumTemplate]];
 sumTemplate=Factor[Together[(originalTemplate+(originalTemplate/.templateExchange))/2]];
 oddTemplate=Factor[Together[originalTemplate-sumTemplate]];
 oddResidual=Factor[Together[oddTemplate+(oddTemplate/.templateExchange)]];
 gate["open tensor exchange-odd residual",oddResidual===0];
 AssociateTo[originalTemplates,ToString[charge]->originalTemplate];AssociateTo[exchangeResiduals,ToString[charge]->oddResidual];
 Put[<|"original"->originalTemplate,"symmetric"->sumTemplate,"odd"->oddTemplate,
 "odd_residual"->oddResidual,"exchange"->templateExchange|>,FileNameJoin[{out,"charge"<>ToString[charge]<>"_open_exchange.wl"}]];
 Do[key=topology<>"_"<>spin<>"_"<>proj<>"_charge"<>ToString[charge];Print["PROJECT_MAP ",key];
  value=HSProjectRealTemplate[sumTemplate,templateGeometry,ph[proj],spins[spin]];
  value=Factor[PowerExpand[value/.Q->Sqrt[Q2]]];
  gate["diagonal components rational in invariants",FreeQ[value,h|Q]&&FreeQ[value,Power[Q2,_Rational]]];
  If[proj==="WW",AssociateTo[ward,key->value];Put[ward,FileNameJoin[{out,"ward.wl"}]];gate["photon Ward per charge and spin",value===0],
   Put[<|"value"->value,"open_exchange_record"->"charge"<>ToString[charge]<>"_open_exchange.wl"|>,FileNameJoin[{out,key<>"_projected.wl"}]];
   Print["MAP_INTEGRAND ",key," symmetric zero = ",value===0];
   mapped=mapExpression[value];AssociateTo[coefficients,key->mapped];AssociateTo[integrands,key->value];targets=Union[targets,Keys[mapped]];
   Put[<|"value"->value,"open_exchange_record"->"charge"<>ToString[charge]<>"_open_exchange.wl","coefficients"->mapped|>,FileNameJoin[{out,key<>".wl"}]]],{spin,Keys[spins]},{proj,Keys[ph]}],{charge,Keys[grouped]}];
residuals=AssociationMap[Function[key,Factor[Total[KeyValueMap[Function[{integral,c},c Times@@MapThread[Power,{families[integral[[1]]]["OnCutUncutPropagators"],-Drop[integral[[2]],2]}]],coefficients[key]]]-integrands[key]]],Keys[coefficients]];
Put[<|"topology"->topology,"input"->input,"input_sha256"->IntegerString[FileHash[input,"SHA256"],16,64],
 "geometry_sha256"->IntegerString[FileHash[geometryFile,"SHA256"],16,64],"source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "charge_degree_by_diagram"->degrees,"tag_weight_unapplied"->record["tag_weight_unapplied"],
 "charge_weights"->If[topology==="RealDistinct",<|"charge0"->Nf-1,"charge1"->otherChargeMoment1/eq,"charge2"->otherChargeMoment2/eq^2|>,<|"charge0"->1|>],
 "integrands"->integrands,"original_open_templates"->originalTemplates,"exchange_odd_residuals"->exchangeResiduals,
 "exchange_conversion"->"(f(k2,k3)+f(k3,k2))/2 under full symmetric cut measure; see exchange-proof.wl",
 "coefficients"->coefficients,"targets"->targets,"ward_residuals"->ward,
 "reconstruction_residuals"->residuals,"positive_energy_support"->geometry["CutEnergyConditions"],
 "qualification"->"Unintegrated LL,XX,YY photon components for both diagonal spin-transfer tensors; Collins and lepton projection unapplied"|>,FileNameJoin[{out,"mapping.wl"}]];
Put[coefficients,FileNameJoin[{out,"coefficients.wl"}]];
text[x_]:=StringReplace[ToString[x,InputForm],Whitespace->""];
external=Take[geometry["BasisMomenta"],Length[geometry["BasisMomenta"]]-Length[geometry["CutMomenta"]]+1];
gram=geometry["CommonGram"][[Range[Length[external]],Range[Length[external]]]];names=Sort[DeleteDuplicates[targets[[All,1]]]];
Export[FileNameJoin[{out,"kira-input.json"}],<|"scope"->topology<>" new full-dimensional diagonal spin/photon tensor targets; no finite NLO acceptance",
 "targets"->(<|"family"->#[[1]],"powers"->#[[2]]|>&/@targets),"external"->(text/@external),
 "invariants"->(text/@Sort[DeleteDuplicates[Cases[gram,symbol_Symbol/;Context[symbol]==="Global`",Infinity]]]/.{"Q2"->"q2"}),
 "scalarproducts"->Flatten[Table[{text[external[[i]]],text[external[[j]]],text[gram[[i,j]]/.Q2->q2]},{i,Length[external]},{j,i,Length[external]}],1],
 "families"->Table[<|"id"->name,"loop_momenta"->(text/@families[name]["LoopMomenta"]),
 "propagators"->MapThread[{text[#1],text[#2]}&,{families[name]["PropagatorMomenta"],families[name]["PropagatorMassesSquared"]}],
 "cut_positions"->families[name]["CutPositions"]|>,{name,names}]|>,"RawJSON"];
Print["REAL_TENSOR_MAP_COMPLETE ",Length[targets]," targets"];Exit[0];
