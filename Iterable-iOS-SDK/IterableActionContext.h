//
// Created by Victor Babenko on 6/27/18.
// Copyright (c) 2018 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IterableAction.h"

/**
 * Enum representing the source of the action: push notification, universal link, etc.
 */
typedef NS_ENUM(NSInteger, IterableActionSource) {
    /** Push Notification */
    IterableActionSourcePush,

    /** Universal Link */
    IterableActionSourceUniversalLink
};

/**
 * An object representing the action to execute and the context it is executing in
 *
 */
@interface IterableActionContext : NSObject

/**
 * Action to execute
 */
@property (nonatomic, readonly) IterableAction *action;

/**
 * Source of the action: push notification, universal link, etc.
 */
@property (nonatomic, readonly) IterableActionSource source;

/**
 * Create an `IterableActionContext` object with the given action and source
 * @param action Action to execute
 * @param source Source of the action
 * @return `IterableActionContext` instance
 */
+ (instancetype)contextWithAction:(IterableAction *)action source:(IterableActionSource)source;

@end