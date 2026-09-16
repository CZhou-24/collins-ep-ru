(* Project actual tagged-spin loop templates and reconstruct their scalar targets.
   Saved topology/routing definitions are reused; numerator coefficients are new. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];engine=FileNameJoin[{root,"collins_sidis_highpt"}];
input=Environment["SIDIS_TEMPLATE_INPUT"];out=Environment["SIDIS_MAP_OUT"];
If[!StringQ[input]||!FileExistsQ[input]||!StringQ[out]||DirectoryQ[out],Print["Need templates and unused output"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
rt=Import[FileNameJoin[{root,"collins_ep_analytic_SIDIS","ru_runtime.json"}],"RawJSON"];
Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};Global`$FeynCalcStartupMessages=False;
Global`$FeynCalcDirectory=rt["feyncalc_root"];FeynCalc`$FeynArtsDirectory=rt["feynarts_root"];
Get[FileNameJoin[{rt["feyncalc_root"],"FeynCalc.m"}]];
Get[FileNameJoin[{engine,"common","spin_core.wl"}]];
Get[FileNameJoin[{engine,"common","spin_nlo.wl"}]];
Get[FileNameJoin[{engine,"common","spin_virtual.wl"}]];
Get[FileNameJoin[{engine,"common","spin_tensor_template.wl"}]];
record=Get[input];loopGeometry=HSVirtualKinematics[];
topfile=FileNameJoin[{root,"SIDIS","Hqq","s05_result","s05_result.wl"}];topbank=Get[topfile];
canonicalFile=FileNameJoin[{root,"SIDIS","common","s09_result","s09_result.wl"}];canonicalBank=Get[canonicalFile];
families=canonicalBank["Families"];changes=canonicalBank["Canonicalization"];
ph=<|"L"->phL,"X"->phX,"Y"->phY,"W"->q|>;spins=<|"11"->{pinX,poutX},"22"->{pinY,poutY}|>;
components={"11_LL","11_XX","11_YY","22_LL","22_XX","22_YY","11_WL","11_WX","11_WY","22_WL","22_WX","22_WY"};
requested=Environment["SIDIS_VIRTUAL_COMPONENTS"];If[StringQ[requested]&&StringLength[requested]>0,components=StringSplit[requested,","]];
rows=<||>;targets={};
Do[i=ToExpression[diagram];candidate=Select[topbank["DiagramMaps"],#["Diagram"]===i&&#["Mode"]==="Pg"&];
 If[Length[candidate]=!=1,Print["Missing actual diagram topology"];Exit[2]];topology=First[candidate]["Topology"];
 Do[Print["VIRTUAL_TEMPLATE_MAP ",component," ",i];spin=StringTake[component,2];photonKeys=Characters[StringTake[component,-2]];
  value=HSProjectVirtualTemplate[record["diagrams"][diagram],record["geometry"],loopGeometry,Lookup[ph,photonKeys],spins[spin]];
  If[MissingQ[topology]&&value=!=0,Put[value,FileNameJoin[{out,component<>"_"<>diagram<>"_unmapped.wl"}]];Print["New topology required for previously zero diagram"];Exit[3]];
  mapped=CheckAbort[HSVirtualMap[value,topology],$Aborted];If[mapped===$Aborted,Exit[4]];
  cc=Merge[KeyValueMap[Function[{integral,c},With[{change=changes[integral[[1]]]},
   Association[GLI[change["Family"],integral[[2,change["Permutation"]]]]->c]]],mapped["coefficients"]],HSOnShell[Total[#]]&];
  cc=Select[cc,#=!=0&];targets=Union[targets,Keys[cc]];
  row=Join[mapped,<|"canonical_coefficients"->cc,"component"->component,"diagram"->i,"value"->value|>];
  AssociateTo[rows,component<>"_"<>diagram->row];Put[row,FileNameJoin[{out,component<>"_"<>diagram<>".wl"}]],{component,components}],{diagram,Keys[record["diagrams"]]}];
inputHashes=AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,{input,topfile,canonicalFile}];
Put[<|"rows"->rows,"targets"->targets,"input_sha256"->inputHashes,
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "routing_definition"->"Original FCTopology denominators reconstructed before applying preserved unit-Jacobian loop translations/orientations and index permutations",
 "normalization"->"Before loop measure, Hermitian conjugation, UV renormalization, and factorization",
 "qualification"->"New polarized target maps, no master evaluation or finite coefficient asserted"|>,FileNameJoin[{out,"mapping.wl"}]];
external={p,q,k1};gram={{0,(s+Q2)/2,(Q2+s+t)/2},{(s+Q2)/2,-Q2,-(Q2+t)/2},{(Q2+s+t)/2,-(Q2+t)/2,0}};
text[x_]:=StringReplace[ToString[x,InputForm],Whitespace->""];names=Sort[DeleteDuplicates[targets[[All,1]]]];
Export[FileNameJoin[{out,"kira-input.json"}],<|"scope"->"New Hqq polarized virtual tensor targets; no finite NLO acceptance",
 "targets"->(<|"family"->#[[1]],"powers"->#[[2]]|>&/@targets),"external"->(text/@external),"invariants"->{"q2","s","t"},
 "scalarproducts"->Flatten[Table[{text[external[[i]]],text[external[[j]]],text[gram[[i,j]]/.Q2->q2]},{i,3},{j,i,3}],1],
 "families"->Table[<|"id"->name,"loop_momenta"->(text/@families[name]["LoopMomenta"]),
 "propagators"->MapThread[{text[#1],text[#2]}&,{families[name]["PropagatorMomenta"],families[name]["PropagatorMassesSquared"]}],
 "cut_positions"->{}|>,{name,names}]|>,"RawJSON"];
Print["VIRTUAL_MAP_COMPLETE ",Length[targets]," targets"];Exit[0];
