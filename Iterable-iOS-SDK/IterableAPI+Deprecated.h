//
// Created by Victor Babenko on 6/18/18.
// Copyright (c) 2018 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IterableAPI.h"

@interface IterableAPI (Deprecated)

/////////////////////////////////
/// @name Creating an IterableAPI
/////////////////////////////////

/*!
 @method

 @abstract Initializes Iterable with launchOptions

 @param apiKey                  your Iterable apiKey
 @param email                   the email of the user logged in
 @param launchOptions           launchOptions from application:didFinishLaunchingWithOptions or custom launchOptions
 @param useCustomLaunchOptions  whether or not to use the custom launchOption without the UIApplicationLaunchOptionsRemoteNotificationKey

 @return an instance of IterableAPI
 */
- (instancetype) initWithApiKey:(NSString *)apiKey andEmail:(NSString *)email launchOptions:(nullable NSDictionary *)launchOptions useCustomLaunchOptions:(BOOL)useCustomLaunchOptions __deprecated_msg("Use [IterableAPI startWithApiKey:launchOptions:] instead.");

/*!
 @method

 @abstract Initializes Iterable with just an API key and email, but no launchOptions

 @param apiKey   your Iterable apiKey
 @param userId   the userId of the user logged in

 @return an instance of IterableAPI
 */
- (instancetype) initWithApiKey:(NSString *)apiKey andUserId:(NSString *) userId __deprecated_msg("Use [IterableAPI startWithApiKey:launchOptions:] instead.");

/*!
 @method

 @abstract Initializes Iterable with launchOptions

 @param apiKey          your Iterable apiKey
 @param userId          the userId of the user logged in
 @param launchOptions   launchOptions from application:didFinishLaunchingWithOptions

 @return an instance of IterableAPI
 */
- (instancetype) initWithApiKey:(NSString *)apiKey andUserId:(NSString *)userId launchOptions:(nullable NSDictionary *)launchOptions __deprecated_msg("Use [IterableAPI startWithApiKey:launchOptions:] instead.");

/*!
 @method

 @abstract Initializes Iterable with launchOptions

 @param apiKey          your Iterable apiKey
 @param userId          the userId of the user logged in
 @param launchOptions   launchOptions from application:didFinishLaunchingWithOptions or custom launchOptions
 @param useCustomLaunchOptions  whether or not to use the custom launchOption without the UIApplicationLaunchOptionsRemoteNotificationKey

 @return an instance of IterableAPI
 */
- (instancetype) initWithApiKey:(NSString *)apiKey andUserId:(NSString *)userId launchOptions:(nullable NSDictionary *)launchOptions useCustomLaunchOptions:(BOOL)useCustomLaunchOptions __deprecated_msg("Use [IterableAPI startWithApiKey:launchOptions:] instead.");

/*!
 @method

 @abstract Initializes a shared instance of Iterable with launchOptions

 @discussion The sharedInstanceWithApiKey with email is preferred over userId.
 This method will set up a singleton instance of the `IterableAPI` class for
 you using the given project API key. When you want to make calls to Iterable
 elsewhere in your code, you can use `sharedInstance`. If launchOptions is there and
 the app was launched from a remote push notification, we will track a pushOpen.

 @param apiKey          your Iterable apiKey
 @param userId           the userId of the user logged in
 @param launchOptions   launchOptions from application:didFinishLaunchingWithOptions

 @return an instance of IterableAPI
 */
+ (IterableAPI *) sharedInstanceWithApiKey:(NSString *)apiKey andUserId:(NSString *)userId launchOptions:(nullable NSDictionary *)launchOptions __deprecated_msg("Use [IterableAPI startWithApiKey:launchOptions:] instead.");

/*!
 @method

 @abstract Initializes a shared instance of Iterable with launchOptions

 @discussion The sharedInstanceWithApiKey with email is preferred over userId.
 This method will set up a singleton instance of the `IterableAPI` class for
 you using the given project API key. When you want to make calls to Iterable
 elsewhere in your code, you can use `sharedInstance`. If launchOptions is there and
 the app was launched from a remote push notification, we will track a pushOpen.

 @param apiKey          your Iterable apiKey
 @param email           the email of the user logged in
 @param launchOptions   launchOptions from application:didFinishLaunchingWithOptions

 @return an instance of IterableAPI
 */
+ (IterableAPI *) sharedInstanceWithApiKey:(NSString *)apiKey andEmail:(NSString *)email launchOptions:(nullable NSDictionary *)launchOptions __deprecated_msg("Use [IterableAPI startWithApiKey:launchOptions:] instead.");

/*!
 @method

 @abstract Get the previously instantiated singleton instance of the API

 @discussion Must be initialized with `sharedInstanceWithApiKey:` before
 calling this class method.

 @return the existing `IterableAPI` instance

 @warning `sharedInstance` will return `nil` if called before calling `sharedInstanceWithApiKey:andEmail:launchOptions:`
 */
+ (nullable IterableAPI *)sharedInstance;

/*!
 @method

 @abstract Sets the previously instantiated singleton instance of the API to nil

 */
+ (void)clearSharedInstance __deprecated_msg("Use [IterableAPI startWithApiKey:launchOptions:config:] to initialize the SDK and setUserEmail:/setUserId: to set the user email/id.");

@end