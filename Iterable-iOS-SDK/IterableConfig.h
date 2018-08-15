//
//  IterableConfig.h
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 6/18/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IterableAction.h"
#include "IterableActionContext.h"

/**
 * Custom URL handling delegate
 */
@protocol IterableURLDelegate <NSObject>

/**
 * Callback called for a deeplink action. Return YES to override default behavior
 * @param url     Deeplink URL
 * @param context  Metadata containing the original action and the source: push or universal link
 * @return Boolean value. Return YES if the URL was handled to override default behavior.
 */
- (BOOL)handleIterableURL:(NSURL *)url context:(IterableActionContext *)context;

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
- (BOOL)handleIterableCustomAction:(IterableAction *)action context:(IterableActionContext *)context;

@end

/**
 Enum representing push platform; apple push notification service, production vs sandbox
 */
typedef NS_ENUM(NSInteger, PushServicePlatform) {
    /** The sandbox push service */
            APNS_SANDBOX,
    /** The production push service */
            APNS,
    /** Detect automatically */
            AUTO
};

/**
 * Iterable SDK configuration object.
 * Create and pass this object during SDK initialization.
 */
@interface IterableConfig : NSObject

/**
 * Push integration name – used for token registration.
 * Make sure the name of this integration matches the one set up in Iterable console.
 */
@property(nonatomic, copy) NSString *pushIntegrationName;

/**
 * Push integration name for development builds – used for token registration.
 * Make sure the name of this integration matches the one set up in Iterable console.
 */
@property(nonatomic, copy) NSString *sandboxPushIntegrationName;

/**
 * APNS environment for the current build of the app.
 * Possible values: `APNS_SANDBOX`, `APNS_SANDBOX`, `AUTO`
 * Defaults to `AUTO` and detects the APNS environment automatically
 */
@property(nonatomic, assign) PushServicePlatform pushPlatform;

/**
 * If set to `true`, the SDK will automatically register the push token when you
 * call `setUserId:` or `setEmail:` and disable the old device entry
 * when the user logs out
 */
@property(nonatomic, assign) BOOL autoPushRegistration;

/**
 * Custom URL handler to override openUrl actions
 */
@property(nonatomic) id<IterableURLDelegate> urlDelegate;

/**
 * Action handler for custom actions
 */
@property(nonatomic) id<IterableCustomActionDelegate> customActionDelegate;

@end
