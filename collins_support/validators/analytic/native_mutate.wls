(* Nonphysical dependency probes, confined to copied inputs. *)
c=Import[Environment["COLLINS_RU_MUTATION"],"RawJSON"];
gate[test_,message_]:=If[!TrueQ[test],Print[message];Exit[1]];
gate[IntegerQ[c["numerator"]]&&IntegerQ[c["denominator"]]&&c["denominator"]!=0,"Invalid probe factor"];
factor=c["numerator"]/c["denominator"];
gate[factor!=0&&factor!=1,"Trivial probe factor"];
If[c["kind"]==="master",
 p=Get[c["path"]];gate[AssociationQ[p]&&KeyExistsQ[p,c["key"]],"Missing probe master"];
 p[c["key"]]=factor*p[c["key"]];Put[p,c["path"]],
 gate[c["kind"]==="kira"&&c["scope"]==="complete_audited_reduction_map","Unsupported mutation scope"];
 gate[ListQ[c["jobs"]]&&Length[c["jobs"]]>0,"No mutation jobs"];
 Do[
  paths=job["paths"];gate[ListQ[paths]&&Length[paths]>0&&DuplicateFreeQ[paths],"Invalid rule paths"];
  lists=Get /@ paths;
  gate[And@@(MatchQ[#,{__Rule}]& /@ lists)&&FreeQ[lists,_Real|$Failed|$Aborted],"Unsupported Kira rule format"];
  raw=DeleteDuplicates[Flatten[lists]];
  gate[DuplicateFreeQ[First /@ raw],"Conflicting raw reduction rules"];
  cert=Get[job["certificate"]];
  gate[AssociationQ[cert]&&MatchQ[cert["rules"],{__Rule}],"Missing baseline audited reduction"];
  complete=cert["rules"];gate[DuplicateFreeQ[First /@ complete],"Duplicate certificate targets"];
  gate[Complement[First /@ raw,First /@ complete]==={},"Raw rule outside certificate"];
  gate[And@@(Function[row,TrueQ[Together[(First[row]/.complete)-Last[row]]===0]] /@ raw),"Copied rules differ from baseline certificate"];
  missing=Complement[First /@ complete,First /@ raw];
  gate[Complement[missing,cert["masters"]]==={}&&Complement[missing,cert["targets"]]==={},"Only audited master identities may be added"];
  gate[And@@(TrueQ[(#/.complete)===#]& /@ missing),"Missing rule is not an identity"];
  (* Uniformly scale the complete reduction operator, including implicit M->M
     targets. These files are disposable; evaluated master values do not change. *)
  changed=(#/.Rule[l_,r_]:>Rule[l,factor*r])& /@ lists;
  changed[[1]]=Join[changed[[1]],(#->factor #& /@ missing)];
  MapThread[Put,{changed,paths}],
 {job,c["jobs"]}]
];
Exit[0];
