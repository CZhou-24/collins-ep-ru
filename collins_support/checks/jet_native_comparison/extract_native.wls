(* Read saved expressions only. Never activate a saved hard integral or run a stage. *)
$HistoryLength=0;
ncContext=Import[Environment["JET_NATIVE_CONTEXT"],"RawJSON"];
ncOut=ncContext["out"]; ncEP=ncContext["ep_run"]; ncHP=ncContext["highpt_run"];
ncGet[base_,rel_]:=Get[FileNameJoin[{base,rel}]];
ncMeasured=ncGet[ncEP,"common/r03_result/measured_coefficients.wl"];
ncObservable=ncGet[ncEP,"common/r07_result/observable_assembly.wl"];
ncEPValues=ncGet[ncEP,"common/r03_result/packet.wl"]["values"];
ncValue[id_]:=ncEPValues[id]["value"]/.RUExact[x_]:>x;
Print["MEASURED_KEYS ",Keys[ncMeasured]];
Print["SOFT_KEYS ",Keys[ncMeasured["soft"]]];
Print["TMD_KEYS ",Keys[ncMeasured["tmd"]]];
ncTMDFull=Map[Map[ncValue,#]&,ncMeasured["tmd"]["full_scale_nodes"]];
ncSoft=KeySelect[ncEPValues,StringContainsQ[#,"soft_"]||StringContainsQ[#,"jet_"]&];
ncSoft=Map[(#["value"]/.RUExact[x_]:>x)&,ncSoft];
ncJets=ncGet[ncHP,"common/r07_result/finite-jet/jet-matching-native.wl"];
ncBornBanks=Map[KeyTake[#,{"LO"}]&,KeyTake[ncGet[ncHP,"common/r07_result/observable/hard-banks.wl"],{"UU_Hqq","UT_Hqq"}]];
ncHPSmall=<||>;
Do[
 Print["READ_SAVED_ASSEMBLY ",ncSpin];
 ncRecord=ncGet[ncHP,"common/r07_result/observable/"<>ncSpin<>"_Hqq.wl"];
 AssociateTo[ncHPSmall,ncSpin->KeyTake[ncRecord,{"LO","Born_times_jet_NLO","TMD_input","flavor_route","flavor_rules","common_scale_map"}]];
 Clear[ncRecord],{ncSpin,{"UU","UT"}}];
ncResult=<|"ep_soft"->ncSoft,"ep_tmd_full"->ncTMDFull,
 "ep_fourier"->ncMeasured["tmd"]["fourier"],"ep_observable"->ncObservable,
 "ep_consumed_sphere"->ncMeasured["consumed_sphere"],
 "ep_soft_details"->ncMeasured["soft"],"highpt_matching"->ncJets["matching"],
 "highpt_born_banks"->ncBornBanks,"highpt_assembly"->ncHPSmall|>;
Put[ncResult,FileNameJoin[{ncOut,"native-extract.wl"}]];
Print["EP_SOFT ",InputForm[ncSoft]];
Print["EP_TMD_FULL ",InputForm[ncTMDFull]];
Print["EP_FOURIER ",InputForm[ncMeasured["tmd"]["fourier"]]];
Print["EP_MEASURES ",InputForm[ncObservable["Fourier_measures"]]];
Print["EP_HF ",InputForm[ncObservable["HF_kernel"]]];
Print["NATIVE_EXTRACT_COMPLETE ", $Version];
Exit[0];
