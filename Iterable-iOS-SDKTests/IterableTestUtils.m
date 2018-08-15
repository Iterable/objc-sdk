//
//  IterableTestUtils.m
//  Iterable-iOS-SDKTests
//
//  Created by Victor Babenko on 8/15/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import "IterableTestUtils.h"
#import "IterableAPI.h"
#import "IterableAPI+Internal.h"

@implementation IterableTestUtils

+ (void)clearApiInstance {
    if (IterableAPI.sharedInstance) {
        IterableAPI.sharedInstance.sdkCompatEnabled = YES;
        [IterableAPI clearSharedInstance];
    }
}

+ (void)resetUserDefaults {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

@end
