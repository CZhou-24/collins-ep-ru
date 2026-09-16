(* Exact continuous collinear family of the saved physical-tagged Hqq qgg
   amplitude. This checks a residue, not the full process finite conversion. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];engine=FileNameJoin[{root,"collins_sidis_highpt"}];
out=Environment["SIDIS_COLLINEAR_OUT"];
If[!StringQ[out]||DirectoryQ[out],Print["Supply unused SIDIS_COLLINEAR_OUT"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
rt=Import[FileNameJoin[{root,"collins_ep_analytic_SIDIS","ru_runtime.json"}],"RawJSON"];
Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};Global`$FeynCalcStartupMessages=False;
Global`$FeynCalcDirectory=rt["feyncalc_root"];FeynCalc`$FeynArtsDirectory=rt["feynarts_root"];
Get[FileNameJoin[{rt["feyncalc_root"],"FeynCalc.m"}]];
FeynCalc`FCSetDiracGammaScheme["BMHV"];
Get[FileNameJoin[{engine,"common","spin_core.wl"}]];
Get[FileNameJoin[{engine,"common","spin_nlo.wl"}]];
Get[FileNameJoin[{engine,"common","spin_real_tensor.wl"}]];
file=FileNameJoin[{root,"SIDIS","Hqq","s01_result","s01_inputs","s01_result.wl"}];bank=Get[file];
$HSChargeSquared=Get[FileNameJoin[{root,"SIDIS","Hqq","s01_result","s01_inputs","s02_result.wl"}]]["ModelChargeSquared"];
amps=bank["RealQGG"]/.{SMP["e"]->1,SMP["g_s"]->1};
bornamp=Total[bank["Born"]]/.{SMP["e"]->1,SMP["g_s"]->1};
HSBornKinematics[];
born=HSBornContraction[bornamp,"T",phX,phX,pinY,poutY]/.{Q->2,r->1,z->1/2,h->1/2,CF->(SUNN^2-1)/(2SUNN)};
Put[<|"dimensional_Born_T22_XX"->born|>,FileNameJoin[{out,"born.wl"}]];
FCClearScalarProducts[];
ev=1-zc+lam^2*m2/4;vx=ev-lam^2*m2/(2zc);vz=lam*aa/4+lam^2*m2/4;
vectors=<|p->{2,0,0,2},q->{0,0,0,-2},k1->{zc,zc,0,0},
 k2->{ev,vx,lam*bb,vz},k3->{2-zc-ev,-zc-vx,-lam*bb,-vz},
 pinX->{0,1,0,0},pinY->{0,0,1,0},poutX->{0,0,0,-1},poutY->{0,0,1,0},
 phL->{1,0,0,0},phX->{0,1,0,0},phY->{0,0,1,0}|>;
hat=-HSDot[vectors[k2],vectors[k2]];keys=Keys[vectors];
Do[With[{a=keys[[i]],b=keys[[j]],bar=Factor[HSDot[vectors[keys[[i]]],vectors[keys[[j]]]]],
 hv=If[MemberQ[{k2,k3},keys[[i]]]&&MemberQ[{k2,k3},keys[[j]]],If[i===j,hat,-hat],0]},
 SP[a,b]=bar;SPE[a,b]=hv;SPD[a,b]=Factor[bar+hv]],{i,Length[keys]},{j,i,Length[keys]}];
HSOnShell[x_]:=Factor[Together[x]];
geometry=<|"vectors4"->vectors,"hat_k2_squared"->Factor[hat],
 "cut_residuals"->{SPD[k2,k2],SPD[k3,k3]},"collinear_invariant"->Factor[2SPD[k1,k2]],
 "tagged_hat_residual"->SPE[k1,k1],"soft_excluded"->HoldComplete[0<zc<1],
 "positive_energy_limit"->{zc,1-zc,1},"parent_Born_point"->HoldComplete[Q==2&&r==1&&z==1/2],
 "angular_measure"->HoldComplete[aa==4Sqrt[(1-zc)m2/zc] n1&&bb==Sqrt[(1-zc)m2/zc] n2&&n.n==1],
 "angular_dimension"->D-2|>;
Put[geometry,FileNameJoin[{out,"geometry.wl"}]];
If[!And@@(#===0&/@geometry["cut_residuals"]),Print["Bad cuts"];Exit[2]];
radial=(1-zc)m2/zc;
average[x_]:=Module[{num=Numerator[Together[x]],den=Denominator[Together[x]]},
 If[!FreeQ[den,aa|bb]||!PolynomialQ[num,{aa,bb}],Print["Nonpolynomial collinear azimuth"];Exit[3]];
 Factor[Total[KeyValueMap[Function[{powers,coef},If[AnyTrue[powers,OddQ],0,
 coef 4^powers[[1]] radial^(Total[powers]/2) Times@@(Pochhammer[1/2,#/2]&/@powers)/Pochhammer[(D-2)/2,Total[powers]/2]]],
 Association[CoefficientRules[num,{aa,bb}]]]]/den]];
sourceHash=IntegerString[FileHash[$InputFileName,"SHA256"],16,64];
pairs=Flatten[Table[{i,j},{i,Length[amps]},{j,i,Length[amps]}],1];
requested=Environment["SIDIS_COLLINEAR_PAIRS"];
If[StringQ[requested]&&StringLength[requested]>0,pairs=(ToExpression/@StringSplit[#,"_"]&/@StringSplit[requested,","])];
If[!And@@(MatchQ[#,{_Integer,_Integer}]&&1<=#[[1]]<=#[[2]]<=Length[amps]&/@pairs),Print["Invalid collinear pair selection"];Exit[3]];
denominators=Table[DeleteDuplicates[Flatten[Cases[amps[[ii]],FeynAmpDenominator[props__]:>
 (Factor[ExpandScalarProduct[1/FeynAmpDenominatorExplicit[FeynAmpDenominator[#]]]]&/@{props}),Infinity]]],{ii,Length[amps]}];
singularDiagrams=Select[Range[Length[amps]],AnyTrue[denominators[[#]],Factor[#/.lam->0]===0&]&];
emissionIdentity=DiracSimplify[GSD[k1].GAD[al].GSD[k1]-2FVD[k1,al]GSD[k1]];
axialSum=-MTD[al,be]+(FVD[k2,al]FVD[p,be]+FVD[p,al]FVD[k2,be])/FCI[SPD[k2,p]];
transverseIdentity=Contract[FVD[k2,al]axialSum];
If[emissionIdentity=!=0||transverseIdentity=!=0,Print["Collinear numerator identity failed"];Exit[4]];
Put[<|"actual_diagram_denominators"->denominators,"vanishing_denominator_diagrams"->singularDiagrams,
 "domain"->HoldComplete[0<zc<1&&m2>0],
 "regular_axial_gauge_denominators"->FCI[{SPD[p,k2],SPD[p,k3]}]/.lam->0,
 "emission_Dirac_identity_residual"->emissionIdentity,"axial_transversality_residual"->transverseIdentity,
 "singular_amplitudes"->amps[[singularDiagrams]],
 "power_counting"->"Away from zc=0,1 the axial gauge denominators are finite. Only the identified amplitudes contain the (k1+k2)^2 propagator. Their observed-leg emission numerator vanishes at lam=0: P=k1/zc, bar u(k1) slash(k1)=0, and k1 is parallel to the emitted k2. Thus these amplitudes are at most lam^-1. Mixed singular/regular pairs are at most lam^-1 and regular/regular pairs are analytic, so only pairs of singular amplitudes can contribute to lam^-2.",
 "qualification"->"Local collinear power counting; not a soft endpoint or complete finite NLO coefficient."|>,FileNameJoin[{out,"denominators.wl"}]];
Put[<|"source_sha256"->sourceHash,"amplitude_sha256"->IntegerString[FileHash[file,"SHA256"],16,64],
 "photon"->"XX","spin"->"22","scheme"->FCGetDiracGammaScheme[],"tag_weight_unapplied"->1/2,"pairs_requested"->pairs,
 "qualification"->"Local k1 parallel k2 residue with k1 physical. Neither endpoint subtraction nor finite operator matching."|>,FileNameJoin[{out,"inputs.wl"}]];
rows=<||>;
Do[{i,j}=pair;Print["QGG_COLLINEAR_PAIR ",i," ",j];
 value=CheckAbort[TimeConstrained[HSRealTensorPair[amps[[i]],amps[[j]],{phX,phX},{pinY,poutY},{k2,k3},"T",False],1800,$Aborted],$Aborted];
 If[value===$Aborted,Print["COLLINEAR_PAIR_ABORTED"];Exit[4]];
 If[i=!=j,value=Factor[value+ComplexExpand[Conjugate[value]]]];
 poles=Association[Table[ToString[k]->Factor[SeriesCoefficient[value,{lam,0,k}]],{k,-4,-2}]];
 avg=Map[average,poles];key=ToString[i]<>"_"<>ToString[j];AssociateTo[rows,key->avg];
 Put[<|"pair"->{i,j},"unaveraged_laurent"->poles,"averaged_laurent"->avg,"source_sha256"->sourceHash|>,FileNameJoin[{out,key<>".wl"}]],
 {pair,pairs}];
summed=Merge[Values[rows],Factor[Total[#]]&];kernel=Factor[m2 summed["-2"]/(2born)];
literal=2((SUNN^2-1)/(2SUNN))zc/(1-zc);
Put[<|"pairs"->rows,"sum"->summed,"extracted_kernel"->kernel,"Born"->born,
 "kernel_minus_literal"->Factor[kernel-literal],"epsilon_expansion"->Series[kernel/.D->4-2eps,{eps,0,2}],
 "normalization"->"b times unweighted qgg T22_XX divided by 2 times dimensional Born T22_XX; b=lam^2 m2",
 "pairs_requested"->pairs,"scope"->"Selected pairs in one outgoing collinear region; incomplete pair sums are not a full splitting kernel. Identical gluon weight 1/2 pairs with the second region only in full integration"|>,FileNameJoin[{out,"collinear.wl"}]];
Print["COLLINEAR_KERNEL ",InputForm[kernel]];Exit[0];
