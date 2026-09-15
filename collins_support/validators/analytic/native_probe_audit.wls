(* Independent check of the regenerated complete reduction operator. *)
c=Import[Environment["COLLINS_RU_MUTATION"],"RawJSON"];
gate[test_,message_]:=If[!TrueQ[test],Print[message];Exit[1]];
factor=c["numerator"]/c["denominator"];
gate[c["kind"]==="kira"&&c["scope"]==="complete_audited_reduction_map","Wrong reduction probe"];
records={};
Do[
 before=Get[job["certificate"]];after=Get[job["probe_certificate"]];
 gate[AssociationQ[before]&&AssociationQ[after],"Missing native certificates"];
 br=before["rules"];ar=after["rules"];
 gate[MatchQ[br,{__Rule}]&&MatchQ[ar,{__Rule}]&&FreeQ[{br,ar},_Real|$Failed|$Aborted],"Invalid exact reduction rules"];
 gate[DuplicateFreeQ[First/@br]&&DuplicateFreeQ[First/@ar]&&Sort[First/@br]===Sort[First/@ar],"Changed reduction targets"];
 gate[Sort[before["masters"]]===Sort[after["masters"]]&&Sort[before["targets"]]===Sort[after["targets"]],"Changed master/target inventory"];
 residuals=(Together[(First[#]/.ar)-factor Last[#]]& /@ br);
 gate[residuals===ConstantArray[0,Length[br]],"Incomplete or incorrect reduction-map mutation"];
 identities=Count[br,Rule[l_,r_]/;l===r];
 AppendTo[records,<|"id"->job["id"],"rules"->Length[br],"identity_rules"->identities,"residuals"->(ToString[#,InputForm]& /@ residuals)|>],
 {job,c["jobs"]}];
Export[c["audit_output"],<|"status"->"PASS","scope"->c["scope"],"factor"->{c["numerator"],c["denominator"]},"jobs"->records|>,"RawJSON"];
Exit[0];
