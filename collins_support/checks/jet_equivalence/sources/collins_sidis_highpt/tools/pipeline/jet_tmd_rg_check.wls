$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
engine=FileNameJoin[{root,"collins_sidis_highpt"}];out=Environment["SIDIS_JET_TMD_RG_OUT"];
If[!StringQ[out]||DirectoryQ[out],Exit[1]];CreateDirectory[out,CreateIntermediateDirectories->True];
helpers=FileNameJoin[{engine,"common",#}]&/@{"jet_matching.wl","tmd_evolution.wl"};Get/@helpers;
(* Literal LO splitting functions, distinct from the candidate jet formulas.
   D0 is the denominator-only plus prescription used in the paper. *)
kernels=<|"Uqq"->CF((1+z^2)D0+3delta1[1]/2),
 "Uqg"->CF(1+(1-z)^2)/z,"Ugq"->TF(z^2+(1-z)^2),
 "Ugg"->2CA(z D0+(1-z)/z+z(1-z))+beta0 delta1[1]/2,
 "Tqq"->CF(2z D0+3delta1[1]/2)|>;
routes=<|"Uqq"->{"U","q","q"},"Uqg"->{"U","q","g"},"Ugq"->{"U","g","q"},
 "Ugg"->{"U","g","g"},"Tqq"->{"T","q","q"}|>;
checks=<||>;rows=<||>;
Do[route=routes[key];jet=HSJetMatching[Sequence@@route,z,L];
 tmd=If[route[[2]]===route[[3]],HSTMDMuGamma[route[[3]],L]delta1[1],0];
 jetDerivative=Map[D[#,L]&,HSJetCanonical[jet,z]];
 sum=Merge[{jetDerivative,HSJetCanonical[tmd,z]},Total];
 residual=Map[Factor,Merge[{sum,Map[-#&,HSJetCanonical[kernels[key],z]]},Total]];
 AssociateTo[checks,key->residual];AssociateTo[rows,key-><|"jet_derivative_canonical"->jetDerivative,"tree_jet_times_TMD_gamma"->tmd,
  "sum_canonical"->sum,"DGLAP_kernel"->kernels[key],"canonical_residuals"->residual|>],{key,Keys[routes]}];
rapidity=AssociationMap[Factor[HSUnsubtractedTMDNuGamma[#,Lb]+HSInJetSoftNuGamma[#,Lb]]&,{CF,CA}];
cs=AssociationMap[Factor[D[HSTMDMuGamma[#,logMu2-logZeta],logZeta]*2-
 D[HSPerturbativeCSKernel[If[#==="q",CF,CA],logMu2-logMuB2,a],logMu2]/a]&,{"q","g"}];
product=Expand[(a c0+a^2 c1)(j0+a j1)(f0+a f1)];
truncated=Normal[Series[product,{a,0,2}]];
orderResidual=Expand[truncated-(a c0 j0 f0+a^2(c1 j0 f0+c0 j1 f0+c0 j0 f1))];
Put[<|"matching_rows"->rows,"rapidity_residuals"->rapidity,"CS_mu_integrability_residuals"->cs,
 "order_product"->truncated,"order_residual"->orderResidual,
 "scale_map"->"Derivatives are with respect to ln(mu^2), a=alpha_s/(2Pi), L=ln(mu^2/zetaJ), zetaJ=(pJT R)^2; running of a enters only beyond these one-loop jet identities",
 "factorization_statement"->"Jet matching times the soft-subtracted TMD has the same timelike LO DGLAP kernel that the inclusive hard coefficient subtracts; no second in-jet soft factor is included",
 "source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,Join[helpers,{$InputFileName,FileNameJoin[{engine,"references","2311.00672v2","source","main.tex"}]}]],
 "qualification"->"Universal jet/TMD RG and order identities, with literature anomalous dimensions. Actual hard-scale cancellation remains an independent assembly check."|>,FileNameJoin[{out,"rg.wl"}]];
If[!And@@(#===0&/@Join[Flatten[Values/@Values[checks]],Values[rapidity],Values[cs],{orderResidual}]),Print["JET_TMD_RG_FAILED"];Exit[2]];
Print["JET_TMD_RG_COMPLETE 20 distribution, 2 rapidity, 2 CS integrability, 1 order checks"];Exit[0];
