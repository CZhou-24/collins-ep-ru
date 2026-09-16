(* Actual r07 coefficients, observable provenance and check inventory. The
   installed validator supplies all acceptance decisions and exact arithmetic. *)
$HistoryLength=0;ctx=Import[Environment["SIDIS_HIGHPT_CONTEXT"],"RawJSON"];
engine=ctx["production"];root=DirectoryName[engine];out=ctx["output"];
Get[FileNameJoin[{root,"collins_support","validators","analytic","native_io.wl"}]];
hard=Get[FileNameJoin[{out,"hard-basis","native-hard.wl"}]];
uu=Get[FileNameJoin[{out,"UU-scalars","uu-scalars.wl"}]];
rg=Get[FileNameJoin[{out,"jet-TMD-RG","rg.wl"}]];
finiteJet=Get[FileNameJoin[{out,"finite-jet","jet-matching-native.wl"}]];
actions=Get[FileNameJoin[{out,"measured-actions","actions.wl"}]];
observable=Get[FileNameJoin[{out,"observable","observable.wl"}]];
flavors=Get[FileNameJoin[{out,"flavors","flavor.wl"}]];
values=Join[hard["values"],uu["values"]];evidence=<||>;exports=<||>;inventory=<||>;checks={};conversions=<||>;
putval[key_,value_,channel_]:=AssociateTo[values,"r07/"<>key->
 <|"constant"->RUExact[value],"terms"->{},"value"->RUExact[value],"eta_order"->0,"eps_order"->0,"sectors"->{channel}|>];
check[id_,kind_,channel_,lhs_,reason_,extra_:<||>]:=AppendTo[checks,Join[
 <|"id"->id,"kind"->kind,"stage"->"r07","channel"->channel,"lhs"->lhs,"reason"->reason|>,
 If[MemberQ[{"finite","uu_recovery","literature"},kind],<||>,<|"rhs"->0|>],extra]];
ev[key_,file_,role_,parents_]:=AssociateTo[evidence,"r07/"<>key-><|"path"->file,"role"->role,"parents"->parents|>];
export[name_,id_,channel_,sector_,order_]:=(AssociateTo[exports,name-><|"value"->id,"evidence"->"r07/finite"|>];
 AssociateTo[inventory,name-><|"channel"->channel,"sector"->sector,"order"->order|>];
 check[name<>".finite","finite",channel,id,"Actual scalar coefficient of the displayed exact hard function/polynomial basis; no remaining regulator." ]);
KeyValueMap[export[#1,#2["value"],#2["channel"],"UU",#2["order"]]&,uu["inventory"]];
Do[channel=If[StringStartsQ[key,"r07/Hqqbar_"],"Hqqbar","Hqq"];
 Which[StringEndsQ[key,"_p0"],
  KeyValueMap[Function[{id,basis},name="UT_"<>StringDrop[id,4];valueID="r07/"<>name;factor=64Pi^4 eq^2;
   AssociateTo[values,valueID-><|"constant"->RUExact[0],"terms"->{<|"ref"->id,"factor"->RUExact[factor]|>},
    "value"->RUExact[factor hard["scalar_values"][id]],"eta_order"->0,"eps_order"->0,"sectors"->{channel}|>];
   AssociateTo[conversions,valueID-><|"bare_value"->id,"factor"->factor,"basis"->basis,
    "meaning"->"eq^2 gs^4 stripped native hard; gs^2=8Pi^2 a, a=alpha_s/(2Pi)."|>];
   export[name,valueID,channel,"UT",2]],hard["basis"][key]],
  StringContainsQ[key,"_scale_"],
   Do[check[StringDrop[id,4]<>".scale","scale_consistency",channel,id,
    "Calculated derivative with respect to ln(muR^2), ln(muPDF^2) or ln(muFF^2), including the derived beta-function/Born or transversity convolution term; native recipe and scale definition are retained."],{id,Keys[hard["basis"][key]]}],
  StringEndsQ[key,"_m1"]||StringEndsQ[key,"_m2"],
   Do[check[StringDrop[id,4]<>".pole","ir_poles",channel,id,
    "Calculated Laurent residue after real, UV-renormalized virtual and applicable initial/outgoing MS contributions; component, branch and distribution remain separate."],{id,Keys[hard["basis"][key]]}]],
 {key,Keys[hard["basis"]]}];
Do[name="UT_Hqq_LO_"<>pol;value=16Pi^3 eq^2 hard["Born_D4"]["Collins_"<>pol];putval[name,value,"Hqq"];
 AssociateTo[conversions,"r07/"<>name-><|"factor"->16Pi^3 eq^2,"meaning"->"Born cut 2Pi delta(w), gs^2=8Pi^2 a."|>];
 export[name,"r07/"<>name,"Hqq","UT",1],{pol,{"L","T"}}];
Do[key="UURecovery_"<>channel;putval[key,uu["literal_reference_candidates"][channel],channel];
 check[channel<>".UU_literal_recovery","uu_recovery",channel,"r07/"<>key,
  "Recover one nonzero archived F1 coefficient from the independently converted transverse photon coefficient at the documented exact physical point. This is UU reuse/convention recovery, not a fresh or independent UU NLO derivation.",
  <|"reference"-><|"source"->"uu_literal_native","equation"->channel|>|>];
 routes=If[MemberQ[{"Hqg","Hgg"},channel],{"Ugq","Ugg"},{"Uqq","Uqg"}];
 If[MemberQ[{"Hqq","Hqqbar"},channel],AppendTo[routes,"Tqq"]];
 Do[KeyValueMap[Function[{part,residual},key="JetRG_"<>channel<>"_"<>route<>"_"<>part;putval[key,residual,channel];
   check[key,"jet_matching",channel,"r07/"<>key,
    "Canonical delta/plus/regular jet derivative plus soft-subtracted TMD evolution equals the literal LO DGLAP kernel. The observable applies one-loop jet matching only to Born hard channels at this order."]],
  rg["matching_rows"][route]["canonical_residuals"]],{route,routes}],{channel,Keys[ctx["channels"]]}];
KeyValueMap[Function[{route,coefficients},KeyValueMap[Function[{part,value},
 key="FiniteJet_"<>route<>"_"<>part;putval[key,value,"Hqq"];
 check[key,"literature","Hqq","r07/"<>key,
  "Finite one-loop universal jet coefficient versus the independently entered pinned literal formula, with the documented canonical distribution conversion.",
  <|"reference"-><|"source"->"jet_literal_coefficients","equation"->route<>"_"<>part|>|>]],coefficients]],finiteJet["matching"]];
KeyValueMap[Function[{label,residual},key="Flavor_"<>label;putval[key,residual,"Hqq"];
 check[key,"normalization","Hqq","r07/"<>key,"Calculated flavor/charge sums against the preserved independent inclusive luminosity contract, including nf=4 and nf=5."]],flavors["residuals"]];
KeyValueMap[Function[{label,residual},key="Rapidity_"<>ToString[label,InputForm];putval[key,residual,"Hqq"];
 check[key,"scale_consistency","Hqq","r07/"<>key,"Unsubtracted TMD and in-jet soft rapidity anomalous dimensions cancel before using the soft-subtracted TMD."]],rg["rapidity_residuals"]];
KeyValueMap[Function[{label,residual},key="CS_"<>label;putval[key,residual,"Hqq"];
 check[key,"scale_consistency","Hqq","r07/"<>key,"Collins-Soper and mu evolution satisfy the displayed integrability relation."]],rg["CS_mu_integrability_residuals"]];
(* Real-only Hqqbar has no Born operator subtraction. Its actual vanishing
   regular single-pole coefficient is the applicable factorization check. *)
factorizationID=First[Keys[hard["basis"]["r07/Hqqbar_Collins_L_plus_Regular_m1"]]];
check["Hqqbar.real_only_factorization","factorization","Hqqbar",factorizationID,
 "The first nonzero Hqqbar UT hard channel has no Born PDF/FF subtraction; its calculated regular single pole must cancel. Other residues remain separate IR checks."];
Do[KeyValueMap[Function[{label,residual},key="Measure_"<>group<>"_"<>label;putval[key,residual,"Hqq"];
  check[key,"normalization","Hqq","r07/"<>key,"Independent exact Breit coordinate/Jacobian and endpoint test-function action; the full PDF/jet measure and physical lower-bound terms are retained."]],actions[group]],
 {group,{"coordinate_residuals","zero_endpoint_tests","one_endpoint_tests"}}];
KeyValueMap[Function[{label,residual},key="Order_"<>label;putval[key,residual,"Hqq"];
 check[key,"identity","Hqq","r07/"<>key,"Actual assembled observable contains only the stated hard orders; the asymmetry is the consistent expansion of the numerator/denominator ratio."]],observable["order_residuals"]];
(* Additional native flavor and boundary evidence is retained with complete
   scalar results. Boundary regularity is separately required by the campaign
   for physical runs; intentionally changed masters may break it in probes. *)
runRoot=DirectoryName[DirectoryName[ctx["inputs"]["r00"]]];toolParents={};
Do[receipt=Import[FileNameJoin[{runRoot,"receipts",stage<>".json"}],"RawJSON"];
 Do[toolNames=Union[Keys[job["outputs"]],Keys[Lookup[job,"audited_outputs",<||>]]];
  toolParents=Join[toolParents,("tool/"<>stage<>"/"<>job["job"]["id"]<>"/"<>#&/@toolNames)],{job,receipt["jobs"]}],
 {stage,{"r01","r02","r04","r05"}}];
ev["hard","hard-basis/native-hard.wl","assembly",Join[
 {"source/r07","r03/realCoefficients","r03/subtractions","r03/scheme","r06/linearplus","r06/linearminus",
  "input/real_master_basis","input/virtual_master_basis"},toolParents]];
ev["UU","UU/uu-channels.wl","conversion",Join[{"source/r07","input/UU_bigTMD_validation"},("input/"<>#<>"_UU"&/@Keys[ctx["channels"]])]];
ev["UURepresentationCheck","UU-scalars/reuse-check.wl","conversion",{"r07/UU","input/uu_scalar_representation"}];
ev["UUScalars","UU-scalars/uu-scalars.wl","conversion",{"r07/UURepresentationCheck"}];
ev["jetRG","jet-TMD-RG/rg.wl","conversion",{"source/r07","input/jet_paper_source","r03/scheme"}];
ev["finiteJet","finite-jet/jet-matching-native.wl","conversion",{"source/r07","input/jet_paper_source","r03/scheme"}];
ev["actions","measured-actions/actions.wl","conversion",{"source/r07","r00/measurement"}];
ev["flavors","flavors/flavor.wl","conversion",{"source/r07","input/flavor_contract"}];
ev["boundary","boundary/boundary.wl","assembly",{"r07/hard"}];
ev["observable","observable/observable.wl","assembly",{"r07/hard","r07/UUScalars","r07/jetRG","r07/finiteJet","r07/actions","r07/flavors","r07/boundary","r00/channel_operators"}];
Put[<|"exports"->exports,"inventory"->inventory,"UT_conversions"->conversions,
 "UU_basis"->uu["basis"],"UT_basis"->hard["basis"],
 "qualification"->"Scalar exports plus their exact reconstruction bases and complete symbolic measured observable. Independent physics review remains pending; historical UU qualifications are preserved."|>,FileNameJoin[{out,"finite-exports.wl"}]];
ev["finite","finite-exports.wl","finite_export",{"r07/observable"}];
Put[<|"schema"->5,"stage"->"r07","values"->values,"evidence"->evidence,"jobs"->{},"exports"->exports|>,FileNameJoin[{out,"packet.wl"}]];
Export[FileNameJoin[{out,"native-contract-r07.json"}],<|"schema"->1,"checks"->checks,"exports"->inventory|>,"RawJSON"];
Print["NATIVE_FINAL_PACKET_PRODUCED ",Length[exports]," exports; acceptance is external"];Exit[0];
