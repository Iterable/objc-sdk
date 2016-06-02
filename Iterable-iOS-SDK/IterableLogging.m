//
//  IterableLogging.m
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 6/1/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <asl.h>

// adds STDERR to the asl logger
void AddStderrOnce()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        asl_add_log_file(NULL, STDERR_FILENO);
    });
}

// macro that generates a logging function for each level
#define __ITERABLE_MAKE_LOG_FUNCTION(LEVEL, NAME) \
void NAME (NSString *format, ...) \
{ \
    AddStderrOnce(); \
    va_list args; \
    va_start(args, format); \
\
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args]; \
    asl_log(NULL, NULL, (LEVEL), "[Iterable] %s", [message UTF8String]); \
\
    va_end(args); \
}

// we're never going to log in EMERG/ALERT/CRIT, so don't generate log functions for those
__ITERABLE_MAKE_LOG_FUNCTION(ASL_LEVEL_ERR, LogError)
__ITERABLE_MAKE_LOG_FUNCTION(ASL_LEVEL_WARNING, LogWarning)
__ITERABLE_MAKE_LOG_FUNCTION(ASL_LEVEL_NOTICE, LogNotice)
__ITERABLE_MAKE_LOG_FUNCTION(ASL_LEVEL_INFO, LogInfo)
// this is defined in the header so that we can use file/method/line
// __ITERABLE_MAKE_LOG_FUNCTION(ASL_LEVEL_DEBUG, LogDebug)

#undef __ITERABLE_MAKE_LOG_FUNCTION
