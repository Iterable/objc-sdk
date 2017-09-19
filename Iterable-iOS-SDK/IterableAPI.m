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
#import "IterableInAppManager.h"
#import "IterableConstants.h"

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

NSCharacterSet* encodedCharacterSet = nil;

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
            result = ITBL_KEY_APNS;
            break;
        case APNS_SANDBOX:
            result = ITBL_KEY_APNS_SANDBOX;
            break;
        default:
            LogError(@"Unexpected PushServicePlatform: %ld", (long)pushServicePlatform);
    }
    
    return result;
}

- (NSCharacterSet *)getEncodedSubset
{
    NSMutableCharacterSet* workingSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [workingSet removeCharactersInString:@"+"];
    return [workingSet copy];
}

/**
 @method
 
 @abstract Creates a full GET URL with host and apiKey, given the endpoint URI
 
 @param action the endpoint URI
 
 @return an `NSString` containing the full URL
 */
- (NSURL *)getUrlForAction:(NSString *)action
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?api_key=%@", endpoint, action, self.apiKey]];
}

/**
 @method
 
 @abstract Creates a full GET URL with host and apiKey, given the endpoint URI and parameters
 
 @param action the endpoint URI
 @param args the `NSDictionary`
 
 @return an `NSString` containing the full URL
 */
- (NSURL *)getUrlForGetAction:(NSString *)action withArgs:(NSDictionary *)args
{
    NSString *urlCombined = [NSString stringWithFormat:@"%@%@?api_key=%@", endpoint, action, self.apiKey];
    
    for (NSString* paramKey in args) {
        NSString* paramValue = args[paramKey];
        
        NSString *params = [NSString stringWithFormat:@"&%@=%@", paramKey, [self encodeURLParam:paramValue]];
        urlCombined = [urlCombined stringByAppendingString:params];
    }
    
    return [NSURL URLWithString:urlCombined];
}

/**
 @method
 
 @abstract Percent encodes the url query parameters
 
 @param paramValue The value to encode
 
 @return an `NSString` containing the encoded value
 */
- (NSString *)encodeURLParam:(NSString *)paramValue
{
    if ([paramValue isKindOfClass:[NSString class]])
    {
        return [paramValue stringByAddingPercentEncodingWithAllowedCharacters:encodedCharacterSet];
    } else {
        return paramValue;
    }
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
    [request setHTTPMethod:ITBL_KEY_POST];
    NSString *bodyPossiblyNil = [IterableAPI dictToJson:args];
    // if dictToJson fails, try sending the event anyways, just don't set the body
    if (bodyPossiblyNil) {
        [request setHTTPBody:[bodyPossiblyNil dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return request;
}

/**
 @method
 
 @abstract Creates a GET request to the specified action URI, with body data `args`
 
 @param action  the action URI
 @param args    the data to GET
 
 @return a GET-method `NSURLRequest` to the specified action with the specified data
 */
- (NSURLRequest *)createGetRequestForAction:(NSString *)action withArgs:(NSDictionary *)args
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self getUrlForGetAction:action withArgs:args]];
    [request setHTTPMethod:ITBL_KEY_GET];
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
                if (onSuccess != nil) {
                    onSuccess(object);
                }
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
            result = ITBL_KEY_PHONE;
            break;
        case UIUserInterfaceIdiomPad:
            result = ITBL_KEY_PAD;
            break;
        default:
            result = ITBL_KEY_UNSPECIFIED;
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
 
 @abstract creates an iterable session with launchOptions
 
 @param launchOptions launchOptions from application:didFinishLaunchingWithOptions
 
 @return an instance of IterableAPI
 */
- (instancetype)createSession:(NSDictionary *)launchOptions
{
    return [self createSession:launchOptions useCustomLaunchOptions:false];
}

/*!
 @method
 
 @abstract creates an iterable session with launchOptions
 
 @param launchOptions launchOptions from application:didFinishLaunchingWithOptions or custom launchOptions
 
 @param useCustomLaunchOptions whether or not to use the custom launchOption without the UIApplicationLaunchOptionsRemoteNotificationKey
 
 @return an instance of IterableAPI
 */
- (instancetype)createSession:(NSDictionary *)launchOptions useCustomLaunchOptions:(BOOL)useCustomLaunchOptions
{
    // the url session doesn't depend on any options/params, so we'll use a singleton that gets created whenever the class is instantiated
    // if it gets instantiated again that's fine; we don't need to reconfigure the session, just keep using the old singleton
    [self createUrlSession];
    
    encodedCharacterSet = [self getEncodedSubset];
    
    // Automatically try to track a pushOpen
    if (launchOptions) {
        if (useCustomLaunchOptions) {
            [self trackPushOpen:launchOptions];
        } else if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
            [self trackPushOpen:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
        }
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
+ (void)clearSharedInstance
{
    @synchronized (self) {
        sharedInstance = nil;
    }
}

// documented in IterableAPI.h
+ (IterableAPI *)sharedInstanceWithApiKey:(NSString *)apiKey andEmail:(NSString *)email launchOptions:(NSDictionary *)launchOptions
{
    @synchronized (self) {
        if(!sharedInstance){
            sharedInstance = [[IterableAPI alloc] initWithApiKey:apiKey andEmail:email launchOptions:launchOptions];
        }
        return sharedInstance;
    }
}

// documented in IterableAPI.h
+ (IterableAPI *)sharedInstanceWithApiKey:(NSString *)apiKey andUserId:(NSString *)userId launchOptions:(NSDictionary *)launchOptions
{
    @synchronized (self) {
        if(!sharedInstance){
            sharedInstance = [[IterableAPI alloc] initWithApiKey:apiKey andUserId:userId launchOptions:launchOptions];
        }
        return sharedInstance;
    }
}

// documented in IterableAPI.h
+(void) getAndTrackDeeplink:(NSURL *)webpageURL callbackBlock:(ITEActionBlock)callbackBlock
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:ITBL_DEEPLINK_IDENTIFIER options:0 error:NULL];
    NSString *urlString = webpageURL.absoluteString;
    NSTextCheckingResult *match = [regex firstMatchInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
    
    if (match == NULL) {
        callbackBlock(webpageURL.absoluteString);
    } else {
        NSURLSessionDataTask *trackAndRedirectTask = [[NSURLSession sharedSession]
                                                      dataTaskWithURL:webpageURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          callbackBlock(response.URL.absoluteString);
                                                      }];
        [trackAndRedirectTask resume];
    }
}

// documented in IterableAPI.h
- (instancetype)initWithApiKey:(NSString *)apiKey andEmail:(NSString *)email
{
    return [self initWithApiKey:apiKey andEmail:email launchOptions:nil];
}

// documented in IterableAPI.h
- (instancetype)initWithApiKey:(NSString *)apiKey andUserId:(NSString *)userId
{
    return [self initWithApiKey:apiKey andUserId:userId launchOptions:nil];
}

// documented in IterableAPI.h
- (instancetype)initWithApiKey:(NSString *)apiKey andEmail:(NSString *)email launchOptions:(NSDictionary *)launchOptions
{
    return [self initWithApiKey:apiKey andEmail:email launchOptions:launchOptions useCustomLaunchOptions:false];
}

// documented in IterableAPI.h
- (instancetype)initWithApiKey:(NSString *)apiKey andUserId:(NSString *)userId launchOptions:(NSDictionary *)launchOptions
{
    return [self initWithApiKey:apiKey andUserId:userId launchOptions:launchOptions useCustomLaunchOptions:false];
}

// documented in IterableAPI.h
- (instancetype)initWithApiKey:(NSString *)apiKey andEmail:(NSString *)email launchOptions:(NSDictionary *)launchOptions useCustomLaunchOptions:(BOOL)useCustomLaunchOptions
{
    if (self = [super init]) {
        _apiKey = [apiKey copy];
        _email = [email copy];
    }
    
    return [self createSession:launchOptions useCustomLaunchOptions:useCustomLaunchOptions];
}

// documented in IterableAPI.h
- (instancetype)initWithApiKey:(NSString *)apiKey andUserId:(NSString *)userId launchOptions:(NSDictionary *)launchOptions useCustomLaunchOptions:(BOOL)useCustomLaunchOptions
{
    if (self = [super init]) {
        _apiKey = [apiKey copy];
        _userId = [userId copy];
    }
    return [self createSession:launchOptions useCustomLaunchOptions:useCustomLaunchOptions];
}

// documented in IterableAPI.h
- (void)trackInAppOpen:(NSString *)messageId {
    NSDictionary *args;
    
    if (_email != nil) {
        args = @{
                 ITBL_KEY_EMAIL: self.email,
                 ITBL_KEY_MESSAGE_ID: messageId
                 };
    } else {
        args = @{
                 ITBL_KEY_USER_ID: self.userId,
                 ITBL_KEY_MESSAGE_ID: messageId
                 };
    }
    NSURLRequest *request = [self createRequestForAction:ENDPOINT_TRACK_INAPP_OPEN withArgs:args];
    [self sendRequest:request onSuccess:[IterableAPI defaultOnSuccess:@"trackInAppOpen"] onFailure:[IterableAPI defaultOnFailure:@"trackInAppOpen"]];
}

// documented in IterableAPI.h
- (void)inAppConsume:(NSString *)messageId {
    NSDictionary *args;
    
    if (_email != nil) {
        args = @{
                 ITBL_KEY_EMAIL: self.email,
                 ITBL_KEY_MESSAGE_ID: messageId
                 };
    } else {
        args = @{
                 ITBL_KEY_USER_ID: self.userId,
                 ITBL_KEY_MESSAGE_ID: messageId
                 };
    }
    NSURLRequest *request = [self createRequestForAction:ENDPOINT_INAPP_CONSUME withArgs:args];
    [self sendRequest:request onSuccess:[IterableAPI defaultOnSuccess:@"inAppConsume"] onFailure:[IterableAPI defaultOnFailure:@"inAppConsume"]];
}

// documented in IterableAPI.h
- (void)trackInAppClick:(NSString *)messageId buttonIndex:(NSNumber*)buttonIndex {
    NSDictionary *args;
    if (_email != nil) {
        args = @{
                 ITBL_KEY_EMAIL: self.email,
                 ITBL_KEY_MESSAGE_ID: messageId,
                 ITERABLE_IN_APP_BUTTON_INDEX: buttonIndex
                 };
    } else {
        args = @{
                 ITBL_KEY_USER_ID: self.userId,
                 ITBL_KEY_MESSAGE_ID: messageId,
                 ITERABLE_IN_APP_BUTTON_INDEX: buttonIndex
                 };
    }
    NSURLRequest *request = [self createRequestForAction:ENDPOINT_TRACK_INAPP_CLICK withArgs:args];
    [self sendRequest:request onSuccess:[IterableAPI defaultOnSuccess:@"trackInAppClick"] onFailure:[IterableAPI defaultOnFailure:@"trackInAppClick"]];
}

// documented in IterableAPI.h
- (void)trackInAppClick:(NSString *)messageId buttonURL:(NSString*)buttonURL {
    NSDictionary *args;
    if (_email != nil) {
        args = @{
                 ITBL_KEY_EMAIL: self.email,
                 ITBL_KEY_MESSAGE_ID: messageId,
                 ITERABLE_IN_APP_CLICK_URL: buttonURL
                 };
    } else {
        args = @{
                 ITBL_KEY_USER_ID: self.userId,
                 ITBL_KEY_MESSAGE_ID: messageId,
                 ITERABLE_IN_APP_CLICK_URL: buttonURL
                 };
    }
    NSURLRequest *request = [self createRequestForAction:ENDPOINT_TRACK_INAPP_CLICK withArgs:args];
    [self sendRequest:request onSuccess:[IterableAPI defaultOnSuccess:@"trackInAppClick"] onFailure:[IterableAPI defaultOnFailure:@"trackInAppClick"]];
}

// documented in IterableAPI.h
- (void)registerToken:(NSData *)token appName:(NSString *)appName pushServicePlatform:(PushServicePlatform)pushServicePlatform
{
    [self registerToken:token appName:appName pushServicePlatform:pushServicePlatform onSuccess:[IterableAPI defaultOnSuccess:@"registerToken"] onFailure:[IterableAPI defaultOnFailure:@"registerToken"]];
}

// documented in IterableAPI.h
- (void)registerToken:(NSData *)token appName:(NSString *)appName pushServicePlatform:(PushServicePlatform)pushServicePlatform onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure
{
    NSString *hexToken = [token ITEHexadecimalString];
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
                 ITBL_KEY_TOKEN: hexToken,
                 ITBL_KEY_PLATFORM: psp,
                 ITBL_KEY_APPLICATION_NAME: appName,
                 ITBL_KEY_DATA_FIELDS: @{
                         ITBL_DEVICE_LOCALIZED_MODEL: [device localizedModel],
                         ITBL_DEVICE_USER_INTERFACE: [IterableAPI userInterfaceIdiomEnumToString:[device userInterfaceIdiom]],
                         ITBL_DEVICE_ID_VENDOR: [[device identifierForVendor] UUIDString],
                         ITBL_DEVICE_SYSTEM_NAME: [device systemName],
                         ITBL_DEVICE_SYSTEM_VERSION: [device systemVersion],
                         ITBL_DEVICE_MODEL: [device model]
                         }
                 };

    NSDictionary *args;
    if (_email != nil) {
        args = @{
                 ITBL_KEY_EMAIL: self.email,
                 ITBL_KEY_DEVICE: deviceDictionary
                 };
    } else {
        args = @{
                 ITBL_KEY_USER_ID: self.userId,
                 ITBL_KEY_DEVICE: deviceDictionary
                 };
    }
    
    LogDebug(@"sending registerToken request with args %@", args);
    NSURLRequest *request = [self createRequestForAction:ENDPOINT_REGISTER_DEVICE_TOKEN withArgs:args];
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
                 ITBL_KEY_EMAIL: allUsers ? [NSNull null]: self.email,
                 ITBL_KEY_TOKEN: self.hexToken
                 };
    } else {
        args = @{
                 ITBL_KEY_USER_ID: allUsers ? [NSNull null]: self.userId,
                 ITBL_KEY_TOKEN: self.hexToken
                 };
    }
    
    LogDebug(@"sending disableToken request with args %@", args);
    NSURLRequest *request = [self createRequestForAction:ENDPOINT_DISABLE_DEVICE withArgs:args];
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
- (void)updateUser:(NSDictionary *)dataFields mergeNestedObjects:(BOOL)mergeNestedObjects onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure
{
    NSDictionary *args;
    if (dataFields) {
        NSNumber *mergeNested = [NSNumber numberWithBool:mergeNestedObjects];
        
        if (_email != nil) {
            args = @{
                     ITBL_KEY_EMAIL: self.email,
                     ITBL_KEY_DATA_FIELDS: dataFields,
                     ITBL_KEY_MERGE_NESTED: mergeNested
                     };
        } else {
            args = @{
                     ITBL_KEY_USER_ID: self.userId,
                     ITBL_KEY_DATA_FIELDS: dataFields,
                     ITBL_KEY_MERGE_NESTED: mergeNested
                     };
        }
        
        NSURLRequest *request = [self createRequestForAction:ENDPOINT_UPDATE_USER withArgs:args];
        [self sendRequest:request onSuccess:onSuccess onFailure:onFailure];
    }
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
                     ITBL_KEY_EMAIL: self.email,
                     ITBL_KEY_EVENT_NAME: eventName,
                     ITBL_KEY_DATA_FIELDS: dataFields
                     };
        } else {
            args = @{
                     ITBL_KEY_USER_ID: self.userId,
                     ITBL_KEY_EVENT_NAME: eventName,
                     ITBL_KEY_DATA_FIELDS: dataFields
                     };
        }
    } else {
        if (_email != nil) {
            args = @{
                     ITBL_KEY_EMAIL: self.email,
                     ITBL_KEY_EVENT_NAME: eventName,
                     };
        } else {
            args = @{
                     ITBL_KEY_USER_ID: self.userId,
                     ITBL_KEY_EVENT_NAME: eventName,
                     };
        }
    }
    NSURLRequest *request = [self createRequestForAction:ENDPOINT_TRACK withArgs:args];
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
          ITBL_KEY_EMAIL: self.email,
          ITBL_KEY_CAMPAIGN_ID: campaignId,
          ITBL_KEY_TEMPLATE_ID: templateId,
          ITBL_KEY_MESSAGE_ID: messageId,
          ITBL_KEY_DATA_FIELDS: reqDataFields
          };
    } else {
        args = @{
          ITBL_KEY_USER_ID: self.userId,
          ITBL_KEY_CAMPAIGN_ID: campaignId,
          ITBL_KEY_TEMPLATE_ID: templateId,
          ITBL_KEY_MESSAGE_ID: messageId,
          ITBL_KEY_DATA_FIELDS: reqDataFields
          };
    }
    NSURLRequest *request = [self createRequestForAction:ENDPOINT_TRACK_PUSH_OPEN withArgs:args];
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
            ITBL_KEY_EMAIL: self.email
            };
    } else {
        apiUserDict = @{
            ITBL_KEY_USER_ID: self.userId
            };
    }
    
    
    if (dataFields) {
        args = @{
                 ITBL_KEY_USER: apiUserDict,
                 ITBL_KEY_ITEMS: itemsToSerialize,
                 ITBL_KEY_TOTAL: total,
                 ITBL_KEY_DATA_FIELDS: dataFields
                 };
    } else {
        args = @{
                 ITBL_KEY_USER: apiUserDict,
                 ITBL_KEY_TOTAL: total,
                 ITBL_KEY_ITEMS: itemsToSerialize
                 };
    }
    NSURLRequest *request = [self createRequestForAction:ENDPOINT_COMMERCE_TRACK_PURCHASE withArgs:args];
    [self sendRequest:request onSuccess:onSuccess onFailure:onFailure];
}

// documented in IterableAPI.h
- (void)spawnInAppNotification:(ITEActionBlock)callbackBlock
{
    //TODO: If html doesn't exist in the payload - display an error message telling htem to upgrade to a later version of the SDK
    NSString *htmlString = [NSString stringWithFormat:@"<style> html, body { height: 100%; } html { background: white } body { background-color:#7A991A; border-radius: 20px; } .image { position: absolute; margin: auto; left: 0; right: 0; top: 0; bottom: 0; width: 40%; } .title { text-align: center; } .button { position: absolute; bottom: 10px; left: 50%; right:50%; } </style> <div> <div class=\"title\"> Iterable HTML In-App </div> <a href=\"iterable.com\" target=\"www.iterable.com\"> <img src=\"https://pbs.twimg.com/profile_images/808895199447486464/yjnIVncG.jpg\" border=\"0\" class=\"image\" alt=\"Null\"> </a> <button class=\"button\"> test </button> </div>"];
    
    //NSString *htmlString = [NSString stringWithFormat:@"<style>.nav {display: inline-block;background-color: #00B2EE;border: 1px solid #000000;border-width: 1px 0px;margin: 0;padding: 0;min-width: 1000px;width: 100%;}.nav li {list-style-type: none;width: 14.28%;float: left;}.nav a {display: inline-block;padding: 10px 0;width: 100%;text-align: center;} body {background-color: transparent;}h4 {color: maroon;margin-left: 40px;}</style><header><span class=\"banner_h\"><img src=\"Images\Top_Banner_4.png\" alt=\"Banner\" height=\"150\" width =\"140\" /></span><nav><ul class=\"nav\"><li><a href=\"itbl://index\">Home</a></li><li><a href=\"about.html\">About Us</a></li></ul></nav></header> Hello Everyone. Please check out the new website:<br> <a href=\"itbl://close\">clicky</a> here. <a href=\"www.google.com\">googled?</a>  <a href=\"app_link://testlinks\">  testLinks?</a><a href=\"otherstringname\">otherstring?</a>"];
    
//    htmlString = @"<HEAD><style>body {background-color: linen;}h4 {color: maroon;margin-left: 40px;} .portrait {width: 300;max-height: 100%;}</style><TITLE>Basic HTML Sample Page</TITLE></HEAD><BODY BGCOLOR=\"WHITE\"><CENTER><H1>A Simple Sample Web Page</H1><div class=\"portrait\"></div><H4>By Sheldon Brown</H4><H2>Demonstrating a few HTML features</H2></CENTER>HTML is really a very simple language. It consists of ordinary text, with commands that are enclosed by \"<\" and \">\" characters. <P>You don't really need to know much HTML to create a page, because you can copy bits of HTML from other pages that do what you want, then change the text!<P>This page shows on the left as it appears in your browser, and the corresponding HTML code appears on the right. The HTML commands are linked to explanations of what they do.<H3>Line Breaks</H3>HTML doesn't normally use line breaks for ordinary text. A white space of any size is treated as a single space. This is because the author of the page has no way of knowing the size of the reader's screen, or what size type they will have their browser set for.<P>If you want to put a line break at a particular place, you can use the BR command, or, for a paragraph break, the P command, which will insert a blank line. The heading command (pr) puts a blank line above and below the heading text.<H4>Starting and Stopping Commands</H4>Most HTML commands come in pairs: for example, H4 marks the beginning of a size 4 heading, and H4 marks the end of it. The closing command is always the same as the opening command, except for the addition of the \"/\".<P>Modifiers are sometimes included along with the basic command, inside the opening command's < >. The modifier does not need to be repeated in the closing command.<H1>This is a size 1 heading</H1><H2>This is a size 2 heading</H2><H3>This is a size 3 heading</H3><H4>This is a size 4 heading</H4><H5>This is a size 5 heading</H5><H6>This is a size 6 heading</H6><center><H4>Copyright © 1997, by<A HREF=\"www.sheldonbrown.com/index.html\">Sheldon Brown</A></H4>If you would like to make a link or bookmark to this page, the URL is:<BR> www.sheldonbrown.com/web_sample1.html</body>";
    
    
    //htmlString = @"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional //EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:v=\"urn:schemas-microsoft-com:vml\" xmlns:o=\"urn:schemas-microsoft-com:office:office\"><head><!--[if gte mso 9]><xml><o:OfficeDocumentSettings><o:AllowPNG/><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml><![endif]--><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/><meta name=\"viewport\" content=\"width=device-width\"/><!--[if !mso]><!--><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"/><!--<![endif]--><title>Simple</title><style type=\"text/css\" id=\"media-query\"> body { margin: 0; padding: 0; } table, tr, td { vertical-align: top; border-collapse: collapse; } .ie-browser table, .mso-container table { table-layout: fixed; } * { line-height: inherit; } a[x-apple-data-detectors=true] { color: inherit !important; text-decoration: none !important; } [owa] .img-container div, [owa] .img-container button { display: block !important; } [owa] .fullwidth button { width: 100% !important; } [owa] .block-grid .col { display: table-cell; float: none !important; vertical-align: top; } .ie-browser .num12, .ie-browser .block-grid, [owa] .num12, [owa] .block-grid { width: 480px !important; } .ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td, .ExternalClass div { line-height: 100%; } .ie-browser .mixed-two-up .num4, [owa] .mixed-two-up .num4 { width: 160px !important; } .ie-browser .mixed-two-up .num8, [owa] .mixed-two-up .num8 { width: 320px !important; } .ie-browser .block-grid.two-up .col, [owa] .block-grid.two-up .col { width: 240px !important; } .ie-browser .block-grid.three-up .col, [owa] .block-grid.three-up .col { width: 160px !important; } .ie-browser .block-grid.four-up .col, [owa] .block-grid.four-up .col { width: 120px !important; } .ie-browser .block-grid.five-up .col, [owa] .block-grid.five-up .col { width: 96px !important; } .ie-browser .block-grid.six-up .col, [owa] .block-grid.six-up .col { width: 80px !important; } .ie-browser .block-grid.seven-up .col, [owa] .block-grid.seven-up .col { width: 68px !important; } .ie-browser .block-grid.eight-up .col, [owa] .block-grid.eight-up .col { width: 60px !important; } .ie-browser .block-grid.nine-up .col, [owa] .block-grid.nine-up .col { width: 53px !important; } .ie-browser .block-grid.ten-up .col, [owa] .block-grid.ten-up .col { width: 48px !important; } .ie-browser .block-grid.eleven-up .col, [owa] .block-grid.eleven-up .col { width: 43px !important; } .ie-browser .block-grid.twelve-up .col, [owa] .block-grid.twelve-up .col { width: 40px !important; } @media only screen and (min-width: 500px) { .block-grid { width: 480px !important; } .block-grid .col { display: table-cell; Float: none !important; vertical-align: top; } .block-grid .col.num12 { width: 480px !important; } .block-grid.mixed-two-up .col.num4 { width: 160px !important; } .block-grid.mixed-two-up .col.num8 { width: 320px !important; } .block-grid.two-up .col { width: 240px !important; } .block-grid.three-up .col { width: 160px !important; } .block-grid.four-up .col { width: 120px !important; } .block-grid.five-up .col { width: 96px !important; } .block-grid.six-up .col { width: 80px !important; } .block-grid.seven-up .col { width: 68px !important; } .block-grid.eight-up .col { width: 60px !important; } .block-grid.nine-up .col { width: 53px !important; } .block-grid.ten-up .col { width: 48px !important; } .block-grid.eleven-up .col { width: 43px !important; } .block-grid.twelve-up .col { width: 40px !important; } } @media (max-width: 500px) { .block-grid, .col { min-width: 320px !important; max-width: 100% !important; } .block-grid { width: calc(100% - 40px) !important; } .col { width: 100% !important; } .col > div { margin: 0 auto; } img.fullwidth { max-width: 100% !important; } } </style></head><body class=\"clean-body\" style=\"margin: 0;padding: 0;-webkit-text-size-adjust: 100%;background-color: transparent\"><!--[if IE]><div class=\"ie-browser\"><![endif]--><!--[if mso]><div class=\"mso-container\"><![endif]--><div class=\"nl-container\" style=\"overflow:hidden;border-radius:25px;min-width: 320px;Margin: 0 auto;background-color: transparent\"><!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td align=\"center\" style=\"background-color: #FFFFFF;\"><![endif]--><div style=\"background-color:#323341;\"><div style=\"Margin: 0 auto;min-width: 320px;max-width: 480px;width: 480px;width: calc(17000% - 84520px);overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;\" class=\"block-grid \"><div style=\"border-collapse: collapse;display: table;width: 100%;\"><!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"background-color:#323341;\" align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width: 480px;\"><tr class=\"layout-full-width\" style=\"background-color:transparent;\"><![endif]--><!--[if (mso)|(IE)]><td align=\"center\" width=\"480\" style=\" width:480px; padding-right: 0px; padding-left: 0px; padding-top:0px; padding-bottom:0px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;\" valign=\"top\"><![endif]--><div class=\"col num12\" style=\"min-width: 320px;max-width: 480px;width: 480px;width: calc(16000% - 76320px);background-color: transparent;\"><div style=\"background-color: transparent; width: 100% !important;\"><!--[if (!mso)&(!IE)]><!--><div style=\"border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent; padding-top:0px; padding-bottom:0px; padding-right: 0px; padding-left: 0px;\"><!--<![endif]--><!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 0px; padding-left: 0px; padding-top: 5px; padding-bottom: 20px;\"><![endif]--><div style=\"color:#ffffff;line-height:120%;font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif; padding-right: 0px; padding-left: 0px; padding-top: 5px; padding-bottom: 20px;\"><div style=\"font-size:13px;line-height:16px;color:#ffffff;font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif;text-align:left;\"><p style=\"margin: 0;font-size: 14px;line-height: 17px;text-align: center\"><strong><span style=\"font-size: 28px; line-height: 33px;\">NEW RELEASE:</span></strong></p><p style=\"margin: 0;font-size: 14px;line-height: 17px;text-align: center\"><strong><span style=\"font-size: 28px; line-height: 33px;\">HTML In-App Notifications</span></strong></p></div></div><!--[if mso]></td></tr></table><![endif]--><div align=\"center\" class=\"img-container center\" style=\"padding-right: 0px; padding-left: 0px;\"><!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 0px; padding-left: 0px;\" align=\"center\"><![endif]--><a href=\"https://iterable.com\" target=\"_blank\"><img class=\"center\" align=\"center\" border=\"0\" src=\"https://app.iterable.com/assets/templates/builder/img/bee_rocket.png\" alt=\"Image\" title=\"Image\" style=\"outline: none;text-decoration: none;-ms-interpolation-mode: bicubic;clear: both;display: block !important;border: none;height: auto;float: none;width: 100%;max-width: 402px\" width=\"402\"/></a><!--[if mso]></td></tr></table><![endif]--></div><!--[if (!mso)&(!IE)]><!--></div><!--<![endif]--></div></div><!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]--></div></div></div><div style=\"background-color:#61626F;\"><div style=\"Margin: 0 auto;min-width: 320px;max-width: 480px;width: 480px;width: calc(17000% - 84520px);overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;\" class=\"block-grid \"><div style=\"border-collapse: collapse;display: table;width: 100%;\"><!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"background-color:#61626F;\" align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width: 480px;\"><tr class=\"layout-full-width\" style=\"background-color:transparent;\"><![endif]--><!--[if (mso)|(IE)]><td align=\"center\" width=\"480\" style=\" width:480px; padding-right: 0px; padding-left: 0px; padding-top:0px; padding-bottom:0px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;\" valign=\"top\"><![endif]--><div class=\"col num12\" style=\"min-width: 320px;max-width: 480px;width: 480px;width: calc(16000% - 76320px);background-color: transparent;\"><div style=\"background-color: transparent; width: 100% !important;\"><!--[if (!mso)&(!IE)]><!--><div style=\"border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent; padding-top:0px; padding-bottom:0px; padding-right: 0px; padding-left: 0px;\"><!--<![endif]--><!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 5px;\"><![endif]--><div style=\"color:#ffffff;line-height:120%;font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif; padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 5px;\"><div style=\"font-size:13px;line-height:16px;color:#ffffff;font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif;text-align:left;\"><p style=\"margin: 0;font-size: 18px;line-height: 22px;text-align: center\"><span style=\"font-size: 24px; line-height: 28px;\"><strong>Fully customizable HTML In-App Notifications</strong></span></p></div></div><!--[if mso]></td></tr></table><![endif]--><!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 0px; padding-bottom: 0px;\"><![endif]--><div style=\"color:#B8B8C0;line-height:150%;font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif; padding-right: 10px; padding-left: 10px; padding-top: 0px; padding-bottom: 0px;\"><div style=\"font-size:13px;line-height:20px;color:#B8B8C0;font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif;text-align:left;\"><p style=\"margin: 0;font-size: 14px;line-height: 21px;text-align: center\"><span style=\"font-size: 14px; line-height: 21px;\">Design and launch your own mobile in-app notifications with our built in HTML editor.</span></p></div></div><!--[if mso]></td></tr></table><![endif]--><div align=\"center\" class=\"button-container center\" style=\"padding-right: 10px; padding-left: 10px; padding-top:15px; padding-bottom:10px;\"><!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"border-spacing: 0; border-collapse: collapse; mso-table-lspace:0pt; mso-table-rspace:0pt;\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top:15px; padding-bottom:10px;\" align=\"center\"><v:roundrect xmlns:v=\"urn:schemas-microsoft-com:vml\" xmlns:w=\"urn:schemas-microsoft-com:office:word\" href=\"itbl://close\" style=\"height:36px; v-text-anchor:middle; width:187px;\" arcsize=\"70%\" strokecolor=\"#C7702E\" fillcolor=\"#C7702E\"><w:anchorlock/><center style=\"color:#ffffff; font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size:16px;\"><![endif]--><a href=\"itbl://close\" target=\"_blank\" style=\"display: inline-block;text-decoration: none;-webkit-text-size-adjust: none;text-align: center;color: #ffffff; background-color: #C7702E; border-radius: 25px; -webkit-border-radius: 25px; -moz-border-radius: 25px; max-width: 167px; width: 127px; width: 35%; border-top: 0px solid transparent; border-right: 0px solid transparent; border-bottom: 0px solid transparent; border-left: 0px solid transparent; padding-top: 0px; padding-right: 20px; padding-bottom: 5px; padding-left: 20px; font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif;mso-border-alt: none\"><span style=\"font-size:16px;line-height:32px;\"><span style=\"font-size: 14px; line-height: 28px;\" data-mce-style=\"font-size: 14px;\">Launch Now</span></span></a><!--[if mso]></center></v:roundrect></td></tr></table><![endif]--></div><div style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px;\"><!--[if (mso)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px;padding-left: 10px; padding-top: 10px; padding-bottom: 10px;\"><table width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td><![endif]--><div align=\"center\"><div style=\"border-top: 0px solid transparent; width:100%; line-height:0px; height:0px; font-size:0px;\">&#160;</div></div><!--[if (mso)]></td></tr></table></td></tr></table><![endif]--></div><!--[if (!mso)&(!IE)]><!--></div><!--<![endif]--></div></div><!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]--></div></div></div><div style=\"background-color:#ffffff;\"><div style=\"Margin: 0 auto;min-width: 320px;max-width: 480px;width: 480px;width: calc(17000% - 84520px);overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;\" class=\"block-grid \"><div style=\"border-collapse: collapse;display: table;width: 100%;\"><!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"background-color:#ffffff;\" align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width: 480px;\"><tr class=\"layout-full-width\" style=\"background-color:transparent;\"><![endif]--><!--[if (mso)|(IE)]><td align=\"center\" width=\"480\" style=\" width:480px; padding-right: 0px; padding-left: 0px; padding-top:30px; padding-bottom:30px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;\" valign=\"top\"><![endif]--><div class=\"col num12\" style=\"min-width: 320px;max-width: 480px;width: 480px;width: calc(16000% - 76320px);background-color: transparent;\"><div style=\"background-color: transparent; width: 100% !important;\"><!--[if (!mso)&(!IE)]><!--><div style=\"border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent; padding-top:30px; padding-bottom:30px; padding-right: 0px; padding-left: 0px;\"><!--<![endif]--><div align=\"center\" style=\"padding-right: 10px; padding-left: 10px; padding-bottom: 10px;\"><div style=\"line-height:10px;font-size:1px\">&#160;</div><div style=\"display: table; max-width:151;\"><!--[if (mso)|(IE)]><table width=\"131\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"border-collapse:collapse; padding-right: 10px; padding-left: 10px; padding-bottom: 10px;\" align=\"center\"><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"border-collapse:collapse; mso-table-lspace: 0pt;mso-table-rspace: 0pt; width:131px;\"><tr><td width=\"32\" style=\"width:32px; padding-right: 5px;\" valign=\"top\"><![endif]--><table align=\"left\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"32\" height=\"32\" style=\"border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;Margin-right: 5px\"><tbody><tr style=\"vertical-align: top\"><td align=\"left\" valign=\"middle\" style=\"word-break: break-word;border-collapse: collapse !important;vertical-align: top\"><a href=\"https://www.facebook.com/\" title=\"Facebook\" target=\"_blank\"><img src=\"https://d2fi4ri5dhpqd1.cloudfront.net/public/resources/social-networks-icon-sets/circle-color/facebook.png\" alt=\"Facebook\" title=\"Facebook\" width=\"32\" style=\"outline: none;text-decoration: none;-ms-interpolation-mode: bicubic;clear: both;display: block !important;border: none;height: auto;float: none;max-width: 32px !important\"/></a></td></tr></tbody></table><!--[if (mso)|(IE)]></td><td width=\"32\" style=\"width:32px; padding-right: 5px;\" valign=\"top\"><![endif]--><table align=\"left\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"32\" height=\"32\" style=\"border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;Margin-right: 5px\"><tbody><tr style=\"vertical-align: top\"><td align=\"left\" valign=\"middle\" style=\"word-break: break-word;border-collapse: collapse !important;vertical-align: top\"><a href=\"http://twitter.com/\" title=\"Twitter\" target=\"_blank\"><img src=\"https://d2fi4ri5dhpqd1.cloudfront.net/public/resources/social-networks-icon-sets/circle-color/twitter.png\" alt=\"Twitter\" title=\"Twitter\" width=\"32\" style=\"outline: none;text-decoration: none;-ms-interpolation-mode: bicubic;clear: both;display: block !important;border: none;height: auto;float: none;max-width: 32px !important\"/></a></td></tr></tbody></table><!--[if (mso)|(IE)]></td><td width=\"32\" style=\"width:32px; padding-right: 0;\" valign=\"top\"><![endif]--><table align=\"left\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"32\" height=\"32\" style=\"border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;Margin-right: 0\"><tbody><tr style=\"vertical-align: top\"><td align=\"left\" valign=\"middle\" style=\"word-break: break-word;border-collapse: collapse !important;vertical-align: top\"><a href=\"http://plus.google.com/\" title=\"Google+\" target=\"_blank\"><img src=\"https://d2fi4ri5dhpqd1.cloudfront.net/public/resources/social-networks-icon-sets/circle-color/googleplus.png\" alt=\"Google+\" title=\"Google+\" width=\"32\" style=\"outline: none;text-decoration: none;-ms-interpolation-mode: bicubic;clear: both;display: block !important;border: none;height: auto;float: none;max-width: 32px !important\"/></a></td></tr></tbody></table><!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]--></div></div><!--[if (!mso)&(!IE)]><!--></div><!--<![endif]--></div></div><!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]--></div></div></div><!--[if (mso)|(IE)]></td></tr></table><![endif]--></div><!--[if (mso)|(IE)]></div><![endif]--></body></html>";
    
    
    OnSuccessHandler onSuccess = ^(NSDictionary* payload) {
        //NSDictionary *dialogOptions = [IterableInAppManager getNextMessageFromPayload:payload];
        //if (dialogOptions != nil) {
            //TODO: change this key to disable functionality on older SDK versions
           // NSDictionary *message = [dialogOptions valueForKeyPath:ITERABLE_IN_APP_CONTENT];
        NSString *messageId = nil;//[dialogOptions valueForKey:ITBL_KEY_MESSAGE_ID];
        
        //NSDictionary *displaySettings = [dialogOptions valueForKey:ITBL_KEY_INAPP_DISPLAY];
        
        //UIEdgeInsetsMake
        
            //TODO: possibly move these into the inAppNotification
            //[self trackInAppOpen:messageId];
            //[self inAppConsume:messageId];
        
        IterableNotificationMetadata *notification = nil;// [IterableNotificationMetadata metadataFromInAppOptions:messageId];
            
            //if (message != nil) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    //[IterableInAppManager showIterableNotification:message trackParams:notification callbackBlock:(ITEActionBlock)callbackBlock];

                    UIColor *backgroundColor = [UIColor colorWithWhite:0 alpha:0.5]; //TODO: getfromPayload
                    
                    //NSDictionary *dict = @{ @"top" : @0, @"left" : @"value2", @"bottom" : @0, @"right" : @"value2"}; //Full
                    NSDictionary *dict = @{ @"top" : @"AutoExpand", @"left" : @"10", @"bottom" : @"AutoExpand", @"right" : @15}; //Center
                    //NSDictionary *dict = @{ @"top" : @0, @"left" : @"value2", @"bottom" : @"AutoExpand", @"right" : @"value2"}; //Top
                    //NSDictionary *dict = @{ @"top" : @"AutoExpand", @"left" : @"value2", @"bottom" : @0, @"right" : @"value2"}; //Bottom
                    
                    //Store later for unit tests
                    NSDictionary *failDefault = @{ @"top" : @1, @"bottom" : @"value2"};
                    
                    UIEdgeInsets edgeInsets = [IterableInAppManager getPaddingFromPayload:dict]; //TODO: getFromPayload
                    //UIEdgeInsets edgeInsets = UIEdgeInsetsZero; //full
                    //UIEdgeInsets edgeInsets = UIEdgeInsetsMake(-1, 0, -1, 0); //Center
                    //UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, -1, 0);; //Top
                    //UIEdgeInsets edgeInsets = UIEdgeInsetsMake(-1, 0, 0, 0);; //Bottom
                    
                    [IterableInAppManager showIterableNotificationHTML:htmlString trackParams:(IterableNotificationMetadata*)notification callbackBlock:(ITEActionBlock)callbackBlock backgroundColor:backgroundColor padding:edgeInsets];
                });
            //}
        //} else {
        //    LogDebug(@"No notifications found for inApp payload %@", payload);
        //}
    };
    
    [self getInAppMessages:@1 onSuccess:onSuccess onFailure:[IterableAPI defaultOnFailure:@"getInAppMessages"]];
}

// documented in IterableAPI.h
- (void)getInAppMessages:(NSNumber *)count
{
    [self getInAppMessages:@1 onSuccess:[IterableAPI defaultOnSuccess:@"getMessages"] onFailure:[IterableAPI defaultOnFailure:@"getMessages"]];
}

// documented in IterableAPI.h
- (void)getInAppMessages:(NSNumber *)count onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure
{
    NSDictionary *args;
    if (_email != nil) {
        args = @{
                ITBL_KEY_EMAIL: self.email,
                ITBL_KEY_COUNT: count
                };
    } else {
        args = @{
                 ITBL_KEY_USER_ID: self.userId,
                 ITBL_KEY_COUNT: count
                };
    }
    NSURLRequest *request = [self createGetRequestForAction:ENDPOINT_GET_INAPP_MESSAGES withArgs:args];
    [self sendRequest:request onSuccess:onSuccess onFailure:onFailure];
}

// documented in IterableAPI.h
-(void) showSystemNotification:(NSString *)title body:(NSString *)body button:(NSString *)button callbackBlock:(ITEActionBlock)callbackBlock
{
    [IterableInAppManager showSystemNotification:title body:body buttonLeft:button buttonRight:nil callbackBlock:callbackBlock];
}

// documented in IterableAPI.h
-(void) showSystemNotification:(NSString *)title body:(NSString *)body buttonLeft:(NSString *)buttonLeft buttonRight:(NSString *)buttonRight callbackBlock:(ITEActionBlock)callbackBlock
{
    [IterableInAppManager showSystemNotification:title body:body buttonLeft:buttonLeft buttonRight:buttonRight  callbackBlock:callbackBlock];
}

@end
