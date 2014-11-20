//
//  IterableAPI.m
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 11/19/14.
//  Copyright (c) 2014 Iterable. All rights reserved.
//

@import Foundation;

#import "IterableAPI.h"


@implementation IterableAPI {
    NSString *apiKey;
    NSString *email;
}

NSString * const endpoint = @"https://api.iterable.com/api/";

- (id)initWithApiKey:(NSString *)key andEmail:(NSString *)eml
{
    self = [super init];
    self->apiKey = key;
    self->email = eml;
    return self;
}

- (NSString *)getUrlForAction:(NSString *)action
{
    return [NSString stringWithFormat:@"%@%@?api_key=%@", endpoint, action, apiKey];
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


@end