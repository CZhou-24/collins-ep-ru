(* Literal Fourier conventions imported from 2311.00672v2 Eqs.98,99.
   The nonperturbative TMD remains an input, with zetaJ=(pJT R)^2. *)
HSTMDMoment[fn_,n_Integer,zh_,b_,Mh_]:=Module[{k},
 2Pi Factorial[n]/(zh^2(zh^2 Mh^2)^n)
 Inactive[Integrate][k(k/b)^n BesselJ[n,b k/zh]fn[k],{k,0,Infinity}]];
HSInverseMoment[fn_,n_Integer,zh_,j_,Mh_]:=Module[{b},
 (zh^2 Mh^2/j)^n/(2Pi Factorial[n])
 Inactive[Integrate][b^(n+1)BesselJ[n,j b/zh]fn[b],{b,0,Infinity}]];
HSCollinsAnalyzer[phi_,j_,zh_,Mh_]:=j/(zh Mh){-Sin[phi],Cos[phi]};
(* This is only the perturbative product. Its arguments must be genuinely
   derived coefficient/convolution operators; no missing C1 is inferred. *)
HSNLOProduct[c0_,c1_,j0_,j1_,a_]:=Normal[Series[(a c0+a^2 c1)(j0+a j1),{a,0,2}]];
