$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
engine=FileNameJoin[{root,"collins_sidis_highpt"}];
files=Join[FileNames[{"*.wl","*.wls"},FileNameJoin[{engine,"common"}]],FileNames[{"*.wl","*.wls"},FileNameJoin[{engine,"tools"}],Infinity]];
checks=AssociationMap[SyntaxQ[Import[#,"Text"]]&,files];
Print[InputForm[checks]];If[!And@@Values[checks],Exit[2]];Print["CONTINUATION_SYNTAX_PASS ",Length[checks]];Exit[0];
