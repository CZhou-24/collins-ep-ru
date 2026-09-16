(* Extract saved scalar masters without evaluating arbitrary selector strings.
   Input files are trusted native Wolfram artifacts, hash-bound by the runner. *)
c = Import[Environment["SIDIS_EXTRACT_CONTEXT"], "RawJSON"];
gate[test_, message_] := If[!TrueQ[test], Print[message]; Exit[1]];
data = Get[c["input"]];
select[path_List] := Fold[Function[{value, key},
  Which[StringQ[key] && AssociationQ[value] && KeyExistsQ[value, key], value[key],
        IntegerQ[key] && ListQ[value] && 1 <= key <= Length[value], value[[key]],
        True, Print["Invalid saved-master selector: ", InputForm[path]]; Exit[1]]], data, path];
extract[key_, path_] := Module[{val = select[path], order = c["orders"][key], variable},
  If[MatchQ[val, _SeriesData],
    variable = val[[1]];
    gate[SymbolName[variable] === "eps" && val[[2]] === 0 && val[[5]]/val[[6]] > order,
      "Saved series has insufficient epsilon depth or a different expansion variable"];
    val = Normal[val] /. variable -> Global`eps];
  val];
masters = Association[KeyValueMap[(#1 -> extract[#1, #2]) &, c["selections"]]];
gate[AssociationQ[masters] && Length[masters] > 0, "Empty saved-master selection"];
gate[FreeQ[masters, _Real | $Failed | $Aborted | Indeterminate | ComplexInfinity | _DirectedInfinity], "Inexact or failed saved master"];
gate[FreeQ[masters, _SeriesData], "Unresolved nested series in saved-master selection"];
Put[masters, c["output"]];
Exit[0];
