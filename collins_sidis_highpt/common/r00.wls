(* Fresh saved-amplitude contractions; independent references are not loaded. *)
$HistoryLength=0;
ctx=Import[Environment["SIDIS_HIGHPT_CONTEXT"],"RawJSON"];
engine=ctx["production"];out=ctx["output"];rt=ctx["runtime"];
Get[FileNameJoin[{DirectoryName[engine],"collins_support","validators","analytic","native_io.wl"}]];
Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};Global`$FeynCalcStartupMessages=False;
Global`$FeynCalcDirectory=rt["feyncalc_root"];FeynCalc`$FeynArtsDirectory=rt["feynarts_root"];
Get[FileNameJoin[{rt["feyncalc_root"],"FeynCalc.m"}]];
FeynCalc`FCSetDiracGammaScheme["BMHV"];
Get[FileNameJoin[{engine,"common","spin_core.wl"}]];
HSBornKinematics[];
bank=Get[ctx["saved_inputs"]["Hqq_amplitudes"]["resolved"]];
oldBorn=Get[ctx["saved_inputs"]["Hqq_born_normalization"]["resolved"]];
$HSChargeSquared=oldBorn["ModelChargeSquared"];
amp=Total[bank["Born"]]/.{SMP["e"]->1,SMP["g_s"]->1};
Put[<|"amplitude"->amp,"charge_vertex"->bank["ChargeVertex"],
 "model_charge_squared"->$HSChargeSquared,"initial_average"->oldBorn["InitialAverages"]["Hqq"],
 "origin"->"Reused hash-bound saved amplitudes; contractions below freshly executed"|>,FileNameJoin[{out,"amplitudes.wl"}]];
Put[<|"vectors"->$HSVectors,"assumptions"->HoldComplete[Q>0&&r>0&&0<z<1&&h>0&&h^2==r z(1-z)],
 "gamma_scheme"->FCGetDiracGammaScheme[],"external_evanescent_components"->0,
 "dimension"->D,"initial_average"->1/(2SUNN)|>,FileNameJoin[{out,"definitions.wl"}]];
all=<||>;physical=<||>;residuals=<||>;vals=<||>;
putval[key_,value_,sectors_:{"Hqq"}]:=AssociateTo[vals,"r00/"<>key-><|"constant"->RUExact[value],"terms"->{},
 "value"->RUExact[value],"eta_order"->0,"eps_order"->0,"sectors"->sectors|>];
Do[value=HSBornUUInvariant[amp,projector];AssociateTo[all,"UU_"<>projector->value];
 putval["UU_"<>projector,value/.CF->(Nc^2-1)/(2Nc)],{projector,{"Pg","Ppp"}}];
photon={phL,phX,phY};names={"L","X","Y"};inspin={pinX,pinY};outspin={poutX,poutY};
Do[
 key="UU_"<>names[[i]]<>names[[j]];value=HSBornContraction[amp,"U",photon[[i]],photon[[j]]];
 AssociateTo[all,key->value];AssociateTo[physical,key->HSOnShell[value/.D->4]];putval[key,physical[key]];
 Do[key="T"<>ToString[a]<>ToString[b]<>"_"<>names[[i]]<>names[[j]];
  value=HSBornContraction[amp,"T",photon[[i]],photon[[j]],inspin[[a]],outspin[[b]]];
  AssociateTo[all,key->value];AssociateTo[physical,key->HSOnShell[value/.D->4]];putval[key,physical[key]],
  {a,2},{b,2}];
 Print["BORN_TENSOR_COMPONENTS ",names[[i]],names[[j]]];
 Put[all,FileNameJoin[{out,"born_tensor_dimensional.wl"}]],{i,3},{j,3}];
Do[AssociateTo[residuals,{"spin_in_orth_"<>ToString[i]->HSOnShell[SP[inspin[[i]],p]],
 "spin_out_orth_"<>ToString[i]->HSOnShell[SP[outspin[[i]],k1]]}];
 Do[AssociateTo[residuals,{"spin_in_gram_"<>ToString[i]<>ToString[j]->HSOnShell[SP[inspin[[i]],inspin[[j]]]+KroneckerDelta[i,j]],
  "spin_out_gram_"<>ToString[i]<>ToString[j]->HSOnShell[SP[outspin[[i]],outspin[[j]]]+KroneckerDelta[i,j]]}],{j,2}],{i,2}];
AssociateTo[residuals,"photon_ward_UU"->HSBornContraction[amp,"U",q,q]];
Do[AssociateTo[residuals,"photon_ward_T"<>ToString[a]<>ToString[b]->HSBornContraction[amp,"T",q,q,inspin[[a]],outspin[[b]]]],{a,2},{b,2}];
Do[AssociateTo[residuals,"gluon_ward_"<>names[[i]]->HSBornContraction[amp,"T",photon[[i]],photon[[i]],pinX,poutX,True]],{i,3}];
fixed=Table[HSBornContraction[amp,"F",phX,phX,si pinX,so poutX],{si,{1,-1}},{so,{1,-1}}];
AssociateTo[residuals,{"spin_normalization_UU"->HSOnShell[Total[Flatten[fixed]]-all["UU_XX"]],
 "spin_normalization_TT"->HSOnShell[fixed[[1,1]]-fixed[[1,2]]-fixed[[2,1]]+fixed[[2,2]]-all["T11_XX"]]}];
rotated=HSBornContraction[amp,"T",phX,phX,(3pinX+4pinY)/5,(5poutX+12poutY)/13];
AssociateTo[residuals,"spin_rotation"->HSOnShell[rotated-({3,4}.Table[all["T"<>ToString[a]<>ToString[b]<>"_XX"],{a,2},{b,2}].{5,12})/65]];
AssociateTo[residuals,{"UU_photon_basis_recovery"->HSOnShell[(all["UU_Pg"]/.D->4)-(physical["UU_LL"]-physical["UU_XX"]-physical["UU_YY"])],
 "UU_p_projection_recovery"->HSOnShell[(all["UU_Ppp"]/.D->4)-Q^2(1+r)^2 physical["UU_LL"]/4]}];
KeyValueMap[putval,residuals];
Get[FileNameJoin[{engine,"common","angular_projection.wl"}]];
angular=HSAngularFromTensor[physical];Put[angular,FileNameJoin[{out,"angular_projection.wl"}]];
angularResiduals=Join[Flatten[angular["lepton"]["residuals"]],{angular["hadron_azimuth_residual"],angular["spin_reversal_residual"],angular["moment_residual"]}];
Do[putval["angular_"<>ToString[i],angularResiduals[[i]]],{i,Length[angularResiduals]}];
Get[FileNameJoin[{engine,"common","channel_operators.wl"}]];
operators=HSChannelOperators[<|"Hqg"->ctx["saved_inputs"]["Hqg_amplitudes"]["resolved"],"Hqqprime"->ctx["saved_inputs"]["Hqqprime_amplitudes"]["resolved"]|>];
Put[operators,FileNameJoin[{out,"channel_operators.wl"}]];
KeyValueMap[putval["zero_"<>#1,#2,{#1}]&,operators["zero_residuals"]];
Put[physical,FileNameJoin[{out,"born_tensor_physical.wl"}]];
Put[residuals,FileNameJoin[{out,"born_residuals.wl"}]];
Put[<|"fixed_spin_half_squares"->fixed,"rotation_contraction"->rotated,
 "density"->HoldComplete[rho[p,S]==GSD[p].(1+GA[5].GS[S])/2],
 "four_sign_extraction_normalization"->"The stored F densities include initial 1/(2Nc); physical fixed-spin W is twice this result. Twice W's bilinear coefficient equals the T tensor."|>,FileNameJoin[{out,"projectors.wl"}]];
Put[<|"scope"->ctx["scope"],"photon_tensor_kept"->True,
 "born_order"->1,"jet_to_parent_fraction"->zJ,"hadron_fraction"->zh,
 "jet_axis"->"standard E-scheme","accuracy"->"Born tensor milestone; no finite NLO coefficient produced at r00"|>,FileNameJoin[{out,"measurement.wl"}]];
(* Prepare the qgg tensors and projections afresh within this run. r01 still
   constructs their integral map and owns the fresh Kira reduction. Keeping
   this preparation with the initial spin contractions avoids the demonstrated
   two-hour r01 timeout without changing the runtime or any formula. *)
qggPreparation=RunProcess[{"python3",FileNameJoin[{engine,"tools","pipeline","native_stage_driver.py"}]}];
Print[qggPreparation["StandardOutput"]];
If[qggPreparation["StandardError"]=!="",Print[qggPreparation["StandardError"]]];
If[qggPreparation["ExitCode"]=!=0,Exit[qggPreparation["ExitCode"]]];
ev[file_,role_,parents_]:=<|"path"->file,"role"->role,"parents"->parents|>;
evidence=<|"r00/definitions"->ev["definitions.wl","definitions",{"source/r00","input/Hqq_born_normalization"}],
 "r00/amplitudes"->ev["amplitudes.wl","amplitudes",{"r00/definitions","input/Hqq_amplitudes"}],
 "r00/projectors"->ev["projectors.wl","projectors",{"r00/amplitudes"}],
 "r00/tensor"->ev["born_tensor_dimensional.wl","projectors",{"r00/projectors"}],
 "r00/residuals"->ev["born_residuals.wl","definitions",{"r00/tensor"}],
 "r00/angular"->ev["angular_projection.wl","projectors",{"r00/tensor"}],
 "r00/channel_operators"->ev["channel_operators.wl","projectors",{"r00/definitions","input/Hqg_amplitudes","input/Hqqprime_amplitudes"}],
 "r00/measurement"->ev["measurement.wl","measurement",{"r00/tensor"}],
 "r00/RealQGGTemplates"->ev["RealQGG-templates/templates.wl","integrands",{"source/r00","r00/tensor","input/Hqq_amplitudes"}],
 "r00/RealQGGProjection"->ev["RealQGG-projected/projection.wl","projectors",{"r00/RealQGGTemplates"}],
 "r00/preparationDriver"->ev["native-driver.json","projectors",{"r00/RealQGGProjection"}]|>;
Put[<|"schema"->5,"stage"->"r00","values"->vals,"evidence"->evidence,"jobs"->{}|>,FileNameJoin[{out,"packet.wl"}]];
Print["R00_CONTRACTIONS_COMPLETE; ACCEPTANCE_LEFT_TO_VALIDATOR"];Exit[0];
