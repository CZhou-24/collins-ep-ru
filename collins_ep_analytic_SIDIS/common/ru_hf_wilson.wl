(* v0.5.1 fresh HF generating source; exact pre-use identity in provenance/hf/COLLINS_REUSE_PLAN.json. No archived output or radial library is loaded. *)
(* Finite-endpoint Wilson derivative, calculated in a free associative algebra.
   This is producing code, not a stored matching coefficient. The all-order
   derivative identity is also retained before the retarded boundary limit. *)
Clear[D16WilsonTaylor];
D16WilsonTaylor[]:=Module[{word,terms,mul,comm,an,at,wilson,field,
 g,b,s,t,x,ell,aa0,aa1,ab0,ab1,at0,at1,left,right,residual,poles,ray,
 derivativeIdentity,rankOne,record},
 terms[q_]:=Module[{ee=Expand[q],tt},tt=If[Head[ee]===Plus,List@@ee,{ee}];
  ({#/.word[___]->1,If[FreeQ[#,word],{},First[Cases[#,word[v___]:>{v},{0,Infinity}]]]}&)/@tt];
 mul[q_,r_]:=Expand[Total[Flatten[Table[aa[[1]]bb[[1]] Apply[word,Join[aa[[2]],bb[[2]]]],
    {aa,terms[q]},{bb,terms[r]}]]]];
 comm[q_,r_]:=mul[q,r]-mul[r,q];
 an[s_,b_]:=word[aa0]+s word[aa1]+b(word[ab0]+s word[ab1]);
 at[s_]:=word[at0]+s word[at1];
 wilson[ell_,x_,b_]:=word[]-I g Integrate[an[s,b],{s,x,ell}]
   -g^2 Integrate[Integrate[mul[an[s,b],an[t,b]],{t,x,s}],{s,x,ell}];
 field[s_]:=D[an[s,b],b]-D[at[s],s]+I g comm[at[s],an[s,b]];
 (* The wave-function derivative cancels on both sides. Retain BOTH endpoint
    gauge fields: no A(ell)=0 condition is used to obtain this residual. *)
 left=I D[wilson[ell,x,b],b]-g mul[at[ell],wilson[ell,x,b]];
 right=-g mul[wilson[ell,x,b],at[x]]+
   g Integrate[Normal[Series[mul[mul[wilson[ell,s,b],field[s]],wilson[s,x,b]],{g,0,1}]],{s,x,ell}];
 residual=Table[FullSimplify[Coefficient[Expand[left-right],g,j]],{j,0,2}];
 (* The ordered-transport derivative follows from its endpoint ODE. In a
    free algebra this identity holds for arbitrary, noncommuting A and F. *)
 derivativeIdentity=Expand[ I g mul[word[aa0],word[at0]]-I g mul[word[at0],word[aa0]]
   +word[at1]-(word[at1]-I g comm[word[at0],word[aa0]])];
 ray=Integrate[Exp[-(lambda+I q)t],{t,0,Infinity},
   Assumptions->lambda>0&&Element[q,Reals]];
 (* A straight-staple transverse Taylor coefficient is one gauge-completed
    derivative operator, including its integrated F term. Separate this from
    the independent two-fraction F operator; the latter is not another tree
    insertion to be counted after defining the completed rank-one moment. *)
 rankOne=HhatD+HhatLinkF;
 record=<|"origin"->"DERIVED finite-endpoint free-algebra calculation through g^2 plus exact transport-ODE identity; EXTERNAL gauge-covariant operator and retarded boundary definitions",
  "connection"->HoldComplete[Dnative==partial+I gS Anative],
  "Wilson"->HoldComplete[W[ell,xi]==PathOrderedExp[-I gS Inactive[Integrate][An[s],{s,xi,ell}]]],
  "field_strength"->HoldComplete[FalphaN==partialAlpha[An]-partialN[Aalpha]+I gS Commutator[Aalpha,An]],
  "finite_endpoint_identity"->HoldComplete[(I partialAlpha-gS Aalpha[ell])[W[ell,xi].psi[xi]]==
    W[ell,xi].I Dalpha[psi[xi]]+gS Inactive[Integrate][W[ell,s].FalphaN[s].W[s,xi].psi[xi],{s,xi,ell}]],
  "endpoint_condition"->HoldComplete[Limit[Aalpha[ell],ell->Infinity]==0],
  "ordered_series"->wilson[ell,x,b],"field_series"->field[s],
  "finite_endpoint_left"->left,"finite_endpoint_right"->right,
  "free_word_residuals"->residual,"transport_ODE_residual"->derivativeIdentity,
  "damped_future_ray"->ray,
  "rank_one_Taylor_components"->rankOne,
  "rank_one_basis_map"->HoldComplete[HhatNative==HhatD+HhatLinkF],
  "tree_HF_coefficient"->Coefficient[Expand[(HhatD+HhatLinkF)/.{HhatD->HhatNative-HhatLinkF}],HFIndependent],
  "tree_scope"->"The Taylor coefficient is the complete gauge-covariant Hhat operator. The integrated link insertion belongs to it. No independent two-fraction coefficient survives at tree level. This is an operator-basis identity, not a free-parton value for a T-odd matrix element; EOM/endpoint terms are retained above.",
  "residuals"->Join[AssociationThread[{"g0","g1","g2"},residual],<|"transport_ODE"->derivativeIdentity|>]|>;
 (* Stable names for dummy free-algebra letters and integration variables.
    The calculated expressions and residuals are otherwise unchanged. *)
 record/.sym_Symbol/;Context[sym]==="Global`"&&
   StringMatchQ[SymbolName[sym],___~~"$"~~DigitCharacter..]:>
   Symbol["CollinsEPD16Wilson`"<>First[StringSplit[SymbolName[sym],"$"]]]
];
