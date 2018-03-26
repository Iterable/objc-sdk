//
//  IterableLogging.h
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 6/1/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

#ifndef IterableLogging_h
#define IterableLogging_h

////////////////////////
/// @name Logging macros
////////////////////////

// function that appends STDERR to the asl logger; uses dispatch_once to only do it once
void AddStderrOnce(void);

// heavily inspired by http://doing-it-wrong.mikeweller.com/2012/07/youre-doing-it-wrong-1-nslogdebug-ios.html
// and http://stackoverflow.com/questions/300673/is-it-true-that-one-should-not-use-nslog-on-production-code
// this is a much more lightweight solution than what is provided by frameworks such as CocoaLumberjack

// ITERABLE_LOG_LEVEL is the minimum log level to display
// ASL_LEVEL_NOTICE is the default output level
// when building in DEBUG, we want to see everything, so show DEBUG-level messages
#ifndef ITERABLE_LOG_LEVEL
    #ifdef DEBUG
        #define ITERABLE_LOG_LEVEL ASL_LEVEL_DEBUG
    #else
        #define ITERABLE_LOG_LEVEL ASL_LEVEL_NOTICE
    #endif
#endif

// macro to log errors; preprocessed out if the log level is lower
#if ITERABLE_LOG_LEVEL >= ASL_LEVEL_ERR
    void LogError(NSString *format, ...);
#else
    #define LogError(...)
#endif

// macro to log warnings; preprocessed out if the log level is lower
#if ITERABLE_LOG_LEVEL >= ASL_LEVEL_WARNING
    void LogWarning(NSString *format, ...);
#else
    #define LogWarning(...)
#endif

// macro to log notices; preprocessed out if the log level is lower
#if ITERABLE_LOG_LEVEL >= ASL_LEVEL_NOTICE
    void LogNotice(NSString *format, ...);
#else
    #define LogNotice(...)
#endif

// macro to log info; preprocessed out if the log level is lower
#if ITERABLE_LOG_LEVEL >= ASL_LEVEL_INFO
    void LogInfo(NSString *format, ...);
#else
    #define LogInfo(...)
#endif

// macro to log debug; preprocessed out if the log level is lower
// this one will also print info about the file, function, and line number the message is coming from
#if ITERABLE_LOG_LEVEL >= ASL_LEVEL_DEBUG
    #define LogDebug(format, ...) \
    { \
        AddStderrOnce(); \
        NSString *message = [NSString stringWithFormat:format, ##__VA_ARGS__]; \
        NSString *messageWithDebug = [NSString stringWithFormat:@"<%@:(%s:%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __PRETTY_FUNCTION__, __LINE__, message]; \
        asl_log(NULL, NULL, (ASL_LEVEL_DEBUG), "[Iterable] %s", [messageWithDebug UTF8String]); \
    }
#else
    #define LogDebug(...)
#endif

#endif /* IterableLogging_h */
