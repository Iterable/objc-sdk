//
//  IterableConfig.m
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 6/18/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import "IterableConfig.h"

@implementation IterableConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _pushPlatform = AUTO;
        _autoPushRegistration = YES;
    }
    return self;
}

@end
