//
//  prandom.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "prandom.h"
#include "psync.h"

///////////////////////////////////////////////////////////////////////////////
// PRandom

PRandom::PRandom()
{
    SetSeed((DWORD)(time(0)+clock()));
}


PRandom::PRandom(DWORD seed)
{
    SetSeed(seed);
}


#define mix(a,b,c,d,e,f,g,h) \
{ \
a^=b<<11; d+=a; b+=c; \
b^=c>>2;  e+=b; c+=d; \
c^=d<<8;  f+=c; d+=e; \
d^=e>>16; g+=d; e+=f; \
e^=f<<10; h+=e; f+=g; \
f^=g>>4;  a+=f; g+=h; \
g^=h<<8;  b+=g; h+=a; \
h^=a>>9;  c+=h; a+=b; \
}


void PRandom::SetSeed(DWORD seed)
{
    int i;
    DWORD a,b,c,d,e,f,g,h;
    DWORD *m,*r;
    randa = randb = randc = 0;
    m=randmem;
    r=randrsl;
    
    for (i=0; i<RandSize; i++)
        r[i] = seed++;
    
    a=b=c=d=e=f=g=h=0x9e3779b9;  /* the golden ratio */
    
    for (i=0; i<4; ++i)          /* scramble it */
    {
        mix(a,b,c,d,e,f,g,h);
    }
    
    /* initialize using the the seed */
    for (i=0; i<RandSize; i+=8)
    {
        a+=r[i  ]; b+=r[i+1]; c+=r[i+2]; d+=r[i+3];
        e+=r[i+4]; f+=r[i+5]; g+=r[i+6]; h+=r[i+7];
        mix(a,b,c,d,e,f,g,h);
        m[i  ]=a; m[i+1]=b; m[i+2]=c; m[i+3]=d;
        m[i+4]=e; m[i+5]=f; m[i+6]=g; m[i+7]=h;
    }
    
    /* do a second pass to make all of the seed affect all of m */
    for (i=0; i<RandSize; i+=8)
    {
        a+=m[i  ]; b+=m[i+1]; c+=m[i+2]; d+=m[i+3];
        e+=m[i+4]; f+=m[i+5]; g+=m[i+6]; h+=m[i+7];
        mix(a,b,c,d,e,f,g,h);
        m[i  ]=a; m[i+1]=b; m[i+2]=c; m[i+3]=d;
        m[i+4]=e; m[i+5]=f; m[i+6]=g; m[i+7]=h;
    }
    
    randcnt=0;
    Generate();            /* fill in the first set of results */
    randcnt=RandSize;  /* prepare to use the first set of results */
}


#define ind(mm,x)  (*(DWORD *)((BYTE *)(mm) + ((x) & ((RandSize-1)<<2))))

#define rngstep(mix,a,b,mm,m,m2,r,x) \
{ \
x = *m;  \
a = (a^(mix)) + *(m2++); \
*(m++) = y = ind(mm,x) + a + b; \
*(r++) = b = ind(mm,y>>RandBits) + x; \
}

unsigned PRandom::Generate()
{
    if (randcnt--)
        return randrsl[randcnt];
    
    register DWORD a,b,x,y,*m,*mm,*m2,*r,*mend;
    mm=randmem; r=randrsl;
    a = randa; b = randb + (++randc);
    for (m = mm, mend = m2 = m+(RandSize/2); m<mend; )
    {
        rngstep( a<<13, a, b, mm, m, m2, r, x);
        rngstep( a>>6 , a, b, mm, m, m2, r, x);
        rngstep( a<<2 , a, b, mm, m, m2, r, x);
        rngstep( a>>16, a, b, mm, m, m2, r, x);
    }
    for (m2 = mm; m2<mend; )
    {
        rngstep( a<<13, a, b, mm, m, m2, r, x);
        rngstep( a>>6 , a, b, mm, m, m2, r, x);
        rngstep( a<<2 , a, b, mm, m, m2, r, x);
        rngstep( a>>16, a, b, mm, m, m2, r, x);
    }
    randb = b; randa = a;
    
    randcnt = RandSize-1;
    return randrsl[randcnt];
}

unsigned PRandom::Number()
{
    static PMutex mutex;

    PWaitAndSignal wait(mutex);
    
    static PRandom rand;
    return rand;
}


// End Of File ///////////////////////////////////////////////////////////////
