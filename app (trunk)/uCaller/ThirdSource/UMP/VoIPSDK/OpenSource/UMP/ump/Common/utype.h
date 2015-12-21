//
//  utype.h
//  UMPStack
//
//  Created by thehuah on 14-3-10.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__utype__
#define __UMPStack__utype__

#ifndef UMP_API
#define UMP_API
#endif


typedef signed char         INT8;
typedef unsigned char       UINT8;

typedef signed short        INT16;
typedef unsigned short      UINT16;

typedef signed int          INT32;
typedef unsigned int        UINT32;

#ifdef __GNUC__
typedef long long INT64;
typedef unsigned long long UINT64;
#else
typedef signed __int64      INT64;
typedef unsigned __int64    UINT64;
#endif

typedef double				REAL;


namespace ump {
    
    //…Ë÷√»’÷æ ‰≥ˆŒƒº˛∫Õµ»º∂
    UMP_API void SetTraceOption(const char * fileName, UINT32 level);
    
    /*
     *	…Ë±∏ª∫≥Â«¯≤Œ ˝
     */
    struct UMP_API BufferParam {
        
        UINT32 size; //√øøÈª∫≥Â«¯µƒ◊÷Ω⁄ ˝
        UINT32 count; //ª∫≥Â«¯ ˝¡ø
        
        BufferParam()
        :size(0),
        count(0) {
            
        }
        explicit BufferParam(UINT32 size,UINT32 count)
        :size(size),
        count(count) {
        }
        virtual ~BufferParam() {
            
        }
        
    };
    
    /*
     *	Õ®”√“Ù∆µª∫≥Â«¯√Ë ˆ
     *	 ‰»Î ‰≥ˆ≤Ÿ◊˜∫Û£¨ptr/size÷µª·±ª–ﬁ∏ƒ£¨±‰∂Ø÷µæÕ « µº  ‰»Î/ ‰≥ˆ¡ø
     */
    struct UMP_API Buffer_C {
        
        const UINT8 * ptr;
        UINT32 size;
        
        Buffer_C(const UINT8 * p, UINT32 sz)
        :ptr(p),
        size(sz) {
        }
        
        void Decrease(UINT32 sz) {
            
            if (sz > size)
                sz = size;
            
            size -= sz;
            if (ptr)
                ptr += sz;
            
        }
    };
    
    
    struct UMP_API Buffer {
        
        UINT8 * ptr;
        UINT32 size;
        
        Buffer(UINT8 * p, UINT32 sz)
        :ptr(p),
        size(sz) {
        }
        
        void Decrease(UINT32 sz) {
            
            if (sz > size)
                sz = size;
            
            size -= sz;
            if (ptr)
                ptr += sz;
            
        }
    };
    
    /*
     *	PCM“Ù∆µ∏Ò Ω√Ë ˆ
     */
    struct UMP_API Format {
        
        UINT32 sampleRate; //≤…—˘¬
        UINT32 bitPerSample; //≤…—˘Œª ˝
        UINT32 channels;  //…˘µ¿ ˝
        
        //“ª–©≥£”√∏Ò Ω
        const static Format af8k16bmono;
        const static Format af8k8bmono;
        const static Format af8k16bstereo;
        const static Format af8k8bstereo;
        const static Format af16k16bmono;
        const static Format af16k8bmono;
        const static Format af16k16bstereo;
        const static Format af16k8bstereo;
        const static Format af32k16bmono;
        
        const static Format afnull;
        
        explicit Format(UINT32 sampleRate = 0, UINT32 bitPerSample = 0, UINT32 channels = 0){}
        
        virtual ~Format(){}
        
        UINT32 GetSampleSize() const;
        
        bool operator == (const Format & other) const;
        bool operator != (const Format & other) const;
        
        bool IsValid() const;

        //∏˘æ›◊÷Ω⁄ ˝º∆À„ ±≥§
        UINT32 CalcTime(UINT32 size) const;
        //∏˘æ› ±≥§º∆À„◊÷Ω⁄ ˝
        UINT32 CalcSize(UINT32 time) const;
        
    };

    namespace codec {
        
        
        enum E_Type {
            
            e_null			= 0,
            e_g711u			= 1,
            e_g711a			= 2,
            e_g729			= 10,
            e_g7231			= 20,
            e_g7221_16k		= 80,
            e_g7221_32k		= 81,
        };
    }
    
}

#endif /* defined(__UMPStack__utype__) */
