$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
engine=FileNameJoin[{root,"collins_sidis_highpt"}];out=FileNameJoin[{root,"collins_support","reports","sidis-highpt-001"}];
If[StringQ[Environment["SIDIS_JET_CHECK_OUT"]],out=Environment["SIDIS_JET_CHECK_OUT"]];
If[!DirectoryQ[out],CreateDirectory[out,CreateIntermediateDirectories->True]];
If[FileExistsQ[FileNameJoin[{out,"jet-matching-native.wl"}]],Print["Refuse evidence overwrite"];Exit[1]];
Get[FileNameJoin[{root,"collins_support","validators","analytic","native_io.wl"}]];
Get[FileNameJoin[{engine,"common","jet_matching.wl"}]];
labels={{"U","q","q"},{"U","q","g"},{"U","g","g"},{"U","g","q"},{"T","q","q"}};
values=Association@Table[StringJoin[item]->HSJetCanonical[HSJetMatching[Sequence@@item,z,L],z],{item,labels}];
splittings=<|"Uqq"-><|"delta"->3CF/2,"plus0"->2CF,"plus1"->0,"regular"->-CF(1+z)|>,
 "Uqg"-><|"delta"->0,"plus0"->0,"plus1"->0,"regular"->CF(1+(1-z)^2)/z|>,
 "Ugg"-><|"delta"->beta0/2,"plus0"->2CA,"plus1"->0,"regular"->2CA(-1+(1-z)/z+z(1-z))|>,
 "Ugq"-><|"delta"->0,"plus0"->0,"plus1"->0,"regular"->TF(z^2+(1-z)^2)|>,
 "Tqq"-><|"delta"->3CF/2,"plus0"->2CF,"plus1"->0,"regular"->-2CF|>|>;
rg=Association@Table[key->Association@Table[part->Factor[2D[values[key][part],L]-2splittings[key][part]+
  If[part=="delta",Switch[key,"Uqq"|"Tqq",CF(2L+3),"Ugg",2CA L+beta0,_,0],0]],
 {part,{"delta","plus0","plus1","regular"}}],{key,Keys[values]}];
orderResidual=Expand[HSTruncateHardJet[c0,c1,j0,j1,a]-(a c0 j0+a^2(c1 j0+c0 j1))];
Put[<|"matching"->values,"splitting"->splittings,"RG_residuals"->rg,"order_residual"->orderResidual,
 "meaning"->"Imported universal jet matching; no DIS C1 is supplied by these functions"|>,FileNameJoin[{out,"jet-matching-native.wl"}]];
encoded=Map[Map[RUExact,#]&,values];encodedRG=Map[Map[RUExact,#]&,rg];
Export[FileNameJoin[{out,"jet-matching-native.json"}],RUEncode[<|"matching"->encoded,"RG_residuals"->encodedRG,"order_residual"->RUExact[orderResidual]|>],"RawJSON"];
Print["JET_MATCHING_EXPORTED; INDEPENDENT_DISTRIBUTION_CHECK_PENDING"];Exit[0];
