(* Derive the positive-energy two-cut Euler measure, following approved SIDIS
   s08, and the independently inspected v0.5.0 quark-pilot diagnostic. *)
c=Import[Environment["COLLINS_RU_REGRESSION"],"RawJSON"];
gate[t_,m_]:=If[!TrueQ[t],Print[m];Exit[1]];
dim=4-2 eps;
equations={en^2-rad^2==0,(Sqrt[w]-en)^2-rad^2==0};
solutions=Select[Solve[equations,{en,rad}],TrueQ[FullSimplify[en>0&&Sqrt[w]-en>0&&rad>0/.#,w>0]]&];
gate[Length[solutions]===1,"Positive-energy solution not unique"];
solution=First[solutions];
jac=FullSimplify[Det[Table[D[f,x],{f,Subtract@@@equations},{x,{en,rad}}]]/.solution,w>0];
radial=FullSimplify[(rad^(dim-2)/Abs[jac])/.solution,w>0&&Element[eps,Reals]];
gauss=Integrate[Exp[-t^2],{t,-Infinity,Infinity}];
radialGauss=Integrate[Exp[-t^2]t^(nn-1),{t,0,Infinity},Assumptions->nn>0];
sphere=(gauss^nn/radialGauss)/.nn->dim-2;
cosine=(1-xx)/(1+xx);
density=FullSimplify[(1-cosine^2)^(-eps) Abs[D[cosine,xx]],xx>0&&Element[eps,Reals]];
prefactor=FullSimplify[(radial sphere)/.w->1,Element[eps,Reals]];
nullDensity=FullSimplify[density/(1-cosine),xx>0&&Element[eps,Reals]];
volume=<|"CutVolume"-><|"order"->2,"terms"->{<|"tuple"->{1,density,{xx},{}},"prefactor"->prefactor,"order"->2,"assumptions"->Element[eps,Reals]|>}|>|>;
null=<|"CutNull"-><|"order"->0,"terms"->{<|"tuple"->{1,nullDensity,{xx},{}},"prefactor"->-2 prefactor,"order"->1,"assumptions"->Element[eps,Reals]|>}|>|>;
Put[volume,c["volume_input"]];Put[null,c["null_input"]];
Put[<|"positive_solution"->solution,"jacobian"->jac,"radial"->radial,"sphere"->sphere,"cosine"->cosine,"density"->density,
 "measure"->HoldComplete[d^dim r deltaPositive[r^2] deltaPositive[(p-r)^2]],
 "support"->HoldComplete[w>0&&r0>0&&p0-r0>0],"w_fixed_after_homogeneity"->1,
 "physical_phase_space_factor"->(2 Pi)^(2-dim)|>,c["geometry"]];
Exit[0];
