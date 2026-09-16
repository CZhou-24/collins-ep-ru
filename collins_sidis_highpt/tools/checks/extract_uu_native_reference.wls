(* Literal saved UU coefficient extraction, independent of the new converter.
   This checks reuse/conversion at an exact physical point, not an independent
   derivation of those historical hard coefficients. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
engine=FileNameJoin[{root,"collins_sidis_highpt"}];out=Environment["SIDIS_UU_REFERENCE_OUT"];
If[!StringQ[out]||DirectoryQ[out],Exit[1]];CreateDirectory[out,CreateIntermediateDirectories->True];
Get[FileNameJoin[{root,"collins_support","validators","analytic","native_io.wl"}]];
project=Import[FileNameJoin[{engine,"project.json"}],"RawJSON"];
point={Q2->5,s->7,t->-4,w->1,mu->1,mu2->1,alphaS->2Pi,FeynCalc`SUNN->3,FeynCalc`Nf->4,Nc->3,Nf->4};
rows=<||>;originals=<||>;
Do[source=project["sources"][project["channels"][channel]["uu_source"]];file=FileNameJoin[{root,"SIDIS",source["path"]}];
 bank=Get[file];hats=bank["Fhats"];born=AssociationQ[hats["F1"]];
 literal=If[born,hats["F1"]["LODelta"],hats["F1"]];
 actualPoint=If[born,point/.Rule[w,1]->Rule[w,0],point];value=literal/.actualPoint;
 AssociateTo[originals,channel-><|"literal"->literal,"point"->actualPoint,"value"->value,"source"->file,
  "source_sha256"->IntegerString[FileHash[file,"SHA256"],16,64]|>];
 AssociateTo[rows,channel-><|"value"->RUExact[value],"source_url"->file,
  "location"->If[born,"Fhats/F1/LODelta","Fhats/F1 (ordinary real-only NLO)"],
  "transcription"->"Native literal selection from the archived UU bank, then exact physical-point substitution shown in literal-uu-reference.wl. No candidate import/observable helper is loaded. alphaS=2Pi sets a=1 for coefficient comparison; Q2=5,s=7,t=-4,w=0 (Born) or 1 (real-only), mu=mu2=1,Nc=3,Nf=4.",
  "independence"->"unpolarized_SIDIS"|>],{channel,Keys[project["channels"]]}];
Put[<|"selections"->originals,"source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "qualification"->"Exact selected coefficient comparison for historical UU reuse and convention recovery. It is not an independent NLO recalculation and does not resolve the historical Hgq MadGraph issue."|>,FileNameJoin[{out,"literal-uu-reference.wl"}]];
result=Export[FileNameJoin[{out,"uu-inclusive-native.json"}],RUEncode[<|"equations"->rows|>],"RawJSON"];If[result===$Failed,Exit[2]];
Print["LITERAL_UU_REFERENCE_EXTRACTED ",Length[rows]];Exit[0];
