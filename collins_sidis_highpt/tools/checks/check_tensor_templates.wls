(* Independent contraction-order check: generic-vector traces versus completed
   explicit physical component traces. This is not an independent physics reference. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];engine=FileNameJoin[{root,"collins_sidis_highpt"}];
out=Environment["SIDIS_TEMPLATE_CHECK_OUT"];If[!StringQ[out]||DirectoryQ[out],Print["Supply unused output"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
rt=Import[FileNameJoin[{root,"collins_ep_analytic_SIDIS","ru_runtime.json"}],"RawJSON"];
Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};Global`$FeynCalcStartupMessages=False;
Global`$FeynCalcDirectory=rt["feyncalc_root"];FeynCalc`$FeynArtsDirectory=rt["feynarts_root"];
Get[FileNameJoin[{rt["feyncalc_root"],"FeynCalc.m"}]];
FeynCalc`FCSetDiracGammaScheme["BMHV"];
Get[FileNameJoin[{engine,"common","spin_core.wl"}]];
Get[FileNameJoin[{engine,"common","spin_nlo.wl"}]];
Get[FileNameJoin[{engine,"common","spin_virtual.wl"}]];
Get[FileNameJoin[{engine,"common","spin_tensor_template.wl"}]];
files=AssociationMap[Environment,{"SIDIS_TEMPLATE_REAL","SIDIS_DIRECT_REAL","SIDIS_TEMPLATE_VIRTUAL","SIDIS_DIRECT_VIRTUAL"}];
If[!And@@(FileExistsQ/@Values[files]),Print["Missing required template comparison input"];Exit[2]];
realRecord=Get[files["SIDIS_TEMPLATE_REAL"]];directR=Get[files["SIDIS_DIRECT_REAL"]];
HSRealKinematics[];projectedR=HSProjectRealTemplate[realRecord["value"],realRecord["geometry"],{phL,phL},{pinX,poutX}];
rdiff=HSOnShell[projectedR-directR["value"]];
virtualRecord=Get[files["SIDIS_TEMPLATE_VIRTUAL"]];directV=Get[files["SIDIS_DIRECT_VIRTUAL"]];
vg=HSVirtualKinematics[];projectedV=HSProjectVirtualTemplate[virtualRecord["value"],virtualRecord["geometry"],vg,{phX,phX},{pinX,poutX}];
vdiff=HSOnShell[projectedV-directV["value"]];
result=<|"real_11_LL_1_1_difference"->rdiff,"virtual_11_XX_diagram1_difference"->vdiff,
 "real_projected"->projectedR,"virtual_projected"->projectedV,
 "input_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,Values[files]],
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "qualification"->"Exact contraction-order equivalence for specified components; no complete NLO or independent physics validation"|>;
Put[result,FileNameJoin[{out,"comparison.wl"}]];Print["TEMPLATE_DIFFERENCES ",InputForm[{rdiff,vdiff}]];
If[rdiff=!=0||vdiff=!=0,Exit[3]];Exit[0];
