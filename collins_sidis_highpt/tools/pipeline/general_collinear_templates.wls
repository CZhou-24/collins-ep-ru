(* Project the singular pairs of the actual qgg tensor onto a continuous
   outgoing collinear family at arbitrary Born Q,r,z. The tagged daughter stays
   physical; D-dimensional transverse recoil belongs to the unobserved pair. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
engine=FileNameJoin[{root,"collins_sidis_highpt"}];
templateDir=Environment["SIDIS_QGG_TEMPLATES"];bornDir=Environment["SIDIS_BORN_DIRECTORY"];out=Environment["SIDIS_COLLINEAR_OUT"];
If[!And@@(StringQ/@{templateDir,bornDir,out})||DirectoryQ[out],Print["Need templates, Born directory and unused output"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
Get[FileNameJoin[{engine,"common","spin_core.wl"}]];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["GENERAL_COLLINEAR_FAILED ",name];Exit[2]];
laurentHelper=FileNameJoin[{engine,"common","rational_laurent.wl"}];Get[laurentHelper];
$HSConstraint=h^2-r z(1-z);
bornfile=FileNameJoin[{bornDir,"born_tensor_dimensional.wl"}];deffile=FileNameJoin[{bornDir,"definitions.wl"}];
born=Get[bornfile];bornGeometry=Get[deffile];v=bornGeometry["vectors"];
parent=v[k1];recoil=v[k2];kr=HSOnShell[HSDot[parent,recoil]];
transverseP=v[p]-HSDot[v[p],recoil]/kr parent-HSDot[v[p],parent]/kr recoil;
basis1=HSOnShell/@(r transverseP/(Q(1+r)h));basis2={0,0,1,0};
alpha=lam^2 m2/(zc Q^2 r);kt=lam(aa basis1+bb basis2);
daughter=zc parent;unobserved=(1-zc)(1-alpha)parent+alpha recoil+kt;
remaining=(1-alpha)recoil+alpha(1-zc)parent-kt;
vectors=Join[KeyDrop[v,{k1,k2}],<|k1->daughter,k2->unobserved,k3->remaining|>];
hat=HSOnShell[-HSDot[unobserved,unobserved]];
geometryChecks=<|"basis1_norm"->HSOnShell[HSDot[basis1,basis1]+1],
 "basis1_parent"->HSOnShell[HSDot[basis1,parent]],"basis1_recoil"->HSOnShell[HSDot[basis1,recoil]],
 "basis2_norm"->HSDot[basis2,basis2]+1,"basis12"->HSOnShell[HSDot[basis1,basis2]],
 "momentum"->(HSOnShell/@(v[p]+v[q]-daughter-unobserved-remaining)),
 "cut2"->HSOnShell[HSDot[unobserved,unobserved]+hat],
 "cut3"->HSOnShell[HSDot[remaining,remaining]+hat],
 "collinear_invariant"->HSOnShell[2HSDot[daughter,unobserved]-lam^2 m2],
 "tagged_mass"->HSOnShell[HSDot[daughter,daughter]]|>;
gate["exact physical-tagged collinear geometry",And@@(#===0&/@Flatten[Values[geometryChecks]])];
radius=(1-zc)m2/zc;
average[x_]:=Module[{value=Together[x],num,den},num=Numerator[value];den=Denominator[value];
 gate["polynomial transverse angular numerator",FreeQ[den,aa|bb]&&PolynomialQ[num,{aa,bb}]];
 HSOnShell[Total[KeyValueMap[Function[{powers,c},If[AnyTrue[powers,OddQ],0,
  c radius^(Total[powers]/2) Times@@(Pochhammer[1/2,#/2]&/@powers)/Pochhammer[(D-2)/2,Total[powers]/2]]],Association[CoefficientRules[num,{aa,bb}]]]]/den]];
invariants={Q2->Q^2,s->Q^2 r,t->HSOnShell[-Q^2-2HSDot[v[q],daughter]],
 w->HSOnShell[HSDot[v[p]+v[q]-daughter,v[p]+v[q]-daughter]],
 a->HSOnShell[-2HSDot[v[p],unobserved]],b->lam^2 m2,hsHat->hat};
Put[<|"vectors"->vectors,"transverse_basis"->{basis1,basis2},"hat2"->hat,"checks"->geometryChecks,
 "invariants"->invariants,"angular_radius_leading"->radius,"angular_dimension"->D-2,
 "conditions"->HoldComplete[Q>0&&r>0&&0<z<1&&0<zc<1&&m2>0&&h>0&&h^2==r z(1-z)],
 "measure"->"Normalized full D-2 collinear transverse sphere; local pole residue before phase-space radial integration",
 "power_counting"->"Only qgg diagrams 1 and 8 have the k1+k2 propagator. The massless observed-leg numerator vanishes at exact collinearity, so their amplitudes have at most a simple 1/lam pole. Axial gauge denominators p.k2,p.k3 stay finite in the stated interior."|>,FileNameJoin[{out,"geometry.wl"}]];
pairs={"1_1","1_8","8_8"};components={"11_LL","11_XX","11_YY","22_LL","22_XX","22_YY"};
requested=Environment["SIDIS_COLLINEAR_COMPONENTS"];If[StringQ[requested]&&StringLength[requested]>0,components=StringSplit[requested,","]];
ph=<|"L"->phL,"X"->phX,"Y"->phY|>;spin=<|"11"->{pinX,poutX},"22"->{pinY,poutY}|>;
rows=<||>;checks=<||>;sourcefiles={bornfile,deffile,$InputFileName,laurentHelper};
Do[file=FileNameJoin[{templateDir,pair<>".wl"}];record=Get[file];AppendTo[sourcefiles,file];
 Do[Print["GENERAL_COLLINEAR ",component," pair ",pair];
  photon=Lookup[ph,Characters[StringTake[component,-2]]];spinPair=spin[StringTake[component,2]];
  replacement={hsIn->spinPair[[1]],hsOut->spinPair[[2]],hsA->photon[[1]],hsB->photon[[2]]};
  dotRules=(#[[1]]->HSOnShell[HSDot[vectors[#[[2]]/.replacement],vectors[#[[3]]/.replacement]]])&/@record["geometry"]["projector_dot_rows"];
  value=record["value"]/.Join[dotRules,invariants];
  expansion=HSRationalLaurent[value,lam,-2];
  gate["no pole stronger than fourth power before angular averaging",expansion["valuation"]>=-4];
  poles=Association[Table[ToString[power]->HSOnShell[Lookup[expansion["coefficients"],power,0]],{power,-4,-2}]];
  If[pair=!="1_1"&&pair=!="8_8",poles=Map[HSOnShell[ComplexExpand[#+Conjugate[#]]]&,poles]];
  averaged=Map[average,poles];
  gate["absence of stronger than collinear squared pole",averaged["-4"]===0&&averaged["-3"]===0];
  AssociateTo[rows,component<>"_"<>pair->averaged];
  Put[<|"component"->component,"pair"->pair,"unaveraged"->poles,"averaged"->averaged,"quotient_checks"->KeyDrop[expansion,"coefficients"]|>,FileNameJoin[{out,component<>"_"<>pair<>".wl"}]],{component,components}],{pair,pairs}];
cf=(SUNN^2-1)/(2SUNN);literal=2cf zc/(1-zc);physicalKernel=literal+cf(D-4)^2(1-zc)/(2(D-2));
Do[residue=HSOnShell[Total[rows[component<>"_"<>#]["-2"]&/@pairs]];
 dimensionalBorn=born["T"<>component]/.CF->cf;
 residual=HSOnShell[m2 residue-2dimensionalBorn physicalKernel];
 AssociateTo[checks,component-><|"residue"->residue,"dimensional_Born"->dimensionalBorn,
 "physical_daughter_residual"->residual,"literal_kernel_difference"->Factor[physicalKernel-literal]|>],{component,components}];
Put[<|"checks"->checks,"physical_daughter_kernel"->physicalKernel,"literal_reference_real_kernel"->literal,
 "input_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,DeleteDuplicates[sourcefiles]],
 "qualification"->"General interior kinematics, outgoing local collinear residue; endpoints, initial factorization and complete finite observable remain separate"|>,FileNameJoin[{out,"comparison.wl"}]];
gate["actual qgg residues match the physical-daughter operator",And@@(#["physical_daughter_residual"]===0&/@Values[checks])];
Print["GENERAL_COLLINEAR_COMPLETE ",Length[checks]," components"];Exit[0];
