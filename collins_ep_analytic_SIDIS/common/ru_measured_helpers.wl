(* Fixed longitudinal fraction and transverse radius. New Collins geometry,
   using approved SIDIS target-job and positive-cut construction patterns.
   All three cuts remain positive-index distributions. Only D0 is a particle.
   The physically positive radial measurement is R=2 beta D1-D2; orientation
   and raised-measurement transport are retained separately, not hidden. *)
Clear[RUMeasuredGeometry,RUWriteMeasuredJob,RUMeasuredEulerInput,RUMeasuredRows];
RUMeasuredGeometry[]:=Module[{polynomials,solution,jac,rho,on,gaussian,sphere2,
 sphereHat,hatRadialDensity,tTransform,eulerDensity,normalization},
 polynomials={KK-2u beta,alpha-1,KK-2beta+tau};
 solution=First[Solve[Thread[polynomials==0],{KK,alpha,beta}]];
 jac=Det[Table[D[q,v],{q,polynomials},{v,{KK,alpha,beta}}]];
 rho=2alpha beta-KK;on=Factor[rho/.solution];
 RUGate["three measured cuts fix positive transverse radius",on===tau];
 RUGate["nondegenerate measured Jacobian",RUZero[jac+2(1-u)]];
 gaussian=Integrate[Exp[-xx^2],{xx,-Infinity,Infinity}];
 sphere2=2gaussian^2/Gamma[1];sphereHat=2gaussian^(-2eps)/Gamma[-eps];
 (* rho_hat=t tau and rho_phys=(1-t)tau. Both radial measures contribute
    1/2, and the delta eliminates their sum. This is a geometric split of
    the actual transverse sphere, initially Re(eps)<0. *)
 hatRadialDensity=sphere2 sphereHat tau^(-eps)t^(-1-eps)/4;
 tTransform=y/(1+y);
 eulerDensity=FullSimplify[t^(-1-eps)/.t->tTransform,y>0&&Element[eps,Reals]] D[tTransform,y];
 eulerDensity=FullSimplify[PowerExpand[eulerDensity],y>0&&Element[eps,Reals]];
 normalization=2(1-u)Pi^(-1+eps)Exp[EulerGamma eps]tau^eps;
 <|"basis"->{KK,alpha,beta},"denominators"->polynomials,
 "defining_scalar_products"->HoldComplete[{p^2==0,n^2==0,p.n==1,k^2==KK,k.n==alpha,k.p==beta}],
 "physical_cut_momentum"->HoldComplete[l==k-u p],"physical_cut_index"->0,
 "fragmentation_bridge"->HoldComplete[{u==z,parent==k,observed_parton==z p,parent^2==z tau/(1-z)}],
 "beam_bridge"->HoldComplete[{u==z,incoming==p,emitted==k-z p,active==p-emitted,
  active==(1+z)p-k,active.n==z,active^2==-tau/(1-z)}],
 "measurement_cut_indices"->{1,2},"solution"->solution,"jacobian"->jac,
 "transverse_radius"->rho,"true_radial_cut"->rho-tau,
 "radial_cut_relation"->Factor[rho-tau-(2beta polynomials[[2]]-polynomials[[3]])],
 "positive_energy"->HoldComplete[0<u<1&&tau>0&&l.n==1-u&&l.p==tau/(2(1-u))],
 "particle_theta"->HoldComplete[Theta[l0]],
 "sphere_split"->{sphere2,sphereHat},"split_density"->hatRadialDensity,
 "hat_fraction_map"->tTransform,"Euler_density"->eulerDensity,
 "physical_measure_prefactor"->Pi^(1-eps)tau^(-eps)/(2(1-u)Gamma[-eps]),
 "normalization"->normalization,"native_prefactor"->Exp[EulerGamma eps]/Gamma[-eps],
 "unit_cut_orientation"->"DiracDelta[alpha-1] DiracDelta[rho-tau]=DiracDelta[D1] DiracDelta[D2]; the absolute radial Jacobian fixes the unit-cut sign. This statement alone is not the raised-cut map.",
 "support"->HoldComplete[0<u<1&&tau>0],
 "IBP_scope"->"Meromorphic dimension continuation from Re(eps)<0 with fixed interior u,tau. Physical theta(l0) is constant on this branch. Endpoint u=1,tau=0 is formed only afterwards as distributions. No cone or eta theta is differentiated inside this family.",
 "Fourier_scope"->"The Euler integral is the actual fixed-radius sphere. Analytic Fourier and rapidity transforms act on its tau density after native evaluation. Physical BMHV angular projection and operator angular continuation are explicit separate operations."|>
];

RUMeasuredRows[coefficient_]:={{{1,1,1},Factor[coefficient]}};

RUWriteMeasuredJob[rows_List]:=Module[{dir,targets,txt,csv,rbound},
 dir=RUPath["jobs/measured"];CreateDirectory[FileNameJoin[{dir,"config"}],CreateIntermediateDirectories->True];
 targets=DeleteDuplicates[First/@rows];rbound=Max[Total/@targets]+1;
 txt[x_]:=StringReplace[ToString[x,InputForm],Whitespace->""];
 csv[x_]:="["<>StringRiffle[txt/@x,","]<>"]";
 Export[FileNameJoin[{dir,"config","integralfamilies.yaml"}],
 "integralfamilies:\n  - name: M\n    loop_momenta: [k]\n    top_level_sectors: [7]\n    propagators:\n      - [\"k^2-2*u*k*p\", 0]\n      - [\"k*n-1\", 0]\n      - [\"k^2-2*k*p+tau\", 0]\n    cut_propagators: [1,2,3]\n","Text"];
 Export[FileNameJoin[{dir,"config","kinematics.yaml"}],
 "kinematics:\n  incoming_momenta: [p,n]\n  outgoing_momenta: []\n  kinematic_invariants:\n    - [u, 0]\n    - [tau, 2]\n  scalarproduct_rules:\n    - [[p,p], 0]\n    - [[n,n], 0]\n    - [[p,n], 1]\n","Text"];
 Export[FileNameJoin[{dir,"targets"}],StringRiffle[("M"<>csv[#])&/@targets,"\n"]<>"\n","Text"];
 Export[FileNameJoin[{dir,"preferred"}],"M[1,1,1]\n","Text"];
 Export[FileNameJoin[{dir,"jobs.yaml"}],
 "jobs:\n  - reduce_sectors:\n      reduce:\n        - {topologies: [M], sectors: [7], r: "<>txt[rbound]<>", s: 0}\n      select_integrals:\n        select_mandatory_list:\n          - [targets]\n      preferred_masters: preferred\n      run_initiate: true\n      run_triangular: true\n      run_back_substitution: true\n  - kira2math:\n      target:\n        - [targets]\n","Text"];
 <|"id"->"measured","inputs"->{"jobs.yaml","config/integralfamilies.yaml","config/kinematics.yaml","targets","preferred"},
 "outputs"->{"results/M/kira_targets.m","tmp/M/masters"},"master_inventory"->"tmp/M/masters","families"->{"M"},
 "sectors"->{"beam_fqq","beam_fqg","beam_hqq","fragment_dqq","fragment_dgq","fragment_collins","fragment_HF","recoil_soft","jet_UU","jet_UT"}|>
];

RUMeasuredEulerInput[]:=Module[{geometry=RUMeasuredGeometry[]},
 <|"FixedRadiusSphere"-><|"order"->2,"terms"->{<|
 "tuple"->{1,geometry["Euler_density"],{y},{}},
 "prefactor"->geometry["native_prefactor"],"order"->2,
 "assumptions"->Element[eps,Reals]&&eps<0|>}|>|>
];
