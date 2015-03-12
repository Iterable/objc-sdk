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

#import "IterableAPI.h"
#import "NSData+Conversion.h"

@interface IterableAPI () {
}
@property(nonatomic, readonly, copy) NSString *apiKey;
@property(nonatomic, readonly, copy) NSString *email;
@end

@implementation IterableAPI {
}

static IterableAPI *sharedInstance = nil;

//NSString * const endpoint = @"https://api.iterable.com/api/";
NSString * const endpoint = @"http://mbp-15-g-2:9000/api/";
//NSString * const endpoint = @"http://staging.iterable.com/api/";


- (instancetype)initWithApiKey:(NSString *)apiKey andEmail:(NSString *)email launchOptions:(NSDictionary *)launchOptions
{
    if (self = [super init]) {
        _apiKey = [apiKey copy];
        _email = [email copy];
    }
    
    // Automatically track a pushOpen
    if (launchOptions && launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self trackPushOpen:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    return self;
}

- (instancetype)initWithApiKey:(NSString *)apiKey andEmail:(NSString *)email
{
    return [self initWithApiKey:apiKey andEmail:email launchOptions:nil];
}

+ (IterableAPI *)sharedInstance
{
    if (sharedInstance == nil) {
        NSLog(@"warning sharedInstance called before sharedInstanceWithApiKey:");
    }
    return sharedInstance;
}

// should be called on app open
+ (IterableAPI *)sharedInstanceWithApiKey:(NSString *)apiKey andEmail:(NSString *)email launchOptions:(NSDictionary *)launchOptions
{
    // threadsafe way to create a static singleton https://stackoverflow.com/questions/5720029/create-singleton-using-gcds-dispatch-once-in-objective-c
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[IterableAPI alloc] initWithApiKey:apiKey andEmail:email launchOptions:launchOptions];
    });
    return sharedInstance;
}


- (NSURL *)getUrlForAction:(NSString *)action
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?api_key=%@", endpoint, action, self.apiKey]];
}

- (NSString *)dictToJson:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"dictToJson failed: %@", error);
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

- (NSURLRequest *)createRequestForAction:(NSString *)action withArgs:(NSDictionary *)args {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self getUrlForAction:action]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[self dictToJson:args] dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (void)sendRequest:(NSURLRequest *)request {
    // TODO - figure out which operation queue to use; main queue or an empty alloc/init queue [NSOperationQueue mainQueue]
    // TODO - don't init NSOperationQueue every single time
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil) {
             //             NSString *asStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             error = nil;
             id object = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:0
                          error:&error];
             if(error) {
                 NSLog(@"could not parse json: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
             } else if([object isKindOfClass:[NSDictionary class]]) {
                 NSDictionary *results = object;
                 NSLog(@"got data %@", results);
             } else {
                 NSLog(@"response is not a dictionary");
             }
             //             [delegate receivedData:data];
         } else if ([data length] == 0 && error == nil) {
             NSLog(@"got no data");
             //             [delegate emptyReply];
         } else if (error != nil) {
             NSLog(@"got error: %@", error);
             //             [delegate downloadError:error];
         }
     }];
}

- (void)getUser {
    NSDictionary *args = @{
                           @"email": self.email
                           };
    NSURLRequest *request = [self createRequestForAction:@"users/get" withArgs:args];
    [self sendRequest:request];
}

- (NSString *)userInterfaceIdiomEnumToString:(UIUserInterfaceIdiom)idiom {
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

- (void)registerToken:(NSData *)token appName:(NSString *)appName {
    UIDevice *device = [UIDevice currentDevice];
    NSDictionary *args = @{
                           @"email": self.email,
                           @"device": @{
                                   @"token": [token hexadecimalString],
                                   @"platform": @"APNS_SANDBOX",
                                   @"applicationName": appName,
                                   @"dataFields": @{
                                           @"name": [device name],
                                           @"localizedModel": [device localizedModel],
                                           @"userInterfaceIdiom": [self userInterfaceIdiomEnumToString:[device userInterfaceIdiom]],
                                           @"identifierForVendor": [[device identifierForVendor] UUIDString],
                                           @"systemName": [device systemName],
                                           @"systemVersion": [device systemVersion],
                                           @"model": [device model]
                                           }
                                   }
                           };
    NSLog(@"%@", args);
    NSURLRequest *request = [self createRequestForAction:@"users/registerDeviceToken" withArgs:args];
    [self sendRequest:request];
}

- (void)sendPush {
    NSDictionary *args = @{
                           @"email": self.email
                           };
    NSURLRequest *request = [self createRequestForAction:@"users/push" withArgs:args];
    [self sendRequest:request];
}

// TODO - make appAlreadyRunning a parameter?
- (void)trackPushOpen:(NSDictionary *)userInfo {
    NSLog(@"[Iterable] %@", @"%@ tracking push open %@");
                             
    if (userInfo && userInfo[@"itbl"]) {
        NSDictionary *pushData = userInfo[@"itbl"];
        if ([pushData isKindOfClass:[NSDictionary class]] && pushData[@"campaignId"]) {
            [self trackPushOpen:pushData[@"campaignId"] templateId:pushData[@"templateId"] appAlreadyRunning:false];
        } else {
            // TODO - throw error here, bad push payload
        }
    }
}

- (void)trackPushOpen:(NSNumber *)campaignId templateId:(NSNumber *)templateId appAlreadyRunning:(BOOL)appAlreadyRunning {
    NSDictionary *args = @{
                           @"email": self.email,
                           @"campaignId": campaignId,
                           @"templateId": templateId,
                           @"dataFields": @{
                                   @"appAlreadyRunning": @(appAlreadyRunning)
                                   }
                           };
    NSURLRequest *request = [self createRequestForAction:@"events/trackPushOpen" withArgs:args];
    [self sendRequest:request];
}

@end