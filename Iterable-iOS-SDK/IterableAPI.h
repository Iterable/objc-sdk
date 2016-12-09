//
//  Iterable_API.h
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 11/19/14.
//  Copyright (c) 2014 Iterable. All rights reserved.
//

@import Foundation;
#import "CommerceItem.h"
#import "IterableConstants.h"
#import "IterableInAppManager.h"

// all params are nonnull, unless annotated otherwise
NS_ASSUME_NONNULL_BEGIN

/**
 The prototype for the completion handler block that gets called when an Iterable call is successful
 */
typedef void (^OnSuccessHandler)(NSDictionary *data);

/**
 The prototype for the completion handler block that gets called when an Iterable call fails
 */
typedef void (^OnFailureHandler)(NSString *reason, NSData *data);

/**
 Enum representing push platform; apple push notification service, production vs sandbox
 */
typedef NS_ENUM(NSInteger, PushServicePlatform) {
    /** The sandbox push service */
    APNS_SANDBOX,
    /** The production push service */
    APNS
};

/**
 `IterableAPI` contains all the essential functions for communicating with Iterable's API
 */
@interface IterableAPI : NSObject

////////////////////
/// @name Properties
////////////////////

/**
 The apiKey that this IterableAPI is using
 */
@property(nonatomic, readonly, copy) NSString *apiKey;

/**
 The email of the logged in user that this IterableAPI is using
 */
@property(nonatomic, readonly, copy) NSString *email;

/**
 The userId of the logged in user that this IterableAPI is using
 */
@property(nonatomic, readonly, copy) NSString *userId;


/**
 The hex representation of this device token
 */
@property(nonatomic, readonly, copy) NSString *hexToken;

/////////////////////////////////
/// @name Creating an IterableAPI
/////////////////////////////////

/*!
 @method
 
 @abstract Initializes a shared instance of Iterable with launchOptions
 
 @discussion This method will set up a singleton instance of the `IterableAPI` class for
 you using the given project API key. When you want to make calls to Iterable
 elsewhere in your code, you can use `sharedInstance`. If launchOptions is there and
 the app was launched from a remote push notification, we will track a pushOpen.
 
 @param apiKey          your Iterable apiKey
 @param userId           the userId of the user logged in
 @param launchOptions   launchOptions from application:didFinishLaunchingWithOptions
 
 @return an instance of IterableAPI
 */
+ (IterableAPI *) sharedInstanceWithApiKey:(NSString *)apiKey andUserId:(NSString *)userId launchOptions:(nullable NSDictionary *)launchOptions;

/*!
 @method
 
 @abstract Initializes a shared instance of Iterable with launchOptions
 
 @discussion This method will set up a singleton instance of the `IterableAPI` class for
 you using the given project API key. When you want to make calls to Iterable
 elsewhere in your code, you can use `sharedInstance`. If launchOptions is there and
 the app was launched from a remote push notification, we will track a pushOpen.
 
 @param apiKey          your Iterable apiKey
 @param email           the email of the user logged in
 @param launchOptions   launchOptions from application:didFinishLaunchingWithOptions
 
 @return an instance of IterableAPI
 */
+ (IterableAPI *) sharedInstanceWithApiKey:(NSString *)apiKey andEmail:(NSString *)email launchOptions:(nullable NSDictionary *)launchOptions;

/*!
 @method
 
 @abstract Get the previously instantiated singleton instance of the API
 
 @discussion Must be initialized with `sharedInstanceWithApiKey:` before
 calling this class method.
 
 @return the existing `IterableAPI` instance
 
 @warning `sharedInstance` will return `nil` if called before calling `sharedInstanceWithApiKey:andEmail:launchOptions:` 
 */
+ (nullable IterableAPI *)sharedInstance;

/////////////////////////////
/// @name Registering a token
/////////////////////////////

/*!
 @method 
 
 @abstract Register this device's token with Iterable

 @param token       The token representing this device/application pair, obtained from
                    `application:didRegisterForRemoteNotificationsWithDeviceToken`
                    after registering for remote notifications
 @param appName     The application name, as configured in Iterable during set up of the push integration
 @param pushServicePlatform     The PushServicePlatform to use for this device; dictates whether to register this token in the sandbox or production environment
 
 @see PushServicePlatform
 
 */
- (void)registerToken:(NSData *)token appName:(NSString *)appName pushServicePlatform:(PushServicePlatform)pushServicePlatform;

/*!
 @method
 
 @abstract Register this device's token with Iterable with custom completion blocks
 
 @param token                   The token representing this device/application pair, obtained from
                                `application:didRegisterForRemoteNotificationsWithDeviceToken`
                                after registering for remote notifications
 @param appName                 The application name, as configured in Iterable during set up of the push integration
 @param pushServicePlatform     The PushServicePlatform to use for this device; dictates whether to register this token in the sandbox or production environment
 @param onSuccess               OnSuccessHandler to invoke if token registration is successful
 @param onFailure               OnFailureHandler to invoke if token registration fails
 
 @see PushServicePlatform
 @see OnSuccessHandler
 @see OnFailureHandler
 */
- (void)registerToken:(NSData *)token appName:(NSString *)appName pushServicePlatform:(PushServicePlatform)pushServicePlatform onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure;

/////////////////////////////
/// @name Disabling a device
/////////////////////////////

/*!
 @method
 
 @abstract Disable this device's token in Iterable, for the current user
 */
- (void)disableDeviceForCurrentUser;

/*!
 @method
 
 @abstract Disable this device's token in Iterable, for all users with this device
  */
- (void)disableDeviceForAllUsers;

/*!
 @method
 
 @abstract Disable this device's token in Iterable, for the current user, with custom completion blocks
 
 @param onSuccess               OnSuccessHandler to invoke if disabling the token is successful
 @param onFailure               OnFailureHandler to invoke if disabling the token fails
 
 @see OnSuccessHandler
 @see OnFailureHandler
 */
- (void)disableDeviceForCurrentUserWithOnSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure;

/*!
 @method
 
 @abstract Disable this device's token in Iterable, for all users with this device, with custom completion blocks
 
 @param onSuccess               OnSuccessHandler to invoke if disabling the token is successful
 @param onFailure               OnFailureHandler to invoke if disabling the token fails
 
 @see OnSuccessHandler
 @see OnFailureHandler
 */
- (void)disableDeviceForAllUsersWithOnSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure;


/////////////////////////
/// @name Tracking events
/////////////////////////

/*!
 @method
 
 @abstract Tracks a purchase
 
 @discussion Pass in the total purchase amount and an `NSArray` of `CommerceItem`s
 
 @param total       total purchase amount
 @param items       list of purchased items
 
 @see CommerceItem
 */
- (void)trackPurchase:(NSNumber *)total items:(NSArray<CommerceItem *>*)items;

/*!
 @method
 
 @abstract Tracks a purchase with additional data
 
 @discussion Pass in the total purchase amount and an `NSArray` of `CommerceItem`s
 
 @param total       total purchase amount
 @param items       list of purchased items
 @param dataFields  an `NSDictionary` containing any additional information to save along with the event
 
 @see CommerceItem
 */
- (void)trackPurchase:(NSNumber *)total items:(NSArray<CommerceItem *>*)items dataFields:(nullable NSDictionary *)dataFields;

/*!
 @method
 
 @abstract Tracks a purchase with additional data and custom completion blocks
 
 @discussion Pass in the total purchase amount and an `NSArray` of `CommerceItem`s
 
 @param total       total purchase amount
 @param items       list of purchased items
 @param dataFields  an `NSDictionary` containing any additional information to save along with the event
 @param onSuccess   OnSuccessHandler to invoke if the purchase is tracked successfully
 @param onFailure   OnFailureHandler to invoke if tracking the purchase fails
 
 @see CommerceItem
 @see OnSuccessHandler
 @see OnFailureHandler
 */
- (void)trackPurchase:(NSNumber *)total items:(NSArray<CommerceItem *>*)items dataFields:(nullable NSDictionary *)dataFields onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure;

/*!
 @method
 
 @abstract Tracks a pushOpen event with a push notification payload
 
 @discussion Pass in the `userInfo` from the push notification payload
 
 @param userInfo    the push notification payload
 */
- (void)trackPushOpen:(NSDictionary *)userInfo;

/*!
 @method
 
 @abstract Tracks a pushOpen event with a push notification and optional additional data
 
 @discussion Pass in the `userInfo` from the push notification payload
 
 @param userInfo    the push notification payload
 @param dataFields  an `NSDictionary` containing any additional information to save along with the event
 */
- (void)trackPushOpen:(NSDictionary *)userInfo dataFields:(nullable NSDictionary *)dataFields;

/*!
 @method
 
 @abstract Tracks a pushOpen event with a push notification, optional additional data, and custom completion blocks
 
 @discussion Pass in the `userInfo` from the push notification payload
 
 @param userInfo    the push notification payload
 @param dataFields  an `NSDictionary` containing any additional information to save along with the event
 @param onSuccess           OnSuccessHandler to invoke if the open is tracked successfully
 @param onFailure           OnFailureHandler to invoke if tracking the open fails
 
 @see OnSuccessHandler
 @see OnFailureHandler
 */
- (void)trackPushOpen:(NSDictionary *)userInfo dataFields:(nullable NSDictionary *)dataFields onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure;

/*!
 @method
 
 @abstract Tracks a pushOpen event for the specified campaign and template ids, whether the app was already running when the push was received, and optional additional data
 
 @discussion Pass in the the relevant campaign data
 
 @param campaignId          The campaignId of the the push notification that caused this open event
 @param templateId          The templateId  of the the push notification that caused this open event
 @param messageId           The messageId  of the the push notification that caused this open event
 @param appAlreadyRunning   This will get merged into the dataFields. Whether the app is already running when the notification was received
 @param dataFields          An `NSDictionary` containing any additional information to save along with the event
 */
- (void)trackPushOpen:(NSNumber *)campaignId templateId:(NSNumber *)templateId messageId:(NSString *)messageId appAlreadyRunning:(BOOL)appAlreadyRunning dataFields:(nullable NSDictionary *)dataFields;

/*!
 @method
 
 @abstract Tracks a pushOpen event for the specified campaign and template ids, whether the app was already running when the push was received, and optional additional data, with custom completion blocks
 
 @discussion Pass in the the relevant campaign data
 
 @param campaignId          The campaignId of the the push notification that caused this open event
 @param templateId          The templateId  of the the push notification that caused this open event
 @param messageId           The messageId  of the the push notification that caused this open event
 @param appAlreadyRunning   This will get merged into the dataFields. Whether the app is already running when the notification was received
 @param dataFields          An `NSDictionary` containing any additional information to save along with the event
 @param onSuccess           OnSuccessHandler to invoke if the open is tracked successfully
 @param onFailure           OnFailureHandler to invoke if tracking the open fails
 
 @see OnSuccessHandler
 @see OnFailureHandler
 */
- (void)trackPushOpen:(NSNumber *)campaignId templateId:(NSNumber *)templateId messageId:(NSString *)messageId appAlreadyRunning:(BOOL)appAlreadyRunning dataFields:(nullable NSDictionary *)dataFields onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure;

/*!
 @method
 
 @abstract Tracks a custom event.
 
 @discussion Pass in the the custom event data.
 
 @param eventName   Name of the event
 */
- (void)track:(NSString *)eventName;

/*!
 @method
 
 @abstract Tracks a custom event with optional additional fields
 
 @discussion Pass in the the custom event data.
 
 @param eventName   Name of the event
 @param dataFields  An `NSDictionary` containing any additional information to save along with the event
 */
- (void)track:(NSString *)eventName dataFields:(nullable NSDictionary *)dataFields;

/*!
 @method
 
 @abstract Tracks a custom event with optional additional fields and custom completion blocks
 
 @discussion Pass in the the custom event data.
 
 @param eventName   Name of the event
 @param dataFields  An `NSDictionary` containing any additional information to save along with the event
 @param onSuccess   OnSuccessHandler to invoke if the track call succeeds
 @param onFailure   OnFailureHandler to invoke if the track call fails
 
 @see OnSuccessHandler
 @see OnFailureHandler
 */
- (void)track:(NSString *)eventName dataFields:(nullable NSDictionary *)dataFields onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure;

/////////////////////////
/// @name In-App Notifications
/////////////////////////

/*!
 @method
 
 @abstract Gets the list of InAppNotification and displays the next notification
 
  @param callbackBlock  Callback ITEActionBlock
 
 */
- (void)spawnInAppNotification:(ITEActionBlock) callbackBlock;


/*!
 @method
 
 @abstract Gets the list of InAppMessages
 
 */
- (void)getInAppMessages;

/*!
 @method
 
 @abstract Gets the list of InAppMessages with optional additional fields and custom completion blocks
 
 @param onSuccess   OnSuccessHandler to invoke if the get call succeeds
 @param onFailure   OnFailureHandler to invoke if the get call fails
 
 @see OnSuccessHandler
 @see OnFailureHandler
 */
- (void)getInAppMessages:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure;

/**
 @method
 
 @abstract Tracks a InAppOpen event with custom completion blocks
 
 @param campaignId     The campaignId of the notification
 @param templateId     The templateId of the notification
 */
- (void)trackInAppOpen:(NSNumber *)campaignId templateId:(NSNumber *)templateID;

/**
 @method
 
 @abstract Tracks a inAppClick event with custom completion blocks
 
 @param campaignId     The campaignId of the notification
 @param templateId     The templateId of the notification
 @param buttonIndex     The index of the button that was clicked
 */
- (void)trackInAppClick:(NSNumber *)campaignId templateId:(NSNumber *)templateId buttonIndex:(NSNumber *)buttonIndex;

@end

NS_ASSUME_NONNULL_END
