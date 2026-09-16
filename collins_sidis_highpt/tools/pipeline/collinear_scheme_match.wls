(* Bind actual incoming/outgoing production limits to the independent physical
   tagged-operator traces. Determine the finite one-loop conversion without
   replacing the literal all-D reference or fitting an observed hard pole. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
outgoingFile=Environment["SIDIS_OUTGOING_COLLINEAR_INPUT"];
incomingFiles=StringSplit[Environment["SIDIS_INCOMING_COLLINEAR_INPUTS"],":"];
operatorFile=Environment["SIDIS_TAGGED_OPERATOR_INPUT"];virtualFile=Environment["SIDIS_OPERATOR_VIRTUAL_INPUT"];
out=Environment["SIDIS_SCHEME_MATCH_OUT"];files=Join[{outgoingFile,operatorFile,virtualFile},incomingFiles];
If[!StringQ[out]||DirectoryQ[out]||!And@@(StringQ[#]&&FileExistsQ[#]&/@files),Print["Need all collinear and operator evidence and unused output"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["SCHEME_MATCH_FAILED ",name];Exit[2]];
outgoing=Get[outgoingFile];incoming=Get/@incomingFiles;operator=Get[operatorFile];virtual=Get[virtualFile];
required=Sort[{"11_LL","11_XX","11_YY","22_LL","22_XX","22_YY"}];
incomingKeys=Flatten[Keys[#["checks"]]&/@incoming];
gate["incoming components unique and complete",DuplicateFreeQ[incomingKeys]&&Sort[incomingKeys]===required];
gate["outgoing components complete",Sort[Keys[outgoing["checks"]]]===required];
gate["actual outgoing residues",And@@(#["physical_daughter_residual"]===0&/@Values[outgoing["checks"]])];
gate["actual incoming residues",And@@Flatten[(#["operator_match_residual"]===0&/@Values[#["checks"]])&/@incoming]];
stronger=Flatten[Table[Values[KeyDrop[row["summed_poles"],"-2"]],{bank,incoming},{row,Values[bank["checks"]]}]];
gate["stronger initial-state powers are zero",And@@(#===0&/@stronger)];
cf=(SUNN^2-1)/(2SUNN);kernel=outgoing["physical_daughter_kernel"];literal=outgoing["literal_reference_real_kernel"];
incomingDifferences=Factor[(#["operator_kernel"]/.xc->zc)-kernel]&/@incoming;
tagDifference=Factor[(operator["BMHV"]/.{CF->cf,z->zc})-kernel];
gate["production and independent tagged operator kernels match",tagDifference===0&&And@@(#===0&/@incomingDifferences)];
gate["physical tagged real BMHV and NDR agree",operator["BMHV_minus_NDR"]===0];
virtualDifferences=virtual["azimuth_averaged_differences"];
gate["virtual operator numerators agree under common transverse integration",And@@(#===0&/@Values[virtualDifferences])];
deltaVirtual=Factor[Total[Values[virtualDifferences]](pole2/eps^2+pole1/eps+finiteScalar)/virtual["traces"]["BMHV"]["Born"]];
difference=Factor[kernel-literal];epsDifference=Factor[difference/.D->4-2eps];
softRational=Together[difference/.zc->1-soft];
softValuation=Exponent[Numerator[softRational],soft,Min]-Exponent[Denominator[softRational],soft,Min];
gate["reference difference has no extra soft endpoint pole",softValuation>=0];
radial=Integrate[v^(-1-eps),{v,0,B},Assumptions->B>0&&eps<0,GenerateConditions->False];
finiteRegular=FullSimplify[SeriesCoefficient[radial epsDifference Exp[eps measureLog],{eps,0,0}],B>0&&0<zc<1];
softResidue=Factor[Limit[(1-zc)epsDifference,zc->1,Direction->"FromBelow"]];
deltaReal=FullSimplify[SeriesCoefficient[
 radial (cf eps^2/(1-eps))Beta[1-eps,2-eps],{eps,0,0}],B>0];
finiteConversion=<|"Delta"->Factor[deltaVirtual+deltaReal],"Plus0"->softResidue,"Regular"->finiteRegular|>;
Put[<|"incoming_component_keys"->incomingKeys,"outgoing_component_keys"->Keys[outgoing["checks"]],
 "incoming_kernel_residuals"->incomingDifferences,"tagged_operator_residual"->tagDifference,
 "incoming_stronger_pole_residuals"->stronger,"virtual_averaged_numerator_residuals"->virtualDifferences,
 "literal_all_D_difference"->difference,"literal_all_D_status"->If[difference===0,"EXACT","MISMATCH"],
 "epsilon_difference"->epsDifference,"soft_endpoint_valuation"->softValuation,
 "unresolved_virtuality_integral"->radial,"finite_regular_pole_product"->finiteRegular,
 "virtual_endpoint_difference_with_arbitrary_scalar_poles"->deltaVirtual,
 "finite_real_endpoint_test_action"->deltaReal,"derived_one_loop_finite_conversion"->finiteConversion,
 "distribution_argument"->"The actual squared-amplitude limits have a single unresolved-virtuality pole. The remaining reference difference is O(eps^2)(1-z); its z endpoint is integrable with the D-dimensional factor [z(1-z)]^(-eps). With physical positive lower convolution bounds, the action on any bounded smooth test function is O(eps). Thus it generates neither a finite regular term nor a delta/plus term. A generic double pole times this difference is not set to zero; its absence for this difference follows from its soft valuation.",
 "virtual_argument"->"Quark vertex and both Wilson attachments have equal BMHV/NDR numerators after the common D-2 transverse average, with scalar denominators depending on l2,lp,ln. Self energies and soft Wilson graphs are spin independent and multiply the equal Born trace. Equality holds before UV/IR regulator identification under a common azimuth-invariant regulator.",
 "renormalized_operator_definition"->"Physical transverse quark operator GammaT=slash(n) gamma5 slash(S), with identical Born normalization and MSbar pole subtraction on both sides; crossed fragmentation quark operator uses the same Dirac projection. Production remains BMHV.",
 "input_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,files],
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "qualification"->"One-loop collinear quark-line operator conversion under the stated angular and subtraction definitions. This does not supply missing finite hard coefficients or certify complete jet/TMD observable assembly. The original evanescent-observed-daughter diagnostic and literal all-D mismatch remain unchanged."|>,FileNameJoin[{out,"scheme.wl"}]];
gate["finite conversion coefficients evaluated",FreeQ[finiteConversion,eps|_Series|_SeriesData|_Limit|_Integrate|Indeterminate|ComplexInfinity]];
Print["COLLINEAR_SCHEME_MATCH_COMPLETE ",InputForm[finiteConversion]];Exit[0];
