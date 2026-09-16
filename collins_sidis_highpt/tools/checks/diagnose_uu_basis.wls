$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
out=Environment["SIDIS_UU_BASIS_DIAGNOSTIC_OUT"];If[DirectoryQ[out],Exit[1]];CreateDirectory[out,CreateIntermediateDirectories->True];
record=Get[Environment["SIDIS_UU_BASIS_DIAGNOSTIC_INPUT"]];value=record["NLO"][1]["Delta"]["L"];
atoms=SortBy[DeleteDuplicates[Cases[value,_Log|_PolyLog|_Zeta,Infinity]],ToString[#,InputForm]&];
variables=Table[Unique["hsTranscendental"],Length[atoms]];polynomial=Expand[value/.Thread[atoms->variables]];
parts=If[Head[polynomial]===Plus,List@@polynomial,{polynomial}];bad=Select[parts,!PolynomialQ[#,variables]&];
Put[<|"value"->value,"atom_rules"->Thread[atoms->variables],"nonpolynomial_terms"->bad|>,FileNameJoin[{out,"diagnosis.wl"}]];
Print["UU_BASIS_NONPOLYNOMIAL_TERMS ",Length[bad]];Print[InputForm[Take[bad,UpTo[3]]]];Exit[0];
