(* Source algorithms adapted from approved SIDIS s03 (Laurent reconstruction),
   s04 (target-derived Kira jobs), s08 (positive-energy Jacobian and Euler density),
   s11 (actual reduction contraction), s17 (endpoint-test subtraction). *)
RUCutRows[expression_,coordinate_,family_]:=Module[{rat,num,den,pow,constant,rows,reconstructed},
 rat=Together[expression];num=Expand[Numerator[rat]];den=Factor[Denominator[rat]];
 pow=Exponent[den,coordinate];constant=Cancel[den/coordinate^pow];
 RUGate["Laurent polynomial and denominator",PolynomialQ[num,coordinate]&&FreeQ[constant,coordinate]];
 rows=({Join[{1,1},{pow-First[#[[1]]]}],Factor[#[[2]]/constant]}& /@ CoefficientRules[num,{coordinate}]);
 reconstructed=Total[(#[[2]] coordinate^(-#[[1,3]]))& /@ rows];
 RUGate["fresh numerator reconstructs",RUZero[reconstructed-expression]];rows];
RUWriteCutJob[rows_]:=Module[{dir,targets,positive,negative,rbound,sbound,text,csv},
 dir=RUPath["jobs/quark"];CreateDirectory[FileNameJoin[{dir,"config"}],CreateIntermediateDirectories->True];
 targets=DeleteDuplicates[First /@ rows];positive=Total[Select[#,#>0&]]& /@ targets;
 negative=-Total[Select[#,#<0&]]& /@ targets;rbound=Max[positive]+1;sbound=Max[negative];
 text[x_]:=StringReplace[ToString[x,InputForm],Whitespace->""];csv[x_]:="["<>StringRiffle[text /@ x,","]<>"]";
 Export[FileNameJoin[{dir,"config","integralfamilies.yaml"}],"integralfamilies:\n  - name: R1\n    loop_momenta: [r]\n    top_level_sectors: [7]\n    propagators:\n      - [r, 0]\n      - [p-r, 0]\n      - [r-n, 0]\n    cut_propagators: [1,2]\n","Text"];
 Export[FileNameJoin[{dir,"config","kinematics.yaml"}],"kinematics:\n  incoming_momenta: [p,n]\n  outgoing_momenta: []\n  kinematic_invariants:\n    - [w, 2]\n  scalarproduct_rules:\n    - [[p,p], w]\n    - [[n,n], 0]\n    - [[p,n], w/2]\n","Text"];
 Export[FileNameJoin[{dir,"targets"}],StringRiffle[("R1"<>csv[#])& /@ targets,"\n"]<>"\n","Text"];
 Export[FileNameJoin[{dir,"preferred"}],"R1[1,1,0]\n","Text"];
 Export[FileNameJoin[{dir,"jobs.yaml"}],"jobs:\n  - reduce_sectors:\n      reduce:\n        - {topologies: [R1], sectors: [7], r: "<>text[rbound]<>", s: "<>text[sbound]<>"}\n      select_integrals:\n        select_mandatory_list:\n          - [targets]\n      preferred_masters: preferred\n      run_initiate: true\n      run_triangular: true\n      run_back_substitution: true\n  - kira2math:\n      target:\n        - [targets]\n","Text"];
 <|"id"->"quark","inputs"->{"jobs.yaml","config/integralfamilies.yaml","config/kinematics.yaml","targets","preferred"},"outputs"->{"results/R1/kira_targets.m","tmp/R1/masters"},"master_inventory"->"tmp/R1/masters","families"->{"R1"},"sectors"->{"beam_fqq","fragment_dqq"}|>];
RUCutGeometry[]:=Module[{en,rad,eqs,sol,jac,radial,cosine,density,gaussian,radialGaussian,sphere},
 eqs={en^2-rad^2==0,(Sqrt[w]-en)^2-rad^2==0};
 sol=Select[Solve[eqs,{en,rad}],TrueQ[FullSimplify[en>0&&Sqrt[w]-en>0&&rad>0/.#,w>0]]&];
 RUGate["unique positive-energy solution",Length[sol]===1];sol=First[sol];
 jac=Det[Table[D[q,v],{q,Subtract@@@eqs},{v,{en,rad}}]]/.sol;
 radial=FullSimplify[(rad^(2-2 eps)/.sol)/Abs[jac],w>0&&Element[eps,Reals]];
 gaussian=Integrate[Exp[-x^2],{x,-Infinity,Infinity}];
 radialGaussian=Integrate[Exp[-x^2] x^(nn-1),{x,0,Infinity},Assumptions->nn>0];
 sphere=(gaussian^nn/radialGaussian)/.nn->2-2 eps;
 cosine=(1-y)/(1+y);
 density=FullSimplify[(1-cosine^2)^(-eps) Abs[D[cosine,y]],y>0&&Element[eps,Reals]];
 <|"equations"->eqs,"positive_solution"->sol,"jacobian"->jac,"radial"->radial,"sphere"->sphere,
 "cosine_map"->cosine,"density"->density,"tuple"->{1,density,{y},{}}|>];
