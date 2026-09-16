(* Exact affine certificates. Coefficients are generated from the producing
   equations, never inferred by dividing a result by an imported master.
   Evaluation always uses the supplied evaluated master association, including
   during dependency probes. A vanishing evaluated result retains its recipe. *)
ClearAll[HSLinearCreate,HSLinearAdd,HSLinearScale,HSLinearMap,HSLinearEvaluate,
 HSLinearCertificate,HSLinearCompact];
HSLinearCreate[constant_,terms_Association]:=<|"constant"->constant,"terms"->terms|>;
HSLinearAdd[rows_List]:=HSLinearCreate[Total[Lookup[rows,"constant"]],
 Merge[Lookup[rows,"terms"],Total]];
HSLinearScale[factor_,row_Association]:=HSLinearCreate[factor row["constant"],
 Map[factor #&,row["terms"]]];
HSLinearMap[operation_,row_Association]:=HSLinearCreate[operation[row["constant"]],
 Map[operation,row["terms"]]];
HSLinearEvaluate[row_Association,known_Association]:=row["constant"]+
 Total[KeyValueMap[Function[{key,factor},
  If[!KeyExistsQ[known,key],Print["MISSING_LINEAR_INPUT ",key];Abort[]];factor known[key]],row["terms"]]];
HSLinearCompact[value_]:=Module[{atoms},
 atoms=DeleteDuplicates[Cases[value,_Log|_PolyLog|_Zeta,Infinity]];
 Collect[Expand[value],atoms,Factor]];
HSLinearCertificate[row_Association,known_Association,sectors_List,epsOrder_Integer:0]:=Module[{terms,value},
 terms=Select[row["terms"],#=!=0&];
 value=HSLinearCompact[HSLinearEvaluate[HSLinearCreate[row["constant"],terms],known]];
 <|"constant"->RUExact[row["constant"]],
  "terms"->KeyValueMap[<|"ref"->#1,"factor"->RUExact[#2]|>&,terms],
  "value"->RUExact[value],"eta_order"->0,"eps_order"->epsOrder,"sectors"->sectors|>];
