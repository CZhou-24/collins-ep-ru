(* Fresh output-bound stage support. Path/identity staging adapted from approved
   SIDIS s22_paths.wl, with historical aliases and cache reuse removed. *)
$HistoryLength=0;
$RUContext=Import[Environment["COLLINS_RU_CONTEXT"],"RawJSON"];
$RUOutput=$RUContext["output"];$RUProduction=$RUContext["production"];
Get[FileNameJoin[{$RUProduction,"common","ru_io.wl"}]];
RUGate[name_,test_]:=If[!TrueQ[test],Print["RU_FAILED: ",name];Exit[1]];
RUPath[name_]:=FileNameJoin[{$RUOutput,name}];
RUPut[x_,name_]:=(Put[x,RUPath[name]];x);
RUZero[x_]:=Factor[Together[x]]===0;
RUEvidence[path_,role_,parents_]:=<|"path"->path,"role"->role,"parents"->parents|>;
RUCertificate[constant_,terms_List,sectors_List,order_:0]:=Module[{ans},
 ans=constant+Total[(#["factor"] #["actual"])& /@ terms];
 ans=Normal[Series[Normal[Series[ans,{eta,0,0}]],{eps,0,order}]];
 <|"constant"->RUExact[constant],"terms"->(<|"ref"->#["ref"],"factor"->RUExact[#["factor"]]|>& /@ terms),"eta_order"->0,"eps_order"->order,"value"->RUExact[Expand[ans]],"sectors"->sectors|>];
RURecord[ref_,factor_,actual_]:=<|"ref"->ref,"factor"->factor,"actual"->actual|>;
