(* Adapted from accepted Collins source; exact original and SHA in provenance/COLLINS_SOURCE_REUSE_PLAN.json. *)
(* Generate complete electron channels, and independently expose the Compton current. *)
realFields=<|"eq"->{{F[2,{1}],F[3,{1}]},{F[2,{1}],F[3,{1}],V[5]}},"eg"->{{F[2,{1}],V[5]},{F[2,{1}],F[3,{1}],-F[3,{1}]}}|>;
realGraphs=Map[InsertFields[CreateTopologies[0,2->3],#[[1]]->#[[2]],Model->"SMQCD",InsertionLevel->{Particles},ExcludeParticles->{V[2|3],S[_],U[_]}]&,realFields];
realFA=Map[CreateFeynAmp[#,PreFactor->1]&,realGraphs];
Gate["two QCD emission orderings in each electron channel",And@@(Length[#]===2& /@ Values[realFA])];
realFC=Map[FCFAConvert[#,IncomingMomenta->{l,p},OutgoingMomenta->{lp,pp,k},UndoChiralSplittings->True,ChangeDimension->D,List->False,SMP->True,Contract->False,DropSumOver->True,FinalSubstitutions->{SMP["m_e"]->0,SMP["m_u"]->0}]&,realFA];
cg=InsertFields[CreateTopologies[0,2->2],{V[1],F[3,{1}]}->{F[3,{1}],V[5]},Model->"SMQCD",InsertionLevel->{Particles}];
cfa=CreateFeynAmp[cg,PreFactor->1];
cfc=FCFAConvert[cfa,IncomingMomenta->{q,p},OutgoingMomenta->{pp,k},UndoChiralSplittings->True,ChangeDimension->D,List->False,SMP->True,Contract->False,DropSumOver->True,FinalSubstitutions->{SMP["m_u"]->0}];
cfc=DotSimplify[cfc]/.{_SUNTF->1,Pair[_,Momentum[_Polarization,D]]->1};
current=FeynAmpDenominatorExplicit[Expand[cfc/(-I (2/3) SMP["e"] SMP["g_s"])]]/.Dot[_Spinor,body__,_Spinor]:>Dot[body];
current=Expand[current];
terms=If[Head[current]===Plus,List@@current,{current}];
routes=Map[Function[term,Module[{chain,route,fac,order},chain=First[Cases[term,_Dot,Infinity]];route=First[Cases[chain,DiracGamma[Momentum[v_,D],D]:>v,Infinity]];fac=Cancel[term/chain];
 Print["GENERATED_ROUTE ",InputForm[{route,fac,FullSimplify[fac SPD[route]]}]];
 Gate["generated scalar propagator normalization",FullSimplify[ExpandScalarProduct[fac SPD[route]]]===1];
 order=If[chain[[1]]===FCI[GAD[Lor1]],"photon_first","gluon_first"];
 <|"route"->(Coefficient[route,#]& /@ {p,pp,k}),"order"->order|>]],terms];
Gate["generated open-current routing",Sort[Lookup[routes,"route"]]===Sort[{{1,0,-1},{0,1,1}}]];
colorEq=SUNSimplify[SUNTrace[SUNT[colorIndex,colorIndex]]/SUNN];
colorEg=SUNSimplify[SUNTrace[SUNT[colorIndex,colorIndex]]/(SUNN^2-1)];
Gate["resolved spin-color averaging",colorEq===CF&&colorEg===1/2];
StagePut[<|"eq"->colorEq,"eg"->colorEg,"fundamental_trace_normalization"->HoldComplete[Tr[Ta.Tb]==TR Delta[a,b]],"fundamental_Casimir"->HoldComplete[CF==TR (Nc^2-1)/Nc]|>,"color_averages.wl"];
(* A closed Function carries the generated route table and Clifford representation.
   No FeynCalc or production helper is needed when the checker loads this packet. *)
makeCurrentEvaluator[crossed_]:=With[{routeData=routes,gammaData=PhysicalGammas[],cross=crossed,colorWeight=If[crossed,2 colorEg,colorEq/CF]},Function[request,Module[
 {mt={1,-1,-1,-1},gm=gammaData,g5,sl,dp,bar,li,pi,lf,pf,kk,qi,ki,qq,rhoi,rhof,cur,lepton,contraction,wp,wg,norm,ans},
 g5=I (Dot@@gm);sl[v_]:=Sum[mt[[ii]] v[[ii]] gm[[ii]],{ii,4}];dp[a_,b_]:=Sum[mt[[ii]] a[[ii]] b[[ii]],{ii,4}];bar[a_]:=gm[[1]].ConjugateTranspose[a].gm[[1]];
 {li,pi,lf,pf,kk}=Lookup[request,{"l","p","lp","pp","k"}];qi=If[cross,-kk,pi];ki=If[cross,-pi,kk];qq=li-lf;
 cur=Table[Total[Map[Function[row,With[{v=row["route"].{qi,pf,ki}},If[row["order"]=="photon_first",gm[[mm]].sl[v].gm[[aa]],gm[[aa]].sl[v].gm[[mm]]]/dp[v,v]]],routeData]],{mm,4},{aa,4}];
 rhoi=sl[If[cross,kk,pi]];rhof=sl[pf];
 lepton=Table[Tr[sl[lf].gm[[mm]].sl[li].gm[[nn]]],{mm,4},{nn,4}];
 contraction[ri_,rf_]:=Re[Sum[-mt[[aa]] mt[[mm]] mt[[nn]] lepton[[mm,nn]] Tr[rf.cur[[mm,aa]].ri.bar[cur[[nn,aa]]]],{aa,4},{mm,4},{nn,4}]]/(4 dp[qq,qq]^2);
 ans=<|"UU"->colorWeight request[If[cross,"TR","CF"]] contraction[rhoi,rhof]|>;
 If[!cross,AssociateTo[ans,"UT"->colorWeight request["CF"] contraction[sl[pi].g5.sl[request["Sin"]],sl[pf].g5.sl[request["Sout"]]]]];
 (* Ward residuals retain actual contractions; a positive matrix norm avoids
    a cancellation of signed terms masquerading as a Ward test. *)
 norm=Max[1,Total[Flatten[Abs[rhof.#.rhoi]^2& /@ Flatten[cur,1]]]];
 wp=Table[rhof.Sum[mt[[mm]] qq[[mm]] cur[[mm,aa]],{mm,4}].rhoi,{aa,4}];
 wg=Table[rhof.Sum[mt[[aa]] ki[[aa]] cur[[mm,aa]],{aa,4}].rhoi,{mm,4}];
 Join[ans,<|"ward_photon"->Total[Flatten[Abs[wp]^2]]/norm,"ward_gluon"->Total[Flatten[Abs[wg]^2]]/norm|>]
]]];
realFunctions=<|"eq"->makeCurrentEvaluator[False],"eg"->makeCurrentEvaluator[True]|>;
StagePut[realFunctions,"real_functions.wl"];
(* Collinear hard projection: the off-shell parent numerator is retained. *)
FCClearScalarProducts[];
SPD[n]=0;SPD[h]=0;SPD[v]=0;SPD[h,n]=z;SPD[v,n]=1-z;SPD[h,v]=ss/2;SPD[Q]=ss;SPD[Q,n]=1;SPD[Q,h]=ss/2;SPD[Q,v]=ss/2;
pol=-MTD[al,be]+(FVD[v,al] FVD[n,be]+FVD[n,al] FVD[v,be])/(1-z);
qqTrace=Contract[DiracSimplify[DiracTrace[GSD[n].GSD[Q].GAD[be].GSD[h].GAD[al].GSD[Q]] pol,DiracTraceEvaluate->True]];
gluonProjector=-MTD[al,be]+FVD[Q,al] FVD[n,be]+FVD[n,al] FVD[Q,be]-ss FVD[n,al] FVD[n,be];
qgTrace=Contract[DiracSimplify[DiracTrace[GSD[h].GAD[al].GSD[v].GAD[be]],DiracTraceEvaluate->True] gluonProjector];
rawSplitting=<|"qq"->Factor[CF qqTrace/(8 ss)/.D->4-2 eps],"qg"->Factor[TR qgTrace/(2 ss (D-2))/.D->4-2 eps]|>;
AssociateTo[rawSplitting,"gq"->Factor[rawSplitting["qq"]/.z->1-z]];
(* Physical spin vectors, after BMHV separation. No D-dimensional gamma5
   anticommutation is applied. Average the two physical transverse directions. *)
FCClearScalarProducts[];SP[n]=0;SP[h]=0;SP[v]=0;SP[h,n]=z;SP[v,n]=1-z;SP[h,v]=ss/2;SP[Q]=ss;SP[Q,n]=1;SP[Q,h]=ss/2;SP[Q,v]=ss/2;SP[S]=-1;SP[n,S]=0;SP[Q,S]=0;SP[h,S]=aa;SP[v,S]=-aa;
pol4=-MT[al,be]+(FV[v,al] FV[n,be]+FV[n,al] FV[v,be])/(1-z);
utTrace=Contract[DiracSimplify[DiracTrace[GS[n].GA[5].GS[S].GS[Q].GA[be].GS[h].GA[5].(GS[S]-aa/z GS[n]).GA[al].GS[Q]] pol4,DiracTraceEvaluate->True]];
transReal=Factor[CF (Expand[utTrace]/.aa^2->z (1-z) ss/2)/(8 ss)];
StagePut[<|"fields"->realFields,"graphs"->realGraphs,"FeynArts"->realFA,"FeynCalc"->realFC,"Compton_FeynArts"->cfa,"open_current"->current,"routes"->routes,"averages"-><|"eq"->CF/4,"eg"->TR/4|>,"crossing"->{p->-k,k->-p},"spin"->HoldComplete[GS[p].GA[5].GS[Sin],GS[pp].GA[5].GS[Sout]],"qq_trace"->qqTrace,"qg_trace"->qgTrace,"transversity_trace"->utTrace,"raw_splitting"->rawSplitting,"transversity_real"->transReal|>,"real_amplitudes.wl"];
(* Exact Ward and soft identities at matrix level, for unconstrained photon
   virtuality. Individual ordering contractions are kept on opposing sides. *)
gam=PhysicalGammas[];metric={1,-1,-1,-1};sp4[v_]:=PhysicalSlash[v,gam];
pv={3/2,0,0,3/2};ov={1,-1/2,Sqrt[3]/2,0};kv={1,-1/2,-Sqrt[3]/2,0};qv=ov+kv-pv;
oneOrdering[row_,mu_,al_,scale_:1]:=With[{vv=row["route"].{pv,ov,scale kv}},If[row["order"]=="photon_first",gam[[mu]].sp4[vv].gam[[al]],gam[[al]].sp4[vv].gam[[mu]]]/MDot[vv,vv]];
wardParts[which_]:=Table[Table[sp4[ov].Sum[metric[[j]] If[which=="photon",qv[[j]],kv[[j]]] If[which=="photon",oneOrdering[routes[[o]],j,i],oneOrdering[routes[[o]],i,j]],{j,4}].sp4[pv],{i,4}],{o,2}];
we=FullSimplify[wardParts["photon"]];wg=FullSimplify[wardParts["gluon"]];
softMatrix=Table[FullSimplify[Limit[lambda sp4[ov].Sum[oneOrdering[row,mu,al,lambda],{row,routes}].sp4[pv],lambda->0]],{mu,4},{al,4}];
softEikonal=Table[(ov[[al]]/MDot[ov,kv]-pv[[al]]/MDot[pv,kv]) sp4[ov].gam[[mu]].sp4[pv],{mu,4},{al,4}];
StagePut[<|"photon_orderings"->we,"gluon_orderings"->wg,"soft_matrix"->softMatrix,"eikonal_matrix"->softEikonal|>,"current_identities.wl"];
$RealProofs=<|"real.ward_e"->ProofPair[we[[1]],-we[[2]]],"real.ward_g"->ProofPair[wg[[1]],-wg[[2]]],"real.soft_limit"->ProofPair[softMatrix,softEikonal],"real.collinear_limits"->ProofPair[{qqTrace/.D->4-2 eps,qgTrace/.D->4-2 eps,Expand[utTrace]/.aa^2->z (1-z) ss/2},{8 ss rawSplitting["qq"]/CF,2 ss (2-2 eps) rawSplitting["qg"]/TR,8 ss transReal/CF},0<z<1&&ss>0&&CF TR!=0]|>;

