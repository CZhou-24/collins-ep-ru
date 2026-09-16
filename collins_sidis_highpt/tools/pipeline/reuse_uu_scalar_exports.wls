(* Reuse a checked exact representation of the explicitly imported UU banks.
   Every complete converted expression must equal this run's fresh native import
   exactly. This does not substitute a cached polarized answer or claim a fresh
   unpolarized derivation. *)
$HistoryLength=0;source=Environment["SIDIS_UU_REPRESENTATION_INPUT"];
currentInput=Environment["SIDIS_UU_CURRENT_INPUT"];out=Environment["SIDIS_UU_SCALAR_OUT"];
If[!StringQ[out]||DirectoryQ[out]||!And@@(FileExistsQ/@{source,currentInput}),Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];portable=Get[source];current=Get[currentInput];checks=<||>;
Do[row=portable["rows"][key];parts=StringSplit[key,"_"];channel=parts[[2]];
 actual=If[parts[[3]]==="LO",current["channels"][channel]["LO"][parts[[4]]],
  branch=Switch[parts[[4]],"plus",1,"minus",-1,"boundary",0,"ordinary","ordinary"];
  current["channels"][channel]["NLO"][branch][parts[[5]]][parts[[6]]]];
 equality=SameQ[actual,row["expression"]];AssociateTo[checks,key->equality];
 If[!TrueQ[equality],Put[<|"quantity"->key,"current"->actual,"recorded"->row["expression"]|>,FileNameJoin[{out,"failure.wl"}]];
  Print["UU_REPRESENTATION_DIFFERS ",key];Exit[2]],{key,Keys[portable["rows"]]}];
Put[portable,FileNameJoin[{out,"uu-scalars.wl"}]];
Put[<|"full_expression_equalities"->checks,"source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,{source,currentInput,$InputFileName}],
 "qualification"->"Exact representation reuse of the six pre-existing UU hard banks. Every current native converted coefficient was checked by structural exact equality; no new UU integration or historical recertification is asserted."|>,
 FileNameJoin[{out,"reuse-check.wl"}]];
Print["UU_REPRESENTATION_REUSE_CHECKED ",Length[checks]," complete hard expressions"];Exit[0];
