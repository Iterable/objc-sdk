//
//  IterableAPI.m
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 11/19/14.
//  Copyright (c) 2014 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IterableAPI.h"


@implementation IterableAPI {
    NSString *endpoint;
    NSString *apiKey;
    NSString *email;
}

- (id)initWithApiKey:(NSString *)key andEmail:(NSString *)eml
{
    self = [super init];
    self->endpoint = @"https://api.iterable.com/api/";
    self->apiKey = key;
    self->email = eml;
    return self;
}

- (NSString*)getUrlForAction:(NSString *)action
{
    return [NSString stringWithFormat:@"%@%@?api_key=%@", endpoint, action, apiKey];
}

@end