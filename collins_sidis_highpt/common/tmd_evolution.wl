(* Imported one-loop anomalous dimensions, pinned 2311.00672v2 Sec.3.1.1.
   The input TMD is already soft subtracted and has zetaJ=(pJT R)^2.
   These functions do not specify its nonperturbative boundary condition.
   Return d ln F/d ln mu^2 divided by a=alpha_s/(2 Pi). *)
HSTMDMuGamma["q",L_]:=CF(L+3/2);
HSTMDMuGamma["g",L_]:=CA L+beta0/2;
(* d ln F/d ln nu divided by a for the unsubtracted factors. *)
HSUnsubtractedTMDNuGamma[color_,Lb_]:=2color Lb;
HSInJetSoftNuGamma[color_,Lb_]:=-2color Lb;
(* Collins-Soper kernel at perturbative small b, supplied only as a
   convention/RG check. No small-b OPE is imposed on the physical input TMD. *)
HSPerturbativeCSKernel[color_,Lb_,a_]:=-2a color Lb;
