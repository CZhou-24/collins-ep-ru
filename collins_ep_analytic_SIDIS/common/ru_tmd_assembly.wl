(* Fixed-fraction cut -> analytic Fourier transform -> local subtraction.
   All integrated bare coefficients multiply the ACTUAL new M sphere.
   Fixed local counterterms are defined before nonphysical dependency probes.
   No final matching coefficient or evaluated old master is loaded. *)
Clear[RUTMDFourierFactors,RUTMDCoefficientAssembly];
RUTMDFourierFactors[]:=Module[{gaussian,laplace,fullScalar,fullVector,
 angularConversion,ratio,series,rankResidual,phaseJac,schemeRatio},
 gaussian=Integrate[Exp[-ss kk^2+I bb kk],{kk,-Infinity,Infinity},
  Assumptions->ss>0&&Element[bb,Reals]];
 laplace=Integrate[xx^(-1-eps)Exp[-xx],{xx,0,Infinity},Assumptions->eps<0];
 fullScalar=Exp[EulerGamma eps]laplace (bb^2/4)^eps;
 fullVector=-I D[Exp[EulerGamma eps]Gamma[-1-eps](bb^2/4)^(1+eps),bb];
 rankResidual=FullSimplify[FunctionExpand[fullVector/(I bb/2)-fullScalar],bb>0];
 RUGate["rank-one Fourier derivative retains exact scalar relation",rankResidual===0];
 (* The inherited physical-J0 continuation is a common b-independent
    extension of both rank-zero and rank-one operators. It is explicitly
    different from averaging a physical spin tensor over D-2 directions. *)
 angularConversion=1/(Gamma[1-eps]Gamma[1+eps]);
 ratio=-Exp[eps(B-2EulerGamma)]Gamma[1-eps]/(eps Gamma[1+eps]);
 series=FullSimplify[Normal[Series[ratio,{eps,0,2}]]];
 phaseJac=FullSimplify[(A/z^2)^eps/A^eps,A>0&&z>0&&Element[eps,Reals]];
 schemeRatio=Exp[EulerGamma eps]/Gamma[1-eps];
 <|"Gaussian"->gaussian,"Schwinger_integrand"->xx^(-1-eps)Exp[-xx],
 "Schwinger_evaluated"->laplace,"full_D_scalar"->fullScalar,"full_D_rank_one"->fullVector,
 "rank_one_residual"->rankResidual,"operator_angular_conversion"->angularConversion,
 "ratio_to_native_sphere"->ratio,"Laurent_ratio"->series,
 "fragmentation_phase_ratio"->phaseJac,"C11_UV_ratio"->schemeRatio,
 "physical_phase"->HoldComplete[{kT==-pT/z,Exp[-I pT.b/z]==Exp[I kT.b]}],
 "Collins_tree"->HoldComplete[CollinsTree[i]==-I b[i]Hhat3[z]/(2z)],
 "log_definition"->HoldComplete[B==Log[mu^2 bb^2 Exp[2EulerGamma]/4]],
 "local_normalization"->HoldComplete[{N0==1,N1==0,N2==-Zeta[2]/2}],
 "scope"->"Fourier is an analytic transform of the actually evaluated fixed-radius density; the raw geometric sphere is never replaced by this normalization identity in producing coefficients."|>
];

RUTMDCoefficientAssembly[generation_Association,soft_Association,ref_String,nativeSphere_]:=Module[
 {values=<||>,full=<||>,canonical=<||>,proofs=<||>,fourier,ratio,std,
 kernels=generation["kernels"],p,p0,res,reg,reg0,channel,sector,isFragment,
 bvar,tvar,regularFactor,plusFactor,endpointRaw,endpointEta,residue,uv,
 schemeShift,finite,localFinite,subtraction,make,record,actual,prefix,
 scaleMap,parts,canonParts,flags,endpointSoft,angularDifference,angularFinite,
 splitting=<||>,splitRaw,splitDelta,splitParts,splitSectors,id},
 fourier=RUTMDFourierFactors[];ratio=fourier["ratio_to_native_sphere"];
 std=soft["unexpanded_ratios"]["standard"];
 angularDifference=Factor[generation["projection"]["Dminus2_minus_physical"]/.D->4-2eps];
 angularFinite=Coefficient[Normal[Series[angularDifference fourier["Laurent_ratio"]nativeSphere,{eps,0,0}]],eps,0];
 RUGate["physical-plane versus Dminus2 transversity shift is beyond one-loop finite order",angularFinite===0];
 make[id_,factor_,constant_,sector_]:=(AssociateTo[values,id->
  RUCertificate[constant,{RURecord[ref,factor,nativeSphere]},{sector}]];id);
 actual[id_]:=values[id]["value"]/.RUExact[x_]:>x;
 Do[
  p=Factor[kernels[sector]];p0=Factor[p/.eps->0];
  res=FullSimplify[Limit[(1-z)p,z->1,Direction->"FromBelow"]];
  reg=Factor[p-res/(1-z)];reg0=Factor[reg/.eps->0];
  isFragment=StringStartsQ[sector,"fragment_"];
  bvar=If[isFragment,Bh,Bq];tvar=If[isFragment,Th,Tq];
  channel=Switch[sector,"beam_fqq","fqq","beam_fqg","fqg","beam_hqq","hqq",
   "fragment_dqq","dqq","fragment_dgq","dgq","fragment_collins","collins"];
  regularFactor=Normal[Series[ratio p If[isFragment,Exp[-2eps Log[z]],1]-ratio res/(1-z),{eps,0,0}]];
  plusFactor=Normal[Series[ratio res,{eps,0,0}]];
  (* Endpoint is formed from the actual soft residue of this cut, not a
     prescribed universal finite delta. Its common eta pole cancels with
     one half of the standard soft operator before epsilon is expanded. *)
  If[res===0,endpointEta=0;residue=0,
   endpointRaw=-res ratio Exp[eta(T-V)/2]/eta+std/2;
   residue=FullSimplify[Cancel[eta endpointRaw]/.eta->0];
   endpointEta=FullSimplify[D[Cancel[eta endpointRaw],eta]/.eta->0];
   RUGate["TMD eta residues cancel before epsilon",residue===0]];
  endpointEta=FullSimplify[Normal[Series[FunctionExpand[endpointEta],{eps,0,0}]]];
  (* N0=1,N1=0 are fixed local Gaussian/MSbar residues. In particular the
     subtraction is not recalculated from a deliberately mutated master. *)
  uv=-Sum[Coefficient[Expand[endpointEta],eps,j]eps^j,{j,-2,-1}];
  schemeShift=FullSimplify[Normal[Series[uv(fourier["C11_UV_ratio"]-1),{eps,0,0}]]];
  Do[
   prefix="r03/tmd_"<>channel<>If[mode=="full","_full_","_canonical_"];
   scaleMap=If[mode=="full",{B->bvar,T->tvar},{B->0,T->0}];
   parts=<|"delta"->make[prefix<>"delta",endpointEta/.scaleMap,
       (uv+If[mode=="canonical",schemeShift,0])/.scaleMap,sector],
    "D0"->make[prefix<>"D0",plusFactor/.scaleMap,res/eps,sector],
    "D1"->make[prefix<>"D1",0,0,sector],
    "regular"->make[prefix<>"regular",regularFactor/.scaleMap,reg0/eps,sector]|>;
   If[mode=="full",AssociateTo[full,channel->parts],AssociateTo[canonical,channel->parts]],
   {mode,{"full","canonical"}}];
  AssociateTo[proofs,channel-><|"D_kernel"->p,"LO_open"->p0,"soft_residue"->res,
   "regular_kernel"->reg,"regular_collinear_counterterm"->reg0/eps,
   "plus_collinear_counterterm"->res/eps,"endpoint_eta_residual"->residue,
   "endpoint_ratio_to_sphere"->endpointEta,"fixed_UV"->uv,"C11_shift"->schemeShift,
   "fragmentation_log"->If[isFragment,HoldComplete[ell==Log[z]],0]|>],
  {sector,Keys[kernels]}];
 (* LO splitting entries are local operator residues, independently fixed
    by the fresh cut numerator and the generated virtual projector. They
    are not disguised evaluated masters or finite matching inputs. *)
 splitRaw=<|"qq"->generation["beam"]["D_dimensional_kernels"]["qq"],
  "qg"->generation["beam"]["D_dimensional_kernels"]["qg"],
  "gq"->generation["projection"]["D_dimensional_kernels"]["gq"],
  "transversity"->generation["beam"]["D_dimensional_kernels"]["transversity"]|>;
 Do[
  p0=Factor[splitRaw[name]/.eps->0];res=FullSimplify[Limit[(1-z)p0,z->1]];
  splitDelta=If[MemberQ[{"qq","transversity"},name],
   generation["operator_virtual"]["native_virtual_endpoint"][[If[name=="qq",1,2]]]/.eps->0,0];
  splitSectors=Switch[name,"qq",{"beam_fqq","fragment_dqq"},"qg",{"beam_fqg"},
   "gq",{"fragment_dgq"},"transversity",{"beam_hqq","fragment_collins"}];
  splitParts=<|"delta"->splitDelta,"D0"->res,"D1"->0,"regular"->Factor[p0-res/(1-z)]|>;
  parts=<||>;
  Do[id="r03/splitting_"<>name<>"_"<>part;
   AssociateTo[values,id->RUCertificate[splitParts[part],{},splitSectors]];
   AssociateTo[parts,part->id],{part,{"delta","D0","D1","regular"}}];
  AssociateTo[splitting,name->parts],{name,Keys[splitRaw]}];
 flags=AssociationMap[And@@Table[Coefficient[Expand[actual[#]],eps,j]===0,{j,-2,-1}]&,
  Flatten[Values/@Join[Values[full],Values[canonical]]]];
 If[!TrueQ[$RUContext["validation_probe"]],RUGate["all physical TMD matching poles cancel",And@@Values[flags]]];
 <|"values"->values,"full_scale_nodes"->full,"canonical_C11_nodes"->canonical,
 "splitting_node_ids"->splitting,
 "fourier"->fourier,"subtractions"->proofs,"pole_checks"->flags,
 "angular_extension_check"-><|"D_kernel_difference"->angularDifference,"actual_new_master_finite_shift"->angularFinite,
 "qualification"->"The two tensor averages differ starting at eps^2. This real kernel has one radial pole and its angular difference vanishes at z=1, hence the finite one-loop shift is zero. The two prescriptions are not asserted identical beyond this order."|>,
 "distribution_identity"->HoldComplete[Integrate[f[z]P[z],{z,0,1}]==
   Integrate[(f[z]-f[1])res/(1-z)+f[z](P[z]-res/(1-z)),{z,0,1}]+Endpoint f[1]],
 "virtual_cancellation"->"The same bare on-shell Wilson/self operator multiplies TMD and collinear trees; its regulated scalar cancels before taking the matching difference. The generated open projector proof and r06 native virtual evidence are separate ancestors; a vector Ward moment alone is not a finite endpoint derivation.",
 "scale_plus_convention"->"Denominator-plus real kernels; the separately canceled virtual collinear delta is not multiplied by an extra -3CF B/2.",
 "independence"->"Shared accepted operator definitions and generating matrix algebra, newly executed physical cut / Kira / SubTropica route. No old finite coefficient packet consumed."|>
];
