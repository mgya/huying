//
//  VoIPDefine.h
//  VoIPSDK
//
//  Created by thehuah on 13-2-22.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#ifndef VOIP_DEFINE_H
#define VOIP_DEFINE_H

#if __has_feature(objc_arc_weak)                //objc_arc_weak
#define UWEAK weak
#define U__WEAK __weak
#define UCFTYPECAST(exp) (__bridge exp)
#define UTYPECAST(exp) (__bridge_transfer exp)
#define UCFRELEASE(exp) CFRelease(exp)

#elif __has_feature(objc_arc)                   //objc_arc
#define UWEAK unsafe_unretained
#define U__WEAK __unsafe_unretained
#define UCFTYPECAST(exp) (__bridge exp)
#define UTYPECAST(exp) (__bridge_transfer exp)
#define UCFRELEASE(exp) CFRelease(exp)

#else                                           //none
#define UWEAK assign
#define U__WEAK
#define UCFTYPECAST(exp) (exp)
#define UTYPECAST(exp) (exp)
#define UCFRELEASE(exp) CFRelease(exp)

#endif //__has_feature

// Compiling for iOS
#ifndef NEEDS_DISPATCH_RETAIN_RELEASE
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000 // iOS 6.0 or later
#define NEEDS_DISPATCH_RETAIN_RELEASE 0
#else                                         // iOS 5.X or earlier
#define NEEDS_DISPATCH_RETAIN_RELEASE 1
#endif
#endif

#define UCLIENT_INFO @"Huying For iOS V1.1.3.702"
#define UCLIENT_VER_CODE 2



#endif //VOIP_DEFINE_H