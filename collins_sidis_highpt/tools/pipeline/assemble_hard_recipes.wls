(* Generate actual affine hard recipes before exact scalar-basis transport.
   No evaluated answer or pole cancellation is assumed. The next native step
   evaluates these recipes using the imported master coefficients. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
contextFile=Environment["SIDIS_HARD_RECIPES_CONTEXT"];cfg=Import[contextFile,"RawJSON"];out=cfg["output"];
If[DirectoryQ[out],Print["Need unused hard-linear output"];Exit[1]];CreateDirectory[out,CreateIntermediateDirectories->True];
gate[name_,test_]:=If[!TrueQ[test],Put[<|"failed_check"->name|>,FileNameJoin[{out,"failure.wl"}]];Print["HARD_LINEAR_FAILED ",name];Exit[2]];
helper=FileNameJoin[{root,"collins_sidis_highpt","common","native_linear.wl"}];Get[helper];
Get[FileNameJoin[{root,"collins_support","validators","analytic","native_io.wl"}]];
real=Association@Table[record=Get[file];record["topology"]->record,{file,cfg["real"]}];
virtual=Map[Get,cfg["virtual"]];sub=Get[cfg["subtractions"]];born=Get[cfg["born"]];scheme=Get[cfg["scheme"]];
knownFile[file_,prefix_]:=Module[{record=Get[file],values},values=If[KeyExistsQ[record,"values"],record["values"],record];
 Association[KeyValueMap[If[StringStartsQ[#1,"master/"],#1,prefix<>#1]->#2&,values]]];
known=Join[knownFile[cfg["real_masters"],"master/r02/cut/"],knownFile[cfg["virtual_masters"],"master/r05/virtual/"]];
gate["selected master coefficients contain no unresolved regulator or scale",FreeQ[known,eps|eta|muR|muPDF|muFF]];
gate["derived one-loop quark-line conversion fixed",And@@(#===0&/@Values[scheme["derived_one_loop_finite_conversion"]])];
projectors=<|"Collins_L"->{"11_LL","22_LL"},"Collins_T"->{"11_XX","11_YY","22_XX","22_YY"}|>;
suffix[n_]:=If[n<0,"m"<>ToString[-n],"p"<>ToString[n]];
branchName[sign_]:=If[sign===1,"plus","minus"];
collect[value_,conditions_]:=HSLinearCompact[Refine[value,conditions]];
exact[value_,conditions_]:=Module[{v=collect[value,conditions]},If[v===0,0,TimeConstrained[FullSimplify[v,conditions],120,v]]];
conditions[sign_]:=Q2>0&&s>w>0&&omega>0&&B>0&&muR>0&&muPDF>0&&muFF>0&&SUNN>1&&
 -Q2-s+w<sign omega-s< -Q2 w/s&&Element[Nf,Integers]&&Nf>=1;
projectReal[topology_,component_,charge_,sign_,dist_]:=Module[{bank=real[topology]["recipes"],key,keys},
 key=topology<>"_"<>component<>"_"<>charge<>"_"<>branchName[sign]<>"_"<>dist;
 If[KeyExistsQ[bank,key],Return[bank[key]]];
 keys=(topology<>"_"<>#<>"_"<>charge<>"_"<>branchName[sign]<>"_"<>dist)&/@projectors[component];
 gate["complete real Collins projection",And@@(KeyExistsQ[bank,#]&/@keys)];
 HSLinearScale[1/2,HSLinearAdd[Lookup[bank,keys]]]];
projectVirtual[component_,sign_]:=Module[{bank=virtual[branchName[sign]]["recipes"]},
 HSLinearScale[1/2,HSLinearAdd[Flatten[Table[
  HSLinearScale[eps^power,bank[index<>"_"<>suffix[power]<>"_"<>branchName[sign]]],
  {index,projectors[component]},{power,-2,0}],1]]]];
projectSub[component_,side_,dist_]:=If[dist==="L1",0,
 Total[sub["MS_counterterms"][#][side][dist]&/@projectors[component]]/2];
projectKernel[component_,side_,dist_]:=If[dist==="L1",0,
 (Total[sub["dimensional_convolutions"][#][side][dist]&/@projectors[component]]/2)/.D->4];
projectBorn[component_]:=Factor[PowerExpand[(Total[born["T"<>#]&/@projectors[component]]/2)/.
 {D->4,CF->(SUNN^2-1)/(2SUNN),r->s/Q2,z->(Q2+s+t)/(Q2+s),Q->Sqrt[Q2]}]];
phase=muR^(2eps)(2Pi)^(-2+2eps);beta=(11SUNN-2Nf)/3;
values=<||>;allRecipes=<||>;results=<||>;comparisons=<||>;
directHqq=If[KeyExistsQ[cfg,"compare_hqq"],Get[cfg["compare_hqq"]],None];
Do[Print["LINEAR_HARD ",channel," ",component," ",sign];finite=<||>;poles=<||>;scales=<||>;distRecipes=<||>;
 Do[realRows=If[channel==="Hqq",Table[
    HSLinearScale[real[topology]["tag_weight_unapplied"],HSLinearAdd[KeyValueMap[
     Function[{charge,weight},HSLinearScale[weight,projectReal[topology,component,charge,sign,dist]]],real[topology]["charge_weights"]]]],
    {topology,{"RealQGG","RealSame","RealDistinct"}}],
   {HSLinearScale[real["Hqqbar"]["tag_weight_unapplied"],projectReal["Hqqbar",component,"charge0",sign,dist]]}];
  realRow=HSLinearMap[Function[x,Normal[Series[phase x,{eps,0,0}]]],HSLinearAdd[realRows]];
  virtualRow=If[channel==="Hqq"&&dist==="Delta",HSLinearScale[2Pi,projectVirtual[component,sign]],HSLinearCreate[0,<||>]];
  ct=If[channel==="Hqq",(projectSub[component,"PDF",dist]+projectSub[component,"FF",dist])/.t->sign omega-s,0];
  row=HSLinearAdd[{realRow,virtualRow,HSLinearCreate[ct,<||>]}];
  row=HSLinearMap[Function[x,collect[x,conditions[sign]]],row];AssociateTo[distRecipes,dist->row];
  key=channel<>"_"<>component<>"_"<>branchName[sign]<>"_"<>dist;
  LaurentRows=Association@Table[power->HSLinearMap[Function[x,collect[Coefficient[Expand[x],eps,power],conditions[sign]]],row],{power,-2,0}];
  
  Do[certificateID="r07/"<>key<>"_"<>suffix[power];
   AssociateTo[allRecipes,certificateID->LaurentRows[power]],{power,-2,0}];
  finiteRow=LaurentRows[0];
  scaleRows=Association@Table[expected=Switch[scale,
    muR,If[channel==="Hqq"&&dist==="Delta",-beta projectBorn[component]/(8Pi),0],
    muPDF,If[channel==="Hqq",projectKernel[component,"PDF",dist]/(4Pi),0],
    muFF,If[channel==="Hqq",projectKernel[component,"FF",dist]/(4Pi),0]]/.t->sign omega-s;
   derivative=HSLinearMap[Function[x,collect[(scale/2)D[x,scale],conditions[sign]]],finiteRow];
   scalar=HSLinearAdd[{derivative,HSLinearCreate[expected,<||>]}];
   scaleID="r07/"<>key<>"_scale_"<>SymbolName[scale];
   AssociateTo[allRecipes,scaleID->scalar];
   SymbolName[scale]->scalar,{scale,{muR,muPDF,muFF}}];
  AssociateTo[scales,dist->scaleRows];
  Put[<|"recipe"->row,"Laurent_recipes"->LaurentRows,"scale_recipes"->scaleRows|>,FileNameJoin[{out,key<>".wl"}]],
  {dist,{"Delta","L0","L1","Regular"}}];
 AssociateTo[results,channel<>"_"<>component<>"_"<>ToString[sign]-><|"finite_candidate"->finite,"poles"->poles,
  "scale_residuals"->scales,"recipes"->distRecipes|>],{channel,{"Hqq","Hqqbar"}},{component,Keys[projectors]},{sign,{1,-1}}];
Put[<|"hard"->results,"values"->values,"recipes"->allRecipes,"direct_assembly_comparison_residuals"->comparisons,
 "Born_D4"->AssociationMap[projectBorn,Keys[projectors]],"known_master_ids"->Keys[known],
 "context_sha256"->IntegerString[FileHash[contextFile,"SHA256"],16,64],
 "source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,{helper,$InputFileName}],
 "qualification"->"Actual master-dependent hard, pole and scale recipes. Evaluation and scalar-basis transport are separate producing steps. No cancellation is asserted here."|>,FileNameJoin[{out,"hard-recipes.wl"}]];
Print["MASTER_DEPENDENT_HARD_RECIPES_PRODUCED"];Exit[0];
