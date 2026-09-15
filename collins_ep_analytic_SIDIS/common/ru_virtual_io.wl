(* Virtual-route helpers. LoadFC adapted from the accepted generating helper;
   exact upstream snapshots and pre-use identities are in provenance/virtual. *)
Clear[RUvGate,RUvBegin,RUvPath,RUvPut,RUvInput,RUvLoadFC,RUvExact,RUvCert];
RUvGate[name_,test_]:=If[!TrueQ[test],Print["VIRTUAL_FAIL: ",name];Quit[1]];
RUvBegin[id_]:=(
 $HistoryLength=0;
 $RUvContext=Import[Environment["COLLINS_RU_CONTEXT"],"RawJSON"];
 RUvGate["requested virtual stage",$RUvContext["stage"]===id];
 $RUvOutput=$RUvContext["output"];
 Get[FileNameJoin[{$RUvContext["production"],"common","ru_io.wl"}]];
);
RUvPath[name_]:=FileNameJoin[{$RUvOutput,name}];
RUvPut[value_,name_]:=Put[value,RUvPath[name]];
RUvInput[id_,name_]:=FileNameJoin[{$RUvContext["inputs"][id],name}];
RUvLoadFC[]:=(Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};
 Global`$FeynCalcStartupMessages=False;
 Global`$FeynCalcDirectory=$RUvContext["runtime"]["feyncalc_root"];
 FeynCalc`$FeynArtsDirectory=$RUvContext["runtime"]["feynarts_root"];
 Get[FileNameJoin[{$RUvContext["runtime"]["feyncalc_root"],"FeynCalc.m"}]];
 FeynArts`$FAVerbose=0;FeynCalc`FCSetDiracGammaScheme["BMHV"];
 RUvGate["native packages are not patched",FeynCalc`$FAPatch===False]);
RUvCert[constant_,terms_List,value_,order_:0]:=<|
 "constant"->RUExact[constant],"terms"->terms,"eta_order"->0,
 "eps_order"->order,"value"->RUExact[value],"sectors"->{"hard_virtual"}|>;
RUvTerm[ref_,factor_]:=<|"ref"->ref,"factor"->RUExact[factor]|>;
RUvLaurent[value_,order_:0]:=Expand[Normal[Series[value,{eps,0,order}]]];
RUvEvidence[path_,role_,parents_List]:=<|"path"->path,"role"->role,"parents"->parents|>;
