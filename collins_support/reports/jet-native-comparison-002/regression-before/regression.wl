<|"downvalues" -> {HoldPattern[HSJetDistributionAction[c_, test_, z_]] :> 
    c["delta"]*(test /. z -> 1)}, 
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
    "test_function" -> "z", "actual" -> "0", "expected" -> "-2", 
    "residual" -> "2", "tolerance" -> "0 (exact symbolic)", 
    "pass" -> False|>, <|"component" -> "plus1", 
    "coefficients" -> 
     "<|\"delta\" -> 0, \"plus0\" -> 0, \"plus1\" -> 3, \"regular\" -> 0|>", 
    "test_function" -> "z", "actual" -> "0", "expected" -> "3", 
    "residual" -> "-3", "tolerance" -> "0 (exact symbolic)", 
    "pass" -> False|>, <|"component" -> "regular", 
    "coefficients" -> "<|\"delta\" -> 0, \"plus0\" -> 0, \"plus1\" -> 0, \
\"regular\" -> 1 + z|>", "test_function" -> "1 + z^2", "actual" -> "0", 
    "expected" -> "25/12", "residual" -> "-25/12", 
    "tolerance" -> "0 (exact symbolic)", "pass" -> False|>}|>
