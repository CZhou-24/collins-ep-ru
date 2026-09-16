(* Symbolic observable built from current-run master-dependent hard coefficients.
   The same mathematical construction is used for physical runs and probes. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];engine=FileNameJoin[{root,"collins_sidis_highpt"}];
out=Environment["SIDIS_OBSERVABLE_OUT"];
nativeFile=Environment["SIDIS_NATIVE_HARD_INPUT"];uuFile=Environment["SIDIS_UU_INPUT"];
files=<|"native_hard"->nativeFile,"UU"->uuFile|>;
If[!StringQ[out]||DirectoryQ[out]||!And@@(StringQ[#]&&FileExistsQ[#]&/@Values[files]),Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["NATIVE_OBSERVABLE_FAILED ",name];Exit[2]];
helpers=FileNameJoin[{engine,"common",#<>".wl"}]&/@{"observable_convolution","observable_distribution_actions","jet_matching","fragmentation","observable_flavors","observable_assembly"};Get/@helpers;
nativeRecord=Get[nativeFile];uu=Get[uuFile]["channels"];
hqq=<|"Hqq"->nativeRecord["hard"]["Hqq"],"Born_D4"->nativeRecord["Born_D4"]|>;
(* Always the same formal boundary expression, including during dependency
   probes. Its explicit physical evaluation is checked in a separate native
   artifact. No baseline expression is substituted into a mutated calculation. *)
formalBoundary[channel_,component_,dist_]:=Inactive[Limit][
 nativeRecord["hard"][channel][component<>"_1"]["finite_candidate"][dist],omega->0,
 Direction->"FromAbove",Assumptions->Q2>0&&s>w>0&&B>0&&muR>0&&muPDF>0&&muFF>0&&SUNN>1&&
  -Q2-s+w< -s< -Q2 w/s];
boundary=<|"boundary"->Association@Table[component-><|"finite"->Association@Table[dist->formalBoundary["Hqq",component,dist],
 {dist,{"Delta","L0","L1","Regular"}}]|>,{component,{"Collins_L","Collins_T"}}]|>;
antiquark=<|"Hqqbar"->Association@Table[component->Association@Table[dist->HSPhysicalBranch[
 Join[Association@Table[sign->nativeRecord["hard"]["Hqqbar"][component<>"_"<>ToString[sign]]["finite_candidate"][dist],{sign,{1,-1}}],
 <|0->formalBoundary["Hqqbar",component,dist]|>]],{dist,{"Delta","L0","L1","Regular"}}],{component,{"Collins_L","Collins_T"}}]|>;
gate["complete channels",Sort[Keys[uu]]===Sort[{"Hqq","Hqg","Hgq","Hgg","Hqqbar","Hqqprime"}]];
parameters=<|"Nf"->Nf,"Q2"->Q2,"xB"->xB,"pJT"->pJT,"u"->u,"y"->y,"zh"->zh,"jT"->jT,"Mh"->Mh,"R"->R,"mu"->muCommon|>;
parts=<||>;hardBanks=<||>;
Do[Print["ASSEMBLE_UU_MEASUREMENT ",channel];hard=HSUUHardBank[channel,uu];
 AssociateTo[hardBanks,"UU_"<>channel->hard];value=HSBuildChannelObservable[channel,"U",hard,parameters];
 AssociateTo[parts,"UU_"<>channel->value];Put[value,FileNameJoin[{out,"UU_"<>channel<>".wl"}]],{channel,Keys[uu]}];
Do[Print["ASSEMBLE_UT_MEASUREMENT ",channel];hard=HSUTHardBank[channel,hqq,boundary,antiquark];
 AssociateTo[hardBanks,"UT_"<>channel->hard];value=HSBuildChannelObservable[channel,"T",hard,parameters];
 AssociateTo[parts,"UT_"<>channel->value];Put[value,FileNameJoin[{out,"UT_"<>channel<>".wl"}]],{channel,{"Hqq","Hqqbar"}}];
UU0=Total[parts["UU_"<>#]["LO"]&/@Keys[uu]];UU1=Total[parts["UU_"<>#]["NLO"]&/@Keys[uu]];
UT0=Total[parts["UT_"<>#]["LO"]&/@{"Hqq","Hqqbar"}];UT1=Total[parts["UT_"<>#]["NLO"]&/@{"Hqq","Hqqbar"}];
prefactor=e^4 pJT/(16 S Q2^2(2Pi)^6);
uuExpression=prefactor(aS UU0+aS^2 UU1);utExpression=prefactor(aS UT0+aS^2 UT1);
asymmetry=HSConsistentAsymmetry[UU0,UU1,UT0,UT1,aS];
(* Independent formal ratio expansion avoids expanding the actual large PDF
   functionals. The same four coefficients enter the substitution below. *)
ratioResidual=Expand[Normal[Series[(v0+aS v1)/(u0+aS u1),{aS,0,1}]]-
 (v0/u0+aS(v1/u0-v0 u1/u0^2))];
orderResiduals=<|"UU"->Coefficient[uuExpression,aS,3],"UT"->Coefficient[utExpression,aS,3],"asymmetry_ratio"->ratioResidual|>;
gate["finite coefficients supplied to full convolution",FreeQ[{UU0,UU1,UT0,UT1},eps|eta|D|_Missing|_SeriesData|_Limit|Indeterminate|ComplexInfinity]];
gate["hard perturbative order retained",And@@(#===0&/@Values[orderResiduals])];
Put[<|"UU"->uuExpression,"UT_Collins"->utExpression,"A_Collins_NLO_expanded"->asymmetry,
 "coefficients"-><|"UU0"->UU0,"UU1"->UU1,"UT0"->UT0,"UT1"->UT1|>,"channel_parts"->parts,
 "prefactor"->prefactor,"parameters"->parameters,"order_residuals"->orderResiduals,
 "measurement"->HoldComplete[dQ2 dy dpJT detaJ dzh d2jT dphiLepton dphiJet],
 "angular_definition"->"Azimuth-averaged density per unit lepton/jet azimuth; the Collins coefficient uses the separately documented 2<sin(phiS-phih) W> moment. Actual integrations rather than normalized averages require their corresponding angular volumes.",
 "kinematic_relations"->HoldComplete[xB==Q2/(y S)&&u==Exp[etaJ]&&aS==alphaS[muCommon]/(2Pi)],
 "physical_support"->HoldComplete[Q2>0&&0<xB<1&&0<y<1&&pJT>0&&u>0&&0<zh<1&&Mh>0&&R>0&&
   pJT/Sqrt[Q2](1/u+xB u/(1-xB))<1],
 "convolution_measure"->HoldComplete[dx/x dzJ/zJ^2],
 "TMD_convention"->"Soft-subtracted symbolic D1 and Collins H1perp at zetaJ=(pJT R)^2, with the literal pinned Fourier convention; no small-b expansion or numerical model.",
 "source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,Join[Values[files],helpers,{$InputFileName}]],
 "qualification"->"Specified leading-power, small-R, small-jT Collins moment using the current evaluated master input. The common boundary is a formal one-sided limit with separate explicit native evaluation evidence. Imported UU historical qualifications remain; this source does not assert workflow acceptance."|>,FileNameJoin[{out,"observable.wl"}]];
Put[hardBanks,FileNameJoin[{out,"hard-banks.wl"}]];
Print["SYMBOLIC_UU_UT_ASYMMETRY_ASSEMBLED; FULL_NATIVE_CAMPAIGN_SEPARATE"];Exit[0];
