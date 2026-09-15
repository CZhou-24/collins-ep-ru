(* Check newly evaluated masters and actual Kira output against beta identities.
   Expected Gamma expressions are comparison-only, never evaluator inputs. *)
c=Import[Environment["COLLINS_RU_REGRESSION_CHECKS"],"RawJSON"];
gate[t_,m_]:=If[!TrueQ[t],Print[m];Exit[1]];
volume=Get[c["volume"]]["CutVolume"];null=Get[c["null"]]["CutNull"];
cert=Get[c["certificate"]];rules=cert["rules"];
gamma=Pi^(1-eps) Gamma[1-eps]/(2 Gamma[2-2 eps]);
expected={R1[1,1,1]->(1-2 eps)/(eps w),R1[1,1,2]->-2(1-2 eps)/((1+eps)w^2),R1[1,1,-1]->-w/2};
ruleResiduals=(Factor[((First[#]/.rules)/R1[1,1,0]/.d->4-2 eps)-Last[#]]& /@ expected);
beta[a_,b_]:=Gamma[a]Gamma[b]/Gamma[a+b];
ratios={-beta[-eps,1-eps]/(w beta[1-eps,1-eps]),beta[-1-eps,1-eps]/(w^2 beta[1-eps,1-eps]),-w beta[2-eps,1-eps]/beta[1-eps,1-eps]};
betaResiduals=MapThread[FullSimplify[FunctionExpand[#1-#2]]&,{ratios,Last/@expected}];
residuals=Join[{FullSimplify[volume-Normal[Series[gamma,{eps,0,2}]]],
 FullSimplify[Normal[Series[null-((R1[1,1,1]/.rules)/R1[1,1,0]/.{d->4-2 eps,w->1})volume,{eps,0,0}]]]},ruleResiduals,betaResiduals];
(* The reported pilot contains both reducible terms and an implicit master.
   Check the real source contraction, including its -2 CF direct-master term. *)
source=CF (eps-1)/w R1[1,1,-1]-2 CF R1[1,1,0]-2 CF w R1[1,1,1];
baseline=Factor[source/.rules/.d->4-2 eps];
Do[
 changed=Get[probe["certificate"]]["rules"];scale=probe["numerator"]/probe["denominator"];
 AppendTo[residuals,Factor[(source/.changed/.d->4-2 eps)-scale baseline]],{probe,c["probes"]}];
gate[residuals===ConstantArray[0,Length[residuals]],"Native regression residual is nonzero"];
Put[<|"Gamma_comparison"->gamma,"baseline_contraction"->baseline,"residuals"->residuals|>,c["native_output"]];
Export[c["output"],<|"status"->"PASS","residuals"->(ToString[#,InputForm]& /@ residuals),"checks"->Length[residuals],
 "scope"->"cut-volume and eikonal masters, actual Kira identities, and complete-map contraction probes only"|>,"RawJSON"];
Exit[0];
