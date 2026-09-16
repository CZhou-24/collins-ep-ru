(* Exact scalar transport in a displayed function basis. The imported objects
   are coefficients of archived master functions, never coefficients of a hard
   answer. Basis expressions and reconstructions remain native evidence. *)
ClearAll[HSBasisRebind,HSBasisSplit,HSBasisCertificates,HSBasisKnown,HSBasisOriginal];
HSBasisKnown[bank_Association,prefix_String]:=Association[
 KeyValueMap[(prefix<>#1)->#2&,bank["values"]]];
HSBasisOriginal[bank_Association,evaluated_Association]:=Association[
 KeyValueMap[Function[{old,expansion},old->Total[KeyValueMap[
  Function[{id,basis},gate["evaluated master coefficient exists",KeyExistsQ[evaluated,id]];
   basis evaluated[id]],expansion]]],bank["expansions"]]];
HSBasisRebind[row_Association,bank_Association,prefix_String]:=Module[{terms={}},
 KeyValueMap[Function[{ref,factor},If[factor=!=0,
  gate["master coefficient view exists",KeyExistsQ[bank["expansions"],StringDrop[ref,StringLength[prefix]]]];
  AppendTo[terms,Association[KeyValueMap[(prefix<>#1)->factor #2&,
   bank["expansions"][StringDrop[ref,StringLength[prefix]]]]]]]],row["terms"]];
 HSLinearCreate[row["constant"],If[terms==={},<||>,Merge[terms,Total]]]];
HSBasisSplit[row_Association]:=Module[{pieces,bases,rows},
 pieces=Map[HSTranscendentalDecompose,Join[<|"constant"->row["constant"]|>,row["terms"]]];
 bases=SortBy[DeleteDuplicates[Flatten[(Lookup[#["terms"],"basis"]&/@Values[pieces])]],ToString[#,InputForm]&];
 coefficient[key_,basis_]:=Total[#["coefficient"]&/@Select[pieces[key]["terms"],#["basis"]===basis&]];
 rows=Table[<|"basis"->basis,"recipe"->HSLinearCreate[coefficient["constant",basis],
   Select[AssociationMap[coefficient[#,basis]&,Keys[row["terms"]]],#=!=0&]]|>,{basis,bases}];
 <|"pieces"->rows,"individual_reconstruction_residuals"->Map[#["reconstruction_residual"]&,pieces]|>];
HSBasisCertificates[key_String,row_Association,known_Association,sectors_List,nominalKnown_:Automatic]:=Module[
 {nominal=If[nominalKnown===Automatic,known,nominalKnown],denominators,commonDen,products,
  decomposition,values=<||>,basis=<||>,recipes=<||>,scalarValues=<||>,normalizations=<||>,
  id,index=0,scalar,value,originalScalar,normalizedTerms,localKnown,localNominal,den,refID,refIndex,colorVariables,colorPieces,colorPowers,colorRows,colorID,colorIndex,colorMonomial,colorRow,
  colorRules,colorCoefficient,colorReconstruction,polynomialProofs=<||>,polynomialResiduals},
 decomposition=HSBasisSplit[row];
 Do[index++;id=key<>"_b"<>IntegerString[index,10,3];scalar=piece["recipe"];originalScalar=scalar;normalizedTerms=<||>;localKnown=<||>;localNominal=<||>;refIndex=0;
  KeyValueMap[Function[{ref,factor},refIndex++;refID=First[StringSplit[key,"/"]]<>"/normalized_"<>StringRiffle[sectors,"_"]<>"_"<>StringReplace[ref,"/"->"_"];
   den=Factor[Denominator[Cancel[nominal[ref]]]];
   AssociateTo[localKnown,refID->Factor[den known[ref]]];AssociateTo[localNominal,refID->Factor[den nominal[ref]]];
   AssociateTo[values,refID-><|"constant"->RUExact[0],"terms"->{<|"ref"->ref,"factor"->RUExact[den]|>},
    "value"->RUExact[localKnown[refID]],"eta_order"->0,"eps_order"->0,"sectors"->sectors|>];
   AssociateTo[recipes,refID->HSLinearCreate[0,<|ref->den|>]];
   AssociateTo[normalizedTerms,refID->Factor[factor/den]];
   AssociateTo[normalizations,refID-><|"master"->ref,"denominator"->den,"nominal_numerator"->localNominal[refID]|>]],scalar["terms"]];
  scalar=HSLinearCreate[scalar["constant"],normalizedTerms];
  (* Clear a common kinematic denominator using the unmutated archived master
     coefficients. This is an explicit change of scalar basis: the denominator
     stays in the displayed reconstruction basis. Probe values cannot choose it. *)
  products=Join[{scalar["constant"]},KeyValueMap[#2 localNominal[#1]&,scalar["terms"]]];
  denominators=Factor[Denominator[Cancel[#]]]&/@products;
  commonDen=Factor[Fold[PolynomialLCM,1,denominators]];
  scalar=HSLinearMap[Function[x,Expand[Factor[commonDen x]]],scalar];
  (* Color, charge and eligible Q2/w powers form a polynomial basis because
     the normalized archived master numerators are proved independent of every
     selected variable. Choices use nominal inputs and never probe values. *)
  colorVariables=Select[{SUNN,Nc,Nf,CF,CA,TF,eq,eqPrime,Q2,w},Function[variable,
    !FreeQ[scalar,variable]&&FreeQ[localNominal,variable]&&
     And@@(PolynomialQ[#,variable]&/@Join[{scalar["constant"]},Values[scalar["terms"]]])]];
  gate["master numerators independent of selected polynomial variables",And@@(FreeQ[localNominal,#]&/@colorVariables)];
  If[colorVariables==={},colorRows={<|"monomial"->1,"recipe"->scalar|>},
   colorPieces=Join[<|"constant"->scalar["constant"]|>,scalar["terms"]];
   gate["cleared coefficients polynomial in selected polynomial variables",And@@(PolynomialQ[#,colorVariables]&/@Values[colorPieces])];
   colorRules=Map[CoefficientRules[#,colorVariables]&,colorPieces];
   colorPowers=Sort[DeleteDuplicates[Flatten[(First/@#)&/@Values[colorRules],1]]];
   If[colorPowers==={},colorPowers={ConstantArray[0,Length[colorVariables]]}];
   colorCoefficient[k_,powers_]:=Total[Last/@Select[colorRules[k],First[#]===powers&]];
   colorRows=Table[<|"monomial"->Times@@MapThread[Power,{colorVariables,powers}],
    "recipe"->HSLinearCreate[colorCoefficient["constant",powers],
      Select[AssociationMap[colorCoefficient[#,powers]&,Keys[scalar["terms"]]],#=!=0&]]|>,{powers,colorPowers}];
   colorReconstruction=HSLinearAdd[HSLinearScale[#["monomial"],#["recipe"]]&/@colorRows];
   polynomialResiduals=Join[<|"constant"->Factor[scalar["constant"]-colorReconstruction["constant"]]|>,
    AssociationMap[Factor[scalar["terms"][#]-Lookup[colorReconstruction["terms"],#,0]]&,Keys[scalar["terms"]]]];
   AssociateTo[polynomialProofs,id-><|"variables"->colorVariables,"nominal_master_independence"->And@@(FreeQ[localNominal,#]&/@colorVariables),
    "residuals"->polynomialResiduals|>];
   gate["polynomial reconstruction",And@@(#===0&/@Values[polynomialResiduals])]];
  colorIndex=0;
  Do[colorIndex++;colorID=id<>"_c"<>IntegerString[colorIndex,10,3];colorRow=colorPiece["recipe"];
   value=Expand[Total[Join[{colorRow["constant"]},KeyValueMap[Factor[#2 localKnown[#1]]&,colorRow["terms"]]]]];
   AssociateTo[values,colorID-><|"constant"->RUExact[colorRow["constant"]],
    "terms"->KeyValueMap[<|"ref"->#1,"factor"->RUExact[#2]|>&,colorRow["terms"]],
    "value"->RUExact[value],"eta_order"->0,"eps_order"->0,"sectors"->sectors|>];
   AssociateTo[basis,colorID->piece["basis"]colorPiece["monomial"]/commonDen];
   AssociateTo[recipes,colorID->colorRow];AssociateTo[scalarValues,colorID->value],{colorPiece,colorRows}],
 {piece,decomposition["pieces"]}];
 <|"values"->values,"basis"->basis,"recipes"->recipes,
  "scalar_values"->scalarValues,"master_numerator_normalizations"->normalizations,
  "reconstruction_residuals"-><|"function_coefficients"->decomposition["individual_reconstruction_residuals"],"polynomial_coefficients"->polynomialProofs|>|>];
