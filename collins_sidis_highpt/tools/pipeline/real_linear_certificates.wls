(* Native linear dependence on individually selected archived cut-master
   coefficients. The factors come from fresh reductions and the regulated
   distribution identity; no answer/master ratio is used. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
input=Environment["SIDIS_REAL_REDUCTION"];portableFile=Environment["SIDIS_REAL_PORTABLE_INPUT"];
directFile=Environment["SIDIS_REAL_DISTRIBUTIONS_INPUT"];out=Environment["SIDIS_REAL_LINEAR_OUT"];
evaluatedFile=Environment["SIDIS_EVALUATED_REAL_MASTERS"];
compareDirect=StringQ[directFile]&&StringLength[directFile]>0;
files=Join[{input,portableFile},If[compareDirect,{directFile},{}],If[StringQ[evaluatedFile]&&StringLength[evaluatedFile]>0,{evaluatedFile},{}]];
If[!StringQ[out]||DirectoryQ[out]||!And@@(StringQ[#]&&FileExistsQ[#]&/@files),Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,condition_]:=If[!TrueQ[condition],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["REAL_LINEAR_FAILED ",name];Exit[2]];
helpers=FileNameJoin[{root,"collins_sidis_highpt","common",#}]&/@{"rational_laurent.wl","native_linear.wl","transcendental_basis.wl","native_compact_basis_linear.wl"};Get/@helpers;
Get[FileNameJoin[{root,"collins_support","validators","analytic","native_io.wl"}]];
fresh=Get[input];portable=Get[portableFile];If[compareDirect,direct=Get[directFile]];
basisFile=Environment["SIDIS_MASTER_BASIS_INPUT"];useBasis=StringQ[basisFile]&&StringLength[basisFile]>0;
If[useBasis,basisBank=Get[basisFile]];basisRecords=<||>;
evaluated=If[StringQ[evaluatedFile]&&StringLength[evaluatedFile]>0,Get[evaluatedFile],portable["values"]];
If[useBasis,
 basisKnown=Association[KeyValueMap[("master/r02/cut/"<>#1)->#2&,evaluated]];
 reconstructed=HSBasisOriginal[basisBank,evaluated];
 (* Unselected saved entries occur only with identically zero weights. Every
    nonzero recipe factor is required to rebind to an imported basis selector. *)
 evaluated=Join[portable["values"],reconstructed]];
known=Association[KeyValueMap[("master/r02/cut/"<>#1)->#2&,evaluated]];
suffix[power_]:=If[power<0,"m"<>ToString[-power],"p"<>ToString[power]];
valuation[value_,variable_]:=With[{v=Together[value]},Exponent[Numerator[v],variable,Min]-Exponent[Denominator[v],variable,Min]];
reduce[value_,assumptions_]:=Module[{v=Refine[value,assumptions],atoms},
 atoms=DeleteDuplicates[Cases[v,_Log|_PolyLog,Infinity]];Collect[Expand[v],atoms,Factor]];
(* Produce a polynomial recipe through the specified final order. The quotient
   and analytic kernel expansions are separate, so their depth is explicit. *)
productRecipe[coefficient_,metadata_,kernel_,last_Integer]:=Module[
 {firstC,firstM,firstK,available,division,terms,coefficientSeries},
 If[coefficient===0,Return[HSLinearCreate[0,<||>]]];
 firstC=valuation[coefficient,eps];firstM=metadata["minimum_power"];available=metadata["available_through"];
 firstK=If[kernel===1,0,Exponent[Normal[Series[kernel,{eps,0,2}]],eps,Min]];
 gate["selected master depth covers the pole product",firstC+available+firstK>=last];
 division=HSRationalLaurent[coefficient,eps,last-firstM-firstK];
 AssociateTo[depthEvidence,ToString[Length[depthEvidence]+1]-><|
  "coefficient_valuation"->firstC,"master_minimum_power"->firstM,
  "kernel_valuation"->firstK,"final_power_required"->last,
  "master_required_through"->(last-firstC-firstK),"master_available_through"->available,
  "master_coefficient_selectors"->metadata["coefficient_ids"],
  "wolfram_coefficient_expression_sha256"->IntegerString[Hash[coefficient,"SHA256"],16,64],
  "rational_prefix_last_power"->(last-firstM-firstK),
  "rational_quotient_reconstruction_residuals"->division["checks"]|>];
 coefficientSeries=Total[KeyValueMap[(eps^#1 #2)&,division["coefficients"]]];
 terms=Association[KeyValueMap[Function[{power,key},
  "master/r02/cut/"<>key->Normal[Series[eps^ToExpression[power]coefficientSeries kernel,{eps,0,last}]]],metadata["coefficient_ids"]]];
 HSLinearCreate[0,terms]];
recipes=<||>;residuals=<||>;certificates=<||>;depthEvidence=<||>;
Do[Print["REAL_LINEAR_COMPONENT ",component];
 coefficients=Select[fresh["master_coefficients"][component],#=!=0&];
 Do[Print["REAL_LINEAR_BRANCH ",sign];
  assumptions=Q2>0&&s>w>0&&omega>0&&B>0&&SUNN>1&&-Q2-s+w<sign omega-s< -Q2 w/s;
  ordinaryRows={};softDelta={};softL0={};softL1={};softOrdinary={};
  KeyValueMap[Function[{master,coefficient},
   id=master[[1]]<>"_"<>StringRiffle[ToString/@master[[2]],"_"];
   view=id<>"_ordinary_"<>If[sign===1,"plus","minus"];
   gate["explicit branch selection exists",KeyExistsQ[portable["branch_views"],view]];
   AppendTo[ordinaryRows,productRecipe[coefficient/.{D->4-2eps,t->sign omega-s},portable["branch_views"][view],1,0]];
   pieces=Select[portable["endpoint_definitions"],#["master"]===master&&#["branch"]===sign&];
   KeyValueMap[Function[{pieceID,piece},
    power=piece["power"];integerPower=power/.eps->0;kappa=-Coefficient[power,eps];
    rational=Cancel[coefficient/.t->sign omega-s];v=valuation[rational,w];
    If[v+integerPower<0,
     gate["only logarithmic endpoint distributions needed",v+integerPower===-1&&TrueQ[kappa>0]];
     leading=Factor[Cancel[w^(-v)rational]/.w->0]/.D->4-2eps;
     metadata=portable["series"][pieceID];
     AppendTo[softDelta,productRecipe[leading,metadata,-B^(-kappa eps)/(kappa eps),0]];
     AppendTo[softL0,productRecipe[leading,metadata,B^(-kappa eps),0]];
     AppendTo[softL1,productRecipe[leading,metadata,-kappa eps B^(-kappa eps),0]];
     AppendTo[softOrdinary,productRecipe[leading,metadata,w^(-1-kappa eps),0]]]],pieces]],coefficients];
  empty=HSLinearCreate[0,<||>];sum[rows_]:=If[rows==={},empty,HSLinearAdd[rows]];
  distributions=<|"Delta"->sum[softDelta],"L0"->sum[softL0],"L1"->sum[softL1],
   "Regular"->HSLinearAdd[{sum[ordinaryRows],HSLinearScale[-1,sum[softOrdinary]]}]|>;
  Do[row=HSLinearMap[Function[x,reduce[x,assumptions]],distributions[dist]];
   actual=reduce[HSLinearEvaluate[row,known],assumptions];
   If[compareDirect,expected=direct["components"][component]["branches"][sign][dist];
    residual=reduce[actual-expected,assumptions];rawResidual=residual;
    If[residual=!=0,residual=TimeConstrained[FullSimplify[residual,assumptions],120,residual]],
    residual=Missing["DirectComparisonNotRequested"];rawResidual=residual];
   key=component<>"_"<>If[sign===1,"plus","minus"]<>"_"<>dist;
   AssociateTo[recipes,key->row];AssociateTo[residuals,key->residual];
   Put[<|"recipe"->row,"value"->actual,"raw_comparison_residual"->rawResidual,"comparison_residual"->residual|>,FileNameJoin[{out,key<>".wl"}]];
   powers=Union[Flatten[Table[If[factor===0,{},Range[Exponent[Expand[factor],eps,Min],Exponent[Expand[factor],eps]]],{factor,Values[row["terms"]]}]],{0}];
   Do[scalar=HSLinearMap[Function[x,reduce[Coefficient[Expand[x],eps,n],assumptions]],row];
    certificateID="r03/"<>key<>"_"<>suffix[n];sectors={If[fresh["topology"]==="Hqqbar","Hqqbar","Hqq"]};
    If[useBasis,
     split=HSBasisCertificates[certificateID,HSBasisRebind[scalar,basisBank,"master/r02/cut/"],basisKnown,sectors,HSBasisKnown[basisBank,"master/r02/cut/"]];
     certificates=Join[certificates,split["values"]];AssociateTo[basisRecords,certificateID->KeyDrop[split,"values"]],
     AssociateTo[certificates,certificateID->HSLinearCertificate[scalar,known,sectors]]],{n,powers}],
   {dist,{"Delta","L0","L1","Regular"}}],{sign,{1,-1}}],{component,Keys[fresh["master_coefficients"]]}];
Put[<|"topology"->fresh["topology"],"recipes"->recipes,"values"->certificates,"comparison_residuals"->residuals,
 "basis_records"->basisRecords,"regulator_depth_evidence"->depthEvidence,"tag_weight_unapplied"->fresh["tag_weight_unapplied"],"charge_weights"->fresh["charge_weights"],
 "source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,Join[files,helpers,{$InputFileName},If[useBasis,{basisFile},{}]]],
 "qualification"->"Exact linear regulated distribution recipes; comparison to the direct native region assembly. Archived master coefficient selections reused, not integrated anew."|>,FileNameJoin[{out,"certificates.wl"}]];
If[compareDirect,gate["linear recipes equal direct distributions",And@@(#===0&/@Values[residuals])]];
Print["REAL_LINEAR_CERTIFICATES_COMPLETE ",Length[certificates]];Exit[0];
