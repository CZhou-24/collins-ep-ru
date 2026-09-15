"""Independent references. These expressions are forbidden production inputs.

All one-loop coefficients multiply a=alpha_s/(2*pi). Laurent expansion order:
eta first at fixed eps, then eps. See docs/REFERENCE_DERIVATION.md.
"""
from fractions import Fraction
from algebra import rat, sym, add, mul, power, sub

def dist(delta=0,regular=0,plus=()):
    return {'delta':rat(delta) if isinstance(delta,int) else delta,
            'regular':rat(regular) if isinstance(regular,int) else regular,
            'plus':[{'n':n,'numerator':x} for n,x in plus]}

def references():
    CF,TR,pi,Bq,Bh,V,Y,r,g,LQ,LJ,Tq,T0,z,eps,kappa=map(sym,
        'CF TR pi Bq Bh V Y r g LQ LJ Tq T0 z eps kappa'.split())
    pi2=power(pi,2)
    def half(B,v):
        return {'-1,-1':mul(-2,CF),'0,-1':mul(-2,CF,B),'-2,0':CF,
                '-1,0':mul(CF,v),'0,0':mul(CF,add(mul(v,B),mul(rat(-1,2),power(B,2)),mul(rat(-1,12),pi2)))}
    halfq=half(Bq,V);halfh=half(Bh,V)
    standard={k:mul(2,v) for k,v in halfq.items()}
    global_bare={'-1,-1':mul(-2,CF),'0,-1':mul(-2,CF,Bq),'-2,0':mul(2,CF),
        '-1,0':mul(CF,add(V,mul(2,Y),Bq)),
        '0,0':mul(CF,add(mul(add(V,mul(2,Y)),Bq),mul(rat(-1,6),pi2)))}
    cs={'-2,0':mul(-1,CF),'-1,0':mul(-1,CF,sub(Bq,r)),
        '0,0':mul(CF,add(mul(rat(-1,2),power(sub(Bq,r),2)),mul(rat(1,12),pi2)))}
    jet1=mul(CF,add(mul(rat(1,2),power(LJ,2)),mul(rat(3,2),LJ),rat(13,2),mul(rat(-3,4),pi2)))
    jet={'-2,0':CF,'-1,0':mul(CF,add(LJ,rat(3,2))),'0,0':jet1}
    qq=dist(mul(rat(3,2),CF),plus=[(0,mul(CF,add(1,power(z,2))))])
    tr=dist(mul(rat(3,2),CF),plus=[(0,mul(2,CF,z))])
    qg=dist(regular=mul(TR,add(power(z,2),power(sub(1,z),2))))
    gq=dist(regular=mul(CF,add(1,power(sub(1,z),2)),power(z,-1)))
    endpoint={
        '-1':dist(mul(-1,power(kappa,-1))),
        '0':dist(plus=[(0,rat(1))]),
        '1':dist(plus=[(1,mul(-1,kappa))]),
        '2':dist(plus=[(2,mul(rat(1,2),power(kappa,2)))])}
    radiation={'soft_bare':{'global':global_bare,'cs_out':cs,'standard':standard,'injet':half(Bh,sub(V,g))},
        'jet_bare':jet,'splitting':{'qq':qq,'qg':qg,'gq':gq,'transversity':tr},'endpoint':endpoint,
        'raw_splitting':{
            'qq':mul(CF,sub(mul(add(1,power(z,2)),power(sub(1,z),-1)),mul(eps,sub(1,z)))),
            'qg':mul(TR,sub(1,mul(2,z,sub(1,z),power(sub(1,eps),-1)))),
            'gq':mul(CF,sub(mul(add(1,power(sub(1,z),2)),power(z,-1)),mul(eps,z)))}}
    def collinear(B,T):return {'-1,-1':mul(2,CF),'0,-1':mul(2,CF,B),
        '-1,0':mul(CF,add(sub(T,V),rat(3,2)))}
    def ct(T):return {'-2,0':mul(-1,CF),'-1,0':mul(-1,CF,add(T,rat(3,2)))}
    soft1=mul(CF,sub(mul(add(mul(2,Y),r),Bq),mul(rat(1,2),power(r,2))))
    operators={'collinear_uv':{'beam_UU':collinear(Bq,Tq),'beam_UT':collinear(Bq,Tq),
            'fragment_UU':collinear(Bh,T0),'fragment_Collins':collinear(Bh,T0)},
        'counterterms':{'soft':{'-1,0':mul(-1,CF,add(mul(2,Y),r))},'jet':ct(LJ),
            'beam':ct(Tq),'fragment':ct(sub(T0,g))},
        'renormalized':{'soft':soft1,'jet':jet1},
        'anomalous':{'hard':mul(CF,add(mul(-2,LQ),-3)),
            'beam_UU':mul(CF,add(Tq,rat(3,2))),'beam_UT':mul(CF,add(Tq,rat(3,2))),
            'fragment_UU':mul(CF,add(sub(T0,g),rat(3,2))),
            'fragment_Collins':mul(CF,add(sub(T0,g),rat(3,2))),
            'jet':mul(CF,add(LJ,rat(3,2))),'soft':mul(CF,add(mul(2,Y),r)),
            'CS_beam':mul(-2,CF,Bq),'CS_fragment':mul(-2,CF,Bh)}}
    HUU,HUT,hard1,s1,f0,f1,d0,d1,t0,t1,c0,c1=map(sym,'HUU HUT hard1 soft1 f0 f1 d0 d1 t0 t1 c0 c1'.split())
    assembly={'UU0':mul(HUU,f0,d0),'UT0':mul(HUT,t0,c0),
        'UU1':mul(HUU,add(mul(add(hard1,s1),f0,d0),mul(f1,d0),mul(f0,d1))),
        'UT1':mul(HUT,add(mul(add(hard1,s1),t0,c0),mul(t1,c0),mul(t0,c1)))}
    return radiation,operators,assembly,{'half_q':halfq,'half_h':halfh}
