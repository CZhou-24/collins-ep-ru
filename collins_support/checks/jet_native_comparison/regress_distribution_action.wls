(* Native regression of the actual production DownValue. No copied definition.
   Independent analytic expectations on [0,1]:
   delta: 3 (1+1^2) = 6;
   plus0: 2 Integrate[(z-1)/(1-z)] = -2;
   plus1: 3 Integrate[Log[1-z](z-1)/(1-z)] = 3;
   regular: Integrate[(1+z)(1+z^2)] = 25/12. *)
ClearAll["Global`*"];
jrRoot = Nest[DirectoryName, $InputFileName, 4];
jrSource = FileNameJoin[{jrRoot, "collins_sidis_highpt", "common", "jet_matching.wl"}];
jrOut = Environment["JET_ACTION_REGRESSION_OUT"];
If[!StringQ[jrOut] || jrOut == "" || DirectoryQ[jrOut],
 Print["Set JET_ACTION_REGRESSION_OUT to an unused report directory."]; Exit[2]];
jrOut = ExpandFileName[jrOut];
If[!StringStartsQ[jrOut, FileNameJoin[{jrRoot, "collins_support", "reports"}] <> "/"],
 Print["Regression outputs must be under collins_support/reports."]; Exit[2]];
CreateDirectory[jrOut, CreateIntermediateDirectories -> True];
Get[jrSource];
jrString[x_] := ToString[x, InputForm];
jrCases = {
 {"delta", <|"delta" -> 3, "plus0" -> 0, "plus1" -> 0, "regular" -> 0|>, 1+z^2, 6},
 {"plus0", <|"delta" -> 0, "plus0" -> 2, "plus1" -> 0, "regular" -> 0|>, z, -2},
 {"plus1", <|"delta" -> 0, "plus0" -> 0, "plus1" -> 3, "regular" -> 0|>, z, 3},
 {"regular", <|"delta" -> 0, "plus0" -> 0, "plus1" -> 0, "regular" -> 1+z|>, 1+z^2, 25/12}
};
jrRows = Table[
 jrActual = FullSimplify[Activate[HSJetDistributionAction[jrCase[[2]], jrCase[[3]], z]]];
 jrResidual = FullSimplify[jrActual - jrCase[[4]]];
 <|"component" -> jrCase[[1]], "coefficients" -> jrString[jrCase[[2]]],
   "test_function" -> jrString[jrCase[[3]]], "actual" -> jrString[jrActual],
   "expected" -> jrString[jrCase[[4]]], "residual" -> jrString[jrResidual],
   "tolerance" -> "0 (exact symbolic)", "pass" -> TrueQ[jrResidual === 0]|>,
 {jrCase, jrCases}];
jrPassed = Count[Lookup[jrRows, "pass"], True];
jrResult = <|"status" -> If[jrPassed == 4, "PASS", "FAIL"],
 "passed" -> jrPassed, "total" -> 4, "source" -> jrSource,
 "source_sha256" -> FileHash[jrSource, "SHA256", "HexString"],
 "regression_sha256" -> FileHash[$InputFileName, "SHA256", "HexString"],
 "wolfram_version" -> $Version, "assumptions" -> "real integration variable 0 < z < 1; smooth polynomial test functions",
 "downvalues" -> jrString[DownValues[HSJetDistributionAction]], "rows" -> jrRows|>;
Put[<|"downvalues" -> DownValues[HSJetDistributionAction], "cases" -> jrCases,
 "results" -> jrRows|>, FileNameJoin[{jrOut, "regression.wl"}]];
Export[FileNameJoin[{jrOut, "regression.json"}], jrResult, "RawJSON"];
Scan[Print[#component, ": ", If[#pass, "PASS", "FAIL"], "; actual=", #actual,
 "; expected=", #expected, "; residual=", #residual] &, jrRows];
Print["Native distribution regression: ", jrPassed, "/4; source SHA256 ", jrResult["source_sha256"]];
Exit[If[jrPassed == 4, 0, 2]];
