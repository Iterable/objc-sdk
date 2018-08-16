//
//  IterableUtil.h
//  Iterable-iOS-SDK
//
//  Created by Tapash Majumder on 5/29/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>

// all params are nonnull, unless annotated otherwise
NS_ASSUME_NONNULL_BEGIN

/*!
 @abstract Iterable Utility class.
 */
@interface IterableUtil : NSObject

+ (NSDate *)currentDate;
+ (BOOL)isSandboxAPNS;
+ (void)hasNotificationPermissionWithCallback:(void (^)(BOOL hasPermission))callback;

@end

NS_ASSUME_NONNULL_END
