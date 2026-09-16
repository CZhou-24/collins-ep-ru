(* UV residue from the actual unreduced polarized rational loop integrands.
   Homogeneous large-loop terms are averaged using exact D-dimensional tensor
   moments. The logarithmic radial integral is the universal massive bubble,
   i Pi^2/epsUV; an auxiliary mass distinguishes its UV pole from scaleless IR.
   No IR-reduced scalar-master coefficient is used to identify the UV pole. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
input=Environment["SIDIS_VIRTUAL_MAP_INPUT"];bornfile=Environment["SIDIS_BORN_INPUT"];out=Environment["SIDIS_VIRTUAL_UV_OUT"];
If[!And@@(StringQ/@{input,bornfile,out})||DirectoryQ[out],Print["Need map, Born and unused output"];Exit[1]];
CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["POLARIZED_UV_FAILED ",name];Exit[2]];
SetAttributes[bounded,HoldFirst];
bounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,900,gate[label<>" time bound",False]],1536*1024^2,gate[label<>" memory bound",False]];
mapping=Get[input];born=Get[bornfile];
helper=FileNameJoin[{root,"collins_sidis_highpt","common","uv_homogeneous.wl"}];Get[helper];
comparisonDir=Environment["SIDIS_UV_COMPARE_PREFIX"];comparisonResiduals=<||>;
Put[<|"input_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,{input,bornfile}],
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],"helper_sha256"->IntegerString[FileHash[helper,"SHA256"],16,64],"memory_bound_bytes"->1536*1024^2|>,FileNameJoin[{out,"inputs.wl"}]];
uvfile=FileNameJoin[{root,"SIDIS","common","s14_result","s14_result.wl"}];universal=Get[uvfile];
gram={{0,Q^2(1+r)/2,Q^2(1+r)z/2},
 {Q^2(1+r)/2,-Q^2,Q^2(r-(1+r)z)/2},
 {Q^2(1+r)z/2,Q^2(r-(1+r)z)/2,0}};
wick[{}]=1;
wick[indices_List]:=wick[indices]=If[OddQ[Length[indices]],0,
 Total[Table[gram[[First[indices],indices[[j]]]]wick[Delete[indices,{{1},{j}}]],{j,2,Length[indices]}]]];
angularAverage[expression_]:=Module[{rational=Together[expression],num,den,rows},
 If[rational===0,Return[0]];num=Numerator[rational];den=Denominator[rational];
 gate["UV denominator is radial",FreeQ[den,loopP|loopQ|loopK]];
 gate["UV numerator polynomial in loop dot products",PolynomialQ[num,{loopP,loopQ,loopK}]];
 rows=CoefficientRules[Expand[num],{loopP,loopQ,loopK}];
 Factor[Total[Map[Function[row,With[{powers=First[row],c=Last[row]},
  If[OddQ[Total[powers]],0,c loop2^(Total[powers]/2)
   wick[Flatten[MapIndexed[ConstantArray[First[#2],#1]&,powers]]]/(2^(Total[powers]/2)Pochhammer[D/2,Total[powers]/2])]]],rows]]/den]];
scaling={loop2->loop2/lam^2,loopP->loopP/lam,loopQ->loopQ/lam,loopK->loopK/lam};
rows=Select[mapping["rows"],!StringContainsQ[#["component"],"_W"]&];evidence=<||>;
Do[Print["POLARIZED_UV ",key];value=rows[key]["value"];
 expansion=bounded[HSUVHomogeneous[value,4],key<>" weighted UV quotient"];
 raw=expansion["rows"];
 gate["no unresolved large-loop expansion",FreeQ[raw,_Series|_SeriesData|_Real|$Aborted|$Failed]];
 If[StringQ[comparisonDir]&&FileExistsQ[FileNameJoin[{comparisonDir,key<>".wl"}]],
  previous=Get[FileNameJoin[{comparisonDir,key<>".wl"}]];
  difference=Map[Factor,Merge[{raw,Map[-#&,previous["homogeneous"]]},Total]];
  AssociateTo[comparisonResiduals,key->difference];Put[comparisonResiduals,FileNameJoin[{out,"generic-series-comparison.wl"}]];
  gate["weighted quotient equals independently executed generic Series prefix",And@@(#===0&/@Values[difference])]];
 averaged=bounded[Map[angularAverage,raw],key<>" angular UV moments"];
 logterm=Lookup[averaged,4,0];coefficient=Factor[loop2^2 logterm];
 gate["logarithmic radial homogeneity",FreeQ[coefficient,loop2|loopP|loopQ|loopK]];
 packet=<|"component"->rows[key]["component"],"diagram"->rows[key]["diagram"],"homogeneous"->raw,
 "angular_averaged"->averaged,"log_coefficient_D"->coefficient,"quotient_checks"->KeyDrop[expansion,"rows"]|>;
 Put[packet,FileNameJoin[{out,key<>".wl"}]];
 AssociateTo[evidence,key->KeyDrop[packet,"homogeneous"]];
 Clear[packet,expansion,raw,averaged,value];ClearSystemCache[],{key,Keys[rows]}];
groups=GroupBy[Values[evidence],#["component"]&];checks=<||>;
fieldUV=Total[KeyValueMap[Function[{field,count},count universal["FieldUVResidues"][field]],universal["FieldBookkeeping"]["Hqq"]["FieldCounts"]]];
couplingUV=universal["FieldBookkeeping"]["Hqq"]["CouplingWeight"]universal["CouplingResidue"];
Do[lower=Merge[KeyDrop[#["angular_averaged"],4]&/@groups[component],Factor[Total[#]]&];
 gate["power UV divergences vanish after angular average and diagram sum",And@@(#===0&/@Values[lower])];
 coefficient=Factor[Total[#["log_coefficient_D"]&/@groups[component]]];
 pre=(I Pi^2/(2Pi)^4)Factor[coefficient/.D->4];
 full=Factor[ComplexExpand[pre+Conjugate[pre]]];
 born4=born["T"<>component]/.{D->4,CF->(SUNN^2-1)/(2SUNN)};
 residual=Factor[full+(fieldUV+couplingUV)born4];
 AssociateTo[checks,component-><|"log_coefficient_D"->coefficient,"pre_Hermitian_UV"->pre,
 "loop_UV"->full,"field_UV"->fieldUV,"coupling_UV"->couplingUV,"Born4"->born4,
 "lower_power_residuals"->lower,"UV_cancellation_residual"->residual|>],{component,Keys[groups]}];
Put[<|"components"->checks,"angular_moment_definition"->HoldComplete[Average[Times@@(ellDot/@vectors)]]==HoldComplete[loop2^(Length[vectors]/2) PairingSum[vectors]/(2^(Length[vectors]/2)Pochhammer[D/2,Length[vectors]/2])],
 "radial_UV_residue"->I Pi^2,"loop_measure_at_D4"->(2Pi)^(-4),
 "radial_definition"->HoldComplete[Integrate[1/(ell^2-M2+I0)^2,{ell,D}]]==HoldComplete[I Pi^(D/2)Gamma[2-D/2](M2)^(D/2-2)],
 "source_sha256"->IntegerString[FileHash[$InputFileName,"SHA256"],16,64],
 "input_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,{input,bornfile,uvfile,helper}],"generic_series_comparison"->comparisonResiduals,
 "qualification"->"Fresh polarized large-loop residues; universal field/coupling constants imported from preserved self-energy derivation; not an IR pole or factorization check"|>,FileNameJoin[{out,"uv.wl"}]];
gate["UV cancellation for every polarized component",And@@(#["UV_cancellation_residual"]===0&/@Values[checks])];
Print["POLARIZED_UV_COMPLETE ",Length[checks]," components"];Exit[0];
