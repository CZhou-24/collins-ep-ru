(* Source-defined strict first-order and distribution algorithms; provenance/assembly/SOURCE_PREUSE.json. No historical inputs. *)
RUObservablePolynomial[hard_,soft_,jetU_,jetT_]:=Module[{uu,ut},
 uu=Expand[HUU (1+a hard)(1+a soft)(1+a jetU)(f0+a f1)(D0+a D1)];
 ut=Expand[HUT (1+a hard)(1+a soft)(1+a jetT)(h0+a h1)(C0+a C1)];
 <|"UU0"->Coefficient[uu,a,0],"UT0"->Coefficient[ut,a,0],
   "UU1"->Coefficient[uu,a,1],"UT1"->Coefficient[ut,a,1]|>];
RUObservableUAction[part_String,expr_,lower_]:=Module[{endpoint=expr/.u->1},
 Switch[part,"regular",Inactive[Integrate][expr,{u,lower,1}],"delta",endpoint,
 "D0",Inactive[Integrate][(expr-endpoint)/(1-u),{u,lower,1}]+endpoint Log[1-lower],
 "D1",Inactive[Integrate][Log[1-u](expr-endpoint)/(1-u),{u,lower,1}]+endpoint Log[1-lower]^2/2]];
RUObservableHFAction[kernel_Association,fraction_]:=Module[{phi,endpoint,derivative,test,parts},
 phi=HFNative[flavor,fraction/u,fraction/(u v),mu]/u;
 endpoint=phi/.v->1;derivative=D[phi,v]/.v->1;
 parts={"regular","delta","D0","D1"};
 Total[Table[
  test=Inactive[Integrate][(kernel[part]/.zh->fraction)(phi-endpoint-(v-1)derivative),{v,0,1}]+
    (kernel["v_delta_"<>part]/.zh->fraction)endpoint-
    (kernel["v_derivative_"<>part]/.zh->fraction)derivative;
  RUObservableUAction[part,test,fraction],{part,parts}]]];
