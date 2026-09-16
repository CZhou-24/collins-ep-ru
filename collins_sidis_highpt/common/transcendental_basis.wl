(* Exact polynomial decomposition in displayed function atoms, including
   literal Re/Im and ArcTanh in the reused UU banks. These atoms remain unchanged
   in native evidence; no real-branch conversion is silently inferred.
   This neither approximates functions nor asserts that all displayed atoms are
   independent. Reconstructing the original expression is checked exactly. *)
ClearAll[HSTranscendentalDecompose];
HSTranscendentalDecompose[value_]:=Module[{atoms,variables,forward,backward,polynomial,rows,result,residual},
 atoms=SortBy[DeleteDuplicates[Cases[value,_Log|_PolyLog|_Zeta|_Re|_Im|_ArcTanh|_otherChargeMoment,Infinity]],ToString[#,InputForm]&];
 If[atoms==={},Return[<|"terms"->{<|"basis"->1,"coefficient"->value|>},"reconstruction_residual"->0,"atoms"->{}|>]];
 variables=Table[Unique["hsTranscendental"],Length[atoms]];
 forward=Thread[atoms->variables];backward=Thread[variables->atoms];
 polynomial=Expand[value/.forward];
 gate["selected function dependence is polynomial",PolynomialQ[polynomial,variables]];
 rows=CoefficientRules[polynomial,variables];
 result=(<|"basis"->(Times@@MapThread[Power,{variables,First[#]}]/.backward),
   "coefficient"->Factor[Last[#]]|>&/@rows);
 residual=Factor[Together[value-Total[(#["basis"]#["coefficient"])&/@result]]];
 gate["exact transcendental basis reconstruction",residual===0];
 <|"terms"->result,"reconstruction_residual"->residual,"atoms"->atoms|>];
