(* Generate the open QCD vertex; project only after retaining its D-dimensional numerator. *)
Get[FileNameJoin[{DirectoryName[$InputFileName],"stage_io.wl"}]];StageBegin["s04"];
Get[FileNameJoin[{DirectoryName[$InputFileName],"physics_helpers.wl"}]];LoadFC[];
diags=InsertFields[CreateTopologies[1,1->2,ExcludeTopologies->{Tadpoles,WFCorrections}],{F[3,{1}]}->{V[1],F[3,{1}]},Model->"SMQCD",InsertionLevel->{Particles},ExcludeParticles->{S[_],U[_],V[2|3],F[1|2|4],F[3,{2|3}]}];
raw=CreateFeynAmp[diags,PreFactor->1];StagePut[<|"graphs"->diags,"amplitudes"->raw|>,"generated_vertex.wl"];
graphCount=Length[raw];Gate["nonempty actual vertex inventory",graphCount>0&&And@@(SymbolName[Head[#]]=="FAFeynAmp"& /@ List@@raw)];
a=FCFAConvert[raw,IncomingMomenta->{p},OutgoingMomenta->{q,pout},LorentzIndexNames->{mu},LoopMomenta->{k},UndoChiralSplittings->True,ChangeDimension->D,List->False,SMP->True,Contract->False,DropSumOver->True,FinalSubstitutions->{SMP["m_u"]->0}];
StagePut[a,"converted_vertex.wl"];
qcd=Coefficient[Expand[SUNSimplify[DotSimplify[a]]],SMP["g_s"],2]/.q->p-pout/.k->ell+p;
StagePut[qcd,"routed_vertex.wl"];
treeGraphs=InsertFields[CreateTopologies[0,1->2],{F[3,{1}]}->{V[1],F[3,{1}]},Model->"SMQCD",InsertionLevel->{Particles}];
treeRaw=CreateFeynAmp[treeGraphs,PreFactor->1];
tree=FCFAConvert[treeRaw,IncomingMomenta->{p},OutgoingMomenta->{q,pout},LorentzIndexNames->{mu},UndoChiralSplittings->True,ChangeDimension->D,List->False,SMP->True,DropSumOver->True,FinalSubstitutions->{SMP["m_u"]->0}];
stripStructures={_Dot->1,_FeynAmpDenominator->1,_Pair->1,_SUNFDelta->1};
loopColor=Factor[I (qcd/.stripStructures)/(DotSimplify[tree]/.stripStructures)];
colorInNc=Factor[loopColor/.{CA->Nc,CF->(Nc^2-1)/(2 Nc)}];
loopColor=Cancel[colorInNc/((Nc^2-1)/(2 Nc))] CF;
StagePut[<|"tree_generation"->treeRaw,"tree"->tree,"loop_to_tree_after_normalized_measure"->loopColor|>,"coupling_normalization.wl"];
chains=DeleteDuplicates[Cases[qcd,z_Dot/;!FreeQ[z,Spinor],Infinity]];
Gate["one generated QCD open spinor chain",Length[chains]===1];
chain=First[chains];metrics=DeleteDuplicates[Cases[qcd,Pair[_LorentzIndex,_LorentzIndex],Infinity]];
num=Contract[(Dot@@Rest[Most[List@@chain]]) Times@@metrics];
FCClearScalarProducts[];SPD[p]=0;SPD[pout]=0;SPD[p,pout]=Q2/2;
canonical=GAD[alpha].GSD[ell+pout].GAD[mu].GSD[ell+p].GAD[alpha];
Gate["generated numerator reconstructs canonical routing",DiracSimplify[num-canonical]===0];
projected=Factor[Contract[DiracSimplify[DiracTrace[GSD[pout].num.GSD[p].GAD[mu]],DiracTraceEvaluate->True]]/DiracSimplify[DiracTrace[GSD[pout].GAD[mu].GSD[p].GAD[mu]],DiracTraceEvaluate->True]];
scalarRules={Pair[Momentum[ell,D],Momentum[ell,D]]->d0,Pair[Momentum[ell,D],Momentum[p,D]]->(d1-d0)/2,Pair[Momentum[ell,D],Momentum[pout,D]]->(d2-d0)/2};
poly=Expand[ExpandScalarProduct[projected]/.scalarRules];
Gate["scalar numerator resolved",FreeQ[poly,_Pair|_DiracTrace]];
(* Tensor decomposition performs no master evaluation; scalar denominators remain. *)
openTID=DiracSimplify[TID[SpinorUBarD[pout].num.SpinorUD[p] FAD[ell,ell+p,ell+pout],ell,ToPaVe->False,UsePaVeBasis->False]];
StagePut[openTID,"open_tensor_decomposition.wl"];
(* Classify these scalar integrals by their active chord distances after TID's loop translations. *)
scalarTID=Factor[openTID/FCI[SpinorUBarD[pout].GAD[mu].SpinorUD[p]]];
chordAudit={};
toFamily[fd_FeynAmpDenominator]:=Module[{momenta,chords,result},
 momenta=(#[[1]]/.Momentum[z_,D]:>z)& /@ List@@fd;
 chords=Sort[Factor[ExpandScalarProduct[SPD[#[[1]]-#[[2]]]]]& /@ Subsets[momenta,{2}]];
 result=Which[chords==={-Q2},V[0,1,1],chords===Sort[{-Q2,0,0}],V[1,1,1],True,badIntegral[fd]];
 AppendTo[chordAudit,<|"momenta"->momenta,"chords"->chords,"family"->result|>];result];
openScalar=scalarTID/.fd_FeynAmpDenominator:>toFamily[fd];
Gate["open current has only scalar bubble and triangle coefficients",FreeQ[openScalar,_Spinor|_DiracGamma|_badIntegral]];
StagePut[<|"scalar_integrals"->scalarTID,"family_expression"->openScalar,"chord_audit"->chordAudit,"routing"->"bubble ell -> ell+p and triangle ell -> -ell map to the declared family"|>,"open_current.wl"];
(* Generate the self-energy graph for the explicit scaleless UV/IR ledger. *)
selfGraphs=InsertFields[CreateTopologies[1,1->1,ExcludeTopologies->{Tadpoles}],{F[3,{1}]}->{F[3,{1}]},Model->"SMQCD",InsertionLevel->{Particles},ExcludeParticles->{S[_],U[_],V[1|2|3],F[1|2|4],F[3,{2|3}]}];
selfRaw=CreateFeynAmp[selfGraphs,PreFactor->1];
selfConverted=FCFAConvert[selfRaw,IncomingMomenta->{p},OutgoingMomenta->{p},LoopMomenta->{k},UndoChiralSplittings->True,ChangeDimension->D,List->False,SMP->True,Contract->False,DropSumOver->True,FinalSubstitutions->{SMP["m_u"]->0}];
selfExpanded=SUNSimplify[DotSimplify[selfConverted]];
selfChains=DeleteDuplicates[Cases[selfExpanded,z_Dot/;!FreeQ[z,Spinor],Infinity]];
Gate["generated gluon self-energy chain",Length[selfChains]===1];
selfMetrics=DeleteDuplicates[Cases[selfExpanded,Pair[_LorentzIndex,_LorentzIndex],Infinity]];
selfGamma=Contract[(Dot@@Rest[Most[List@@First[selfChains]]]) Times@@selfMetrics];
StagePut[<|"graphs"->selfGraphs,"amplitudes"->selfRaw,"converted"->selfConverted,"numerator"->selfGamma,"bubble_exchange_average"->(k->p/2)|>,"generated_self_energy.wl"];
StagePut[<|"numerator"->num,"projected_numerator"->projected,"scalar_numerator"->poly,"scalar_rules"->scalarRules,"denominator_symbols"->{d0,d1,d2},"propagator_momenta"->{ell,ell+p,ell+pout},"dimension"->D,"loop_measure"->"d^D ell/(i pi^(D/2))","loop_prefactor"->loopColor,"open_tensor_decomposition"->openTID|>,"integrands.wl"];
Export[StagePath["diagrams.json"],<|"schema"->1,"generated_vertex_graphs"->graphCount,"generated_self_energy_graphs"->Length[selfRaw],"selection"->"coefficient of g_s^2 in the generated SMQCD photon vertex","routing"->"q=p-pout; k=ell+p","self_energy"->"generated separately; massless on-shell integral scaleless, UV/IR split retained","D"->"4-2 eps; no gamma5 in virtual reduction"|>,"RawJSON"];
g=PhysicalGammas[];av={a0,a1,a2,a3};bv={b0,b1,b2,b3};aslash=PhysicalSlash[av,g];bslash=PhysicalSlash[bv,g];
lv={l0,l1,l2,l3};pv={p0,p1,p2,p3};pvout={r0,r1,r2,r3};kv=lv+pv;qv=pv-pvout;
StagePut[<|"virtual.ward"->ProofPair[aslash.(bslash-aslash).bslash,MDot[bv,bv] aslash-MDot[av,av] bslash,True],
 "virtual.routing"->With[{ka=kv,qa=qv,pa=pv,ra=pvout,la=lv,gg=DiagonalMatrix[{1,-1,-1,-1}]},ProofHeld[HoldComplete[{ka.gg.ka,(ka-qa).gg.(ka-qa),(ka-ra-qa).gg.(ka-ra-qa)}],HoldComplete[{(la+pa).gg.(la+pa),(la+ra).gg.(la+ra),la.gg.la}],True]]|>,"proofs.wl"];
StageFinish[];
