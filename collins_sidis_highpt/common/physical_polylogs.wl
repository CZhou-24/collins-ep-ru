(* Principal-branch dilogarithm conversion in the physical DIS region.
   Li2(x)+Li2(1/x)=-Pi^2/6-Log(-x)^2/2 for real x>1.
   This is a representation conversion, not a change to an archived master.
   Each real-function substitution is conditional on a proved domain. *)
HSPhysicalHermitian[value_,conditions_]:=Module[
 {polylogs,conjugated,rules={},argument,converted,atoms,domains,symbols,forward,backward,
  algebraic,hermitian,checks={},points,residuals},
 (* A master continued from above its cut is recorded as Conjugate[PolyLog[2,x]].
    Resolve that head first, with the conjugate branch identity, so no Conjugate
    survives into the converted expression or the reconstruction residual.
    Listing it before the plain rule keeps ReplaceAll from rewriting the inner
    dilogarithm with the below-the-cut branch. *)
 conjugated=DeleteDuplicates[Cases[value,Conjugate[PolyLog[2,_]],Infinity]];
 Do[argument=Last[First[term]];
  If[TrueQ[FullSimplify[argument>1,conditions]],
   AppendTo[rules,term->Pi^2/3-Log[argument]^2/2-PolyLog[2,1/argument]+I Pi Log[argument]]],
  {term,conjugated}];
 polylogs=DeleteDuplicates[Cases[value,PolyLog[2,_],Infinity]];
 Do[argument=Last[term];
  If[TrueQ[FullSimplify[argument>1,conditions]],
   AppendTo[rules,term->Pi^2/3-Log[argument]^2/2-PolyLog[2,1/argument]-I Pi Log[argument]]],
  {term,polylogs}];
 converted=value/.rules;
 atoms=DeleteDuplicates[Cases[converted,_Log|_PolyLog,Infinity]];
 domains=AssociationMap[Function[term,Switch[Head[term],
   Log,FullSimplify[Last[term]>0,conditions],
   PolyLog,FullSimplify[Element[Last[term],Reals]&&Last[term]<1,conditions],
   _,False]],atoms];
 gate["physical logarithms and dilogarithms have proved real domains",And@@Values[domains]];
 symbols=Table[Unique["physicalRealFunction"],Length[atoms]];
 forward=Thread[atoms->symbols];backward=Thread[symbols->atoms];
 algebraic=converted/.forward;
 hermitian=Expand[ComplexExpand[algebraic+Conjugate[algebraic]]]/.backward;
 (* These numerical samples supplement the exact domain/branch conversion;
    they are not reported as a proof of symbolic equality. *)
 points={{Q2->4,s->3,t->-2,mu->2,SUNN->3,Nf->4,eps->1/37},
   {Q2->7,s->11,t->-5,mu->3,SUNN->3,Nf->5,eps->1/43},
   {Q2->5,s->2,t->-6,mu->7/3,SUNN->3,Nf->3,eps->1/31}};
 residuals=Table[Abs[N[(First[rule]-Last[rule])/.point,60]],{rule,rules},{point,points}];
 gate["principal-branch conversion numerical cross-check",And@@(#<10^-50&/@Flatten[residuals])];
 <|"value"->hermitian,"pre_Hermitian_converted"->converted,"branch_rules"->rules,
  "real_function_domains"->domains,"conditions"->conditions,
  "conversion_identity"->HoldComplete[PolyLog[2,x]+PolyLog[2,1/x]==-Pi^2/6-Log[-x]^2/2],
  "conjugate_branch_identity"->HoldComplete[Conjugate[PolyLog[2,x]]==Conjugate[PolyLog[2,x-I 0]]==PolyLog[2,x+I 0]],
  "branch"->"Principal PolyLog on x>1; Log[-x]=Log[x]+I Pi. Conjugate[PolyLog[2,x]] is the value just above the cut. Original archived values retained.",
  "numerical_settings"-><|"precision_digits"->60,"absolute_tolerance"->10^-50,"points"->points|>,
  "numerical_conversion_residuals"->residuals|>];
