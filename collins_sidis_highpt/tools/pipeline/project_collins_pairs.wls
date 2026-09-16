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
openHelper=FileNameJoin[{engine,"common","open_tensor_polynomial.wl"}];Get[openHelper];
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
(* This block is assembled below with the shared input and exact cut-map code.
   The full open tensor is retained before the named Collins projection. *)
projectorRows=templateGeometry["projector_dot_rows"];projectorVariables=First/@projectorRows;momenta=templateGeometry["momenta"];
templateDot[left_,right_]:=Module[{ii,jj,match},
 ii=FirstPosition[momenta,left];jj=FirstPosition[momenta,right];
 If[!MissingQ[ii]&&!MissingQ[jj],Return[templateGeometry["gramD"][[First[ii],First[jj]]]]];
 If[MemberQ[{{p,hsIn},{k1,hsOut}}, {left,right}]||MemberQ[{{hsIn,p},{hsOut,k1}}, {left,right}],Return[0]];
 If[left===right&&MemberQ[{hsIn,hsOut},left],Return[-1]];
 match=SelectFirst[projectorRows,Sort[#[[{2,3}]]]===Sort[{left,right}]&,Missing["NoDot"]];
 gate["open tensor dot lookup",!MissingQ[match]];First[match]];
conserve=(#[[1]]->(templateDot[p,#[[3]]]+templateDot[q,#[[3]]]-templateDot[k1,#[[3]]]-templateDot[k2,#[[3]]]))&/@Select[projectorRows,#[[2]]===k3&];
photonSwap=(#[[1]]->templateDot[#[[2]]/.{hsA->hsB,hsB->hsA},#[[3]]/.{hsA->hsB,hsB->hsA}])&/@projectorRows;
templateExchange=Join[exchange,(#[[1]]->templateDot[#[[2]]/.{k2->k3,k3->k2},#[[3]]/.{k2->k3,k3->k2}])&/@projectorRows];
wardRules=(#[[1]]->templateDot[#[[2]]/.hsA->q,#[[3]]/.hsA->q])&/@projectorRows;
definitions=<|"Collins_L"->{{{phL,phL},{pinX,poutX}},{{phL,phL},{pinY,poutY}}},
 "Collins_T"->{{{phX,phX},{pinX,poutX}},{{phY,phY},{pinX,poutX}},{{phX,phX},{pinY,poutY}},{{phY,phY},{pinY,poutY}}}|>;
monomialHelper=FileNameJoin[{engine,"common","collins_monomial_projection.wl"}];Get[monomialHelper];HSCollinsMonomialSetup[templateGeometry];
(* Apply the one-sided Ward replacement before reducing open coefficients.
   Then project pairs linearly onto the Collins harmonic before the scalar
   k2/k3 exchange conversion. The complete native tensors are retained. *)
SetAttributes[bounded,HoldFirst];
bounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,900,
 Print["COLLINS_MONOMIAL_TIME_LIMIT ",label];Exit[3]],1280*1024^2,
 Print["COLLINS_MONOMIAL_MEMORY_LIMIT ",label];Exit[4]];
coefficients=<||>;integrands=<||>;originalTemplates=<||>;exchangeResiduals=<||>;ward=<||>;targets={};pairResults=<||>;
Do[Print["DIRECT_OPEN_WARD charge ",charge];
 terms=Map[Function[pairKey,With[{ij=ToExpression/@StringSplit[pairKey,"_"]},
  If[ij[[1]]===ij[[2]],pairValues[pairKey]/.wardRules,
   (pairValues[pairKey]/.wardRules)+HSRealRationalConjugate[(pairValues[pairKey]/.photonSwap)/.wardRules]]]],grouped[charge]];
 wardValue=bounded[HSOpenTensorCollect[Total[terms]/.conserve,projectorVariables],"direct Ward coefficients"];
 AssociateTo[ward,ToString[charge]->wardValue];Put[ward,FileNameJoin[{out,"ward.wl"}]];
 gate["full one-sided photon Ward before spin projection",wardValue===0];Clear[terms,wardValue];ClearSystemCache[],{charge,Keys[grouped]}];
Do[ij=ToExpression/@StringSplit[pairKey,"_"];Print["MONOMIAL_COLLINS_PAIR ",topology," ",pairKey];
 tensor=pairValues[pairKey];charge=Total[degrees[[ij]]];projected=<||>;
 Do[Print["MONOMIAL_COMPONENT ",component];
  value=bounded[HSCollinsPolynomialProject[tensor,component],"pair spin trace and angular average"];
  If[ij[[1]]=!=ij[[2]],value=HSOnShell[value+HSRealRationalConjugate[value]]];
  AssociateTo[projected,component->Factor[PowerExpand[value/.Q->Sqrt[Q2]]]],{component,Keys[definitions]}];
 packet=<|"pair"->ij,"charge_degree"->charge,"Collins"->projected,"full_open_tensor_source"->input|>;
 AssociateTo[pairResults,pairKey->packet];Put[packet,FileNameJoin[{out,"pair_"<>pairKey<>".wl"}]];
 Clear[value,tensor,packet,projected];ClearSystemCache[],{pairKey,pairKeys}];

Put[<|"topology"->topology,"pair_files"->Keys[pairResults],"input_sha256"->IntegerString[FileHash[input,"SHA256"],16,64],"source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],"ward"->ward,"qualification"->"Fresh full pair projections; integral mapping is a separate linear step"|>,FileNameJoin[{out,"projection.wl"}]];
Print["FRESH_COLLINS_PAIR_PROJECTIONS_COMPLETE ",Length[pairResults]];Exit[0];
