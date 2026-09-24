#!/usr/bin/env wolframscript
(* Regression: a compact-basis block with more than 999 colour/charge monomials
   must export every coefficient under a unique identifier and reconstruct the
   input exactly. Before the fix, IntegerString[n,10,3] wrapped index 1000 to
   "000" and 1001 onwards overwrote 001 onwards, silently dropping terms while
   the polynomial-reconstruction gate, evaluated before IDs were assigned,
   still passed. No physics input is used: the block is a synthetic polynomial. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
failures={};
gate[name_,test_]:=If[!TrueQ[test],AppendTo[failures,name];Print["COMPACT_BASIS_ID_FAILED ",name]];
helpers=FileNameJoin[{root,"collins_sidis_highpt","common",#<>".wl"}]&/@{"native_linear","transcendental_basis","native_compact_basis_linear"};Get/@helpers;
Get[FileNameJoin[{root,"collins_support","validators","analytic","native_io.wl"}]];

(* 1. the identifier helper itself never truncates *)
ids=HSCompactIndex/@Range[1,1203];
gate["helper keeps three-digit padding below 1000",HSCompactIndex[7]==="007"&&HSCompactIndex[999]==="999"];
gate["helper widens at 1000",HSCompactIndex[1000]==="1000"&&HSCompactIndex[1001]==="1001"];
gate["helper identifiers unique through 1203",DuplicateFreeQ[ids]];

(* 2. a synthetic block with 1003 monomials in SUNN, Q2 and w, no master terms *)
monomials=Flatten[Table[SUNN^i Q2^j w^k,{i,0,16},{j,0,6},{k,0,7}]];   (* 17*7*8 = 952 *)
monomials=Join[monomials,Table[SUNN^i Q2^7,{i,0,50}]];                (* +51 = 1003 *)
gate["synthetic block has 1003 monomials",Length[monomials]===1003&&DuplicateFreeQ[monomials]];
coefficients=Table[Prime[n],{n,Length[monomials]}];
polynomial=Expand[coefficients.monomials];
row=HSLinearCreate[polynomial,<||>];
split=HSBasisCertificates["r07/synthetic_block",row,<||>,{"Hqq"},<||>];
exported=Keys[split["values"]];
gate["every monomial exported once",Length[exported]===1003];
gate["exported identifiers unique",DuplicateFreeQ[exported]];
gate["no wrapped identifier",!AnyTrue[exported,StringEndsQ[#,"_c000"]&]];
gate["identifiers 1000..1003 present",And@@(MemberQ[exported,"r07/synthetic_block_b001_c"<>ToString[#]]&/@{1000,1001,1002,1003})];
reconstruction=Expand[Total[KeyValueMap[Factor[split["scalar_values"][#1]]#2&,split["basis"]]]];
gate["exported basis reconstructs the block exactly",Expand[reconstruction-polynomial]===0];
Print["exported identifiers: ",Length[exported],"   reconstruction residual: ",InputForm[Expand[reconstruction-polynomial]]];
If[failures=!={},Print["COMPACT_BASIS_ID_REGRESSION_FAILED ",failures];Exit[2]];
Print["COMPACT_BASIS_ID_REGRESSION_PASS"];Exit[0];
