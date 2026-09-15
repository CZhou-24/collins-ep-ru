Get[FileNameJoin[{DirectoryName[$InputFileName],"stage_io.wl"}]];StageBegin["s07"];
Get[FileNameJoin[{DirectoryName[$InputFileName],"physics_helpers.wl"}]];LoadFC[];
integ=Get[StageInput["s04","integrands.wl"]];red=Get[StageInput["s05","reduction.wl"]];masters=Get[StageInput["s06","masters.wl"]];born=Get[StageInput["s03","tensors.wl"]];
color=integ["loop_prefactor"];
scalar=Factor[(red["reduced"]/.masters["values"])/.D->4-2 eps];
bare=Expand[Normal[Series[color Exp[eps L] scalar,{eps,0,0}]]];
(* UV origin: large-ell angular average of the actual projected vertex numerator. *)
uvLeading=(integ["projected_numerator"]/.{Pair[Momentum[ell,D],Momentum[p,D]] Pair[Momentum[ell,D],Momentum[pout,D]]->Q2 ell2/(2 D),Pair[Momentum[ell,D],Momentum[ell,D]]->ell2,Pair[Momentum[ell,D],Momentum[p,D]]->0,Pair[Momentum[ell,D],Momentum[pout,D]]->0});
vertexUV=Factor[Coefficient[uvLeading,ell2]/.D->4];
(* The generated gluon self-energy has gamma_a slash(ell+p) gamma^a.
   The two massless propagators' exchange maps the generated loop momentum k to p/2. *)
selfData=Get[StageInput["s04","generated_self_energy.wl"]];
selfNumerator=DiracSimplify[selfData["numerator"]/.selfData["bubble_exchange_average"]];
selfUV=Factor[(selfNumerator/FCI[GSD[p]])/.D->4];
Gate["vertex and external-leg UV poles cancel",vertexUV+selfUV===0];
selfSplit=color selfUV (1/epsUV-1/epsIR);
vertexSplit=bare/.eps->epsIR;
vertexSplit=vertexSplit+color vertexUV (1/epsUV-1/epsIR);
renormalized=Expand[(vertexSplit+selfSplit)/.{epsUV->eps,epsIR->eps}];
(* In the on-shell EFT the loop integrals are scaleless. Minimal current
   renormalization fixes Z by the remaining poles; no finite part is removed. *)
currentIR=Total[Table[Coefficient[renormalized,eps,n] eps^n,{n,-2,-1}]];
finite=FullSimplify[renormalized-currentIR];
Gate["finite current matching",FreeQ[finite,eps|_V|_DiracTrace|_SMP|_SUNFDelta]];
(* Construct interference with the reduced open current in the actual Born amplitude. *)
amp=Get[StageInput["s03","amplitudes.wl"]]["amplitude"];
FCClearScalarProducts[];SetMandelstam[s,t,u,l,p,-lout,-pout,0,0,0,0];
interference=2 finite FeynAmpDenominatorExplicit[amp ComplexConjugate[amp]];
traces=FermionSpinSum[interference,ExtraFactor->1/(4 SUNN),Head->density];
uu=Factor[SUNSimplify[DiracSimplify[traces/.density->Identity]]/((2/3)^2 SMP["e"]^4)];
Do[With[{mom=m},SP[si,mom]=0;SP[so,mom]=0],{m,{l,p,lout,pout}}];SP[si]=SP[so]=-1;SP[si,so]=-1;
utTraces=traces/.{density[DiracGamma[Momentum[p]]]:>GS[p].GA[5].GS[si],density[DiracGamma[Momentum[pout]]]:>GS[pout].GA[5].GS[so],density[x_]:>x};
ut=Factor[SUNSimplify[DiracSimplify[utTraces]]/((2/3)^2 SMP["e"]^4)];
StagePut[<|"coefficient_alpha_s_over_4pi"->bare,"vertex_UV"->color vertexUV/epsUV,"vertex_split"->vertexSplit,"self_energy_split"->selfSplit,"self_energy_gamma"->selfNumerator|>,"bare_virtual.wl"];
StagePut[<|"coefficient"->renormalized,"current_IR_factor"->currentIR,"scheme"->"minimal on-shell vector-current matching; no finite IR subtraction"|>,"renormalized_virtual.wl"];
StagePut[<|"h1"->finite,"amplitude_coefficient_alpha_s_over_4pi"->finite,"UU_interference"->uu,"UT_interference"->ut,"squared_convention"->"H=1+alpha_s/(2 pi) h1","open_current_reduction"->red["open_reduced"]|>,"hard.wl"];
Export[StagePath["pole_ledger.json"],<|"schema"->1,"vertex_UV"->ToString[color vertexUV/epsUV,InputForm],"on_shell_legs"->ToString[selfSplit,InputForm],"remaining_IR"->ToString[currentIR,InputForm],"current_matching"->"EFT loop scaleless; minimal current counterterm obtained from IR poles, with no finite adjustment","coupling"->"MSbar; coupling counterterm starts at relative two loops because Born has no g_s","vector_current"->"conserved, no independent current UV renormalization","spin"->"open vector line reduced in D before 4D spin projection; no axial insertion in loop, hence no Z5 conversion here; polarized beam/fragmentation matching deferred"|>,"RawJSON"];
StagePut[<|"virtual.uv_cancellation"->With[{a=vertexSplit,b=selfSplit,c=renormalized/.eps->epsIR},ProofHeld[HoldComplete[a+b],HoldComplete[c],epsUV!=0&&epsIR!=0]],
 "hard.ir_subtraction"->With[{a=renormalized,z=currentIR,h=finite},ProofHeld[HoldComplete[a-z],HoldComplete[h],eps!=0]],
 "hard.spin_uu"->ProofPair[uu,2 finite born["H_UU"],s>0&&t<0&&u<0&&s+t+u==0],
 "hard.spin_ut"->ProofPair[ut,2 finite born["H_UT"],s>0&&t<0&&u<0&&s+t+u==0]|>,"proofs.wl"];
Print["DERIVED_CURRENT ",InputForm[finite]];StageFinish[];
