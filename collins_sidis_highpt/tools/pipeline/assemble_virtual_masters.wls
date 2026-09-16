(* New polarized coefficients times definition-matched archived virtual masters.
   UV bookkeeping is checked independently of the unpolarized tensor residues.
   Remaining IR poles are retained; this is not a finite hard coefficient. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
input=Environment["SIDIS_VIRTUAL_REDUCTION"];bornfile=Environment["SIDIS_BORN_INPUT"];out=Environment["SIDIS_VIRTUAL_ASSEMBLY_OUT"];uvproofFile=Environment["SIDIS_VIRTUAL_UV_INPUT"];
If[!And@@(StringQ/@{input,bornfile,out,uvproofFile})||!FileExistsQ[uvproofFile]||DirectoryQ[out],Print["Need reduction, dimensional Born, large-loop UV proof and unused output"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["VIRTUAL_ASSEMBLY_FAILED ",name];Exit[2]];
branchHelper=FileNameJoin[{root,"collins_sidis_highpt","common","physical_polylogs.wl"}];Get[branchHelper];
path[stage_]:=FileNameJoin[{root,"SIDIS","common",stage<>"_result",stage<>"_result.wl"}];
normalizeContext[x_Association]:=Association[KeyValueMap[(normalizeContext[#1]->normalizeContext[#2])&,x]];
normalizeContext[x_List]:=normalizeContext/@x;
normalizeContext[x_]:=x/.FeynCalc`GLI->Global`GLI;
fresh=normalizeContext[Get[input]];born=Get[bornfile];parents=normalizeContext[Get[path["s12"]]];
oldReduction=normalizeContext[Get[path["s09"]]];uv=Get[path["s14"]];uvproof=Get[uvproofFile];
gate["large-loop UV residue checks",And@@(#["UV_cancellation_residual"]===0&/@Values[uvproof["components"]])];
topfile=FileNameJoin[{root,"SIDIS","Hqq","s05_result","s05_result.wl"}];topbank=Get[topfile];
masterFiles=Sort[FileNames["s19_masters.wl",FileNameJoin[{root,"SIDIS","common","s19_result","s19_virtual"}],Infinity]];
gate["archived physical master bank exists",Length[masterFiles]>0];
masterBanks=normalizeContext[Get[#]]&/@masterFiles;masterValues=First[masterBanks]["Masters"];
masters=fresh["fresh_final_masters"];
Put[<|"needed"->masters,"available"->Keys[masterValues],"missing"->Complement[masters,Keys[masterValues]]|>,FileNameJoin[{out,"master-inventory.wl"}]];
gate["all actual masters have archived values",Complement[masters,Keys[masterValues]]==={}];
bankResiduals=Table[AssociationMap[Function[master,Normal[masterValues[master]-bank["Masters"][master]]],masters],{bank,Rest[masterBanks]}];
gate["all archived physical master copies agree",And@@(#===0&/@Flatten[Values/@bankResiduals])];
physical=Q2>0&&s>0&&t<0&&Q2+s+t>0&&mu>0&&SUNN>1&&Element[Nf,Reals];
invariantMap={r->s/Q2,z->(Q2+s+t)/(Q2+s),Q->Sqrt[Q2],CF->(SUNN^2-1)/(2SUNN)};
convert[x_]:=Factor[PowerExpand[x/.invariantMap]];
coefficients=Map[Map[convert,#]&,Select[fresh["master_coefficients"],True&]];
coefficients=KeySelect[coefficients,!StringContainsQ[#,"_W"]&];
valuation[x_]:=If[x===0,Infinity,With[{v=Together[x/.D->4-2eps]},Exponent[Numerator[v],eps,Min]-Exponent[Denominator[v],eps,Min]]];
measure=topbank["Measure"]/.Epsilon->eps;
gate["loop measure convention",measure===mu^(2eps)(2Pi)^(-4+2eps)];
external={p,q,k1};gram={{0,(s+Q2)/2,(Q2+s+t)/2},{(s+Q2)/2,-Q2,-(Q2+t)/2},{(Q2+s+t)/2,-(Q2+t)/2,0}};
coords[x_]:=Coefficient[Expand[x],#]&/@external;
metadata=<||>;
Do[data=parents["VirtualMasterParents"][master];family=oldReduction["Families"][master[[1]]];
 shifts=family["PropagatorMomenta"]-ell;active=Flatten[Position[master[[2]],1]];
 chords=Table[Factor[coords[shifts[[i]]-shifts[[j]]].gram.coords[shifts[[i]]-shifts[[j]]]],{i,active},{j,active}];
 chordResiduals=Map[Factor,chords-data["OriginalChordMatrix"],{2}];
 gate["master propagator chord matrix matches parent",And@@(#===0&/@Flatten[chordResiduals])];
 raw=masterValues[master];gate["archived master has series remainder",MatchQ[raw,_SeriesData]&&raw[[1]]===eps];
 nonzero=DeleteCases[Lookup[Values[coefficients],master],0];minimum=Min[valuation/@nonzero];required=Max[0,-minimum];available=raw[[5]]-1;
 AssociateTo[metadata,master-><|"required_through"->required,"available_through"->available,
 "coefficient_minimum"->minimum,"chord_residuals"->chordResiduals,"parent"->data,
 "measure"->measure,"evaluation"->"ARCHIVED PHYSICAL MASTER REUSE"|>];
 Put[metadata,FileNameJoin[{out,"master-depth.wl"}]];
 gate["master depth covers actual coefficient valuation",available>=required],{master,masters}];
reduce[value_]:=Module[{refined,functions},refined=Refine[value,physical];
 functions=DeleteDuplicates[Cases[refined,_Log|_PolyLog|_Re|_Im,Infinity]];Collect[Expand[refined],functions,Factor]];
bare=<||>;pre=<||>;renormalized=<||>;uvChecks=<||>;laurent=<||>;
fieldCounts=uv["FieldBookkeeping"]["Hqq"]["FieldCounts"];
fieldUV=Total[KeyValueMap[Function[{field,count},count uv["FieldUVResidues"][field]],fieldCounts]];
couplingUV=uv["FieldBookkeeping"]["Hqq"]["CouplingWeight"]uv["CouplingResidue"];
Do[Print["ASSEMBLE_VIRTUAL ",component];
 terms=KeyValueMap[Function[{master,c},value=Series[measure(c/.D->4-2eps)masterValues[master],{eps,0,0}];
  gate["product retains finite depth",value===0||(MatchQ[value,_SeriesData]&&value[[5]]>0)];Normal[value]],coefficients[component]];
 interference=reduce[Total[terms]];AssociateTo[pre,component->interference];
 branchRecord=HSPhysicalHermitian[interference,physical];
 Put[branchRecord,FileNameJoin[{out,component<>"_branch-conversion.wl"}]];
 hermitian=reduce[branchRecord["value"]];
 Put[<|"pre_Hermitian"->interference,"Hermitian"->hermitian,"unresolved_atoms"->DeleteDuplicates[Cases[hermitian,_Re|_Im|_Conjugate|_GLI|_Real|_Limit|Indeterminate|ComplexInfinity,Infinity]]|>,FileNameJoin[{out,component<>"_continuation.wl"}]];
 gate["continued interference fully resolved",FreeQ[hermitian,_Re|_Im|_Conjugate|_GLI|_Real|_Limit|Indeterminate|ComplexInfinity]];
 dimensionalBorn=convert[born["T"<>component]]/.D->4-2eps;
 (* UV and IR are entangled by massless IBP/scaleless identities. Use the
    separately checked large-loop residue of the original integrands. *)
 loopUV=convert[uvproof["components"][component]["loop_UV"]];
 uvResidual=Factor[loopUV+(fieldUV+couplingUV)(dimensionalBorn/.eps->0)];
 AssociateTo[uvChecks,component-><|"loop_UV"->loopUV,"field_UV"->fieldUV,
 "coupling_UV"->couplingUV,"dimensional_Born"->dimensionalBorn,"residual"->uvResidual|>];
 Put[uvChecks,FileNameJoin[{out,"uv-checks.wl"}]];
 gate["polarized UV residue plus fields and coupling cancels",uvResidual===0];
 ren=reduce[Normal[Series[hermitian+couplingUV uv["MSPole"]dimensionalBorn,{eps,0,0}]]];
 rows=Association[Table[ToString[power]->reduce[Coefficient[Expand[ren],eps,power]],{power,-2,0}]];
 AssociateTo[bare,component->hermitian];AssociateTo[renormalized,component->ren];AssociateTo[laurent,component->rows];
 Put[<|"component"->component,"pre_Hermitian"->interference,"bare_Hermitian"->hermitian,
 "UV_renormalized"->ren,"Laurent"->rows,"UV_check"->uvChecks[component]|>,FileNameJoin[{out,component<>".wl"}]],{component,Keys[coefficients]}];
files=Join[{input,bornfile,uvproofFile,branchHelper,path["s09"],path["s12"],path["s14"],topfile},masterFiles];
Put[<|"master_metadata"->metadata,"coefficients"->coefficients,"master_values"->KeyTake[masterValues,masters],
 "master_banks_equal_residuals"->bankResiduals,"UV_checks"->uvChecks,"renormalized_virtual"->renormalized,"Laurent"->laurent,
 "measure"->measure,"physical_conditions"->physical,"field_counts"->fieldCounts,
 "couplings_removed"->topbank["CouplingsRemoved"],"input_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,files],
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "qualification"->"New polarized UV-renormalized virtual tensor using archived masters; IR poles retained, no factorization or finite observable acceptance"|>,FileNameJoin[{out,"virtual.wl"}]];
Print["POLARIZED_VIRTUAL_ASSEMBLED ",Length[coefficients]," components"];Exit[0];
