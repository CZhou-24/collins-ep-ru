(* Fresh operator zeros from actual tagged saved amplitudes, before any photon
   projection. Virtual entries are Born-loop interferences, not loop squares. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
engine=FileNameJoin[{root,"collins_sidis_highpt"}];base=FileNameJoin[{root,"collins_support","reports","sidis-highpt-001"}];If[StringQ[Environment["SIDIS_HIGHPT_REPORT_ROOT"]],base=Environment["SIDIS_HIGHPT_REPORT_ROOT"]];out=FileNameJoin[{base,"channel-zero-002"}];
If[DirectoryQ[out],Print["Refuse output reuse"];Exit[1]];CreateDirectory[out];
rt=Import[FileNameJoin[{root,"collins_ep_analytic_SIDIS","ru_runtime.json"}],"RawJSON"];
Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};Global`$FeynCalcStartupMessages=False;
Global`$FeynCalcDirectory=rt["feyncalc_root"];FeynCalc`$FeynArtsDirectory=rt["feynarts_root"];
Get[FileNameJoin[{rt["feyncalc_root"],"FeynCalc.m"}]];
FeynCalc`FCSetDiracGammaScheme["BMHV"];
Get[FileNameJoin[{engine,"common","spin_core.wl"}]];
files=<|"Hqg"->FileNameJoin[{root,"SIDIS","Hqg","s01_result","s01_inputs","s04_result.wl"}],
 "Hqqprime"->FileNameJoin[{root,"SIDIS","Hqqprime","s01_result","s01_inputs","s01_result","real.wl"}]|>;
bank=Get[files["Hqg"]];groups=<|"Hqg_Born"->{bank["Born"],bank["Born"]},"Hqg_Real"->{bank["Real"],bank["Real"]},"Hqg_VirtualInterference"->{bank["Virtual"],bank["Born"]}|>;
prime=Get[files["Hqqprime"]];If[AssociationQ[prime],prime=prime["amplitudes"]];
AssociateTo[groups,"Hqqprime_Real"->{prime,prime}];rows=<||>;
KeyValueMap[Function[{key,amplitudes},Print["OPERATOR_ZERO ",key];
 values=Table[Factor[DiracSimplify[HSTaggedSpinSum[amplitudes[[1,i]],amplitudes[[2,j]],"T",pinX,poutX],DiracTraceEvaluate->True]],
 {i,Length[amplitudes[[1]]]},{j,Length[amplitudes[[2]]]}];
 AssociateTo[rows,key->values];Put[rows,FileNameJoin[{out,"quark_traces.wl"}]];
 If[!And@@(#===0&/@Flatten[values]),Print["NONZERO_OR_UNRESOLVED_OPERATOR_TRACE ",key];Exit[2]]],groups];
(* Helicity-two collinear gluon operator between spin-half proton states. *)
jz=DiagonalMatrix[{1/2,-1/2}];op={{g11,g12},{g21,g22}};
constraint=jz.op-op.jz-2op;solution=Solve[Thread[Flatten[constraint]==0],Flatten[op]];
residual=Simplify[op/.First[solution]];
Put[<|"commutator_equation"->constraint,"solution"->solution,"operator_residual"->residual,
 "applies_to"->{"Hgq","Hgg"},"assumption"->"Forward twist-two collinear distribution in a spin-half proton; a gluon helicity flip has |Delta Jz|=2."|>,FileNameJoin[{out,"gluon_operator.wl"}]];
Put[<|"source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "inputs_sha256"->Map[IntegerString[FileHash[#,"SHA256"],16,64]&,files],
 "spin_helper_sha256"->IntegerString[FileHash[FileNameJoin[{engine,"common","spin_core.wl"}],"SHA256"],16,64],
 "quark_pair_counts"->Map[Length[Flatten[#]]&,rows],"all_quark_residuals"->Flatten[Values[rows]]|>,FileNameJoin[{out,"identity.wl"}]];
Print["CHANNEL_OPERATOR_ZEROS ",InputForm[Map[Length[Flatten[#]]&,rows]]," GLUON ",InputForm[residual]];Exit[0];
