(* Exact one-sided common boundary by linear asymptotic series. Each term is
   expanded far enough to retain its constant term, including products with
   negative powers of omega. All negative-power/logarithmic residues remain
   explicit; a probe can spoil their cancellation. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
input=Environment["SIDIS_NATIVE_HARD_INPUT"];out=Environment["SIDIS_NATIVE_BOUNDARY_OUT"];
If[!StringQ[out]||DirectoryQ[out]||!FileExistsQ[input],Exit[1]];CreateDirectory[out,CreateIntermediateDirectories->True];
helper=FileNameJoin[{root,"collins_sidis_highpt","common","native_linear.wl"}];Get[helper];record=Get[input];
conditions=Q2>0&&s>w>0&&B>0&&muR>0&&muPDF>0&&muFF>0&&SUNN>1&&
 -Q2-s+w< -s< -Q2 w/s&&Element[Nf,Integers]&&Nf>=1;
SetAttributes[bounded,HoldFirst];bounded[expression_]:=MemoryConstrained[TimeConstrained[expression,900,$Failed],1536*1024^2,$Failed];
requested=Environment["SIDIS_NATIVE_BOUNDARY_COMPONENTS"];
labels=If[StringQ[requested]&&StringLength[requested]>0,StringSplit[requested,","],All];
results=<||>;summary=<||>;
Do[label=channel<>"_"<>component<>"_"<>dist;
 If[labels===All||MemberQ[labels,label],limits=<||>;seriesRecords=<||>;
 Do[value=record["hard"][channel][component<>"_"<>ToString[sign]]["finite_candidate"][dist];
  Print["NATIVE_BOUNDARY_SERIES ",label," ",sign];collected=HSLinearCompact[value];
  terms=If[Head[collected]===Plus,List@@collected,{collected}];prefixes={};index=0;
  Do[index++;Print["BOUNDARY_SERIES_TERM ",label," ",sign," ",index,"/",Length[terms]];
   prefix=bounded[Normal[Assuming[conditions&&omega>0,Series[term,{omega,0,0}]]]];
   AppendTo[prefixes,prefix];Put[<|"input"->term,"series_through_constant"->prefix,"conditions"->conditions|>,
    FileNameJoin[{out,label<>"_"<>ToString[sign]<>"_term"<>ToString[index]<>".wl"}]],{term,terms}];
  series=If[FreeQ[prefixes,$Failed],bounded[HSLinearCompact[Total[prefixes]]],$Failed];
  finite=FreeQ[series,$Failed|omega|_Series|_SeriesData|_DirectedInfinity|Indeterminate|_Missing|eps|eta];
  limit=If[finite,series,Missing["UncanceledOrUnevaluatedAsymptoticTerms"]];
  AssociateTo[limits,ToString[sign]->limit];AssociateTo[seriesRecords,ToString[sign]->series];
  Put[<|"series"->series,"finite_limit"->limit,"conditions"->conditions|>,FileNameJoin[{out,label<>"_"<>ToString[sign]<>".wl"}]],{sign,{1,-1}}];
 finite=FreeQ[limits,_Missing];residual=If[finite,bounded[FullSimplify[limits["1"]-limits["-1"],conditions]],Missing["NoFinitePair"]];
 AssociateTo[results,label-><|"limits"->limits,"asymptotic_series"->seriesRecords,"difference"->residual|>];
 AssociateTo[summary,label-><|"finite_evaluated_limits"->TrueQ[finite],"equal_limits"->TrueQ[residual===0]|>];
 Export[FileNameJoin[{out,"summary.json"}],<|"rows"->summary,"all_completed_pass"->And@@Flatten[Values/@Values[summary]],
  "complete_boundary_inventory"->(Length[summary]===16),"qualification"->"Exact asymptotic coefficients; all 16 physical boundary rows are required. Dependency probes may spoil regularity."|>,"RawJSON"]],
 {channel,{"Hqq","Hqqbar"}},{component,{"Collins_L","Collins_T"}},{dist,{"Delta","L0","L1","Regular"}}];
Put[<|"rows"->results,"conditions"->conditions,"source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,{input,helper,$InputFileName}]|>,
 FileNameJoin[{out,"boundary.wl"}]];
Print["NATIVE_BOUNDARY_SERIES_RECORDED ",Length[summary]];Exit[0];
