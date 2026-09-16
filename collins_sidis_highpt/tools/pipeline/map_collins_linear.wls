(* Linearity-first cut map of completed native Collins pair projections.
   Each smaller rational term is reconstructed exactly before coefficients are
   merged. Development projection reuse is explicit; no master values or old
   unpolarized numerator are used in this mapping. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];engine=FileNameJoin[{root,"collins_sidis_highpt"}];
input=Environment["SIDIS_TEMPLATE_INPUT"];pairsDirectory=Environment["SIDIS_PROJECTED_PAIRS"];out=Environment["SIDIS_MAP_OUT"];
If[!StringQ[input]||!FileExistsQ[input]||!StringQ[pairsDirectory]||!DirectoryQ[pairsDirectory]||!StringQ[out]||DirectoryQ[out],Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
helper=FileNameJoin[{engine,"common","real_families.wl"}];Get[helper];
SetAttributes[bounded,HoldFirst];bounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,600,
 Print["LINEAR_MAP_TIMEOUT ",label];Exit[3]],1024*1024^2,Print["LINEAR_MAP_MEMORY ",label];Exit[4]];
record=Get[input];topology=record["topology"];pairKeys=Keys[record["pairs"]];
geometryFile=FileNameJoin[{root,"SIDIS","common","s02_result","s02_result.wl"}];HSCutFamilySetup[Get[geometryFile]];
exchange={a->t-w-a,b->s-w-b};
pairFiles=AssociationMap[FileNameJoin[{pairsDirectory,"pair_"<>#<>".wl"}]&,pairKeys];
gate["all native pair projections supplied",And@@(FileExistsQ/@Values[pairFiles])];
wardFile=FileNameJoin[{pairsDirectory,"ward.wl"}];ward=Get[wardFile];gate["completed open Ward evidence",AssociationQ[ward]&&And@@(#===0&/@Values[ward])];
exchangeFile=FileNameJoin[{pairsDirectory,"exchange-proof.wl"}];exchangeProof=Get[exchangeFile];
gate["physical exchange proof present",AssociationQ[exchangeProof]&&KeyExistsQ[exchangeProof,"checks"]];
Put[exchangeProof,FileNameJoin[{out,"exchange-proof.wl"}]];Put[ward,FileNameJoin[{out,"ward.wl"}]];
projections=Map[Get,pairFiles];
gate["every pair bound to its generating tensor",And@@(#["full_open_tensor_source"]===input&/@Values[projections])];
grouped=GroupBy[pairKeys,projections[#]["charge_degree"]&];
coefficients=<||>;integrands=<||>;originals=<||>;targets={};residuals=<||>;pieces=<||>;
Do[Do[key=topology<>"_"<>component<>"_charge"<>ToString[charge];Print["LINEAR_MAP_COMPONENT ",key];
 mappedPieces={};originalTerms={};scalarTerms={};checks={};pairEvidence=<||>;
 Do[Print["LINEAR_MAP_PAIR ",key," ",pairKey];original=projections[pairKey]["Collins"][component];AppendTo[originalTerms,original];
  values={original/2,(original/.exchange)/2};pairMaps={};pairChecks={};
  Do[value=values[[orientation]];
   gate["actual projected coefficient is rational",FreeQ[value,h|Q|ny]&&FreeQ[value,Power[Q2,_Rational]]];
   mapped=bounded[mapExpression[value],"pair "<>pairKey<>" orientation "<>ToString[orientation]];
   reconstructed=Total[KeyValueMap[Function[{integral,c},c Times@@MapThread[Power,
    {families[integral[[1]]]["OnCutUncutPropagators"],-Drop[integral[[2]],2]}]],mapped]];
   residual=bounded[Factor[Together[reconstructed-value]],"independent pair reconstruction"];
   gate["each mapped pair reconstructs",residual===0];
   AppendTo[mappedPieces,mapped];AppendTo[scalarTerms,value];AppendTo[checks,residual];
   AppendTo[pairMaps,mapped];AppendTo[pairChecks,residual],{orientation,2}];
  evidence=<|"original"->original,"exchange_terms"->values,"maps"->pairMaps,"reconstruction_residuals"->pairChecks,
   "projection_file"->pairFiles[pairKey],"projection_sha256"->IntegerString[FileHash[pairFiles[pairKey],"SHA256"],16,64]|>;
  Put[evidence,FileNameJoin[{out,key<>"_pair_"<>pairKey<>".wl"}]];AssociateTo[pairEvidence,pairKey->evidence];ClearSystemCache[],{pairKey,grouped[charge]}];
 Print["LINEAR_MAP_MERGE ",key];merged=bounded[merge[mappedPieces],"merge actual integral coefficients"];
 AssociateTo[coefficients,key->merged];AssociateTo[integrands,key->Total[scalarTerms]];
 AssociateTo[originals,key-><|"original_projected_integrand"->Total[originalTerms],"full_tensor_source"->input,"pairs"->grouped[charge]|>];
 AssociateTo[residuals,key->Total[checks]];AssociateTo[pieces,key->pairEvidence];targets=Union[targets,Keys[merged]];
 Put[<|"coefficients"->merged,"reconstruction_residual"->Total[checks],"proof"->"Exact reconstruction of every term plus linear coefficient merge"|>,FileNameJoin[{out,key<>".wl"}]],
 {component,{"Collins_L","Collins_T"}}],{charge,Keys[grouped]}];
Put[<|"topology"->topology,"input"->input,"input_sha256"->IntegerString[FileHash[input,"SHA256"],16,64],
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],"geometry_sha256"->IntegerString[FileHash[geometryFile,"SHA256"],16,64],
 "helper_sha256"->IntegerString[FileHash[helper,"SHA256"],16,64],"projection_reuse_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,Values[pairFiles]],
 "tag_weight_unapplied"->record["tag_weight_unapplied"],"charge_weights"->If[topology==="RealDistinct",
  <|"charge0"->Nf-1,"charge1"->otherChargeMoment1/eq,"charge2"->otherChargeMoment2/eq^2|>,<|"charge0"->1|>],
 "integrands"->integrands,"original_open_templates"->originals,"coefficients"->coefficients,"targets"->targets,
 "ward_residuals"->ward,"reconstruction_residuals"->residuals,"pair_mapping_evidence"->pieces,
 "exchange_conversion"->exchangeProof,"positive_energy_support"->geometry["CutEnergyConditions"],
 "qualification"->"Fresh linear cut mapping of explicitly reused native pair projections; every smaller rational map reconstructs before summation. No finite NLO acceptance."|>,FileNameJoin[{out,"mapping.wl"}]];
Put[coefficients,FileNameJoin[{out,"coefficients.wl"}]];
text[x_]:=StringReplace[ToString[x,InputForm],Whitespace->""];
external=Take[geometry["BasisMomenta"],Length[geometry["BasisMomenta"]]-Length[geometry["CutMomenta"]]+1];
gram=geometry["CommonGram"][[Range[Length[external]],Range[Length[external]]]];names=Sort[DeleteDuplicates[targets[[All,1]]]];
Export[FileNameJoin[{out,"kira-input.json"}],<|"scope"->topology<>" actual linearly mapped polarized targets",
 "targets"->(<|"family"->#[[1]],"powers"->#[[2]]|>&/@targets),"external"->(text/@external),
 "invariants"->(text/@Sort[DeleteDuplicates[Cases[gram,symbol_Symbol/;Context[symbol]==="Global`",Infinity]]]/.{"Q2"->"q2"}),
 "scalarproducts"->Flatten[Table[{text[external[[i]]],text[external[[j]]],text[gram[[i,j]]/.Q2->q2]},{i,Length[external]},{j,i,Length[external]}],1],
 "families"->Table[<|"id"->name,"loop_momenta"->(text/@families[name]["LoopMomenta"]),
  "propagators"->MapThread[{text[#1],text[#2]}&,{families[name]["PropagatorMomenta"],families[name]["PropagatorMassesSquared"]}],
  "cut_positions"->families[name]["CutPositions"]|>,{name,names}]|>,"RawJSON"];
Print["LINEAR_CUT_MAP_COMPLETE ",Length[targets]];Exit[0];
