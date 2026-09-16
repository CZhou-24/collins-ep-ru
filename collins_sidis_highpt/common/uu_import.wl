(* Reuse the six accepted inclusive UU banks. No polarized expression enters
   this import. Source notation is retained beside each explicit conversion. *)
ClearAll[HSImportUUChannel];
HSImportUUChannel[channel_String,file_String]:=Module[
 {bank,hats,bornQ,normalization,colorRules,convertOrder,projection,lo,nlo,
  reconstruction=<||>,finiteCheck,branches,distributions,canonical,raw},
 bank=Get[file];hats=bank["Fhats"];
 If[bank["Channel"]=!=channel||!TrueQ[bank["Accepted"]],Return[Failure["UnacceptedUUInput",<|"file"->file|>]]];
 bornQ=AssociationQ[hats["F1"]];
 normalization=(2Pi)^4;
 colorRules={FeynCalc`SUNN->Nc,FeynCalc`Nf->Nf};
 convertOrder[value_,order_]:=Module[{coefficient,residual},
  coefficient=(value/.colorRules)/.alphaS->2Pi;
  residual=Expand[(value/.colorRules)-coefficient(alphaS/(2Pi))^order];
  AssociateTo[reconstruction,ToString[Length[reconstruction]+1]->residual];
  normalization coefficient];
 projection[f1_,f2_]:=HSUUPhotonFromFhats[f1,f2,Q2/(Q2+s)];
 distributions={"Delta","L0","L1","Regular"};
 If[bornQ,
  lo=projection[convertOrder[hats["F1"]["LODelta"],1],convertOrder[hats["F2"]["LODelta"],1]];
  branches=Keys[hats["F1"]["NLO"]];
  nlo=Association@Table[sign->Association@Table[dist->projection[
    convertOrder[hats["F1"]["NLO"][sign][dist],2],
    convertOrder[hats["F2"]["NLO"][sign][dist],2]],{dist,distributions}],{sign,branches}],
  lo=Missing["NoBornHardChannel"];
  nlo=<|"ordinary"->Join[Association@Table[dist->projection[
    convertOrder[bank[dist]["F1"],2],convertOrder[bank[dist]["F2"],2]],{dist,Most[distributions]}],
    <|"Regular"->projection[convertOrder[hats["F1"],2],convertOrder[hats["F2"],2]]|>]|>];
 finiteCheck=FreeQ[{lo,nlo},eps|eta|_Series|_SeriesData|_Integrate|_Limit|_Real|Indeterminate|ComplexInfinity];
 <|"channel"->channel,"source"->file,"source_sha256"->IntegerString[FileHash[file,"SHA256"],16,64],
   "LO"->lo,"NLO"->nlo,"coupling_reconstruction_residuals"->reconstruction,
   "finite_exact_expression"->finiteCheck,"original_Fhats"->hats,
   "normalization_conversion"->"a=alpha_s/(2Pi). Multiply saved Fhats by (2Pi)^4 to undo their hardNormalization; no charge factors removed. L=F2/(2*xhat)-F1, T=2*F1, xhat=Q2/(Q2+s).",
   "symbol_conversion"->HoldComplete[FeynCalc`SUNN->Nc,FeynCalc`Nf->Nf],
   "scale_convention"->"Keep source mu and mu2 symbols literal; an eventual common scale sets mu=muCommon and mu2=muCommon^2 explicitly.",
   "distribution_convention"->If[bornQ,bank["PlusDefinition"],"Delta,L0,L1 are the saved exact zeros; ordinary finite remainder retained"],
   "branch_convention"->If[bornQ,bank["BranchConvention"],"Ordinary expression at physical s,t,w; no imposed artificial branch"],
   "source_physical_conditions"->bank["PhysicalConditions"],
   "qualification"->"Reused saved inclusive UU coefficients. This conversion does not rerun or recertify their original derivation or historical comparisons; Hgq MadGraph qualification remains."|>];
