Get[FileNameJoin[{DirectoryName[$InputFileName],"native_io.wl"}]];
c=Import[Environment["COLLINS_RU_REEXPORT"],"RawJSON"];
p=Get[c["input"]];
If[!AssociationQ[p],Print["Native artifact must be an Association"];Exit[1]];
exactQ[x_]:=MatchQ[x,_RUExact]&&FreeQ[x,_Real];
If[c["mode"]==="packet"&&KeyExistsQ[p,"values"],
 Do[If[!exactQ[v["constant"]]||!exactQ[v["value"]]||!And@@(exactQ[#["factor"]]& /@ v["terms"]),Print["Native value fields require raw RUExact expressions"];Exit[1]],{v,Values[p["values"]]}];
 Do[If[!And@@(exactQ /@ f["denominators"])||!And@@((exactQ[#["integrand"]]&&exactQ[#["numerator"]])& /@ f["targets"]),Print["Native integrand fields require raw RUExact expressions"];Exit[1]],{f,Lookup[p,"families",{}]}]
];
result=If[c["mode"]==="masters",Map[RUTree,p],RUEncode[p]];
If[!FreeQ[result,_Real|Indeterminate|ComplexInfinity|_DirectedInfinity],Print["Inexact/nonfinite export"];Exit[1]];
Export[c["output"],result,"RawJSON"];
Exit[0];
