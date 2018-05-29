//
//  IterableUtil.m
//  Iterable-iOS-SDK
//
//  Created by Tapash Majumder on 5/29/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import "IterableUtil.h"

@implementation IterableUtil

+ (IterableUtil *)sharedInstance
{
    static IterableUtil * _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[IterableUtil alloc] init];
    });
    return _sharedInstance;
}

@synthesize currentDate = _currentDate;

- (NSDate *)currentDate {
    if (_currentDate == nil) {
        _currentDate = [NSDate date];
    }
    return _currentDate;
}

- (void)setCurrentDate:(NSDate *)val {
    _currentDate = val;
}

@end
