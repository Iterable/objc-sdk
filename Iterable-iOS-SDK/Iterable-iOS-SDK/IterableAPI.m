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

//NSString * const endpoint = @"https://api.iterable.com/api/";
//NSString * const endpoint = @"http://mbp-15-g-2:9000/api/";
NSString * const endpoint = @"http://staging.iterable.com/api/";


- (id)initWithApiKey:(NSString *)apiKey andEmail:(NSString *)email
{
    self = [super init];
    if (self) {
        _apiKey = [apiKey copy];
        _email = [email copy];
    }
    return self;
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

- (void)registerToken:(NSData *)token {
    UIDevice *device = [UIDevice currentDevice];
    NSDictionary *args = @{
                           @"email": self.email,
                           @"device": @{
                                   @"token": [token hexadecimalString],
                                   @"platform": @"APNS_SANDBOX",
                                   @"applicationName": @"foobar",
//                                   @"applicationName": [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey],
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