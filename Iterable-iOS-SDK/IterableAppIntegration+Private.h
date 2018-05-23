//
// Created by Victor Babenko on 5/22/18.
// Copyright (c) 2018 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IterableAppIntegration.h"

@class IterableAPI;

@interface IterableAppIntegration (Private)

+ (void)performDefaultNotificationAction:(NSDictionary *)userInfo api:(IterableAPI *)api;

@end