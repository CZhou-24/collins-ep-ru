(* Explicit flavor contract inherited from the saved inclusive channel labels.
   A flavor is {species,sign}, sign=+1 for quark and -1 for antiquark.
   quarkCharge[species] is the quark charge; no fitted PDF or TMD is supplied.
   The sum over spectators contains quark species once, not twice. *)
ClearAll[HSFlavorKind,HSFlavorCharge,HSOtherChargeMoment,HSFlavorRules,
 HSUUFlavorRoutes,HSUTFlavorRoutes,HSJetFlavorRoutes];
HSFlavorKind["g"]:="g";
HSFlavorKind[{species_,sign_}]:="q";
HSFlavorCharge[{species_,sign_}]:=sign quarkCharge[species];
HSOtherChargeMoment[species_,power_,nf_]:=
 Inactive[Sum][quarkCharge[spectator]^power,{spectator,1,nf}]-quarkCharge[species]^power;
HSFlavorRules[channel_,incoming_,outgoing_,nf_]:=Switch[channel,
 "Hqq",{eq->quarkCharge[incoming[[1]]],
   otherChargeMoment[1]->HSOtherChargeMoment[incoming[[1]],1,nf],
   otherChargeMoment[2]->HSOtherChargeMoment[incoming[[1]],2,nf],
   otherChargeMoment1->HSOtherChargeMoment[incoming[[1]],1,nf],
   otherChargeMoment2->HSOtherChargeMoment[incoming[[1]],2,nf]},
 "Hqqbar",{eq2->quarkCharge[incoming[[1]]]^2,eq->quarkCharge[incoming[[1]]]},
 "Hqg",{eq->quarkCharge[incoming[[1]]]},
 "Hgq",{eq->quarkCharge[outgoing[[1]]]},
 "Hgg",{chargeSum->Inactive[Sum][quarkCharge[species]^2,{species,1,nf}]},
 "Hqqprime",{eq->HSFlavorCharge[incoming],eqp->HSFlavorCharge[outgoing]}];

(* Each route is {incoming,outgoing,weight}. The sums and species restriction
   are explicit in the assembly evidence, with no charge-symmetric FF model. *)
HSUUFlavorRoutes["Hqq"]:={{{i,sigma},{i,sigma},1}};
HSUUFlavorRoutes["Hqqbar"]:={{{i,sigma},{i,-sigma},1}};
HSUUFlavorRoutes["Hqg"]:={{{i,sigma},"g",1}};
HSUUFlavorRoutes["Hgq"]:={{"g",{i,sigma},1}};
HSUUFlavorRoutes["Hgg"]:={{"g","g",1}};
HSUUFlavorRoutes["Hqqprime"]:={{{i,sigma},{j,tau},1-KroneckerDelta[i,j]}};
HSUTFlavorRoutes["Hqq"]:=HSUUFlavorRoutes["Hqq"];
HSUTFlavorRoutes["Hqqbar"]:=HSUUFlavorRoutes["Hqqbar"];
HSJetFlavorRoutes["U",parent_List]:={{parent,1},{"g",1}};
HSJetFlavorRoutes["U","g"]:={{"g",1},{{j,tau},1}};
HSJetFlavorRoutes["T",parent_List]:={{parent,1}};
