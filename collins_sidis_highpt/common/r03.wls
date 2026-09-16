(* The installed validator owns the stage and all external tool receipts. *)
$HistoryLength=0;
ctx=Import[Environment["SIDIS_HIGHPT_CONTEXT"],"RawJSON"];
result=RunProcess[{"python3",FileNameJoin[{ctx["production"],"tools","pipeline","native_stage_driver.py"}]}];
Print[result["StandardOutput"]];If[result["StandardError"]=!="",Print[result["StandardError"]]];
Exit[result["ExitCode"]];
