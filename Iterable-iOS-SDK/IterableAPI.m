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
#import "IterableNotificationMetadata.h"

@interface IterableAPI () {
}

@end

@implementation IterableAPI {
}

// the shared instance we've created
static IterableAPI *sharedInstance = nil;

// the URL session we're going to be using
static NSURLSession *urlSession = nil;

// the API endpoint
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
+ (nullable NSString *)dictToJson:(NSDictionary *)dict
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
    NSString *bodyPossiblyNil = [IterableAPI dictToJson:args];
    // if dictToJson fails, try sending the event anyways, just don't set the body
    if (bodyPossiblyNil) {
        [request setHTTPBody:[bodyPossiblyNil dataUsingEncoding:NSUTF8StringEncoding]];
    }
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
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:request
                                               completionHandler:^(NSData *data,
                                                                   NSURLResponse *response,
                                                                   NSError *error)
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
    [task resume];
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

/**
 @method
 
 @abstract creates a singleton URLSession for the class to use
 */
- (void)createUrlSession
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        urlSession = [NSURLSession sessionWithConfiguration:configuration];
    });
}

/**
 @method
 
 @abstract default success completion handler; debug logs the result from Iterable
 
 @param identifier an identifier for what succeeded; pass in something like the function name
 
 @return a completion handler for use with `onSuccess` of `sendRequest:onSuccess:onFailure:`
 */
+ (OnSuccessHandler)defaultOnSuccess:(NSString *)identifier
{
    return ^(NSDictionary *data)
    {
        LogDebug(@"%@ succeeded, got response: %@", identifier, data);
    };
}

/**
 @method
 
 @abstract default failure completion handler; warning logs the result from Iterable
 
 @param identifier an identifier for what succeeded; pass in something like the function name
 
 @return a completion handler for use with `onFailure` of `sendRequest:onSuccess:onFailure:`
 */
+ (OnFailureHandler)defaultOnFailure:(NSString *)identifier
{
    return ^(NSString *reason, NSData *data)
    {
        LogWarning(@"%@ failed: %@. Got response %@", identifier, reason, data);
    };
}

/*!
 @method
 
 @abstract Initializes Iterable with launchOptions
 
 @param apiKey          your Iterable apiKey
 @param email           the email of the user logged in
 @param launchOptions   launchOptions from application:didFinishLaunchingWithOptions
 
 @return an instance of IterableAPI
 */
- (instancetype)initWithApiKey:(NSString *)apiKey andEmail:(NSString *)email launchOptions:(NSDictionary *)launchOptions
{
    if (self = [super init]) {
        _apiKey = [apiKey copy];
        _email = [email copy];
    }
    
    return [self createSession:launchOptions];
}

/*!
 @method
 
 @abstract Initializes Iterable with launchOptions
 
 @param apiKey          your Iterable apiKey
 @param userId          the userId of the user logged in
 @param launchOptions   launchOptions from application:didFinishLaunchingWithOptions
 
 @return an instance of IterableAPI
 */
- (instancetype)initWithApiKey:(NSString *)apiKey andUserId:(NSString *)userId launchOptions:(NSDictionary *)launchOptions
{
    if (self = [super init]) {
        _apiKey = [apiKey copy];
        _userId = [userId copy];
    }
    return [self createSession:launchOptions];
}

/*!
 @method
 
 @abstract creates an iterable session with launchOptions

 @param launchOptions   launchOptions from application:didFinishLaunchingWithOptions
 
 @return an instance of IterableAPI
 */
- (instancetype)createSession:(NSDictionary *)launchOptions
{
    // the url session doesn't depend on any options/params, so we'll use a singleton that gets created whenever the class is instantiated
    // if it gets instantiated again that's fine; we don't need to reconfigure the session, just keep using the old singleton
    [self createUrlSession];
    
    if (launchOptions && launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        // Automatically try to track a pushOpen
        [self trackPushOpen:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
    return self;
}

//////////////////////////////////////////////////////////////
/// @name Implementations of things documents in IterableAPI.h
//////////////////////////////////////////////////////////////

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
+ (IterableAPI *)sharedInstanceWithApiKey:(NSString *)apiKey andUserId:(NSString *)userId launchOptions:(NSDictionary *)launchOptions
{
    // threadsafe way to create a static singleton https://stackoverflow.com/questions/5720029/create-singleton-using-gcds-dispatch-once-in-objective-c
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[IterableAPI alloc] initWithApiKey:apiKey andUserId:userId launchOptions:launchOptions];
    });
    return sharedInstance;
}

// documented in IterableAPI.h
- (void)registerToken:(NSData *)token appName:(NSString *)appName pushServicePlatform:(PushServicePlatform)pushServicePlatform
{
    [self registerToken:token appName:appName pushServicePlatform:pushServicePlatform onSuccess:[IterableAPI defaultOnSuccess:@"registerToken"] onFailure:[IterableAPI defaultOnFailure:@"registerToken"]];
}

// documented in IterableAPI.h
- (void)registerToken:(NSData *)token appName:(NSString *)appName pushServicePlatform:(PushServicePlatform)pushServicePlatform onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure
{
    NSString *hexToken = [token hexadecimalString];
    _hexToken = hexToken;

    UIDevice *device = [UIDevice currentDevice];
    NSString *psp = [IterableAPI pushServicePlatformToString:pushServicePlatform];
    
    if (!psp) {
        LogError(@"registerToken: invalid pushServicePlatform");
        if (onFailure) {
            onFailure(@"Not registering device token - the specified PushServicePlatform is invalid", [[NSData alloc] init]);
        }
        return;
    }
    
    NSDictionary *deviceDictionary = @{
                 @"token": hexToken,
                 @"platform": psp,
                 @"applicationName": appName,
                 @"dataFields": @{
                         @"localizedModel": [device localizedModel],
                         @"userInterfaceIdiom": [IterableAPI userInterfaceIdiomEnumToString:[device userInterfaceIdiom]],
                         @"identifierForVendor": [[device identifierForVendor] UUIDString],
                         @"systemName": [device systemName],
                         @"systemVersion": [device systemVersion],
                         @"model": [device model]
                         }
                 };

    NSDictionary *args;
    if (_email != nil) {
        args = @{
                 @"email": self.email,
                 @"device": deviceDictionary
                 };
    } else {
        args = @{
                 @"userId": self.userId,
                 @"device": deviceDictionary
                 };
    }
    
    LogDebug(@"sending registerToken request with args %@", args);
    NSURLRequest *request = [self createRequestForAction:@"users/registerDeviceToken" withArgs:args];
    [self sendRequest:request onSuccess:onSuccess onFailure:onFailure];
}

/*!
 @method
 
 @abstract Disable this device's token in Iterable with custom completion blocks. `allUsers` indicates whether to disable for all users with this token, or only current user 
 
 @param onSuccess               OnSuccessHandler to invoke if disabling the token is successful
 @param onFailure               OnFailureHandler to invoke if disabling the token fails
 
 @see OnSuccessHandler
 @see OnFailureHandler
 */
- (void)disableDevice:(BOOL)allUsers onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure
{
    if (!self.hexToken || (!allUsers && !(self.email || self.userId))) {
        LogWarning(@"disableDevice: email or token not yet registered");
        if (onFailure) {
            onFailure(@"Not disabling device - you must call registerToken first, and sharedInstance must have an email or userId", [[NSData alloc] init]);
        }
        return;
    }
    NSDictionary *args;
    if (_email != nil) {
        args = @{
                 @"email": allUsers ? [NSNull null]: self.email,
                 @"token": self.hexToken
                 };
    } else {
        args = @{
                 @"userId": allUsers ? [NSNull null]: self.userId,
                 @"token": self.hexToken
                 };
    }
    
    LogDebug(@"sending disableToken request with args %@", args);
    NSURLRequest *request = [self createRequestForAction:@"users/disableDevice" withArgs:args];
    [self sendRequest:request onSuccess:onSuccess onFailure:onFailure];
}

// documented in IterableAPI.h
- (void)disableDeviceForCurrentUser
{
    return [self disableDeviceForCurrentUserWithOnSuccess:[IterableAPI defaultOnSuccess:@"disableDevice"] onFailure:[IterableAPI defaultOnFailure:@"disableDevice"]];
}

// documented in IterableAPI.h
- (void)disableDeviceForAllUsers
{
    return [self disableDeviceForAllUsersWithOnSuccess:[IterableAPI defaultOnSuccess:@"disableDevice"] onFailure:[IterableAPI defaultOnFailure:@"disableDevice"]];
}

// documented in IterableAPI.h
- (void)disableDeviceForCurrentUserWithOnSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure
{
    return [self disableDevice:FALSE onSuccess:onSuccess onFailure:onFailure];
}

// documented in IterableAPI.h
- (void)disableDeviceForAllUsersWithOnSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure
{
    return [self disableDevice:TRUE onSuccess:onSuccess onFailure:onFailure];
}

// documented in IterableAPI.h
- (void)track:(NSString *)eventName
{
    [self track:eventName dataFields:nil];
}

// documented in IterableAPI.h
- (void)track:(NSString *)eventName dataFields:(NSDictionary *)dataFields
{
    [self track:eventName dataFields:dataFields onSuccess:[IterableAPI defaultOnSuccess:@"track"] onFailure:[IterableAPI defaultOnFailure:@"track"]];
}

// documented in IterableAPI.h
- (void)track:(NSString *)eventName dataFields:(NSDictionary *)dataFields onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure
{
    NSDictionary *args;
    if (dataFields) {
        
        if (_email != nil) {
            args = @{
                     @"email": self.email,
                     @"eventName": eventName,
                     @"dataFields": dataFields
                     };
        } else {
            args = @{
                     @"userId": self.userId,
                     @"eventName": eventName,
                     @"dataFields": dataFields
                     };
        }
    } else {
        if (_email != nil) {
            args = @{
                     @"email": self.email,
                     @"eventName": eventName,
                     };
        } else {
            args = @{
                     @"userId": self.userId,
                     @"eventName": eventName,
                     };
        }
    }
    NSURLRequest *request = [self createRequestForAction:@"events/track" withArgs:args];
    [self sendRequest:request onSuccess:onSuccess onFailure:onFailure];
}

// documented in IterableAPI.h
- (void)trackPushOpen:(NSDictionary *)userInfo
{
    [self trackPushOpen:userInfo dataFields:nil];
}

// documented in IterableAPI.h
- (void)trackPushOpen:(NSDictionary *)userInfo dataFields:(NSDictionary *)dataFields
{
    [self trackPushOpen:userInfo dataFields:dataFields onSuccess:[IterableAPI defaultOnSuccess:@"trackPushOpen"] onFailure:[IterableAPI defaultOnFailure:@"trackPushOpen"]];
}

// documented in IterableAPI.h
- (void)trackPushOpen:(NSDictionary *)userInfo dataFields:(NSDictionary *)dataFields onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure
{
    IterableNotificationMetadata *notification = [IterableNotificationMetadata metadataFromLaunchOptions:userInfo];
    if (notification && [notification isRealCampaignNotification]) {
        [self trackPushOpen:notification.campaignId templateId:notification.templateId messageId:notification.messageId appAlreadyRunning:false dataFields:dataFields onSuccess:onSuccess onFailure:onFailure];
    } else {
        if (onFailure) {
            onFailure(@"Not tracking push open - payload is not an Iterable notification, or a test/proof/ghost push", [[NSData alloc] init]);
        }
    }
}

// documented in IterableAPI.h
- (void)trackPushOpen:(NSNumber *)campaignId templateId:(NSNumber *)templateId messageId:(NSString *)messageId appAlreadyRunning:(BOOL)appAlreadyRunning dataFields:(NSDictionary *)dataFields
{
    [self trackPushOpen:campaignId templateId:templateId messageId:messageId appAlreadyRunning:appAlreadyRunning dataFields:dataFields onSuccess:[IterableAPI defaultOnSuccess:@"trackPushOpen"] onFailure:[IterableAPI defaultOnFailure:@"trackPushOpen"]];
}

// documented in IterableAPI.h
- (void)trackPushOpen:(NSNumber *)campaignId templateId:(NSNumber *)templateId messageId:(NSString *)messageId appAlreadyRunning:(BOOL)appAlreadyRunning dataFields:(NSDictionary *)dataFields onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure
{
    NSMutableDictionary *reqDataFields;
    if (dataFields) {
        reqDataFields = [dataFields mutableCopy];
    } else {
        reqDataFields = [NSMutableDictionary dictionary];
    }
    reqDataFields[@"appAlreadyRunning"] = @(appAlreadyRunning);
    
    NSDictionary *args;
    
    if (_email != nil) {
        args = @{
          @"email": self.email,
          @"campaignId": campaignId,
          @"templateId": templateId,
          @"messageId": messageId,
          @"dataFields": reqDataFields
          };
    } else {
        args = @{
          @"userId": self.userId,
          @"campaignId": campaignId,
          @"templateId": templateId,
          @"messageId": messageId,
          @"dataFields": reqDataFields
          };
    }
    NSURLRequest *request = [self createRequestForAction:@"events/trackPushOpen" withArgs:args];
    [self sendRequest:request onSuccess:onSuccess onFailure:onFailure];
}

// documented in IterableAPI.h
- (void)trackPurchase:(NSNumber *)total items:(NSArray<CommerceItem *> *)items
{
    [self trackPurchase:total items:items dataFields:nil];
}

// documented in IterableAPI.h
- (void)trackPurchase:(NSNumber *)total items:(NSArray<CommerceItem *> *)items dataFields:(NSDictionary *)dataFields
{
    [self trackPurchase:total items:items dataFields:dataFields onSuccess:[IterableAPI defaultOnSuccess:@"trackPurchase"] onFailure:[IterableAPI defaultOnFailure:@"trackPurchase"]];
}

// documented in IterableAPI.h
- (void)trackPurchase:(NSNumber *)total items:(NSArray<CommerceItem *> *)items dataFields:(NSDictionary *)dataFields onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure
{
    NSDictionary *args;
    
    NSMutableArray *itemsToSerialize = [[NSMutableArray alloc] init];
    for (CommerceItem *item in items) {
        NSDictionary *itemDict = [item toDictionary];
        [itemsToSerialize addObject:itemDict];
    }
    NSDictionary *apiUserDict;
    if (_email != nil) {
        apiUserDict = @{
            @"email": self.email
            };
    } else {
        apiUserDict = @{
            @"userId": self.userId
            };
    }
    
    
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
    [self sendRequest:request onSuccess:onSuccess onFailure:onFailure];
}

@end
