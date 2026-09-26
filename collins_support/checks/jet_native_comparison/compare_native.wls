(* Focused Wolfram comparison. No workflow entry point, hard contraction,
   amplitude, reduction, dependency probe, or full campaign is invoked. *)
$HistoryLength=0;
ncContext=Import[Environment["JET_NATIVE_CONTEXT"],"RawJSON"];
ncRoot=ncContext["repo"];ncOut=ncContext["out"];
ncData=Get[FileNameJoin[{ncOut,"native-extract.wl"}]];
Get[FileNameJoin[{ncRoot,"collins_ep_analytic_SIDIS","common","ru_stage.wl"}]];
Get/@(FileNameJoin[{ncRoot,"collins_ep_analytic_SIDIS","common",#}]&/@
 {"ru_observable_helpers.wl","ru_soft_assembly.wl","ru_tmd_assembly.wl"});
Get/@(FileNameJoin[{ncRoot,"collins_sidis_highpt","common",#}]&/@
 {"fragmentation.wl","jet_matching.wl","tmd_evolution.wl","observable_convolution.wl",
  "observable_distribution_actions.wl","observable_flavors.wl","observable_assembly.wl"});
ncRows={};ncDetails=<||>;ncWP=60;ncTolerance=10^-30;
ncString[x_String]:=x;
ncString[x_]:=ToString[x,InputForm];
ncExact[id_,group_,left_,right_,note_:""]:=Module[{diff},
 diff=TimeConstrained[FullSimplify[left-right],30,$Aborted];
 AppendTo[ncRows,<|"id"->id,"group"->group,"status"->Which[diff===0,"EXACT",diff===$Aborted||!FreeQ[diff,Indeterminate|ComplexInfinity|_Integrate],"UNRESOLVED",True,"DISCREPANCY"],
  "left"->ncString[left],"right"->ncString[right],"residual"->ncString[diff],"scaled_residual"->If[diff===0,"0","unresolved"],
  "tolerance"->"0 (symbolic)","notes"->note|>];
 Print[id," ",Last[ncRows]["status"]];If[diff=!=0,Print["DIFFERENCE ",ncString[diff]]]];
ncNumerical[id_,group_,left_,right_,note_:"",expectedDifference_:False]:=Module[{ll=N[left,ncWP],rr=N[right,ncWP],diff,scaled,status},
 diff=ll-rr;scaled=Abs[diff]/Max[1,Abs[ll],Abs[rr]];
 status=If[NumberQ[scaled]&&TrueQ[scaled<ncTolerance],If[expectedDifference,"EXPECTED_NONZERO_DIFFERENCE","NUMERICAL_AGREEMENT"],"DISCREPANCY"];
 If[expectedDifference&&!TrueQ[Abs[ll]>ncTolerance],status="UNRESOLVED"];
 AppendTo[ncRows,<|"id"->id,"group"->group,"status"->status,"left"->ncString[ll],"right"->ncString[rr],
  "residual"->ncString[diff],"scaled_residual"->ncString[scaled],"tolerance"->ncString[ncTolerance],"notes"->note|>];
 Print[id," ",status," ",ncString[scaled]]];
(* Compare different dummy variable names without changing any operators. *)
ncBoundNormalize[expr_]:=expr/.(q_Symbol/;StringMatchQ[SymbolName[q],RegularExpression["(b|bb|zz|ww|xx)\\$[0-9]+"]]):>
 Symbol["ncBound"<>First[StringSplit[SymbolName[q],"$"]]];
Get[FileNameJoin[{DirectoryName[$InputFileName],"quadrature.wl"}]];
ncLinearLogs[expr_]:=MapAll[Function[node,Replace[node,
 Inactive[Integrate][f_,ranges__List]:>Total[
  (Bh^#[[1,1]] Th^#[[1,2]] Inactive[Integrate][#[[2]],ranges])&/@CoefficientRules[Expand[f],{Bh,Th}]]]],expr];
ncCleanIntegrals[expr_]:=FixedPoint[(#/.{
 Inactive[Integrate][0,___]->0,
 Inactive[Integrate][Inactive[Integrate][f_,inner__List],outer__List]:>Inactive[Integrate][f,outer,inner]})&,expr];
ncPhiQ[t_]:=t(1-t)^2;
ncPhiG[t_]:=2t(1-t)^3/5;
ncPhiC[t_]:=3Mh t^2(1-t)^3/5;
ncPhiHF[t1_,t2_]:=Mh t1(1-t1)^2(t1/t2)^2(1-t1/t2)^2/7;
ncInputRules={FFq[t_]:>ncPhiQ[t],FFg[t_]:>ncPhiG[t],Hhatq[t_]:>ncPhiC[t],
 HFNative[_,t1_,t2_,_]:>ncPhiHF[t1,t2],
 Derivative[0,0,1,0][HFNative][_,t1_,t2_,_]:>(D[ncPhiHF[ncT1,ncT2],ncT2]/.{ncT1->t1,ncT2->t2})};
ncColorRules={CF->4/3,CA->3,TF->1/2,TR->1/2,Nc->3,Nf->1};

(* Recontract saved, actually evaluated sphere with native soft assembly.
   Its factors and theta/Fourier integral chain are reused, not rederived. *)
ncSoftDetails=ncData["ep_soft_details"];ncSoft=ncData["ep_soft"];
ncSoftFresh=RUSoftCoefficientAssembly[ncSoftDetails["factors"],"audit/saved_sphere",
 ncData["ep_consumed_sphere"],ncSoftDetails["measurement"]];
Do[If[KeyExistsQ[ncSoftFresh["values"],id],
 ncExact["soft_reassembly/"<>id,"native_saved_reassembly",ncSoftFresh["values"][id]["value"]/.RUExact[q_]:>q,ncSoft[id],
 "Fresh native RUSoftCoefficientAssembly, saved sphere and angular/Fourier factors; not a new cut integral."]],{id,Keys[ncSoft]}];
ncExact["soft_shift_with_poles","soft_separation",ncSoft["r03/soft_injet"],
 ncSoft["r03/soft_standard"]/2/.{Bq->Bh,V->V-g},"eta before eps; poles retained; Bh and Bq refer to different Fourier momenta."];
ncInFinite=Coefficient[Coefficient[ncSoft["r03/soft_injet"],eta,0],eps,0];
ncExact["soft_rapidity_native","soft_separation",-2D[ncInFinite,V],HSInJetSoftNuGamma[CF,Bh]];
ncExact["soft_plus_unsubtracted_TMD","soft_separation",-2D[ncInFinite,V]+HSUnsubtractedTMDNuGamma[CF,Bh],0];
ncExact["local_zetaJ","conventions",(2pJT Cosh[Y])^2 R^2/(4Cosh[Y]^2),(pJT R)^2];
ncFourierFresh=RUTMDFourierFactors[];
Do[ncExact["native_fourier/"<>key,"native_saved_reassembly",ncFourierFresh[key],ncData["ep_fourier"][key]],
 {key,{"Gaussian","full_D_scalar","full_D_rank_one","operator_angular_conversion","ratio_to_native_sphere","fragmentation_phase_ratio"}}];

(* Execute both inverse/forward definitions. The Gaussian is a transform test,
   not an all-b continuation of the ep small-b expansion. *)
$Assumptions=beta>0&&zh>0&&Mh>0&&bb>0&&jT>0&&Element[{CF,CA,L,Bh,Th},Reals];
ncGaussU=FullSimplify[Activate[HSTMDMoment[Function[k,ampU Exp[-beta k^2]],0,zh,bb,Mh]]];
ncGaussT=FullSimplify[Activate[HSTMDMoment[Function[k,ampT Exp[-beta k^2]],1,zh,bb,Mh]]];
ncEPGauss=(ncFourierFresh["Gaussian"]/.{ss->beta,bb->bx/zh})*
 (ncFourierFresh["Gaussian"]/.{ss->beta,bb->by/zh});
ncEPForwardU=ampU ncEPGauss/.{bx->bb,by->0};
(* HC=-HTrento/zh. For forward phase exp(-i k.b/zh),
   vector integral of k HC/Mh is i zh/Mh times the scalar derivative. *)
ncEPVector=FullSimplify[I zh/Mh D[-ampT(ncEPGauss/.{bx->bb,by->0})/zh,bb]];
ncEPForwardC=FullSimplify[ncEPVector/(-I bb/(2zh))];
ncExact["Gaussian_forward_U","Fourier_conversion",ncEPForwardU,zh^2 ncGaussU];
ncExact["Gaussian_forward_C","Fourier_conversion",ncEPForwardC,-2zh^4 Mh ncGaussT];
ncExact["Gaussian_inverse_U","Fourier_conversion",
 FullSimplify[Activate[HSInverseMoment[Function[vv,Evaluate[ncGaussU/.bb->vv]],0,zh,jT,Mh]]],ampU Exp[-beta jT^2]];
ncExact["Gaussian_inverse_T","Fourier_conversion",
 FullSimplify[Activate[HSTMDInput["T","q",zh,jT,Mh,mu,zeta]/.
 H1perpTilde1[_,_,vv_,_,_]:>(ncGaussT/.bb->vv)]],jT ampT Exp[-beta jT^2]/(zh Mh)];
ncMeasures=ncData["ep_observable"]["Fourier_measures"];
ncHPU=HSTMDInput["U","q",zh,jT,Mh,mu,zeta];
ncHPT=HSTMDInput["T","q",zh,jT,Mh,mu,zeta];
ncRadial[expr_]:=expr/.Inactive[Integrate][f_,{q_,0,Infinity}]:>(f/.q->bh);
ncExact["native_U_radial_measure","Fourier_conversion",ncMeasures[[2]] dInput[bh],
 ncRadial[ncHPU/.D1Tilde[_,_,vv_,_,_]:>dInput[vv]/zh^2]];
ncExact["native_T_signed_radial_measure","Fourier_conversion",ncMeasures[[3]] cInput[bh],
 -ncRadial[ncHPT/.H1perpTilde1[_,_,vv_,_,_]:>-cInput[vv]/(2zh^4 Mh)],
 "Comparison applies the declared native-HC/Trento radial sign; full hard angular frames are not identified."];
ncExact["analyzer_local_sine","conventions",{Cos[phiS],Sin[phiS]}.HSCollinsAnalyzer[phiH,jT,zh,Mh],
 jT Sin[phiS-phiH]/(zh Mh)];

(* Native ep distribution action vs its actual saved assembly bindings. *)
ncKernelAction[kernel_,fn_,fraction_]:=Total[Table[
 If[part==="delta",kernel[part] fn[fraction],
 If[MemberQ[{"D0","D1"},part],kernel[part] RUObservableUAction[part,fn[fraction/u]/u,fraction],
 RUObservableUAction["regular",(kernel[part]/.z->u)fn[fraction/u]/u,fraction]]],{part,{"delta","D0","D1","regular"}}]];
ncD1=ncKernelAction[ncData["ep_tmd_full"]["dqq"],FFq,zh]+ncKernelAction[ncData["ep_tmd_full"]["dgq"],FFg,zh];
ncC1=ncKernelAction[ncData["ep_tmd_full"]["collins"],Hhatq,zh];
ncBindings=ncData["ep_observable"]["native_bindings"];
ncExact["saved_ep_UU_convolution","native_saved_reassembly",ncD1,(D1/.ncBindings)/.xi->u];
ncExact["saved_ep_UT_convolution","native_saved_reassembly",ncC1,(C1/.ncBindings)/.xi->u];
ncHF=RUObservableHFAction[ncData["ep_observable"]["HF_kernel"]/.B->Bh,zh];
ncExact["saved_ep_HF_action","native_saved_reassembly",ncHF,ncData["ep_observable"]["HF_full_contact_action"]];
ncTestPhi=ncPhiHF[zh/u,zh/(u v)]/u;
ncExact["HF_test_endpoint_value","test_input_scope",ncTestPhi/.v->1,0];
ncExact["HF_test_endpoint_derivative","test_input_scope",D[ncTestPhi,v]/.v->1,0,
 "Nonzero polarized two-fraction test in the inherited endpoint class; generic contacts remain uncertified."];
ncEPPoly=RUObservablePolynomial[0,0,ncSoft["r03/jet_UU_bare_remainder"],ncSoft["r03/jet_UT_bare_remainder"]]/.
 {HUU->1,HUT->1,f0->1,h0->1,f1->0,h1->0};
ncExact["ep_isolated_fragmentation_U1","assembly_order",ncEPPoly["UU1"],D1];
ncExact["ep_isolated_fragmentation_T1","assembly_order",ncEPPoly["UT1"],C1];
ncExact["highpt_fragmentation_order","assembly_order",HSTruncateHardJet[1,0,F0,F1+j1 F0,a],a F0+a^2(F1+j1 F0),
 "One-loop fragmentation is O(a) relative to each workflow's different Born order. Hhighpt starts at a."];

(* Rebuild only LO and Born-times-jet from actual saved Born banks. A zero
   hard_NLO bank is an explicit isolation input, not a computed DIS hard C1. *)
ncParameters=<|"Nf"->Nf,"Q2"->Q2,"xB"->xB,"pJT"->pJT,"u"->u,"y"->y,
 "zh"->zh,"jT"->jT,"Mh"->Mh,"R"->R,"mu"->muCommon|>;
ncZeroHard=AssociationMap[<|"L"->0,"T"->0|>&,{"Delta","L0","L1","Regular"}];
ncHPFresh=<||>;
Do[ncSector=If[spin==="UU","U","T"];
 ncBank=Join[ncData["highpt_born_banks"][spin<>"_Hqq"],<|"NLO"->ncZeroHard|>];
 ncBuilt=HSBuildChannelObservable["Hqq",ncSector,ncBank,ncParameters];
 AssociateTo[ncHPFresh,spin->ncBuilt];
 Do[ncExact["saved_highpt/"<>spin<>"/"<>part,"native_saved_reassembly",
  ncBoundNormalize[ncBuilt[part]],ncBoundNormalize[ncData["highpt_assembly"][spin][part]],
  "Actual saved Born bank; unchanged native HSBuildChannelObservable; hard_NLO isolated out."],
 {part,{"LO","Born_times_jet_NLO","TMD_input"}}],{spin,{"UU","UT"}}];

(* Exact distribution coefficients and independently implemented native actions.
   The output is the matching correction, not an endpoint point value. *)
ncJetKernels=<||>;
Do[ncRoute=If[key==="Tqq",{"T","q","q"},If[key==="Uqq",{"U","q","q"},{"U","q","g"}]];
 ncFresh=HSJetCanonical[HSJetMatching[Sequence@@ncRoute,z,L],z];
 AssociateTo[ncJetKernels,key->ncFresh];
 Do[ncExact["saved_jet/"<>key<>"/"<>part,"native_saved_reassembly",ncFresh[part],ncData["highpt_matching"][key][part]],
 {part,{"delta","plus0","plus1","regular"}}],{key,{"Uqq","Tqq","Uqg"}}];
ncEPJetAction[kern_,test_,lower_]:=kern["delta"](test/.u->1)+
 kern["plus0"]RUObservableUAction["D0",test,lower]+
 kern["plus1"]RUObservableUAction["D1",test,lower]+
 RUObservableUAction["regular",(kern["regular"]/.z->u)test,lower];
Do[ncPhi={1,z,1+z+z^2}[[index]];ncJet=ncJetKernels[key];
 ncHA=HSDistributionOneAction[ncJet,ncPhi,z,0];ncEA=ncEPJetAction[ncJet,ncPhi/.z->u,0];
 ncExact["jet_test/"<>key<>"/"<>ToString[index],"distribution_actions",
  Activate[ncHA],Activate[ncEA],"Smooth polynomial test on [0,1], symbolic L; delta and plus pieces retained."],
 {key,{"Uqq","Tqq"}},{index,1,3}];
(* This convenience helper is not called by HSBuildChannelObservable.
   Test its actual DownValue separately. The explicit RHS grouping correction
   is identified by old/new hashes; historical discrepancy evidence is retained. *)
Do[ncJet=ncJetKernels[key];
 ncExact["auxiliary_distribution_helper/"<>key,"auxiliary_helper_discrepancy",
  Activate[HSJetDistributionAction[ncJet,1,z]],Activate[HSDistributionOneAction[ncJet,1,z,0]],
  "Native auxiliary helper versus production action on phi=1 after explicit RHS grouping. The original two nonzero differences remain in jet-native-comparison-001/verified; production still uses HSDistributionOneAction. The historical group name is retained for direct row comparison."],
 {key,{"Uqq","Tqq"}}];
(* Nonpolynomial tests and finite lower limits; two native action definitions. *)
Do[ncJet=ncJetKernels[key]/.ncColorRules/.L->ncLog;
 ncHA=HSDistributionOneAction[ncJet,Exp[-z](1+z^2),z,ncLower];
 ncEA=ncEPJetAction[ncJet,Exp[-u](1+u^2),ncLower];
 ncNumerical["out_of_jet/"<>key<>"/"<>ncString[{ncLog,ncLower}],"semiinclusive_difference",
  ncNumericIntegrals[ncHA],ncNumericIntegrals[ncEA],
  "Expected high-pT minus ep extra-jet coefficient; shared intrinsic input is factored out. No distribution point values.",True],
 {key,{"Uqq","Tqq","Uqg"}},{ncLog,{0,Log[4],-Log[4]}},{ncLower,{1/5,2/5}}];

(* Several common small-b windows with nonzero quark, gluon, Collins and HF
   test inputs. Only small-b-window actions are claimed for the local OPE.
   These are reproducible smooth test functions, not fitted fragmentation. *)
ncCases={
 <|"id"->"k1","zh"->1/3,"pJT"->20,"R"->1/10,"mu"->2,"jT"->1/5,"Y"->0,"bmin"->1/20,"bmax"->1/4|>,
 <|"id"->"k2","zh"->1/2,"pJT"->30,"R"->3/20,"mu"->9,"jT"->2/5,"Y"->1/3,"bmin"->1/25,"bmax"->1/5|>,
 <|"id"->"k3","zh"->2/3,"pJT"->40,"R"->1/5,"mu"->4,"jT"->3/5,"Y"->-1/2,"bmin"->1/30,"bmax"->3/20|>};
ncWindow[b_,lo_,hi_]:=(b-lo)^2(hi-b)^2/(hi-lo)^4;
ncSampleResults=<||>;
Do[
 Print["KINEMATIC_CASE ",point["id"]];
 ncZ=point["zh"];ncLo=point["bmin"];ncHi=point["bmax"];
 ncRules={zh->ncZ,Mh->7/50,mu->point["mu"],jT->point["jT"],pJT->point["pJT"],R->point["R"]};
 ncDTest=ncCleanIntegrals[ncLinearLogs[ncD1/.ncInputRules/.ncRules/.ncColorRules]];
 ncCTest=ncCleanIntegrals[ncLinearLogs[ncC1/.ncInputRules/.ncRules/.ncColorRules]];
 ncHFTest=ncHF/.ncInputRules/.ncRules/.ncColorRules;
 ncHFTest=ncHFTest/.Inactive[Integrate][ff_,range__List]:>Inactive[Integrate][Cancel[ff],range];
 ncHFTest=ncCleanIntegrals[ncLinearLogs[ncHFTest]];
 If[!FreeQ[ncHFTest,HFNative],Print["ADAPTER_UNBOUND_HF_INPUT"];Exit[3]];
 ncDP=ncNumericIntegrals[ncDTest];ncCP=ncNumericIntegrals[ncCTest];ncHFP=ncNumericIntegrals[ncHFTest];
 ncDP=ncDP/.{Bh->Log[point["mu"]^2 bh^2 Exp[2EulerGamma]/4],Th->Log[point["mu"]^2/(point["pJT"]point["R"])^2]};
 ncCP=(ncCP+ncHFP)/.{Bh->Log[point["mu"]^2 bh^2 Exp[2EulerGamma]/4],Th->Log[point["mu"]^2/(point["pJT"]point["R"])^2]};
 ncIntrinsic=<|"UU0"->ncPhiQ[ncZ],"UU1"->ncDP,
  "UT0"->(ncPhiC[ncZ]/.Mh->7/50),"UT1"->ncCP|>;
 ncEPCommon=Join[ncEPPoly,<|"UT1"->ncEPPoly["UT1"]+HF1|>]/.
  {D0->ncIntrinsic["UU0"],D1->ncIntrinsic["UU1"],C0->ncIntrinsic["UT0"],C1->ncCP,HF1->0};
 (* CP already includes HF exactly once; high-pT gets the same supplied intrinsic factor. *)
 Do[
  ncOrder=Last[Characters[key]];ncSpin=StringTake[key,2];
  ncFactor=ncIntrinsic[key];
  ncEPRad=ncEPCommon[key](ncMeasures[[If[ncSpin==="UU",2,3]]]/.ncRules);
  ncHPRad=If[ncSpin==="UU",ncRadial[ncHPU/.D1Tilde[_,_,vv_,_,_]:>(ncFactor/.bh->vv)/zh^2],
   -ncRadial[ncHPT/.H1perpTilde1[_,_,vv_,_,_]:>-(ncFactor/.bh->vv)/(2zh^4 Mh)]]/.ncRules;
  ncEVal=NIntegrate[Evaluate[ncWindow[bh,ncLo,ncHi]ncEPRad],{bh,ncLo,ncHi},WorkingPrecision->ncWP,AccuracyGoal->40,PrecisionGoal->40];
  ncHVal=NIntegrate[Evaluate[ncWindow[bh,ncLo,ncHi]ncHPRad],{bh,ncLo,ncHi},WorkingPrecision->ncWP,AccuracyGoal->40,PrecisionGoal->40];
  ncNumerical[point["id"]<>"/"<>key,"common_intrinsic_native_assemblies",ncEVal,ncHVal,
   "Shared ep small-b input supplied to high-pT, explicit normalization/sign map; polarized NLO includes nonzero physical-class HF."];
  AssociateTo[ncSampleResults,point["id"]<>"/"<>key-><|"ep"->ncEVal,"highpt_converted"->ncHVal|>],
 {key,{"UU0","UU1","UT0","UT1"}}];
 (* Test the actual production Born-times-jet action with a physical smooth
    PDF weight. Its independent weight comes from solving delta(w), not
    from copying HSBreitBornJetAction's coordinate formula. *)
 Do[
  ncSpin=If[ncKey==="Uqq","UU","UT"];
  ncBornBank=ncData["highpt_born_banks"][ncSpin<>"_Hqq"]["LO"];
  ncBorn=(HSAzimuthAveragedLepton[ncBornBank["L"],ncBornBank["T"],Q2,y]/.
    ncHPFresh[ncSpin]["common_scale_map"])/.
   {Q2->10000,y->2/5,eq->2/3}/.ncColorRules;
  ncPDF=If[ncSpin==="UU",xx(1-xx)^3,2xx(1-xx)^3/5];
  ncPhysicalJet=ncJetKernels[ncKey]/.L->Log[point["mu"]^2/(point["pJT"]point["R"])^2]/.ncColorRules;
  ncProductionAction=HSBreitBornJetAction[ncBorn,ncPhysicalJet,ncPDF,xx,z,10000,1/10,point["pJT"],6/5];
  ncInvariants=HSBreitHardInvariants[10000,1/10,xx,point["pJT"],6/5,z];
  ncXRoot=xx/.First[Solve[ncInvariants["w"]==0,xx]];
  ncPhysicalLower=HSBreitConvolutionBounds[10000,1/10,point["pJT"],6/5,z]["zJ_min"];
  ncWeight=Together[(ncBorn/.{s->ncInvariants["s"],t->ncInvariants["t"]})
    ncPDF/(xx z^2 D[ncInvariants["w"],xx])/.xx->ncXRoot];
  ncOtherAction=ncEPJetAction[ncPhysicalJet,ncWeight/.z->u,ncPhysicalLower];
  ncTreeFactor=ncSampleResults[point["id"]<>"/"<>ncSpin<>"0"]["ep"];
  ncBornWeight=ncWeight/.z->1;
  ncNumerical[point["id"]<>"/physical_"<>ncKey,"weighted_semiinclusive_difference",
   ncTreeFactor ncNumericIntegrals[ncProductionAction]/ncBornWeight,
   ncTreeFactor ncNumericIntegrals[ncOtherAction]/ncBornWeight,
   "Actual HSBuildChannelObservable Born-times-jet action; archived Born coefficients, Q2=10000, xB=1/10, exp(etaJ)=6/5, y=2/5, one quark, PDF=x(1-x)^3 (UT times 2/5). Delta(w) solved independently; reduced by native Born weight. Difference from ep extra jet=0, coefficient of relative a.",True],
 {ncKey,{"Uqq","Tqq"}}];
 ncRecoil=(ncSoft["r03/recoil_soft_finite"]/.{CF->4/3,r->Log[point["R"]^2],Y->point["Y"],
  Bq->Log[point["mu"]^2(1/7)^2 Exp[2EulerGamma]/4]});
 ncNumerical[point["id"]<>"/recoil_separate","recoil_expected_difference",ncRecoil,ncRecoil,
  "Saved native ep recoil coefficient retained outside fragmentation comparison; high-pT has no electron-jet recoil observable.",True],
 {point,ncCases}];
AssociateTo[ncDetails,<|"kinematics"->ncCases,"sample_results"->ncSampleResults,
 "test_inputs"->HoldComplete[{FFq[t]==t(1-t)^2,FFg[t]==2t(1-t)^3/5,Hhatq[t]==3Mh t^2(1-t)^3/5,
 HFNative[flavor,t1,t2,mu]==Mh t1(1-t1)^2(t1/t2)^2(1-t1/t2)^2/7}],
 "fresh_highpt_isolated_assemblies"->ncHPFresh,"native_ep_fragmentation_polynomial"->ncEPPoly,
 "auxiliary_distribution_DownValues"->DownValues[HSJetDistributionAction],
 "native_forward_Gaussian"->{ncEPForwardU,ncEPForwardC,ncGaussU,ncGaussT}|>];
Put[ncDetails,FileNameJoin[{ncOut,"comparison-expressions.wl"}]];
ncCounts=Counts[Lookup[ncRows,"status"]];
ncStatus=Which[Lookup[ncCounts,"UNRESOLVED",0]>0,"COMPARISONS_HAVE_UNRESOLVED_ROWS",
 Lookup[ncCounts,"DISCREPANCY",0]>0,"FOCUSED_COMPARISON_COMPLETE_WITH_DISCREPANCIES",
 True,"FOCUSED_CHECKS_COMPLETE_WITH_QUALIFICATIONS"];
Export[FileNameJoin[{ncOut,"comparison.csv"}],Prepend[Values/@ncRows,Keys[First[ncRows]]],"CSV"];
Export[FileNameJoin[{ncOut,"native-results.json"}],<|"status"->ncStatus,"counts"->ncCounts,"rows"->ncRows,
 "wolfram_version"->$Version,"working_precision"->ncWP,"accuracy_goal"->40,"precision_goal"->40,
 "numerical_scaled_tolerance"->ncString[ncTolerance],"kinematics"->Map[Map[ncString],ncCases],
 "independent_intrinsic_highpt_matching"->False,"full_cross_section_equivalence"->False|>,"RawJSON"];
Print["NATIVE_COMPARISON_DONE ",ncStatus," ",ncCounts];Exit[0];
