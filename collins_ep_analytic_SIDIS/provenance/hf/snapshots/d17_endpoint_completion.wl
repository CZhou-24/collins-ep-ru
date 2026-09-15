(* Explicit regulated action and physical-equivalence extension. No unknown
   generic endpoint coefficient is assigned a derived zero here. *)
Clear[D17EndpointCompletion];
D17EndpointCompletion[regulated_Association,normalization_,unregulated_]:=Module[
 {pieces,left,right,hermitian,zeroResidual,cnum,rawNum,pnum,
  xpart,ypart,lpart,splitResidual,m1,m2,opp1,opp2,
  contactAction,fields,formal},
 pieces=Map[Factor[normalization #/(1-v-I lambda)]&,
   regulated["D_traces"]];
 left=Factor[CF pieces["a"]+(CF-CA/2)pieces["b"]-CA pieces["c"]/2];
 (* Reflection conjugates the ray/Feynman prescriptions as well as the
    amplitude. The real physical HF scalar is held fixed after projection. *)
 right=ComplexExpand[Conjugate[left]];
 hermitian=Factor[Together[(left+right)/2]];
 zeroResidual=Factor[(hermitian/.lambda->0)-unregulated];
 (* The troublesome graph's numerator vanishes at the joint x=y=0
    endpoint. Retain an exact polynomial decomposition, including damping.
    Its factors bound the numerator by C(x+y+lambda), cancelling the
    possible 1/(1-uv-i lambda) enhancement on the physical test class. *)
 rawNum=Numerator[Together[pieces["c"]]];
 pnum=Expand[rawNum/.{u->1-y,v->1-x}];
 xpart=Cancel[(pnum-(pnum/.x->0))/x];
 ypart=Cancel[((pnum/.x->0)-(pnum/.{x->0,y->0}))/y];
 lpart=Cancel[(pnum/.{x->0,y->0})/lambda];
 splitResidual=Expand[pnum-x xpart-y ypart-lambda lpart];
 m1=Integrate[x (x^2-lambda^2)/(x^2+lambda^2)^2,{x,0,1},Assumptions->lambda>0];
 m2=Integrate[x^2 (x^2-lambda^2)/(x^2+lambda^2)^2,{x,0,1},Assumptions->lambda>0];
 opp1=Integrate[x/(x^2+lambda^2),{x,0,1},Assumptions->lambda>0];
 opp2=Integrate[x^2/(x^2+lambda^2),{x,0,1},Assumptions->lambda>0];
 <|"origin"->"DERIVED regulated cut action and mathematical physical-class extension; normalization/basis and endpoint identities are separate required operator inputs.",
 "regulated_graph_densities"->pieces,"single_cut_density"->left,
 "conjugate_cut_density"->right,"Hermitian_cut_density"->hermitian,
 "damping_zero_D_density_residual"->zeroResidual,
 "joint_endpoint_numerator"->pnum,
 "joint_endpoint_decomposition"-><|"x_polynomial"->xpart,"y_polynomial"->ypart,
   "lambda_polynomial"->lpart,"residual"->splitResidual|>,
 "common_regulator_action"->HoldComplete[
  Limit[Integrate[Klambda[u,v](Phi[u,v]),{v,0,1}],lambda->0,
    Direction->"FromAbove"]],
 "generic_transport_action"->HoldComplete[
  Integrate[K[u,v](Phi[u,v]-Phi[u,1]-(v-1)Derivative[0,1][Phi][u,1]),{v,0,1}]
   +c0[u]Phi[u,1]-c1[u]Derivative[0,1][Phi][u,1]],
 "generic_contacts"-><|"v_delta"->Missing["GenericRegulatorExtensionNotFixed"],
   "v_derivative"->Missing["GenericRegulatorExtensionNotFixed"]|>,
 "physical_equivalence_condition"->HoldComplete[
  Phi[u,1]==0&&Derivative[0,1][Phi][u,1]==0&&
  Abs[Phi[u,v]]<=C[u](1-v)^(1+alpha)&&alpha>0],
 "representative_definition"->HoldComplete[
  KphysicalRepresentative[Phi]==Integrate[K[u,v]
   (Phi[u,v]-Phi[u,1]-(v-1)Derivative[0,1][Phi][u,1]),{v,0,1}]],
 "representative_contact_origin"->"If and only if the actual operator proves the stated endpoint class at this perturbative order, zero c0/c1 is a chosen representative of the same physical action. It is not a determination of either generic distributional contact. Smooth artificial numerator probes retain their explicit nonzero generic contact integrals.",
 "domination_argument"->"For x=1-v,y=1-u in[0,1], |x+-i lambda|>=x and |v+i lambda|>=v. The last internal axial denominator satisfies |x+y-xy-i lambda|>=sqrt((x+y-xy)^2+lambda^2). The displayed polynomial decomposition bounds its numerator by C(x+y+lambda), uniformly cancelling that denominator. The physical field x^(1+alpha) then leaves an integrable x^(alpha-1) bound. This also controls the joint u=v=1 endpoint. Damping is removed in the convergent matrix-element action before meromorphic continuation of the transverse master.",
 "linear_same_sign_action"->m1,"quadratic_same_sign_action"->m2,
 "linear_opposite_sign_action"->opp1,"quadratic_opposite_sign_action"->opp2,
 "linear_damping_rescale_shift"->FullSimplify[
   Limit[(m1/.lambda->c lambda)-m1,lambda->0,Direction->"FromAbove"],c>0],
 "quadratic_damping_rescale_shift"->FullSimplify[
   Limit[(m2/.lambda->c lambda)-m2,lambda->0,Direction->"FromAbove"],c>0],
 "quadratic_equal_opposite_residual"->Limit[m2-opp2,lambda->0,Direction->"FromAbove"],
 "linear_equal_opposite_residual"->Limit[m1-opp1,lambda->0,Direction->"FromAbove"]|>
];
