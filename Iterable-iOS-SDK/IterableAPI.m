//
//  IterableAPI.m
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 11/19/14.
//  Copyright (c) 2014 Iterable. All rights reserved.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

@import Foundation;
@import UIKit;

#include <asl.h>

#import "IterableAPI.h"
#import "NSData+Conversion.h"
#import "CommerceItem.h"
#import "IterableLogging.h"

@interface IterableAPI () {
}

@end

@implementation IterableAPI {
}

static IterableAPI *sharedInstance = nil;

NSString * const endpoint = @"https://api.iterable.com/api/";

//////////////////////////
/// @name Internal methods
//////////////////////////

/**
 @method
 
 @abstract Converts a PushServicePlatform into a NSString recognized by Iterable
 
 @param pushServicePlatform the PushServicePlatform
 
 @return an NSString that the Iterable backend can understand
 */
+ (NSString *)pushServicePlatformToString:(PushServicePlatform)pushServicePlatform
{
    NSString *result = nil;
    
    switch(pushServicePlatform) {
        case APNS:
            result = @"APNS";
            break;
        case APNS_SANDBOX:
            result = @"APNS_SANDBOX";
            break;
        default:
            LogError(@"Unexpected PushServicePlatform: %ld", (long)pushServicePlatform);
    }
    
    return result;
}

/**
 @method
 
 @abstract Creates a full URL with host and apiKey, given the endpoint URI
 
 @param action the endpoint URI
 
 @return an `NSString` containing the full URL
 */
- (NSURL *)getUrlForAction:(NSString *)action
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?api_key=%@", endpoint, action, self.apiKey]];
}

/**
 @method
 
 @abstract Converts an `NSDictionary` into a JSON string
 
 @param dict the `NSDictionary`
 
 @return an `NSString` containing the JSON representation of `dict`
 */
+ (NSString *)dictToJson:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    if (! jsonData) {
        LogWarning(@"dictToJson failed: %@", error);
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

/**
 @method 
 
 @abstract Creates a POST request to the specified action URI, with body data `args`
 
 @param action  the action URI
 @param args    the data to POST
 
 @return a POST-method `NSURLRequest` to the specified action with the specified data
 */
- (NSURLRequest *)createRequestForAction:(NSString *)action withArgs:(NSDictionary *)args
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self getUrlForAction:action]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[IterableAPI dictToJson:args] dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

/**
 @method
 
 @abstract executes the given `request`, attaching success and failure handlers
 
 @discussion A request is consider successful as long as it does not meet any of the criteria outlined below:
 
 - there is no response
 - the server responds with a non-OK status
 - the server responds with a string that can not be parsed into JSON
 - the server responds with a string that can be parsed into JSON, but is not a dictionary

 @param request     An `NSURLRequest` with the request to execute.
 @param onSuccess   A closure to execute if the request is successful. 
                    It should accept one argument, an `NSDictionary` of the response.
 @param onFailure   A closure to execute if the request fails. 
                    It should accept two arguments: an `NSString` containing the reason this request failed, and an `NSData` containing the raw response.
 */
- (void)sendRequest:(NSURLRequest *)request onSuccess:(void (^)(NSDictionary *))onSuccess onFailure:(void (^)(NSString *, NSData *))onFailure
{
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil) {
             error = nil;
             id object = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:0
                          error:&error];
             if(error) {
                 NSString *reason = [NSString stringWithFormat:@"Could not parse json: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                 if (onFailure != nil) onFailure(reason, data);
             } else if([object isKindOfClass:[NSDictionary class]]) {
                 if (onSuccess != nil) onSuccess(object);
             } else {
                 if (onFailure != nil) onFailure(@"Response is not a dictionary", data);
             }
         } else if ([data length] == 0 && error == nil) {
             if (onFailure != nil) onFailure(@"No data received", data);
         } else if (error != nil) {
             NSString *reason = [NSString stringWithFormat:@"%@", error];
             if (onFailure != nil) onFailure(reason, data);
         }
     }];
}

/**
 @method
 
 @abstract Generates an `NSString` representing a `UIUserInterfaceIdiom`
 
 @param idiom the `UIUserInterfaceIdiom` to convert to a string
 
 @return a string representing the `idiom`
 */
+ (NSString *)userInterfaceIdiomEnumToString:(UIUserInterfaceIdiom)idiom
{
    NSString *result = nil;
    switch (idiom) {
        case UIUserInterfaceIdiomPhone:
            result = @"Phone";
            break;
        case UIUserInterfaceIdiomPad:
            result = @"Pad";
            break;
        default:
            result = @"Unspecified";
    }
    return result;
}


//////////////////////////////////////////////////////////////
/// @name Implementations of things documents in IterableAPI.h
//////////////////////////////////////////////////////////////

// documented in IterableAPI.h
- (instancetype)initWithApiKey:(NSString *)apiKey andEmail:(NSString *)email launchOptions:(NSDictionary *)launchOptions
{
    if (self = [super init]) {
        _apiKey = [apiKey copy];
        _email = [email copy];
    }
    
    if (launchOptions && launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        // Automatically try to track a pushOpen
        [self trackPushOpen:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] dataFields:nil];
    }
    
    return self;
}

// documented in IterableAPI.h
- (instancetype)initWithApiKey:(NSString *)apiKey andEmail:(NSString *)email
{
    return [self initWithApiKey:apiKey andEmail:email launchOptions:nil];
}

// documented in IterableAPI.h
+ (IterableAPI *)sharedInstance
{
    if (sharedInstance == nil) {
        LogError(@"[sharedInstance called before sharedInstanceWithApiKey");
    }
    return sharedInstance;
}

// documented in IterableAPI.h
+ (IterableAPI *)sharedInstanceWithApiKey:(NSString *)apiKey andEmail:(NSString *)email launchOptions:(NSDictionary *)launchOptions
{
    // threadsafe way to create a static singleton https://stackoverflow.com/questions/5720029/create-singleton-using-gcds-dispatch-once-in-objective-c
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[IterableAPI alloc] initWithApiKey:apiKey andEmail:email launchOptions:launchOptions];
    });
    return sharedInstance;
}

// documented in IterableAPI.h
- (void)registerToken:(NSData *)token appName:(NSString *)appName pushServicePlatform:(PushServicePlatform)pushServicePlatform
{
    NSString *hexToken = [token hexadecimalString];

    if ([hexToken length] != 64) {
         LogError(@"registerToken: invalid token");
    } else {
        UIDevice *device = [UIDevice currentDevice];
        NSString *psp = [IterableAPI pushServicePlatformToString:pushServicePlatform];

        if (!psp) {
            LogError(@"registerToken: invalid pushServicePlatform");
            return;
        }

        NSDictionary *args = @{
                               @"email": self.email,
                               @"device": @{
                                       @"token": hexToken,
                                       @"platform": psp,
                                       @"applicationName": appName,
                                       @"dataFields": @{
                                               @"name": [device name],
                                               @"localizedModel": [device localizedModel],
                                               @"userInterfaceIdiom": [IterableAPI userInterfaceIdiomEnumToString:[device userInterfaceIdiom]],
                                               @"identifierForVendor": [[device identifierForVendor] UUIDString],
                                               @"systemName": [device systemName],
                                               @"systemVersion": [device systemVersion],
                                               @"model": [device model]
                                               }
                                       }
                               };
        LogDebug(@"sending registerToken request with args %@", args);
        NSURLRequest *request = [self createRequestForAction:@"users/registerDeviceToken" withArgs:args];
        [self sendRequest:request onSuccess:^(NSDictionary *data)
         {
             LogDebug(@"registerToken succeeded, got response: %@", data);
         } onFailure:^(NSString *reason, NSData *data)
         {
             LogWarning(@"registerToken failed: %@. Got response %@", reason, data);
         }];

    }
}

// documented in IterableAPI.h
- (void)track:(nonnull NSString *)eventName dataFields:(NSDictionary *)dataFields
{
    NSDictionary *args;
    if (dataFields) {
        args = @{
                 @"email": self.email,
                 @"eventName": eventName,
                 @"dataFields": dataFields
                 };
        
    } else {
        args = @{
                 @"email": self.email,
                 @"eventName": eventName,
                 };
        
    }
    NSURLRequest *request = [self createRequestForAction:@"events/track" withArgs:args];
    [self sendRequest:request onSuccess:^(NSDictionary *data)
     {
         LogDebug(@"track succeeded, got response: %@", data);
     } onFailure:^(NSString *reason, NSData *data)
     {
         LogWarning(@"track failed: %@. Got response %@", reason, data);
     }];
}

// documented in IterableAPI.h
- (void)trackPushOpen:(NSDictionary *)userInfo dataFields:(NSDictionary *)dataFields
{
    LogDebug(@"tracking push open");
    
    if (userInfo && userInfo[@"itbl"]) {
        NSDictionary *pushData = userInfo[@"itbl"];
        if ([pushData isKindOfClass:[NSDictionary class]] && pushData[@"campaignId"]) {
            [self trackPushOpen:pushData[@"campaignId"] templateId:pushData[@"templateId"] appAlreadyRunning:false dataFields:dataFields];
        } else {
            // TODO - throw error here, bad push payload
            LogError(@"error tracking push open");
        }
    }
}

// documented in IterableAPI.h
- (void)trackPushOpen:(nonnull NSNumber *)campaignId templateId:(nonnull NSNumber *)templateId appAlreadyRunning:(BOOL)appAlreadyRunning dataFields:(NSDictionary *)dataFields
{
    NSMutableDictionary *reqDataFields;
    if (dataFields) {
        reqDataFields = [dataFields mutableCopy];
        reqDataFields[@"appAlreadyRunning"] = @(appAlreadyRunning);
    } else {
        reqDataFields = [NSMutableDictionary dictionary];
        reqDataFields[@"appAlreadyRunning"] = @(appAlreadyRunning);
    }
    
    NSDictionary *args = @{
                           @"email": self.email,
                           @"campaignId": campaignId,
                           @"templateId": templateId,
                           @"dataFields": reqDataFields
                           };
    NSURLRequest *request = [self createRequestForAction:@"events/trackPushOpen" withArgs:args];
    [self sendRequest:request onSuccess:^(NSDictionary *data)
     {
         LogDebug(@"trackPushOpen succeeded, got response: %@", data);
     } onFailure:^(NSString *reason, NSData *data)
     {
         LogWarning(@"trackPushOpen failed: %@. Got response %@", reason, data);
     }];
}

// documented in IterableAPI.h
- (void)trackPurchase:(nonnull NSNumber *)total items:(nonnull NSArray<CommerceItem> *)items dataFields:(NSDictionary *)dataFields
{
    NSDictionary *args;
    
    NSMutableArray *itemsToSerialize = [[NSMutableArray alloc] init];
    for (CommerceItem *item in items) {
        NSDictionary *itemDict = [item toDictionary];
        [itemsToSerialize addObject:itemDict];
    }
    NSDictionary *apiUserDict = @{
                                  @"email": self.email
                                  };
    
    if (dataFields) {
        args = @{
                 @"user": apiUserDict,
                 @"items": itemsToSerialize,
                 @"total": total,
                 @"dataFields": dataFields
                 };
    } else {
        args = @{
                 @"user": apiUserDict,
                 @"total": total,
                 @"items": itemsToSerialize
                 };
    }
    NSURLRequest *request = [self createRequestForAction:@"commerce/trackPurchase" withArgs:args];
    [self sendRequest:request onSuccess:^(NSDictionary *data)
     {
         LogDebug(@"trackPurchase succeeded, got response: %@", data);
     } onFailure:^(NSString *reason, NSData *data)
     {
         LogWarning(@"trackPurchase failed: %@. Got response %@", reason, data);
     }];
}

@end
