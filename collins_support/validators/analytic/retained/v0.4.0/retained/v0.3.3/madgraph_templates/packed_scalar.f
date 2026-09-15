C Synthetic format fixture, NOT generated native MadGraph evidence.
      REAL*8 FUNCTION MATRIX(P,NHEL,IC)
      IMPLICIT NONE
      INTEGER NCOLOR
      PARAMETER (NCOLOR=1)
      INTEGER CF(NCOLOR*(NCOLOR+1)/2),DENOM
      COMPLEX*16 AMP(2),JAMP(NCOLOR)
      INCLUDE 'coupl.inc'
      CALL SYNTHETIC_CURRENT(AMP)
      JAMP(1)=AMP(1)+AMP(2)
      MATRIX=0D0
      MATRIX=CF(1)*JAMP(1)*DCONJG(JAMP(1))/DENOM
      END
