//
//  prandom.h
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__prandom__
#define __UMPStack__prandom__


#ifdef P_USE_PRAGMA
#pragma interface
#endif

#include "pcommon.h"

/**Mersenne Twister random number generator.
 An application would create a static instance of this class, and then use
 if to generate a sequence of psuedo-random numbers.
 
 Usually an application would simply use PRandom::Number() but if
 performance is an issue then it could also create a static local variable
 such as:
 {
 static PRandom rand;
 for (i = 0; i < 10000; i++)
 array[i] = rand;
 }
 
 This method is not thread safe, so it is the applications responsibility
 to assure that its calls are single threaded.
 */
class PRandom
{
public:
    /**Construct the random number generator.
     This version will seed the random number generator with a value based
     on the system time as returned by time() and clock().
     */
    PRandom();
    
    /**Construct the random number generator.
     This version allows the application to choose the seed, thus letting it
     get the same sequence of values on each run. Useful for debugging.
     */
    PRandom(
            DWORD seed    ///< New seed value, must not be zero
    );
    
    /**Set the seed for the random number generator.
     */
    void SetSeed(
                 DWORD seed    ///< New seed value, must not be zero
    );
    
    /**Get the next psuedo-random number in sequence.
     This generates one pseudorandom unsigned integer (32bit) which is
     uniformly distributed among 0 to 2^32-1 for each call.
     */
    unsigned Generate();
    
    /**Get the next psuedo-random number in sequence.
     */
    inline operator unsigned() { return Generate(); }
    
    
    /**Get the next psuedo-random number in sequence.
     This utilises a single system wide thread safe PRandom variable. All
     threads etc will share the same psuedo-random sequence.
     */
    static unsigned Number();
    
    
protected:
    enum {
        RandBits = 8, ///< I recommend 8 for crypto, 4 for simulations
        RandSize = 1<<RandBits
    };
    
    DWORD randcnt;
    DWORD randrsl[RandSize];
    DWORD randmem[RandSize];
    DWORD randa;
    DWORD randb;
    DWORD randc;
};

#endif /* defined(__UMPStack__prandom__) */
