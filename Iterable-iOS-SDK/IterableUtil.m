//
//  IterableUtil.m
//  Iterable-iOS-SDK
//
//  Created by Tapash Majumder on 5/29/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import "IterableUtil.h"
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@implementation IterableUtil

+ (NSDate *)currentDate {
    return [NSDate date];
}

+ (NSDictionary*)mobileProvisionDictionary {
    static NSDictionary* mobileProvision = nil;
    if (!mobileProvision) {
        NSString *provisioningPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
        if (!provisioningPath) {
            mobileProvision = @{};
        }

        // Use the ASCII encoding to drop all binary data
        NSString *binaryString = [NSString stringWithContentsOfFile:provisioningPath encoding:NSASCIIStringEncoding error:NULL];
        if (!binaryString) {
            mobileProvision = @{};
        }

        NSScanner *scanner = [NSScanner scannerWithString:binaryString];
        NSString *plistString;
        if ([scanner scanUpToString:@"<plist" intoString:nil] &&
            [scanner scanUpToString:@"</plist>" intoString:&plistString]) {

            plistString = [plistString stringByAppendingString:@"</plist>"];
            mobileProvision = [NSPropertyListSerialization
                    propertyListWithData:[plistString dataUsingEncoding:NSUTF8StringEncoding]
                                 options:NSPropertyListImmutable format:nil
                                   error:nil];
        } else {
            mobileProvision = @{};
        }
    }
    return mobileProvision;
}

+ (BOOL)isSandboxAPNS {
    NSDictionary *mobileProvision = [self mobileProvisionDictionary];
    if (![mobileProvision count]) {
        // mobileprovision file not found; default to production on devices and sandbox on simulator
#if TARGET_IPHONE_SIMULATOR
        return YES;
#else
        return NO;
#endif
    } else {
        NSDictionary *entitlements = mobileProvision[@"Entitlements"];
        if ([@"development" isEqualToString: entitlements[@"aps-environment"]])
            return YES;
    }
    return NO;
}

+ (void)hasNotificationPermissionWithCallback:(void (^)(BOOL hasPermission))callback {
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
            callback(settings.authorizationStatus == UNAuthorizationStatusAuthorized);
        }];
    } else {
        callback([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone);
    }
}

@end
