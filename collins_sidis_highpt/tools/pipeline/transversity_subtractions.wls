(* Distributional MSbar collinear convolutions of the dimensional tagged Born
   tensor. Kernel imported from pinned 2311.00672v2 Eq.(32); the finite scheme
   match to the production prescription is explicitly not set to zero here. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
bornfile=Environment["SIDIS_BORN_INPUT"];out=Environment["SIDIS_SUBTRACTION_OUT"];
If[!StringQ[bornfile]||!StringQ[out]||DirectoryQ[out],Print["Need dimensional Born and unused output"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["TRANSVERSITY_SUBTRACTION_FAILED ",name];Exit[2]];
born=Get[bornfile];cf=(SUNN^2-1)/(2SUNN);
referenceFile=FileNameJoin[{root,"collins_sidis_highpt","references","jet_snippets.json"}];references=Import[referenceFile,"RawJSON"];
literal=references["snippets"]["transversity_kernel_32"];
kernel=cf(2x kernelPlus[1/(1-x)]+3kernelDelta[1-x]/2);
canonical=<|"Delta"->3cf/2,"Plus0"->2cf,"Regular"->-2cf|>;
moments=Table[original=cf(2Integrate[(x^(n+1)-1)/(1-x),{x,0,1}]+3/2);
 converted=canonical["Plus0"]Integrate[(x^n-1)/(1-x),{x,0,1}]+canonical["Regular"]/(n+1)+canonical["Delta"];
 <|"monomial"->x^n,"literal_action"->original,"canonical_action"->converted,"residual"->Factor[original-converted]|>,{n,0,3}];
gate["distribution conversion of literal transversity kernel",And@@(#["residual"]===0&/@moments)];
physical=Q2>0&&s>w>0&&w-Q2-s<t<-Q2 w/s&&B>0;
endpoint=Q2>0&&s>0&&-Q2-s<t<0&&B>0;
scaledS=-Q2+eta(s+Q2);scaledT=-Q2+(t+Q2)/zeta;
recoil=-Q2+eta(s+Q2)+(t+Q2)/zeta-eta(Q2+s+t-w)/zeta;
incoming=Factor[eta/.First[Solve[(recoil/.zeta->1)==0,eta]]];
outgoing=Factor[zeta/.First[Solve[(recoil/.eta->1)==0,zeta]]];
jacIn=FullSimplify[1/Abs[D[recoil,eta]/.{eta->incoming,zeta->1}],physical];
jacOut=FullSimplify[1/Abs[D[recoil,zeta]/.{eta->1,zeta->outgoing}],physical];
gate["both physical collinear roots in unit interval",FullSimplify[0<incoming<1&&0<outgoing<1,physical]];
invariantBorn=Association[Table[component->Factor[PowerExpand[born["T"<>component]/.
 {r->s/Q2,z->(Q2+s+t)/(Q2+s),Q->Sqrt[Q2],CF->cf}]],{component,{"11_LL","11_XX","11_YY","22_LL","22_XX","22_YY"}}]];
convolutions=<||>;counterterms=<||>;
Do[tensor=invariantBorn[component];mapped=tensor/.{s->scaledS,t->scaledT};sides=<||>;counterSides=<||>;
 Do[rootValue=If[side==="PDF",incoming,outgoing];
  weight=If[side==="PDF",Factor[(jacIn/incoming)(mapped/.{eta->incoming,zeta->1})],
   Factor[(jacOut/outgoing^(2-2 eps))(mapped/.{eta->1,zeta->outgoing})]];
  pole=Factor[weight/(1-rootValue)];endpointBorn=FullSimplify[Limit[w pole,w->0,Direction->"FromAbove"],endpoint];
  ratio=FullSimplify[Limit[(1-rootValue)/w,w->0,Direction->"FromAbove"],endpoint];
  gate["mapped endpoint equals dimensional Born",Factor[endpointBorn-tensor]===0];
  gate["positive endpoint rescaling",FullSimplify[ratio>0,endpoint]];
  delta=canonical["Delta"]tensor+canonical["Plus0"]tensor Log[B ratio];
  plus=canonical["Plus0"]tensor;
  regular=Factor[canonical["Regular"]weight+canonical["Plus0"](pole-tensor/w)];
  reconstruction=Factor[regular+plus/w-weight(2cf rootValue/(1-rootValue))];
  gate["ordinary convolution reconstructs literal kernel",reconstruction===0];
  row=<|"Delta"->delta,"L0"->plus,"Regular"->regular,"root"->rootValue,"weight"->weight,
   "endpoint_scale"->ratio,"ordinary_reconstruction_residual"->reconstruction|>;
  AssociateTo[sides,side->row];
  scale=If[side==="PDF",muPDF,muFF];
  (* gs^2 [alpha_s/(2 Pi)] 2 Pi / gs^4 = 1/(4 Pi).
     Dimensional Born is kept through the finite pole product. *)
  cterms=Map[Normal[Series[((muR^2/scale^2)^eps/(4Pi))(1/eps-EulerGamma+Log[4Pi])(#/.D->4-2eps),{eps,0,0}]]&,KeyTake[row,{"Delta","L0","Regular"}]];
  AssociateTo[counterSides,side->cterms],{side,{"PDF","FF"}}];
 AssociateTo[convolutions,component->sides];AssociateTo[counterterms,component->counterSides],{component,Keys[invariantBorn]}];
Put[<|"dimensional_convolutions"->convolutions,"MS_counterterms"->counterterms,"kernel"->kernel,"kernel_canonical"->canonical,
 "kernel_test_actions"->moments,"literal_reference_snippet"->literal,
 "scaled_invariants"-><|"s"->scaledS,"t"->scaledT,"recoil"->recoil|>,"roots"->{incoming,outgoing},"jacobians"->{jacIn,jacOut},
 "convolution_measures"-><|"PDF"->HoldComplete[deta/eta],"FF"->HoldComplete[dzeta/zeta^(2-2 eps)]|>,
 "measure_basis"->"Incoming collinear PDF convolution and invariant observed-particle fragmentation convolution; physical photon basis and spin directions do not rescale",
 "coupling_normalization"->HoldComplete[gs^2(alphaS/(2Pi))2Pi/gs^4/.alphaS->gs^2/(4Pi)],
 "finite_scheme_terms_unfixed"-><|"PDF"->HoldComplete[Convolution[DeltaC_PDF,BornD]],"FF"->HoldComplete[Convolution[BornD,DeltaC_FF]]|>,
 "scales"->{muR,muPDF,muFF},"input_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,{bornfile,referenceFile}],
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "qualification"->"Explicit MSbar subtraction in the literal kernel convention. Production collinear match and any finite conversion must be resolved before final coefficient acceptance."|>,FileNameJoin[{out,"subtractions.wl"}]];
Print["TRANSVERSITY_MS_CONVOLUTIONS_COMPLETE ",Length[counterterms]," components, both sides"];Exit[0];
