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
#import <Foundation/Foundation.h>

#import "IterableAPI.h"

@interface IterableAPI () {
}
@property(nonatomic, copy) NSString *apiKey;
@property(nonatomic, copy) NSString *email;
@end

@implementation IterableAPI {
}

NSString * const endpoint = @"https://api.iterable.com/api/";

- (id)initWithApiKey:(NSString *)key andEmail:(NSString *)eml
{
    if (self = [super init]) {
        self.apiKey = key;
        self.email = eml;
        return self;
    } else {
        return nil;
    }
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
             NSLog(@"got data %@", data);
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

@end