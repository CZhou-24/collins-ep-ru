(* Match the two fresh diagnostic masters to saved positive-energy Euler
   definitions and calculate required depth from the new coefficients. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
base=FileNameJoin[{root,"collins_support","reports","sidis-highpt-001"}];If[StringQ[Environment["SIDIS_HIGHPT_REPORT_ROOT"]],base=Environment["SIDIS_HIGHPT_REPORT_ROOT"]];out=FileNameJoin[{base,"cut-master-depth-001"}];
If[DirectoryQ[out],Print["Refuse output reuse"];Exit[1]];CreateDirectory[out];
path[stage_]:=FileNameJoin[{root,"SIDIS","common",stage<>"_result",stage<>"_result.wl"}];
input=Get[path["s08"]];evaluations=Get[path["s10"]];oldReduction=Get[path["s04"]];geometry=Get[path["s02"]];
fresh=Get[FileNameJoin[{base,"real-kira-check-001","reduction.wl"}]];
gate[name_,test_]:=If[!TrueQ[test],Print["MASTER_MATCH_FAILED ",name];Exit[2]];
gate["exact saved geometry identity",geometry["Accepted"]===True];
masters=fresh["fresh_final_masters"];coefficients=Map[Function[x,AssociationMap[Factor[Coefficient[Expand[x],#]]&,masters]],fresh["reduced_polarized_coefficients"]];
valuation[x_,variable_]:=If[x===0,Infinity,With[{v=Together[x]},Exponent[Numerator[v],variable,Min]-Exponent[Denominator[v],variable,Min]]];
metadata=<||>;values=<||>;
Do[gate["same master indices and family",KeyExistsQ[input["Masters"],master]&&KeyExistsQ[oldReduction["Families"],master[[1]]]];
 gate["same family propagators and cuts",oldReduction["Families"][master[[1]]]["PropagatorMomenta"]===geometry["Families"][master[[1]]]["PropagatorMomenta"]&&oldReduction["Families"][master[[1]]]["CutPositions"]===geometry["Families"][master[[1]]]["CutPositions"]];
 data=input["Masters"][master];class=data["Class"];raw=evaluations["Classes"][class]["Series"]/.SubTropica`eps->Global`eps;
 nonzero=DeleteCases[Lookup[Values[coefficients],master],0];
 emin=Min[valuation[#/.D->4-2eps,eps]&/@nonzero];wmin=Min[valuation[#,w]&/@nonzero];
 pref=data["RegulatedPrefactor"];
 mpower=FullSimplify[Limit[w D[pref,w]/pref,w->0,Direction->"FromAbove"],Q2>0&&s>0&&-Q2-s<t<0&&Element[eps,Reals]];
 required=Max[0,-emin+If[wmin+(mpower/.eps->0)<0,1,0]];
 gate["integer regulator requirement",IntegerQ[required]];
 available=If[MatchQ[raw,_SeriesData],raw[[5]]-1,Infinity];
 gate["saved master class reaches actual coefficient depth",available>=required];
 series=Series[pref(raw/.data["PhysicalSubstitutions"]),{eps,0,required}];
 gate["prefactor times saved series retains needed depth",MatchQ[series,_SeriesData]&&series[[5]]>required];
 AssociateTo[values,master->series];
 AssociateTo[metadata,master-><|"class"->class,"coefficient_epsilon_minimum"->emin,"coefficient_soft_minimum"->wmin,
 "regulated_master_soft_power"->mpower,"required_through"->required,"available_class_through"->available,
 "definition"->data,"measure"->input["MasterMeasure"],"status"->"EXACT DEFINITION MATCH; ARCHIVED EVALUATION REUSED"|>],{master,masters}];
ordinary=Map[Function[rows,Total[KeyValueMap[Function[{m,c},Normal[Series[(c/.D->4-2eps)values[m],{eps,0,0}]]],rows]]],coefficients];
Put[<|"masters"->metadata,"coefficients"->coefficients,"master_series"->values,"ordinary_contractions"->ordinary,
 "input_hashes"->AssociationMap[IntegerString[FileHash[path[#],"SHA256"],16,64]&,{"s02","s04","s08","s10"}],
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "qualification"->"Only ordinary w>0 contractions here. Endpoint distributions, UV/factorization, scheme conversion and complete real/virtual channels remain required."|>,FileNameJoin[{out,"matched_masters.wl"}]];
Print["MASTER_DEFINITION_DEPTH_MATCH ",InputForm[Map[KeyTake[#,{"class","coefficient_epsilon_minimum","coefficient_soft_minimum","required_through","available_class_through"}]&,metadata]]];Exit[0];
