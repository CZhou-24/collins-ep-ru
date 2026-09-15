(* Validator-owned execution of actual SubTropica integrals.
   Evaluation options follow SIDIS/common/s10_evaluate_cut_masters.wl and
   s13_evaluate_virtual_masters.wl at 5062dcb2407594dafcc2f9f72800e96ff9e6d957.
   The candidate supplies unevaluated Euler inputs, not evaluated answers. *)
Get[FileNameJoin[{DirectoryName[$InputFileName],"native_io.wl"}]];
c=Import[Environment["COLLINS_RU_TOOL_CONTEXT"],"RawJSON"];
gate[test_,message_]:=If[!TrueQ[test],Print[message];Exit[1]];
Get[FileNameJoin[{c["runtime"]["subtropica_root"],"Kernel","init.m"}]];
SubTropica`$PolymakeCommand=c["runtime"]["polymake"];
SubTropica`STCheckDependencies[];
SetOptions[HyperIntica`HyperInt, "EvaluatePeriodsQ" -> True];
input=Get["euler_inputs.wl"];
gate[AssociationQ[input]&&Length[input]>0,"Euler master inputs must be a nonempty Association"];
gate[And@@(StringQ[#]&&StringMatchQ[#,RegularExpression["[A-Za-z][A-Za-z0-9_]*"]]& /@ Keys[input]),"Invalid master ID"];
results=<||>;rawResults=<||>;
Do[spec=input[key];gate[AssociationQ[spec]&&Sort[Keys[spec]]===Sort[{"terms","order"}],"Invalid master specification"];
 gate[IntegerQ[spec["order"]]&&0<=spec["order"]<=4&&ListQ[spec["terms"]]&&Length[spec["terms"]]>0,"Invalid expansion order/terms"];
 total=0;rawTerms={};
 Do[term=spec["terms"][[j]];
  gate[AssociationQ[term]&&Sort[Keys[term]]===Sort[{"tuple","prefactor","order","assumptions"}],"Invalid Euler term"];
  gate[IntegerQ[term["order"]]&&0<=term["order"]<=8,"Invalid requested integral depth"];
  tuple=term["tuple"]/.Global`eps->SubTropica`eps;
  gate[ListQ[tuple]&&Length[tuple]>=4,"Unsupported SubTropica tuple"];
  $Assumptions=term["assumptions"]/.Global`eps->SubTropica`eps;
  raw=SubTropica`STIntegrate[tuple,"Order"->term["order"],"Integrator"->"HyperIntica","LROrderBackend"->"HyperIntica",
   "KernelsAvailable"->1,"SimplifyOutput"->Identity,"Verbose"->False,"ShowTimings"->True,"ScanGauges"->False,
   "SetProblemID"->(key<>"_"<>ToString[j]),"SaveAllIntegrands"->(key<>"_"<>ToString[j]<>"_integrands.wl"),
   "ReuseExistingResults"->False,"ClearCachesPerIntegrand"->True];
  gate[MatchQ[raw,_SeriesData]&&FreeQ[raw,$Failed|$Aborted|_SubTropica`STIntegrate]&&raw[[1]]===SubTropica`eps&&raw[[2]]===0&&raw[[5]]/raw[[6]]>term["order"],"SubTropica did not return the requested series"];
  rules=HyperIntica`GetAlgebraicBackSubRules[];
  AppendTo[rawTerms,<|"input"->tuple,"raw"->raw,"letter_rules"->rules|>];
  normalized=(raw/.rules)/.HyperIntica`Hlog[arg_,word_List]:>HyperIntica`HlogAsMpl[arg,word];
  normalized=FixedPoint[(#/.{HyperIntica`mzv[n_Integer]:>Zeta[n],HyperIntica`Mpl[{n_Integer},{arg_}]:>PolyLog[n,arg]})&,normalized];
  gate[FreeQ[normalized,_HyperIntica`Wm|_HyperIntica`Wp],"Unresolved algebraic letters"];
  (* Retain SeriesData precision while multiplying the regulated prefactor. *)
  product=Series[(term["prefactor"]/.Global`eps->SubTropica`eps)*normalized,{SubTropica`eps,0,spec["order"]}];
  gate[MatchQ[product,_SeriesData]&&product[[5]]/product[[6]]>spec["order"],"Insufficient epsilon depth after prefactor"];
  total+=product,
 {j,Length[spec["terms"]]}];
 AssociateTo[results,key->(Normal[total]/.SubTropica`eps->Global`eps)];AssociateTo[rawResults,key->rawTerms],
{key,Keys[input]}];
Put[rawResults,"raw_results.wl"];Put[results,"masters.wl"];
(* Keep failed native artifacts, but never label unevaluated period tuples PASS.
   The separate native reexport is still required by the runner. *)
gate[FreeQ[results,_Real|Indeterminate|ComplexInfinity|_DirectedInfinity],"Inexact/nonfinite master"];
Map[RUTree,results];
Export["subtropica_execution.json",<|"status"->"PASS","master_count"->Length[results],"orders"->Map[#["order"]&,input],"version"->ToString[SubTropica`$SubTropicaVersion],"reuse"->False|>,"RawJSON"];
Exit[0];
