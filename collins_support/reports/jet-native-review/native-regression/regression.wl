<|"downvalues" -> {HoldPattern[HSJetDistributionAction[c_, test_, z_]] :> 
    c["delta"]*(test /. z -> 1) + Inactive[Integrate][
      c["plus0"]*((test - (test /. z -> 1))/(1 - z)) + 
       c["plus1"]*Log[1 - z]*((test - (test /. z -> 1))/(1 - z)) + 
       c["regular"]*test, {z, 0, 1}]}, 
 "cases" -> {{"delta", <|"delta" -> 3, "plus0" -> 0, "plus1" -> 0, 
     "regular" -> 0|>, 1 + z^2, 6}, {"plus0", <|"delta" -> 0, "plus0" -> 2, 
     "plus1" -> 0, "regular" -> 0|>, z, -2}, 
   {"plus1", <|"delta" -> 0, "plus0" -> 0, "plus1" -> 3, "regular" -> 0|>, z, 
    3}, {"regular", <|"delta" -> 0, "plus0" -> 0, "plus1" -> 0, 
     "regular" -> 1 + z|>, 1 + z^2, 25/12}}, 
 "results" -> {<|"component" -> "delta", "coefficients" -> 
     "<|\"delta\" -> 3, \"plus0\" -> 0, \"plus1\" -> 0, \"regular\" -> 0|>", 
    "test_function" -> "1 + z^2", "actual" -> "6", "expected" -> "6", 
    "residual" -> "0", "tolerance" -> "0 (exact symbolic)", "pass" -> True|>, 
   <|"component" -> "plus0", "coefficients" -> 
     "<|\"delta\" -> 0, \"plus0\" -> 2, \"plus1\" -> 0, \"regular\" -> 0|>", 
    "test_function" -> "z", "actual" -> "-2", "expected" -> "-2", 
    "residual" -> "0", "tolerance" -> "0 (exact symbolic)", "pass" -> True|>, 
   <|"component" -> "plus1", "coefficients" -> 
     "<|\"delta\" -> 0, \"plus0\" -> 0, \"plus1\" -> 3, \"regular\" -> 0|>", 
    "test_function" -> "z", "actual" -> "3", "expected" -> "3", 
    "residual" -> "0", "tolerance" -> "0 (exact symbolic)", "pass" -> True|>, 
   <|"component" -> "regular", "coefficients" -> 
     "<|\"delta\" -> 0, \"plus0\" -> 0, \"plus1\" -> 0, \"regular\" -> 1 + \
z|>", "test_function" -> "1 + z^2", "actual" -> "25/12", 
    "expected" -> "25/12", "residual" -> "0", 
    "tolerance" -> "0 (exact symbolic)", "pass" -> True|>}|>
