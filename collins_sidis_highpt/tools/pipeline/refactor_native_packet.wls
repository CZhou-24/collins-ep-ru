(* Focused or stage-owned exact certificate representation. Existing packet
   evidence is never overwritten; caller supplies distinct input/output paths. *)
$HistoryLength=0;root=DirectoryName[DirectoryName[DirectoryName[DirectoryName[$InputFileName]]]];
cfg=Import[Environment["SIDIS_CERTIFICATE_DAG_CONTEXT"],"RawJSON"];
input=cfg["input"];out=cfg["output"];If[FileExistsQ[out],Exit[1]];
helper=FileNameJoin[{root,"collins_sidis_highpt","common","native_certificate_dag.wl"}];Get[helper];
packet=Get[input];masters=<||>;shapeProof=Missing["NotRequested"];shapeFiles={};
KeyValueMap[Function[{prefix,file},part=Get[file];
 masters=Join[masters,If[prefix==="",part,Association[KeyValueMap[(prefix<>#1)->#2&,part]]]]],cfg["masters"]];
If[TrueQ[Lookup[cfg,"attach_evidence",False]]&&!KeyExistsQ[cfg,"nominal_banks"],Print["FIXED_NOMINAL_BANKS_REQUIRED"];Exit[2]];
If[KeyExistsQ[cfg,"nominal_banks"],
 shapeHelper=FileNameJoin[{root,"collins_sidis_highpt","common","native_master_shape.wl"}];Get[shapeHelper];
 nominal=<||>;KeyValueMap[Function[{prefix,file},bank=Get[file];
  nominal=Join[nominal,Association[KeyValueMap[(prefix<>#1)->#2&,bank["values"]]]]],cfg["nominal_banks"]];
 aligned=CheckAbort[HSAlignMasterDenominators[packet,nominal,masters],Exit[2]];
 packet=aligned["packet"];shapeProof=KeyDrop[aligned,"packet"];shapeFiles=Join[{shapeHelper},Values[cfg["nominal_banks"]]]];
result=CheckAbort[HSCertificateDAG[packet,masters],Exit[2]];
proof=Join[KeyDrop[result,"packet"],<|"master_denominator_shapes"->shapeProof,"source_sha256"->AssociationMap[IntegerString[FileHash[#,"SHA256"],16,64]&,
 Join[{input,helper,$InputFileName},Values[cfg["masters"]],shapeFiles]]|>];
Put[proof,cfg["proof"]];finalPacket=result["packet"];
If[TrueQ[Lookup[cfg,"attach_evidence",False]],
 proofID=finalPacket["stage"]<>"/certificateTransport";
 evidence=Map[Join[#,<|"parents"->Append[#["parents"],proofID]|>]&,finalPacket["evidence"]];
 AssociateTo[evidence,proofID-><|"path"->FileNameTake[cfg["proof"]],"role"->"conversion",
  "parents"->{"source/"<>finalPacket["stage"]}|>];
 AssociateTo[finalPacket,"evidence"->evidence]];
Put[finalPacket,out];
Export[cfg["summary"],<|"original_certificates"->result["original_certificates"],
 "shared_polynomial_nodes"->result["shared_polynomial_nodes"],"qualification"->result["qualification"]|>,"RawJSON"];
Print["CERTIFICATE_DAG_PRODUCED ",Length[result["packet"]["values"]]];Exit[0];
