(* Test the new flavor routes against the preserved independently generated
   inclusive flavor contract, with independent symbolic PDF/FF components.
   Electric charges are test inputs; no PDF, FF or Collins fit is introduced. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];engine=FileNameJoin[{root,"collins_sidis_highpt"}];
out=Environment["SIDIS_FLAVOR_CHECK_OUT"];If[!StringQ[out]||DirectoryQ[out],Exit[1]];CreateDirectory[out,CreateIntermediateDirectories->True];
helper=FileNameJoin[{engine,"common","observable_flavors.wl"}];Get[helper];
assemblyHelper=FileNameJoin[{engine,"common","observable_assembly.wl"}];Get[assemblyHelper];
referenceFile=FileNameJoin[{root,"SIDIS","numerics","s08_result"}];reference=Import[referenceFile,"RawJSON"];
flavors=reference["flavor_order"];checks=<||>;rows=<||>;
index["g"]:=First[FirstPosition[flavors,"g"]]-1;
speciesNames={"u","d","s","c","b"};
index[{species_Integer,sign_Integer}]:=First[FirstPosition[flavors,speciesNames[[species]]<>If[sign===-1,"bar",""]]]-1;
pdf[flavor_]:=Symbol["f"<>ToString[index[flavor]]];ff[flavor_]:=Symbol["d"<>ToString[index[flavor]]];
Clear[quarkCharge];Do[quarkCharge[k]=ToExpression[reference["model_charges"][speciesNames[[k]]]],{k,Length[speciesNames]}];
(* Wolfram parses the saved SymPy luminosities after the explicit power-token
   conversion. Inputs contain only pre-reviewed sums/products and symbols. *)
parse[x_String]:=ToExpression[StringReplace[x,"**"->"^"]];
Do[ref=reference["luminosities"][ToString[nf]];
 Do[route=First[HSUUFlavorRoutes[channel]];{incoming,outgoing,weight}=route;
  charge=Switch[channel,"Hgg",chargeSum,"Hqqbar",eq2,_,eq^2];
  (* Keep flavor evaluation inside the activated sum, where its indices are integers. *)
  expression=HSFlavorSum[channel,weight(charge/.HSFlavorRules[channel,incoming,outgoing,nf])
    hsPDF[incoming]hsFF[outgoing],nf];
  value=Activate[expression]/.{hsPDF[f_]:>pdf[f],hsFF[f_]:>ff[f]};
  residual=Expand[value-parse[ref["expressions"][channel]]];
  AssociateTo[checks,channel<>"_nf"<>ToString[nf]->residual];AssociateTo[rows,channel<>"_nf"<>ToString[nf]->value],
  {channel,{"Hgg","Hgq","Hqg","Hqqbar"}}];
 Do[route=First[HSUUFlavorRoutes["Hqqprime"]];{incoming,outgoing,weight}=route;
  monomial=Switch[label,"IncomingChargeSquared",eq^2,"PrimeChargeSquared",eqp^2,"MixedIncomingPrimeCharge",eq eqp];
  expression=HSFlavorSum["Hqqprime",weight(monomial/.HSFlavorRules["Hqqprime",incoming,outgoing,nf])hsPDF[incoming]hsFF[outgoing],nf];
  value=Activate[expression]/.{hsPDF[f_]:>pdf[f],hsFF[f_]:>ff[f]};
  residual=Expand[value-parse[ref["expressions"]["Hqqprime_"<>label]]];
  AssociateTo[checks,"Hqqprime_"<>label<>"_nf"<>ToString[nf]->residual],
  {label,{"IncomingChargeSquared","PrimeChargeSquared","MixedIncomingPrimeCharge"}}];
 (* Hqq grouped luminosities retain the same flavor on both sides. Compare
    their charge-squared Born sum and every other-flavor charge-square moment. *)
 route=First[HSUUFlavorRoutes["Hqq"]];{incoming,outgoing,weight}=route;
 expression=HSFlavorSum["Hqq",(eq^2/.HSFlavorRules["Hqq",incoming,outgoing,nf])hsPDF[incoming]hsFF[outgoing],nf];
 value=Activate[expression]/.{hsPDF[f_]:>pdf[f],hsFF[f_]:>ff[f]};
 expected=Total[parse[#["charge"]]^2 parse[#["expression"]]&/@ref["hqq_charge_groups"]];
 AssociateTo[checks,"Hqq_nf"<>ToString[nf]->Expand[value-expected]];
 Do[group=SelectFirst[ref["hqq_charge_groups"],parse[#["charge"]]===quarkCharge[species]&];
  residual=Expand[Activate[HSOtherChargeMoment[species,2,nf]]-parse[group["other_moment2"]]];
  AssociateTo[checks,"Hqq_moment_nf"<>ToString[nf]<>"_species"<>ToString[species]->residual],{species,nf}],{nf,{4,5}}];
Put[<|"residuals"->checks,"generated_luminosities"->rows,"source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,{helper,assemblyHelper,referenceFile,$InputFileName}],
 "qualification"->"Exact flavor/charge contraction checks against archived inclusive bookkeeping; does not validate a hard coefficient or supply nonperturbative functions"|>,FileNameJoin[{out,"flavor.wl"}]];
Print["FLAVOR_CONTRACT_CHECKS ",Length[checks],"; nonzero keys ",Keys[Select[checks,#=!=0&]]];
Exit[If[And@@(#===0&/@Values[checks]),0,2]];
