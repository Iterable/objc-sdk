//
//  IterableConfig.h
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 6/18/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IterableAction;

/**
 * Custom URL handling delegate
 */
@protocol IterableURLDelegate <NSObject>

/**
 * Callback called for a deeplink action. Return YES to override default behavior
 * @param url     Deeplink URL
 * @param action  Original openUrl Action object
 * @return Boolean value. Return YES if the URL was handled to override default behavior.
 */
- (BOOL)handleIterableURL:(NSURL *)url fromAction:(IterableAction *)action;

@end

/**
 * Custom action handling delegate
 */
@protocol IterableCustomActionDelegate <NSObject>

/**
 * Callback called for custom actions from push notifications
 * @param action  `IterableAction` object containing action payload
 * @return Boolean value. Reserved for future use.
 */
- (BOOL)handleIterableCustomAction:(IterableAction *)action;

@end

/**
 * Iterable SDK configuration object.
 * Create and pass this object during SDK initialization.
 */
@interface IterableConfig : NSObject

/**
 * Push integration name – used for token registration.
 * Make sure the name of this integration matches the one set up in Iterable console.
 */
@property(nonatomic, copy) NSString *pushIntegration;

/**
 * Custom URL handler to override openUrl actions
 */
@property(nonatomic) id<IterableURLDelegate> urlDelegate;

/**
 * Action handler for custom actions
 */
@property(nonatomic) id<IterableCustomActionDelegate> customActionDelegate;

@end
