(* Adapted from accepted Collins source; exact original and SHA in provenance/COLLINS_SOURCE_REUSE_PLAN.json. *)
(* Shared operations, with no reference results loaded. *)
Gate[label_,test_] := If[!TrueQ[test], Print["FAIL: ",label]; Quit[1]];
ProofPair[left_,right_,assumptions_:True] := <|"lhs"->With[{v=left},HoldComplete[v]],"rhs"->With[{v=right},HoldComplete[v]],"assumptions"->assumptions|>;
ProofHeld[left_HoldComplete,right_HoldComplete,assumptions_:True] := <|"lhs"->left,"rhs"->right,"assumptions"->assumptions|>;
MDot[a_,b_] := a.DiagonalMatrix[{1,-1,-1,-1}].b;
LoadFC[] := (Global`$FAPatch=False;Global`$LoadAddOns={"FeynArts"};Global`$FeynCalcStartupMessages=False;
 Global`$FeynCalcDirectory=$RUContext["runtime"]["feyncalc_root"];
 FeynCalc`$FeynArtsDirectory=$RUContext["runtime"]["feynarts_root"];
 Get[FileNameJoin[{$RUContext["runtime"]["feyncalc_root"],"FeynCalc.m"}]];
 FeynArts`$FAVerbose=0;FeynCalc`FCSetDiracGammaScheme["BMHV"];
 Gate["no automatic package patch",FeynCalc`$FAPatch===False]);
PhysicalGammas[] := Module[{z=ConstantArray[0,{2,2}],id=IdentityMatrix[2],sigma},
 sigma={{{0,1},{1,0}},{{0,-I},{I,0}},{{1,0},{0,-1}}};
 Prepend[(ArrayFlatten[{{z,#},{-#,z}}]& /@ sigma),ArrayFlatten[{{id,z},{z,-id}}]]];
PhysicalSlash[v_,g_] := Sum[{1,-1,-1,-1}[[i]] v[[i]] g[[i]],{i,4}];
CMVectors[] := <|"p"->en {1,0,0,1},"l"->en {1,0,0,-1},"pout"->en {1,st,0,ct},"lout"->en {1,-st,0,-ct},"Xi"->{0,1,0,0},"Xo"->{0,ct,0,-st},"N"->{0,0,1,0}|>;
CMConditions = en>0 && -1<ct<1 && st>0 && ct^2+st^2==1;
CMInvariants = {s->4 en^2,t->-2 en^2 (1-ct),u->-2 en^2 (1+ct)};

