(* Fresh vector-current integrand, ordinary Kira reduction inputs.
   SIDIS algorithms: s14 mapScalar reconstruction; s09 bounds/job export.
   Neither SIDIS historical inputs nor old Collins coefficient exports are read. *)
Get[FileNameJoin[{DirectoryName[$InputFileName],"ru_virtual_io.wl"}]];RUvBegin["r04"];
RUvLoadFC[];
Get[FileNameJoin[{$RUvContext["production"],"common","ru_virtual_generate.wl"}]];
den={d0,d1,d2};
Clear[RUvScalarMap];
RUvScalarMap[expression_]:=Module[{terms,powers,coefficient,mapped,reconstructed},
 terms=If[Head[Expand[expression]]===Plus,List@@Expand[expression],{Expand[expression]}];
 mapped=Total[Map[Function[term,
  powers=Table[Exponent[Numerator[Together[term]],z]-Exponent[Denominator[Together[term]],z],{z,den}];
  coefficient=Cancel[term/(Times@@(den^powers))];
  RUvGate["scalar coefficient contains no loop coordinate",FreeQ[coefficient,d0|d1|d2]];
  coefficient Apply[V,-powers]],terms]];
 reconstructed=mapped/.V[va_,vb_,vc_]:>d0^(-va)d1^(-vb)d2^(-vc);
 If[Factor[Together[reconstructed-expression]]=!=0,RUvPut[<|"input"->expression,"mapped"->mapped,"reconstructed"->reconstructed,"residual"->Factor[Together[reconstructed-expression]]|>,"scalar_map_failure.wl"]];
 RUvGate["exact rational loop reconstruction",Factor[Together[reconstructed-expression]]===0];mapped];
targetExpression=RUvScalarMap[poly/(d0 d1 d2)];
dotDerivatives={{2 d0,d0+d1,d0+d2},{d1-d0,d1-d0,d1-d0+Q2},{d2-d0,d2-d0+Q2,d2-d0}};
ibpIntegrands=Table[(If[j==1,D,0]-Sum[dotDerivatives[[j,i]]/den[[i]],{i,3}])/(d0 d1 d2),{j,3}];
ibp=RUvScalarMap /@ ibpIntegrands;
targets=Union[Cases[{targetExpression,ibp,V[1,1,1],V[0,1,1]},_V,Infinity]];
indices=List@@#& /@targets;
positiveSums=Total[Select[#,#>0&]]& /@indices;
negativeSums=-Total[Select[#,#<0&]]& /@indices;
sectors=Sort[DeleteDuplicates[Total[MapIndexed[If[#1>0,2^(First[#2]-1),0]&,#]]& /@indices]];
topSectors=Select[sectors,Function[sector,!AnyTrue[DeleteCases[sectors,sector],BitAnd[sector,#]===sector&]]];
rBound=Max[positiveSums]+1;sBound=Max[negativeSums]+1;
job=RUvPath["jobs/virtual"];CreateDirectory[FileNameJoin[{job,"config"}],CreateIntermediateDirectories->True];
text[x_]:=StringReplace[ToString[x,InputForm],Whitespace->""];
csv[x_]:="["<>StringRiffle[text/@x,","]<>"]";
Export[FileNameJoin[{job,"config","integralfamilies.yaml"}],
 "integralfamilies:\n  - name: V\n    loop_momenta: [ell]\n    top_level_sectors: "<>csv[topSectors]<>"\n    propagators:\n      - [ell, 0]\n      - [ell+p, 0]\n      - [ell+pout, 0]\n","Text"];
Export[FileNameJoin[{job,"config","kinematics.yaml"}],
 "kinematics:\n  incoming_momenta: [p,pout]\n  outgoing_momenta: []\n  kinematic_invariants:\n    - [q2, 2]\n  scalarproduct_rules:\n    - [[p,p], 0]\n    - [[pout,pout], 0]\n    - [[p,pout], q2/2]\n","Text"];
Export[FileNameJoin[{job,"targets"}],StringRiffle[text/@targets,"\n"]<>"\n","Text"];
Export[FileNameJoin[{job,"preferred"}],"V[0,1,1]\n","Text"];
Export[FileNameJoin[{job,"jobs.yaml"}],
 "jobs:\n  - reduce_sectors:\n      reduce:\n        - {topologies: [V], sectors: "<>csv[topSectors]<>", r: "<>text[rBound]<>", s: "<>text[sBound]<>"}\n      select_integrals:\n        select_mandatory_list:\n          - [targets]\n      preferred_masters: preferred\n      run_initiate: true\n      run_triangular: true\n      run_back_substitution: true\n  - kira2math:\n      target:\n        - [targets]\n","Text"];
RUvPut[<|"scalar_numerator"->poly,"denominators"->den,"target_expression"->targetExpression,
 "targets"->targets,"independent_IBP_divergences"->ibp,"IBP_integrands"->ibpIntegrands,
 "open_current"->openScalar,"loop_prefactor"->loopColor,
 "r_bound"->rBound,"s_bound"->sBound,
 "measure"->"SIDIS unnormalized Minkowski d^D ell with muDR^(2 eps)/(2 Pi)^D; normalized conversion is derived in r05/r06",
 "boundary"->"Uncut ordinary Feynman integrals, dimensional analytic continuation; no measurement theta boundary is inserted in this virtual current.",
 "physical_support"->Q2>0,"propagator_i0"->"Every denominator has +i0; q=p-pout is spacelike."|>,"virtual_map.wl"];
familyTargets=Map[Function[target,With[{powers=List@@target,
 coefficient=Coefficient[Expand[targetExpression],target]},
 <|"powers"->powers,"numerator"->RUExact[If[coefficient===0,1,coefficient]],
 "integrand"->RUExact[If[coefficient===0,1,coefficient]/Times@@(den^powers)]|>]],targets];
packet=<|"schema"->5,"stage"->"r04","values"-><||>,
 "families"->{<|"id"->"V","denominators"->(RUExact/@den),"cuts"->{},"targets"->familyTargets|>},
 "jobs"->{<|"id"->"virtual","inputs"->{"jobs.yaml","config/integralfamilies.yaml","config/kinematics.yaml","targets","preferred"},
  "outputs"->{"results/V/kira_targets.m","results/V/masters.final"},"master_inventory"->"results/V/masters.final",
  "families"->{"V"},"sectors"->{"hard_virtual"}|>},
 "evidence"-><|
  "r04/generated_vertex"->RUvEvidence["generated_vertex.wl","amplitudes",{"source/r04","source/r00"}],
  "r04/generated_self_energy"->RUvEvidence["generated_self_energy.wl","amplitudes",{"source/r04"}],
  "r04/open_current"->RUvEvidence["open_current.wl","integrands",{"r04/generated_vertex"}],
  "r04/integrands"->RUvEvidence["integrands.wl","integrands",{"r04/open_current","r04/generated_self_energy"}],
  "r04/loop_mapping"->RUvEvidence["virtual_map.wl","loop_mapping",{"r04/integrands"}]|>|>;
RUvPut[packet,"packet.wl"];Print["R04_INPUTS_COMPLETE"];Quit[0];
