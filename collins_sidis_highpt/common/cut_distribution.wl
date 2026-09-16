(* Scalar cut-master endpoint algebra reused verbatim from SIDIS/common/s17_assemble_real.wl.
Source SHA256: 1df84e6817fdcf4b0db8c588d1083a9be499530c63ba10b6cb9991083d1f77e5.
This file imports an algorithm, not unpolarized numerator coefficients.
Callers provide actual new coefficients and explicitly matched archived master inputs. *)
branchAssumptions[sign_] := Q2>0&&s>0&&omega>0&&B>0&&
  -Q2-s<sign omega-s<0&&SUNN>1&&Nc>1;
reduce[value_,assumptions_] := Module[{refined,functions},
  refined=Refine[value,assumptions];
  functions=DeleteDuplicates[Cases[refined,_Log|_PolyLog|_ArcTan|_Re|_Im,Infinity]];
  Collect[Expand[refined],functions,Factor]];
epsilonSeries[value_,order_,label_] := Module[{series},
  series=bounded[Series[value,{eps,0,order}],label];
  gate[label<>" regulator coverage",FreeQ[series,eps|_SeriesData|_Series]||(MatchQ[series,_SeriesData]&&series[[5]]>order)];
  Normal[series]];
endpointIntegral=Integrate[rr^(-1-kap ep),{rr,0,B},
  Assumptions->kap>0&&ep<0&&B>0,GenerateConditions->False];
gate["regulated endpoint integral evaluated",FreeQ[endpointIntegral,_Integrate|_ConditionalExpression]];
logKernel=Normal[Series[Exp[-kap ep ellLog],{ep,0,2}]];
laurentProduct[laurent_,kernel_,order_] := Module[{polynomial=Expand[laurent],first,last},
  If[polynomial===0,Return[0]];
  first=Exponent[polynomial,eps,Min];last=Exponent[polynomial,eps];
  Total@Table[eps^n Coefficient[polynomial,eps,n] Normal[Series[kernel,{eps,0,order-n}]],{n,first,last}]];

softPieces[master_,sign_] := softPieces[master,sign]=Module[
  {data,metadata,assumptions,replacement,power,prefactor,value,pieces={},entry,
   definition,parameterRules,lambdaForm,lambdaPower,lambdaRegular,totalPower,regular},
  data=inputs["Masters"][master];metadata=regions["Masters"][master];
  assumptions=branchAssumptions[sign]&&w>0;
  replacement=t->sign omega-s;
  power=metadata["PrefactorSoftPower"];
  prefactor=bounded[FullSimplify[(data["RegulatedPrefactor"]/w^power)/.replacement,
    assumptions&&Element[eps,Reals]],"remove regulated cut recoil power"];
  If[metadata["DivergentParameters"]==={},
    value=(evaluations["Classes"][data["Class"]]["Series"]/.SubTropica`eps->eps)/.
      data["PhysicalSubstitutions"]/.replacement;
    Return[{<|"Power"->power,"Regular"->prefactor value|>}]];
  definition=regions["RegionMasterMap"][master]["ParameterDefinition"];
  parameterRules=Solve[First[definition]==Last[definition],SubTropica`\[Lambda]];
  gate["unique physical soft-region parameter",Length[parameterRules]===1];
  lambdaForm=Factor[SubTropica`\[Lambda]/.First[parameterRules]/.data["PhysicalSubstitutions"]/.replacement];
  lambdaPower=bounded[FullSimplify[Limit[w D[lambdaForm,w]/lambdaForm,w->0,
    Direction->"FromAbove",Assumptions->branchAssumptions[sign]],branchAssumptions[sign]],"region recoil valuation"];
  gate["region recoil valuation is a positive integer",IntegerQ[lambdaPower]&&lambdaPower>0];
  lambdaRegular=Factor[lambdaForm/w^lambdaPower];
  gate["region expansion remains on its positive physical side",
    FullSimplify[Limit[lambdaRegular,w->0,Direction->"FromAbove",Assumptions->branchAssumptions[sign]]>0,
      branchAssumptions[sign]]];
  Do[
    value=regions["RegionValues"][entry["IntegralID"]]["Series"];
    If[value===0,Continue[]];
    totalPower=Expand[power+lambdaPower(entry["LambdaPower"]/.SubTropica`eps->eps)];
    regular=prefactor lambdaRegular^(entry["LambdaPower"]/.SubTropica`eps->eps) value;
    AppendTo[pieces,<|"Power"->totalPower,"Regular"->regular,"Region"->entry["Region"]|>],
    {entry,regions["RegionMasterMap"][master]["Entries"]}];pieces];

pieceEndpoint[piece_,sign_] := pieceEndpoint[piece,sign]=bounded[
  FullSimplify[Limit[piece["Regular"],w->0,Direction->"FromAbove",
    Assumptions->branchAssumptions[sign]&&Element[eps,Reals]],
    branchAssumptions[sign]&&Element[eps,Reals]],"regular master endpoint"];
softRows[coefficient_,piece_,sign_] := Module[
  {power=piece["Power"],integerPower,kappa,rational,valuation,firstPower,leading,value},
  integerPower=power/.eps->0;kappa=-Coefficient[power,eps];
  gate["regulated soft power is affine with integer recoil degree",
    IntegerQ[integerPower]&&PolynomialQ[power,eps]&&Exponent[power,eps]<=1];
  rational=Cancel[coefficient/.t->sign omega-s];
  valuation=Exponent[Numerator[rational],w,Min]-Exponent[Denominator[rational],w,Min];
  firstPower=valuation+integerPower;
  If[firstPower>=0,Return[{}]];
  gate["measured recoil degree needs only a leading endpoint coefficient",firstPower===-1];
  leading=Factor[Cancel[w^(-valuation)rational]/.w->0];
  gate["rational endpoint coefficient is finite",FreeQ[leading,w|Indeterminate|ComplexInfinity|_DirectedInfinity]];
  value=epsilonSeries[(leading/.D->4-2eps)pieceEndpoint[piece,sign],1,"leading soft epsilon coefficient"];
  value=bounded[reduce[value,branchAssumptions[sign]],"leading endpoint collection"];
  gate["endpoint coefficients are fully evaluated",FreeQ[value,w|_Limit|_Derivative|_Series|_SeriesData|Indeterminate|ComplexInfinity]];
  If[value===0,{},{{kappa,firstPower,value}}]];

