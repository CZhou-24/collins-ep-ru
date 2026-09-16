(* Actual full qgg tensor in an initial-state collinear family. The axial
   reference p becomes singular in this limit, so ALL 36 diagram pairs are
   retained and stronger poles are tested only after summing them. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
engine=FileNameJoin[{root,"collins_sidis_highpt"}];
templateDir=Environment["SIDIS_QGG_TEMPLATES"];bornDir=Environment["SIDIS_BORN_DIRECTORY"];out=Environment["SIDIS_COLLINEAR_OUT"];
If[!And@@(StringQ/@{templateDir,bornDir,out})||DirectoryQ[out],Print["Need templates, Born directory and unused output"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["INITIAL_COLLINEAR_FAILED ",name];Exit[2]];
SetAttributes[bounded,HoldFirst];
bounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,600,gate[label<>" time bound",False]],1024^3,gate[label<>" memory bound",False]];
helpers=FileNameJoin[{engine,"common",#}]&/@{"spin_core.wl","rational_laurent.wl","open_tensor_polynomial.wl"};Scan[Get,helpers];
$HSConstraint=h^2-r z(1-z);
bornfile=FileNameJoin[{bornDir,"born_tensor_dimensional.wl"}];deffile=FileNameJoin[{bornDir,"definitions.wl"}];
born=Get[bornfile];v=Get[deffile]["vectors"];
parent=v[p];recoil=v[k2];pr=HSOnShell[HSDot[parent,recoil]];
basis1={-h/(1-z),1,0,-h/(1-z)};basis2={0,0,1,0};
alpha=xc lam^2 m2/(2pr);beta0=(1-xc)/xc;kt=lam(aa basis1+bb basis2);
emitted=beta0(1-alpha)parent+alpha recoil+kt;
remaining=(1-alpha)recoil+beta0 alpha parent-kt;
vectors=Join[KeyDrop[v,{p,k2}],<|p->parent/xc,k2->emitted,k3->remaining|>];
hat=HSOnShell[-HSDot[emitted,emitted]];
geometryChecks=<|"basis1_norm"->HSOnShell[HSDot[basis1,basis1]+1],
 "basis1_parent"->HSOnShell[HSDot[basis1,parent]],"basis1_recoil"->HSOnShell[HSDot[basis1,recoil]],
 "basis2_norm"->HSDot[basis2,basis2]+1,"basis12"->HSOnShell[HSDot[basis1,basis2]],
 "momentum"->(HSOnShell/@(vectors[p]+v[q]-v[k1]-emitted-remaining)),
 "cut2"->HSOnShell[HSDot[emitted,emitted]+hat],
 "cut3"->HSOnShell[HSDot[remaining,remaining]+hat],
 "incoming_virtuality"->HSOnShell[2HSDot[vectors[p],emitted]-lam^2 m2],
 "tagged_mass"->HSOnShell[HSDot[v[k1],v[k1]]]|>;
gate["exact initial-collinear geometry",And@@(#===0&/@Flatten[Values[geometryChecks]])];
radius=(1-xc)m2;
average[x_]:=Module[{value=Together[x],num,den},num=Numerator[value];den=Denominator[value];
 gate["polynomial transverse angular numerator",FreeQ[den,aa|bb]&&PolynomialQ[num,{aa,bb}]];
 HSOnShell[Total[KeyValueMap[Function[{powers,c},If[AnyTrue[powers,OddQ],0,
  c radius^(Total[powers]/2)Times@@(Pochhammer[1/2,#/2]&/@powers)/Pochhammer[(D-2)/2,Total[powers]/2]]],Association[CoefficientRules[num,{aa,bb}]]]]/den]];
invariants={Q2->Q^2,s->HSOnShell[HSDot[vectors[p]+v[q],vectors[p]+v[q]]],
 t->HSOnShell[-Q^2-2HSDot[v[q],v[k1]]],
 w->HSOnShell[HSDot[vectors[p]+v[q]-v[k1],vectors[p]+v[q]-v[k1]]],
 a->-lam^2 m2,b->HSOnShell[2HSDot[v[k1],emitted]],hsHat->hat};
Put[<|"vectors"->vectors,"transverse_basis"->{basis1,basis2},"hat2"->hat,"checks"->geometryChecks,
 "invariants"->invariants,"angular_radius_leading"->radius,"angular_dimension"->D-2,
 "conditions"->HoldComplete[Q>0&&r>0&&0<z<1&&0<xc<1&&m2>0&&h>0&&h^2==r z(1-z)],
 "measure"->"Normalized D-2 transverse sphere; local virtuality residue before radial phase-space integration",
 "incoming_fraction"->HoldComplete[pBorn==xc pReal],
 "normalization"->"Incoming density slash(pReal)=slash(pBorn)/xc. Compare residue to 2 Born K/(xc m2). Couplings eq^2 gs^4 and species weight remain stripped.",
 "gauge_qualification"->"All 36 pairs retained because axial reference p is collinear to k2; no individual-graph gauge artifact is discarded."|>,FileNameJoin[{out,"geometry.wl"}]];
pairs=Flatten[Table[ToString[i]<>"_"<>ToString[j],{i,8},{j,i,8}]];
components={"11_LL","11_XX","11_YY","22_LL","22_XX","22_YY"};
requested=Environment["SIDIS_COLLINEAR_COMPONENTS"];If[StringQ[requested]&&StringLength[requested]>0,components=StringSplit[requested,","]];
ph=<|"L"->phL,"X"->phX,"Y"->phY|>;spin=<|"11"->{pinX,poutX},"22"->{pinY,poutY}|>;
rows=<||>;checks=<||>;sourcefiles=Join[{bornfile,deffile,$InputFileName},helpers];
Do[file=FileNameJoin[{templateDir,pair<>".wl"}];record=Get[file];AppendTo[sourcefiles,file];
 Do[Print["INITIAL_COLLINEAR ",component," pair ",pair];
  photon=Lookup[ph,Characters[StringTake[component,-2]]];spinPair=spin[StringTake[component,2]];
  replacement={hsIn->spinPair[[1]],hsOut->spinPair[[2]],hsA->photon[[1]],hsB->photon[[2]]};
  dotRules=(#[[1]]->HSOnShell[HSDot[vectors[#[[2]]/.replacement],vectors[#[[3]]/.replacement]]])&/@record["geometry"]["projector_dot_rows"];
  value=record["value"]/.Join[dotRules,invariants];
  expansion=bounded[HSRationalLaurent[value,lam,-2],component<>" "<>pair<>" Laurent quotient"];
  gate["initial-collinear Laurent bound",expansion["valuation"]>=-8];
  poles=Association[Table[ToString[power]->HSOnShell[Lookup[expansion["coefficients"],power,0]],{power,-8,-2}]];
  ij=ToExpression/@StringSplit[pair,"_"];
  If[ij[[1]]=!=ij[[2]],poles=Map[HSOnShell[#+HSRealRationalConjugate[#]]&,poles]];
  averaged=Map[average,poles];AssociateTo[rows,component<>"_"<>pair->averaged];
  Put[<|"component"->component,"pair"->pair,"unaveraged"->poles,"averaged"->averaged,
   "quotient_checks"->KeyDrop[expansion,"coefficients"]|>,FileNameJoin[{out,component<>"_"<>pair<>".wl"}]];
  Clear[value,expansion,poles,averaged];ClearSystemCache[],{component,components}],{pair,pairs}];
cf=(SUNN^2-1)/(2SUNN);literal=2cf xc/(1-xc);operatorKernel=literal+cf(D-4)^2(1-xc)/(2(D-2));
Do[summed=Map[HSOnShell,Merge[rows[component<>"_"<>#]&/@pairs,Total]];
 residue=summed["-2"];dimensionalBorn=born["T"<>component]/.CF->cf;
 residual=HSOnShell[xc m2 residue-2dimensionalBorn operatorKernel];
 AssociateTo[checks,component-><|"summed_poles"->summed,"residue"->residue,
  "dimensional_Born"->dimensionalBorn,"operator_match_residual"->residual,
  "literal_kernel_difference"->Factor[operatorKernel-literal]|>],{component,components}];
Put[<|"checks"->checks,"operator_kernel"->operatorKernel,"literal_reference_real_kernel"->literal,
 "input_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,DeleteDuplicates[sourcefiles]],
 "qualification"->"Full actual qgg local initial-collinear family. No outgoing finite conversion or complete NLO observable is inferred."|>,FileNameJoin[{out,"comparison.wl"}]];
gate["all stronger gauge-dependent initial-collinear poles cancel",And@@Flatten[(#===0&/@Values[KeyDrop[#["summed_poles"],"-2"]])&/@Values[checks]]];
gate["actual initial-collinear residue matches independent operator",And@@(#["operator_match_residual"]===0&/@Values[checks])];
Print["INITIAL_COLLINEAR_COMPLETE ",Length[checks]," components, all 36 pairs"];Exit[0];
