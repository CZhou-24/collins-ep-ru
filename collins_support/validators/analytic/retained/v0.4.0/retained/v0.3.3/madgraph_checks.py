"""Verifier-owned native MG5 tree checks; no fitted providers or stored oracle.

The scalar Fortran standalone adapter supports the one-dimensional color bases
of photon-only eq->eq, eq->eqg and eg->eqqbar. Unknown templates fail closed.
Self-tests do NOT establish native MadGraph compatibility on a user's runtime.
"""
from __future__ import annotations

import cmath
import hashlib
import json
import math
import os
from pathlib import Path
import random
import re
import subprocess
import sys
from native_evidence import snapshot_native_tree
from support import access

ALPHA_EM = 1 / 137.035999084
ALPHA_S = .118
CHARGE = 2 / 3
RTOL = 2e-7
ATOL = 2e-10
PROCESSES = {
    "born_eq": {"process": "e- u > e- u / z h QED=2 QCD=0", "n": 4, "average": 12},
    "real_eq": {"process": "e- u > e- u g / z h QED=2 QCD=1", "n": 5, "average": 12},
    "real_eg": {"process": "e- g > e- u u~ / z h QED=2 QCD=1", "n": 5, "average": 32},
}


class Unsupported(RuntimeError):
    """Unavailable runtime or unsupported native interface; acceptance BLOCKED."""


class CommandFailed(RuntimeError):
    """An available command executed but returned a failing status."""


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def record(name, status, detail):
    return {"id": "madgraph." + name, "status": status, "detail": detail}


def close(a, b, scale=1.):
    return math.isfinite(a) and math.isfinite(b) and abs(a-b) <= ATOL*scale + RTOL*max(abs(a), abs(b))


def native_float(value):
    result = float(value.replace("D", "E").replace("d", "e"))
    if not math.isfinite(result):
        raise ValueError("nonfinite native number")
    return result


def dot(a, b):
    return a[0]*b[0] - math.fsum(x*y for x, y in zip(a[1:], b[1:]))


def points(seed, count=6):
    """Seeded physical 2->2 and 2->3 points, independent of candidate code."""
    import real_oracle as clifford
    rng = random.Random("collins-mg-v3:" + str(seed))
    out = []
    for name, spec in PROCESSES.items():
        for i in range(count):
            energy = rng.uniform(8., 35.)
            if name == "born_eq":
                c, phi = rng.uniform(-.65, .65), rng.uniform(-math.pi, math.pi)
                v = [math.sqrt(1-c*c)*math.cos(phi), math.sqrt(1-c*c)*math.sin(phi), c]
                ps = [[energy, 0., 0., -energy], [energy, 0., 0., energy],
                      [energy]+[-energy*x for x in v], [energy]+[energy*x for x in v]]
            else:
                r = clifford.sample(rng, energy)
                ps = [r[k] for k in ("l", "p", "lp", "pp", "k")]
            q = [a-b for a,b in zip(ps[0], ps[2])]
            scale = (2*energy)**2
            # Rare collinear configurations are rejected before requesting values.
            if abs(dot(q,q)) < .005*scale:
                raise ValueError("phase-space generator generated near-forward photon")
            spin_in = clifford.spin(ps[1], rng.uniform(-math.pi, math.pi)) if name != "real_eg" else None
            spin_out = clifford.spin(ps[3], rng.uniform(-math.pi, math.pi)) if name != "real_eg" else None
            request = {"id": f"{name}.{i}", "process": name, "momenta": ps,
                       "incoming": [11, 21 if name == "real_eg" else 2],
                       "outgoing": [11,2]+([21] if name == "real_eq" else [-2] if name == "real_eg" else []),
                       "spin_in": spin_in, "spin_out": spin_out,
                       "alpha_em": ALPHA_EM, "alpha_s": ALPHA_S, "quark_charge": CHARGE,
                       "normalization": "full_couplings_initial_spin_color_average_no_flux",
                       "convention_baseline": "SIDIS_dsigma_till_NLO; adapter must document conversion from pinned repository conventions",
                       "metric": "+---",
                       "momentum_order": "incoming electron, incoming parton, outgoing electron, outgoing quark, optional outgoing gluon or antiquark",
                       "UT_definition": "double_transverse_quark_spin_coefficient"}
            validate_point(request)
            out.append(request)
    return out


def validate_point(r):
    p = r["momenta"]
    if len(p) != PROCESSES[r["process"]]["n"]:
        raise ValueError("external-leg count")
    if any(len(k)!=4 or not all(math.isfinite(x) for x in k) or k[0]<=0 for k in p):
        raise ValueError("nonphysical four momentum")
    scale = max(k[0] for k in p)**2
    if any(abs(dot(k,k)) > 1e-10*scale for k in p):
        raise ValueError("external mass shell")
    residual = [sum(k[j] for k in p[:2])-sum(k[j] for k in p[2:]) for j in range(4)]
    if max(map(abs,residual)) > 1e-10*math.sqrt(scale):
        raise ValueError("momentum conservation")
    for index, key in ((1,"spin_in"),(3,"spin_out")):
        s = r[key]
        if s is not None and (abs(dot(s,s)+1)>1e-9 or abs(dot(s,p[index]))>1e-9*math.sqrt(scale)):
            raise ValueError("spin vector must obey S.p=0, S^2=-1")


def covariant(r, polarized=False):
    """Independent Clifford trace; full tree couplings, same initial averages."""
    import real_oracle as c
    l,p,lp,pp = r["momenta"][:4]
    prefactor = (4*math.pi*ALPHA_EM)**2 * CHARGE**2
    if r["process"] != "born_eq":
        rr = dict(zip(("l","p","lp","pp","k"),r["momenta"]))
        rr.update(Sin=r["spin_in"],Sout=r["spin_out"])
        return prefactor*(4*math.pi*ALPHA_S)*c.contract(rr, "eg" if r["process"]=="real_eg" else "eq", polarized)
    rho,rhop = c.slash(p),c.slash(pp)
    if polarized:
        rho = c.chain(rho,c.G5,c.slash(r["spin_in"]))
        rhop = c.chain(rhop,c.G5,c.slash(r["spin_out"]))
    result = sum(c.METRIC[mu]*c.METRIC[nu]*c.trace(c.chain(c.slash(lp),c.G[mu],c.slash(l),c.G[nu]))*
                 c.trace(c.chain(rhop,c.G[mu],rho,c.G[nu]))
                 for mu in range(4) for nu in range(4))/4
    q = [a-b for a,b in zip(l,lp)]
    if abs(result.imag)>1e-8*max(1.,abs(result.real)):
        raise ValueError("complex covariant trace")
    return prefactor*result.real/dot(q,q)**2


def matmul(a,b):
    return [[sum(a[i][k]*b[k][j] for k in range(len(b))) for j in range(len(b[0]))] for i in range(len(a))]


def weyl_matrices():
    """+--- Weyl basis, consistent with massless HELAS spinor identities."""
    z = [[0j]*2 for _ in range(2)]
    eye = [[1,0],[0,1]]
    def blocks(a,b,c,d):
        return [a[i]+b[i] for i in range(2)] + [c[i]+d[i] for i in range(2)]
    g0 = blocks(z,eye,eye,z)
    sigma = [[[0,1],[1,0]],[[0,-1j],[1j,0]],[[1,0],[0,-1]]]
    gs = [g0]+[blocks(z,s,[[-x for x in row] for row in s],z) for s in sigma]
    g5 = [[(-1 if i<2 else 1) if i==j else 0 for j in range(4)] for i in range(4)]
    return gs,g5


def spin_density(p, s, basis):
    """Return off-diagonal helicity matrix of /p gamma5 /S.

    basis is native incoming IXXXXX or outgoing spinors reconstructed from
    native OXXXXX, h=(-1,+1), with ubar from gamma0. Coefficients reconstruct
    the covariant density exactly; this
    calibrates phases independently of any amplitude comparison or fitted sign.
    """
    if len(basis)!=2 or any(len(u)!=4 for u in basis):
        raise ValueError("expected two four-component native spinors")
    if any(not math.isfinite(x.real) or not math.isfinite(x.imag) for u in basis for x in u):
        raise ValueError("nonfinite native spinor")
    gs,g5 = weyl_matrices()
    def slash(v):
        return [[sum((1 if mu==0 else -1)*v[mu]*gs[mu][i][j] for mu in range(4)) for j in range(4)] for i in range(4)]
    pslash = slash(p)
    target = matmul(matmul(pslash,g5),slash(s))
    dagger_target = matmul(target,gs[0])
    norm = 2*p[0]
    completeness = [[sum(u[i]*sum(u[k].conjugate()*gs[0][k][j] for k in range(4)) for u in basis) for j in range(4)] for i in range(4)]
    if max(abs(completeness[i][j]-pslash[i][j]) for i in range(4) for j in range(4)) > 1e-8*norm:
        raise Unsupported("native HELAS spinors fail /p completeness in supported Weyl basis")
    rho = [[sum(basis[a][i].conjugate()*dagger_target[i][j]*basis[b][j] for i in range(4) for j in range(4))/norm**2 for b in range(2)] for a in range(2)]
    recovered = [[sum(rho[a][b]*basis[a][i]*sum(basis[b][k].conjugate()*gs[0][k][j] for k in range(4)) for a in range(2) for b in range(2)) for j in range(4)] for i in range(4)]
    if max(abs(recovered[i][j]-target[i][j]) for i in range(4) for j in range(4)) > 1e-8*norm:
        raise Unsupported("native HELAS density does not reconstruct covariant spin projector")
    if any(abs(rho[i][i])>1e-8 for i in range(2)) or abs(sum(abs(x)**2 for row in rho for x in row)-2)>1e-8:
        raise Unsupported("transverse density is not a pure off-diagonal Pauli matrix")
    return rho


def coherent_sum(amps, ci, co, color, average):
    """M(h,k) M*(h',k') rho_in[h,h'] rho_out[k',k]."""
    total = 0j
    for hel,a in amps.items():
        for hp,b in amps.items():
            if any(hel[j]!=hp[j] for j in range(len(hel)) if j not in (1,3)):
                continue
            total += color*a*b.conjugate()*ci[(hel[1]+1)//2][(hp[1]+1)//2]*co[(hp[3]+1)//2][(hel[3]+1)//2]
    if abs(total.imag)>1e-8*max(1,abs(total.real)):
        raise ValueError("coherent cross section not real")
    return total.real/average


def instrument_matrix(source):
    """Capture scalar-color JAMP; retain all generated amplitude statements.

    Guarded against unknown template formats. Exact original/modified source
    hashes are retained by the caller. No candidate code can provide this hook.
    """
    f = re.search(r"(?im)^\s*REAL\*8\s+FUNCTION\s+(\w*MATRIX)\(P,NHEL,IC\)",source)
    if not f:
        raise Unsupported("unsupported standalone MATRIX signature")
    name = f.group(1)
    tail = source[f.start():]
    if not re.search(r"NCOLOR\s*=\s*1\b",tail,re.I):
        raise Unsupported("only audited one-dimensional color bases are supported")
    packed = re.search(r"CF\s*\(\s*NCOLOR\s*\*\s*\(\s*NCOLOR\s*\+\s*1\s*\)\s*/\s*2\s*\)",tail,re.I)
    square = re.search(r"CF\s*\(\s*NCOLOR\s*,\s*NCOLOR\s*\)",tail,re.I)
    denom_array = re.search(r"DENOM\s*\(\s*NCOLOR\s*\)",tail,re.I)
    if packed and not square and not denom_array:
        color_expression = "DBLE(CF(1))/DBLE(DENOM)"
    elif square and not packed and denom_array:
        color_expression = "DBLE(CF(1,1))/DBLE(DENOM(1))"
    else:
        raise Unsupported("unsupported scalar color metric layout")
    marker = re.search(r"(?im)^\s*"+re.escape(name)+r"\s*=\s*0(?:\.0*)?D0\s*$",tail)
    include = re.search(r"(?im)^\s*include\s*['\"]coupl.inc['\"]",tail)
    if not marker or not include or not re.search(r"JAMP\s*\(\s*1\s*\)",tail[:marker.start()],re.I):
        raise Unsupported("unsupported JAMP/color-assembly boundary")
    declarations = "      COMPLEX*16 AUDITAMP\n      REAL*8 AUDITCOLOR\n      COMMON/AUDITCAPTURE/AUDITAMP,AUDITCOLOR\n"
    capture = "      AUDITAMP=JAMP(1)\n      AUDITCOLOR="+color_expression+"\n"
    tail = tail[:marker.start()]+capture+tail[marker.start():]
    tail = tail[:include.start()]+declarations+tail[include.start():]
    return source[:f.start()]+tail,name


def _fortran_line_code(line):
    """Remove an inline comment and mask literals for fixed-form call counting.

    Fortran quotes escape themselves by doubling. In particular, an exclamation
    mark inside a quoted filename is data, not an inline comment delimiter.
    Unknown unterminated literals fail closed rather than hiding a later call.
    """
    masked = []
    index = 0
    while index < len(line):
        char = line[index]
        if char == "!":
            return line[:index], "".join(masked)
        if char not in "'\"":
            masked.append(char)
            index += 1
            continue
        quote = char
        masked.append(" ")
        index += 1
        while index < len(line):
            masked.append(" ")
            if line[index] == quote:
                if index + 1 < len(line) and line[index + 1] == quote:
                    masked.append(" ")
                    index += 2
                    continue
                index += 1
                break
            index += 1
        else:
            raise Unsupported("unsupported unterminated/continued Fortran literal")
    return line, "".join(masked)


def initialization_call(original_driver):
    """Retain exactly one active literal SETPARA call in a fixed-form driver.

    Count calls before checking the supported one/two-argument API so an extra
    unsupported call cannot be silently ignored. Full-line and inline comments
    do not count; strings are masked for counting but retained for parsing.
    Continuations, inline conditional calls and multiple statements on a call's line
    are intentionally unsupported. Unrelated native continuation lines remain
    intact: this function only reads the original source.
    """
    statements = []
    for raw in original_driver.splitlines():
        line = raw.expandtabs(8)
        if not line.strip() or line[0] in "cC*!":
            continue
        code, masked = _fortran_line_code(line)
        if not code.strip():
            continue
        fields = code[:6].ljust(6)
        layout_ok = all(c.isspace() or c.isdigit() for c in fields[:5])
        continuation = fields[5] not in " 0"
        body = code[6:] if layout_ok else code
        mask_body = masked[6:] if layout_ok else masked
        if continuation and statements:
            statements[-1][0] += " " + body
            statements[-1][1] += " " + mask_body
            statements[-1][2] = False
        else:
            statements.append([body, mask_body, layout_ok and not continuation])

    calls = []
    for body, masked, supported_line in statements:
        # Fixed-form Fortran ignores whitespace outside literal strings. This
        # also detects split CALL/SETPARA tokens on unsupported continuations.
        compact = re.sub(r"\s+", "", masked).upper()
        count = len(re.findall(r"CALLSETPARA(?![A-Z0-9_])", compact))
        calls.extend([(body, supported_line)] * count)
    if len(calls) != 1:
        raise Unsupported("unsupported generated model initialization; expected exactly one active SETPARA call")
    body, supported_line = calls[0]
    literal = r"(?:'(?:[^']|'')+'|\"(?:[^\"]|\"\")+\")"
    match = re.fullmatch(r"\s*CALL\s+SETPARA\s*\(\s*" + literal +
                         r"\s*(?:,\s*\.(TRUE|FALSE)\.)?\s*\)\s*", body, re.I)
    if not supported_line or match is None:
        raise Unsupported("unsupported generated SETPARA call; require one literal filename and optional literal logical argument on one statement line")
    optional = ", ." + match.group(1).upper() + "." if match.group(1) else ""
    return "CALL SETPARA('../../Cards/param_card.dat'" + optional + ")"


def driver_source(matrix_name, nexternal, setpara_call="CALL SETPARA('../../Cards/param_card.dat')"):
    """Driver exports SMATRIX, every complex JAMP and native quark spinors."""
    prefix = matrix_name[:-len("MATRIX")]
    return f'''      PROGRAM COLLINS_AUDIT
      IMPLICIT NONE
      INTEGER N,H,I,J,K,HELS({nexternal}),IC({nexternal})
      INTEGER MASK
      REAL*8 ZERO
      PARAMETER (ZERO=0D0)
      REAL*8 P(0:3,{nexternal}),UU,T,AC,PMASS({nexternal})
      REAL*8 {matrix_name}
      COMPLEX*16 AMP,WI(6),WO(6)
      COMMON/AUDITCAPTURE/AMP,AC
      INCLUDE 'coupl.inc'
      {setpara_call}
      INCLUDE 'pmass.inc'
      IF(MAXVAL(ABS(PMASS)).GT.1D-12) STOP 91
      READ(*,*) N
      DO K=1,N
        DO I=1,{nexternal}
          READ(*,*) (P(J,I),J=0,3)
          IC(I)=1
        ENDDO
        CALL {prefix}SMATRIX(P,UU)
        WRITE(*,'(A,I6,ES26.17)') 'MGUU ',K,UU
        DO MASK=0,{2**nexternal-1}
          DO I=1,{nexternal}
            HELS(I)=2*IBITS(MASK,I-1,1)-1
          ENDDO
          T={matrix_name}(P,HELS,IC)
          WRITE(*,'(A,2I6,4ES26.17)') 'MGAMP ',K,MASK,
     &      DBLE(AMP),DIMAG(AMP),AC,T
        ENDDO
        DO H=-1,1,2
          CALL IXXXXX(P(0,2),0D0,H,1,WI)
          CALL OXXXXX(P(0,4),0D0,H,1,WO)
          DO I=3,6
            WRITE(*,'(A,3I6,4ES26.17)') 'MGSPIN ',K,H,I,
     &        DBLE(WI(I)),DIMAG(WI(I)),DBLE(WO(I)),DIMAG(WO(I))
          ENDDO
        ENDDO
      ENDDO
      END
'''


def parse_native(text, requests):
    by_index = {i+1:{"amps":{},"spin_in":{h:[None]*4 for h in (-1,1)},"spin_out":{h:[None]*4 for h in (-1,1)}} for i in range(len(requests))}
    for line in text.splitlines():
        fields = line.split()
        if not fields or fields[0] not in ("MGUU","MGAMP","MGSPIN"):
            continue
        tag = fields.pop(0)
        k = int(fields.pop(0))
        if k not in by_index:
            raise ValueError("unexpected native point id")
        row=by_index[k]
        if tag=="MGUU":
            if len(fields)!=1: raise ValueError("malformed native UU")
            if "UU" in row: raise ValueError("duplicate native UU")
            row["UU"] = native_float(fields[0])
            if row["UU"]<0: raise ValueError("negative native UU")
        elif tag=="MGAMP":
            if len(fields)!=5: raise ValueError("malformed native amplitude")
            mask=int(fields.pop(0)); re_a,im_a,color,sq = map(native_float,fields)
            if color<=0: raise ValueError("nonpositive scalar color metric")
            n=len(requests[k-1]["momenta"])
            if mask not in range(2**n): raise ValueError("native helicity mask")
            hel=tuple(2*((mask>>i)&1)-1 for i in range(n))
            if hel in row["amps"]: raise ValueError("duplicate native helicity")
            a=complex(re_a,im_a)
            if not close(color*abs(a)**2,sq): raise ValueError("captured JAMP does not reproduce MATRIX")
            if "color" in row and not close(row["color"],color): raise ValueError("color metric changed by helicity")
            row["amps"][hel]=a; row["color"]=color
        else:
            if len(fields)!=6: raise ValueError("malformed native spinor")
            h,i=int(fields.pop(0)),int(fields.pop(0)); values=list(map(native_float,fields))
            if h not in (-1,1) or i not in (3,4,5,6): raise ValueError("spinor index")
            for name,value in zip(("spin_in","spin_out"),(complex(*values[:2]),complex(*values[2:]))):
                if row[name][h][i-3] is not None: raise ValueError("duplicate spinor")
                row[name][h][i-3]=value
    for i,r in enumerate(requests,1):
        row=by_index[i]; n=len(r["momenta"])
        if "UU" not in row or len(row["amps"])!=2**n or any(x is None for key in ("spin_in","spin_out") for u in row[key].values() for x in u):
            raise Unsupported("incomplete native amplitude/spinor output")
        average=PROCESSES[r["process"]]["average"]
        reconstructed=row["color"]*sum(abs(a)**2 for a in row["amps"].values())/average
        if not close(reconstructed,row["UU"]): raise ValueError("native helicity/color sum disagrees with native SMATRIX; initial average or color basis unsupported")
        if r["process"]!="real_eg":
            # OXXXXX returns ubar in the native amplitude's actual phase
            # convention. Reconstruct u = gamma0 ubar^dagger; never assume
            # outgoing IXXXXX and OXXXXX have matching phases.
            g0=weyl_matrices()[0][0]
            outgoing={h:[sum(g0[i][j]*row["spin_out"][h][j].conjugate() for j in range(4)) for i in range(4)] for h in (-1,1)}
            ci=spin_density(r["momenta"][1],r["spin_in"],[row["spin_in"][h] for h in (-1,1)])
            co=spin_density(r["momenta"][3],r["spin_out"],[outgoing[h] for h in (-1,1)])
            row["UT"]=coherent_sum(row["amps"],ci,co,row["color"],average)
            # Independent convention controls: spin reversal, zero polarization,
            # and arbitrary HELAS phase changes compensated in density matrices.
            neg=[[-x for x in line] for line in ci]
            zero=[[0j,0j],[0j,0j]]
            if not close(coherent_sum(row["amps"],neg,co,row["color"],average),-row["UT"]): raise ValueError("spin reversal")
            if not close(coherent_sum(row["amps"],neg,[[-x for x in line] for line in co],row["color"],average),row["UT"]): raise ValueError("double spin reversal")
            if coherent_sum(row["amps"],zero,co,row["color"],average)!=0: raise ValueError("zero spin")
            aphase,bphase=(.371,-.219),(.817,.133)
            changed={h:a*cmath.exp(1j*(aphase[(h[1]+1)//2]-bphase[(h[3]+1)//2])) for h,a in row["amps"].items()}
            ci2=[[ci[a][b]*cmath.exp(1j*(aphase[b]-aphase[a])) for b in range(2)] for a in range(2)]
            co2=[[co[a][b]*cmath.exp(1j*(bphase[b]-bphase[a])) for b in range(2)] for a in range(2)]
            if not close(coherent_sum(changed,ci2,co2,row["color"],average),row["UT"]): raise ValueError("helicity rephasing")
    return by_index


def command(argv, cwd, log, timeout, stdin=None):
    if not isinstance(argv,list) or not argv or any(not isinstance(x,str) for x in argv):
        raise ValueError("command must be nonempty argv list")
    env=dict(os.environ,OMP_NUM_THREADS="1",OPENBLAS_NUM_THREADS="1",PYTHONHASHSEED="0")
    try:
        p=subprocess.run(argv,cwd=str(cwd),input=stdin,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=timeout,env=env,check=False)
    except (FileNotFoundError,subprocess.TimeoutExpired) as e:
        partial=getattr(e,"stdout",None) or ""
        if isinstance(partial,bytes): partial=partial.decode(errors="replace")
        Path(log).write_text(partial+"\n"+str(e)+"\n")
        raise Unsupported(str(e)) from e
    Path(log).write_text(p.stdout)
    if p.returncode:
        raise CommandFailed(f"command exit {p.returncode}; see {log}")
    return p.stdout


def parameter_card(text):
    """Set only fixed benchmark couplings and explicit external masses."""
    out=[];block=None;found=set()
    for line in text.splitlines():
        raw=line.split("#",1)[0].strip().split()
        if raw and raw[0].lower()=="block": block=raw[1].lower()
        elif raw and raw[0].lower()=="decay": block=None
        elif raw and block in ("sminputs","mass"):
            try: key=int(raw[0])
            except ValueError: key=None
            value=None
            if block=="sminputs" and key in (1,3):
                value=1/ALPHA_EM if key==1 else ALPHA_S;found.add(key)
            if block=="mass" and key in (11,2,21): value=0.
            if value is not None: line=f"  {key}  {value:.17g} # verifier benchmark"
        out.append(line)
    if found!={1,3}: raise Unsupported("unsupported SM parameter card: missing aEWM1/as")
    return "\n".join(out)+"\n"


def validate_candidate(payload, requests):
    if not isinstance(payload,dict) or type(payload.get("schema")) is not int or payload["schema"]!=1:
        raise ValueError("candidate response schema")
    rows=payload.get("rows")
    if not isinstance(rows,list) or any(not isinstance(r,dict) or not isinstance(r.get("id"),str) for r in rows):
        raise ValueError("candidate rows must be objects with string IDs")
    proposed={r["id"]:r for r in rows}
    if len(proposed)!=len(rows) or set(proposed)!={r["id"] for r in requests}:
        raise ValueError("candidate row IDs must match requests exactly")
    for r in requests:
        for key in (("UU",) if r["process"]=="real_eg" else ("UU","UT")):
            a=proposed[r["id"]].get(key)
            if isinstance(a,bool) or not isinstance(a,(int,float)) or not math.isfinite(a):
                raise ValueError("candidate missing/nonfinite "+r["id"]+"."+key)
            if key=="UU" and a<0:
                raise ValueError("negative candidate UU")
    return proposed


def native_comparisons(request, result):
    return [record("native_covariant."+request["id"]+"."+key,
                   "PASS" if close(result[key],covariant(request,key=="UT")) else "FAIL",
                   {"MG":result[key],"Clifford":covariant(request,key=="UT"),
                    "meaning":"independent tree amplitude; not TMD matching"})
            for key in (("UU",) if request["process"]=="real_eg" else ("UU","UT"))]


def candidate_comparisons(requests, actual, native):
    checks=[]
    for r in requests:
        if r["id"] not in native: continue
        for key in (("UU",) if r["process"]=="real_eg" else ("UU","UT")):
            a,b=actual[r["id"]][key],native[r["id"]][key]
            checks.append(record("candidate."+r["id"]+"."+key,"PASS" if close(a,b) else "FAIL",
                                 {"candidate":a,"MG":b,"absolute_error":abs(a-b)}))
    return checks


def native_process(name, requests, cfg, dest):
    dest=Path(dest).resolve();dest.mkdir(parents=True,exist_ok=False)
    response=dest.parent/"candidate-response.json"
    candidate_hash=sha(response) if response.is_file() else None
    root=access(cfg["root"])
    mg=root/"bin/mg5_aMC"
    if not mg.is_file(): raise Unsupported("MadGraph bin/mg5_aMC missing")
    timeout=min(max(int(cfg.get("timeout_seconds",600)),1),3600)
    output=dest/"standalone"
    if any(c.isspace() for c in str(output)): raise Unsupported("MG generation path must contain no whitespace")
    card=dest/"generate.mg5"
    card.write_text("set automatic_html_opening False\nset group_subprocesses False\nimport model sm\ngenerate "+PROCESSES[name]["process"]+"\noutput standalone "+str(output)+" -f\nquit\n")
    command([cfg.get("python",sys.executable),str(mg),str(card)],dest,dest/"generation.log",timeout)
    subdirs=[p for p in (output/"SubProcesses").glob("P*") if (p/"matrix.f").is_file()]
    if len(subdirs)!=1: raise Unsupported("expected exactly one standalone subprocess")
    sub=subdirs[0]; matrix=sub/"matrix.f"; original=matrix.read_text()
    (dest/"matrix.original.f").write_text(original)
    instrumented,symbol=instrument_matrix(original)
    matrix.write_text(instrumented)
    check=sub/"check_sa.f"
    original_check=check.read_text()
    setpara_call=initialization_call(original_check)
    # check_sa.f can be a generated link. Remove only this new-build link.
    if check.is_symlink(): check.unlink()
    check.write_text(driver_source(symbol,PROCESSES[name]["n"],setpara_call))
    pc=output/"Cards/param_card.dat";pc.write_text(parameter_card(pc.read_text()))
    make=cfg.get("make","make")
    command([make,"-j1"],output/"Source",dest/"build-source.log",timeout)
    command([make,"-j1","check"],sub,dest/"build-subprocess.log",timeout)
    data=str(len(requests))+"\n"+"\n".join(" ".join(format(x,".17e") for x in p) for r in requests for p in r["momenta"])+"\n"
    (dest/"momenta.txt").write_text(data)
    text=command([str(sub/"check")],sub,dest/"native-output.txt",timeout,data)
    rows=parse_native(text,requests)
    native_tree=snapshot_native_tree(output)
    identities={str(p.relative_to(output)):sha(p) for p in sorted(output.rglob("*")) if p.is_file() and (p.suffix in (".f",".inc",".dat") or p.name in ("check","makefile","make_opts"))}
    if candidate_hash is not None and sha(response)!=candidate_hash:
        raise ValueError("candidate response changed during native generation")
    artifacts={name:sha(dest/name) for name in ("generate.mg5","matrix.original.f","momenta.txt","native-output.txt","generation.log","build-source.log","build-subprocess.log")}
    version=(root/"VERSION").read_text() if (root/"VERSION").is_file() else "VERSION file absent; entry-point and generated source hashes retained"
    manifest={"schema":1,"process":name,"request_ids":[r["id"] for r in requests],
              "mg5_entry_sha256":sha(mg),"mg5_version":version,
              "original_matrix_sha256":sha(dest/"matrix.original.f"),
              "candidate_before_native_generation_sha256":candidate_hash,
              "generated_build":identities,"native_tree":native_tree,"artifacts":artifacts,
              "subprocess":str(sub.relative_to(output)),"matrix_symbol":symbol,
              "setpara_call":setpara_call}
    (dest/"build-identities.json").write_text(json.dumps(manifest,sort_keys=True,indent=2)+"\n")
    return rows


def run_checks(repo, run, runtime, evidence_dir, seed):
    """Return audit records. Every mandatory native+candidate comparison required.

    runtime['madgraph']: {root, python?, make?, timeout_seconds?}.
    runtime['madgraph_candidate_command']: argv placeholders {repo}, {run},
    {requests}, {response}. Candidate gets requests only; response JSON object
    {schema:1, rows:[{id, UU, UT?}]} uses full-coupling conventions above.
    """
    ev=Path(evidence_dir).resolve();ev.mkdir(parents=True,exist_ok=True)
    checks=[]
    try:
        req=points(seed)
        request_path=ev/"requests.json";request_path.write_text(json.dumps({"schema":1,"seed":seed,"rows":req},indent=2)+"\n")
    except Exception as e:
        return [record("phase_space","FAIL",str(e))]
    checks.append(record("phase_space","PASS",{"points":len(req),"requests_sha256":sha(request_path)}))
    cfg=runtime.get("madgraph")
    if not isinstance(cfg,dict) or not cfg.get("root"):
        return checks+[record("native.runtime","BLOCKED","Set madgraph.root to a real MG5 installation; mock or archived reports never satisfy this gate.")]
    # Capture candidate answers BEFORE constructing any native answer files.
    # This is dependency separation, not an OS sandbox against a hostile actor.
    actual=None
    argv=runtime.get("madgraph_candidate_command")
    response=ev/"candidate-response.json"
    if not argv:
        checks.append(record("candidate.adapter","BLOCKED","madgraph_candidate_command is required; standalone MadGraph checks alone do not certify candidate derivations."))
    elif response.exists():
        checks.append(record("candidate.freshness","FAIL","Refusing a pre-existing candidate response"))
    else:
        try:
            if not isinstance(argv,list) or any(not isinstance(x,str) for x in argv): raise ValueError("candidate command must be argv list")
            replacements={"repo":str(Path(repo).resolve()),"run":str(Path(run).resolve()),"requests":str(request_path),"response":str(response)}
            expanded=[part.format(**replacements) for part in argv]
            command(expanded,Path(repo),ev/"candidate.log",min(int(cfg.get("timeout_seconds",600)),3600))
            actual=validate_candidate(json.loads(response.read_text()),req)
            checks.append(record("candidate.freshness","PASS",{"response_sha256":sha(response),"answered_before_native_generation":True}))
        except Unsupported as e:
            checks.append(record("candidate.adapter","BLOCKED",str(e)))
        except Exception as e:
            checks.append(record("candidate.adapter","FAIL",type(e).__name__+": "+str(e)))
    native={}
    for name in PROCESSES:
        selection=[r for r in req if r["process"]==name]
        try:
            values=native_process(name,selection,cfg,ev/name)
            for index,r in enumerate(selection,1):
                result=values[index];native[r["id"]]={key:result[key] for key in ("UU","UT") if key in result}
                checks.extend(native_comparisons(r,result))
        except (Unsupported, CommandFailed) as e:
            checks.append(record(name,"BLOCKED",str(e)))
        except Exception as e:
            checks.append(record(name,"FAIL",type(e).__name__+": "+str(e)))
    (ev/"native-values.json").write_text(json.dumps(native,indent=2,sort_keys=True)+"\n")
    if actual is not None:
        checks.extend(candidate_comparisons(req,actual,native))
    return checks


def replay_checks(evidence_dir, seed):
    """Recompute successful-run core records from raw archived native evidence.

    Never read stored PASS flags. Verify generated source/build hashes, source
    instrumentation, input momenta and native output, then redo helicity sums,
    covariant traces and candidate comparisons. A missing native archive is
    BLOCKED. This checks archive consistency; it does not rerun MG or prove
    that an adversarially forged archive came from MG.
    """
    ev=Path(evidence_dir).resolve();checks=[]
    try:
        req=points(seed)
        request_path=ev/"requests.json"
        payload=json.loads(request_path.read_text())
        if json.dumps(payload,sort_keys=True,allow_nan=False)!=json.dumps({"schema":1,"seed":seed,"rows":req},sort_keys=True,allow_nan=False):
            raise ValueError("stored requests differ from verifier-seeded points")
        checks.append(record("phase_space","PASS",{"points":len(req),"requests_sha256":sha(request_path)}))
        response=ev/"candidate-response.json"
        actual=validate_candidate(json.loads(response.read_text()),req)
        candidate_hash=sha(response)
        # Each verifier build manifest must carry this hash captured before
        # that native build. Fresh process execution remains a live-run gate.
        checks.append(record("candidate.freshness","PASS",{"response_sha256":candidate_hash,"answered_before_native_generation":True}))
        native={}
        for name in PROCESSES:
            dest=ev/name;output=dest/"standalone"
            manifest=json.loads((dest/"build-identities.json").read_text())
            selection=[r for r in req if r["process"]==name]
            if (type(manifest.get("schema")) is not int or manifest["schema"]!=1 or manifest.get("process")!=name or
                manifest.get("request_ids")!=[r["id"] for r in selection] or
                manifest.get("candidate_before_native_generation_sha256")!=candidate_hash):
                raise ValueError("native build identity/process/candidate receipt mismatch: "+name)
            if (not re.fullmatch(r"[0-9a-f]{64}",str(manifest.get("mg5_entry_sha256"))) or
                not isinstance(manifest.get("mg5_version"),str) or not manifest["mg5_version"]):
                raise ValueError("missing MG5 entry-point/version identity")
            if snapshot_native_tree(output)!=manifest.get("native_tree"):
                raise ValueError("Native build tree or generated link evidence changed")
            for group,root in (("artifacts",dest),("generated_build",output)):
                entries=manifest.get(group)
                if not isinstance(entries,dict) or not entries:
                    raise ValueError("missing native build hashes: "+group)
                for path,digest in entries.items():
                    relative=Path(path)
                    if relative.is_absolute() or ".." in relative.parts or not re.fullmatch(r"[0-9a-f]{64}",str(digest)):
                        raise ValueError("invalid native artifact identity")
                    if sha(root/relative)!=digest:
                        raise ValueError("native artifact hash mismatch: "+str(root/relative))
            required={"generate.mg5","matrix.original.f","momenta.txt","native-output.txt","generation.log","build-source.log","build-subprocess.log"}
            if not required.issubset(manifest["artifacts"]):
                raise ValueError("incomplete native artifact inventory")
            relative=Path(manifest["subprocess"])
            if relative.is_absolute() or ".." in relative.parts or relative.parts[0]!="SubProcesses":
                raise ValueError("invalid native subprocess path")
            sub=output/relative
            required_build={str(relative/"matrix.f"),str(relative/"check_sa.f"),str(relative/"check"),"Cards/param_card.dat"}
            if not required_build.issubset(manifest["generated_build"]):
                raise ValueError("incomplete native source/executable inventory")
            original=(dest/"matrix.original.f").read_text()
            instrumented,symbol=instrument_matrix(original)
            if (symbol!=manifest["matrix_symbol"] or (sub/"matrix.f").read_text()!=instrumented or
                sha(dest/"matrix.original.f")!=manifest["original_matrix_sha256"]):
                raise ValueError("native instrumentation does not follow verifier transform")
            setpara=manifest["setpara_call"]
            # Manifest stores the canonical statement without fixed-form
            # indentation; restore its statement field for source parsing.
            if initialization_call("      " + setpara)!=setpara:
                raise ValueError("unsupported archived initialization")
            if (sub/"check_sa.f").read_text()!=driver_source(symbol,PROCESSES[name]["n"],setpara):
                raise ValueError("native driver differs from verifier source")
            card=output/"Cards/param_card.dat"
            if parameter_card(card.read_text())!=card.read_text():
                raise ValueError("native coupling/mass inputs differ from benchmark")
            data=str(len(selection))+"\n"+"\n".join(" ".join(format(x,".17e") for x in p) for r in selection for p in r["momenta"])+"\n"
            if (dest/"momenta.txt").read_text()!=data:
                raise ValueError("native momenta differ from seeded requests")
            rows=parse_native((dest/"native-output.txt").read_text(),selection)
            for i,r in enumerate(selection,1):
                result=rows[i]
                native[r["id"]]={key:result[key] for key in (("UU",) if name=="real_eg" else ("UU","UT"))}
                checks.extend(native_comparisons(r,result))
        cached=json.loads((ev/"native-values.json").read_text())
        if not isinstance(cached,dict):
            raise ValueError("invalid native cache")
        validate_candidate({"schema":1,"rows":[dict(id=key,**value) for key,value in cached.items()]},req)
        if cached!=native:
            raise ValueError("cached native values differ from raw helicity output")
        checks.extend(candidate_comparisons(req,actual,native))
    except (FileNotFoundError,Unsupported) as e:
        return checks+[record("replay.evidence","BLOCKED",str(e))]
    except Exception as e:
        return checks+[record("replay.evidence","FAIL",type(e).__name__+": "+str(e))]
    return checks


if __name__ == "__main__":
    import argparse
    p=argparse.ArgumentParser(description=__doc__)
    for name in ("repo","run","runtime","evidence-dir"): p.add_argument("--"+name,required=True)
    p.add_argument("--seed",type=int,default=1729)
    a=p.parse_args()
    checks=run_checks(a.repo,a.run,json.loads(Path(a.runtime).read_text()),a.evidence_dir,a.seed)
    print(json.dumps({"checks":checks},indent=2))
    sys.exit(0 if checks and all(c["status"]=="PASS" for c in checks) else 2 if any(c["status"]=="BLOCKED" for c in checks) else 1)
