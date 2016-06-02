//
//  IterableLogging.h
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 6/1/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

#ifndef IterableLogging_h
#define IterableLogging_h

#include <asl.h>

////////////////////////
/// @name Logging macros
////////////////////////

// heavily inspired by http://doing-it-wrong.mikeweller.com/2012/07/youre-doing-it-wrong-1-nslogdebug-ios.html
// and http://stackoverflow.com/questions/300673/is-it-true-that-one-should-not-use-nslog-on-production-code

// ASL_LEVEL_NOTICE is the default output level
// when building in DEBUG, we want to see everything, so show DEBUG-level messages 

#ifndef ITERABLE_LOG_LEVEL
    #ifdef DEBUG
        #define ITERABLE_LOG_LEVEL ASL_LEVEL_DEBUG
    #else
        #define ITERABLE_LOG_LEVEL ASL_LEVEL_NOTICE
    #endif
#endif

#if ITERABLE_LOG_LEVEL >= ASL_LEVEL_ERR
    void LogError(NSString *format, ...);
#else
    #define LogError(...)
#endif

#if ITERABLE_LOG_LEVEL >= ASL_LEVEL_WARNING
    void LogWarning(NSString *format, ...);
#else
    #define LogWarning(...)
#endif

#if ITERABLE_LOG_LEVEL >= ASL_LEVEL_NOTICE
    void LogNotice(NSString *format, ...);
#else
    #define LogNotice(...)
#endif

#if ITERABLE_LOG_LEVEL >= ASL_LEVEL_INFO
    void LogInfo(NSString *format, ...);
#else
    #define LogInfo(...)
#endif

#if ITERABLE_LOG_LEVEL >= ASL_LEVEL_DEBUG
    #define LogDebug(format, ...) \
    { \
        NSString *message = [NSString stringWithFormat:format, ##__VA_ARGS__]; \
        NSString *messageWithDebug = [NSString stringWithFormat:@"<%@:(%s:%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __PRETTY_FUNCTION__, __LINE__, message]; \
        asl_log(NULL, NULL, (ASL_LEVEL_DEBUG), "[Iterable] %s", [messageWithDebug UTF8String]); \
    }
#else
    #define LogDebug(...)
#endif

#endif /* IterableLogging_h */
