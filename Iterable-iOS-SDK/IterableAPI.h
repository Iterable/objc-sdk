//
//  Iterable_API.h
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 11/19/14.
//  Copyright (c) 2014 Iterable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommerceItem.h"
#import "IterableAction.h"
#import "IterableConstants.h"
#import "IterableAttributionInfo.h"

// all params are nonnull, unless annotated otherwise
NS_ASSUME_NONNULL_BEGIN

/**
 The prototype for the completion handler block that gets called when an Iterable call is successful
 */
typedef void (^OnSuccessHandler)(NSDictionary *data);

/**
 The prototype for the completion handler block that gets called when an Iterable call fails
 */
typedef void (^OnFailureHandler)(NSString *reason, NSData *_Nullable data);

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

/**
 The userInfo dictionary which came with last push.
 */
@property(nonatomic, readonly, copy, nullable) NSDictionary *lastPushPayload;
/**
 Attribution info (campaignId, messageId etc.) for last push open or app link click from an email.
 */
@property(nonatomic, readwrite, strong, nullable) IterableAttributionInfo *attributionInfo;

@property(nonatomic) id<IterableURLDelegate> urlDelegate;
@property(nonatomic) id<IterableCustomActionDelegate> customActionDelegate;

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
- (instancetype) initWithApiKey:(NSString *)apiKey andEmail:(NSString *)email launchOptions:(nullable NSDictionary *)launchOptions useCustomLaunchOptions:(BOOL)useCustomLaunchOptions;

/*!
 @method
 
 @abstract Initializes Iterable with just an API key and email, but no launchOptions
 
 @param apiKey   your Iterable apiKey
 @param userId   the userId of the user logged in
 
 @return an instance of IterableAPI
 */
- (instancetype) initWithApiKey:(NSString *)apiKey andUserId:(NSString *) userId;

/*!
 @method
 
 @abstract Initializes Iterable with launchOptions
 
 @param apiKey          your Iterable apiKey
 @param userId          the userId of the user logged in
 @param launchOptions   launchOptions from application:didFinishLaunchingWithOptions
 
 @return an instance of IterableAPI
 */
- (instancetype) initWithApiKey:(NSString *)apiKey andUserId:(NSString *)userId launchOptions:(nullable NSDictionary *)launchOptions;

/*!
 @method
 
 @abstract Initializes Iterable with launchOptions
 
 @param apiKey          your Iterable apiKey
 @param userId          the userId of the user logged in
 @param launchOptions   launchOptions from application:didFinishLaunchingWithOptions or custom launchOptions
 @param useCustomLaunchOptions  whether or not to use the custom launchOption without the UIApplicationLaunchOptionsRemoteNotificationKey
 
 @return an instance of IterableAPI
 */
- (instancetype) initWithApiKey:(NSString *)apiKey andUserId:(NSString *)userId launchOptions:(nullable NSDictionary *)launchOptions useCustomLaunchOptions:(BOOL)useCustomLaunchOptions;

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
+ (IterableAPI *) sharedInstanceWithApiKey:(NSString *)apiKey andUserId:(NSString *)userId launchOptions:(nullable NSDictionary *)launchOptions;

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

/*!
 @method
 
 @abstract Sets the previously instantiated singleton instance of the API to nil
 
 */
+ (void)clearSharedInstance;

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

/*!
 @method
 
 @abstract Updates the available user fields
 
 @param dataFields              Data fields to store in the user profile
 @param mergeNestedObjects      Merge top level objects instead of overwriting
 @param onSuccess               OnSuccessHandler to invoke if update is successful
 @param onFailure               OnFailureHandler to invoke if update fails
 
 @see OnSuccessHandler
 @see OnFailureHandler
 */
- (void)updateUser:(NSDictionary *)dataFields mergeNestedObjects:(BOOL)mergeNestedObjects onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure;

/*!
 @method

 @abstract Updates the current user's email.

 @discussion Also updates the current email in this IterableAPI instance if the API call was successful.

 @param newEmail                New email
 @param onSuccess               OnSuccessHandler to invoke if update is successful
 @param onFailure               OnFailureHandler to invoke if update fails

 @see OnSuccessHandler
 @see OnFailureHandler
 */
- (void)updateEmail:(NSString *)newEmail onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure;

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

/*!
 @method
 
 @abstract Updates a user's subscription preferences
 
 @param emailListIds                Email lists to subscribe to
 @param unsubscribedChannelIds      List of channels to unsubscribe from
 @param unsubscribedMessageTypeIds  List of message types to unsubscribe from
 
 @discussion passing in an empty array will clear subscription list, passing in nil will not modify the list
 */
- (void)updateSubscriptions:(nullable NSArray *)emailListIds unsubscribedChannelIds:(nullable NSArray *)unsubscribedChannelIds unsubscribedMessageTypeIds:(nullable NSArray *)unsubscribedMessageTypeIds;

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
 
 @param count  the number of messages to fetch
 */
- (void)getInAppMessages:(NSNumber *)count;

/*!
 @method
 
 @abstract Gets the list of InAppMessages with optional additional fields and custom completion blocks
 
  @param count  the number of messages to fetch
 @param onSuccess   OnSuccessHandler to invoke if the get call succeeds
 @param onFailure   OnFailureHandler to invoke if the get call fails
 
 @see OnSuccessHandler
 @see OnFailureHandler
 */
- (void)getInAppMessages:(NSNumber *)count onSuccess:(OnSuccessHandler)onSuccess onFailure:(OnFailureHandler)onFailure;

/**
 @method
 
 @abstract Tracks a InAppOpen event with custom completion blocks
 
 @param messageId       The messageId of the notification
 */
- (void)trackInAppOpen:(NSString *)messageId;

/**
 @method
 
 @abstract Tracks a inAppClick event
 
 @param messageId       The messageId of the notification
 @param buttonIndex     The index of the button that was clicked
 */
- (void)trackInAppClick:(NSString *)messageId buttonIndex:(NSNumber *)buttonIndex;

/**
 @method
 
 @abstract Tracks a inAppClick event
 
 @param messageId       The messageId of the notification
 @param buttonURL     The url of the button that was clicked
 */
- (void)trackInAppClick:(NSString *)messageId buttonURL:(NSString *)buttonURL;

/**
 @method
 
 @abstract Consumes the notification and removes it from the list of inAppMessages
 
 @param messageId       The messageId of the notification
 */
- (void)inAppConsume:(NSString *)messageId;


/*!
 @method
 
 @abstract displays a iOS system style notification with one button
 
 @param title           the NSDictionary containing the dialog options
 @param body            the notification message body
 @param button          the text of the left button
 @param callbackBlock   the callback to send after a button on the notification is clicked
 
 @discussion            passes the string of the button clicked to the callbackBlock
 */
-(void) showSystemNotification:(NSString *)title body:(NSString *)body button:(NSString *)button callbackBlock:(ITEActionBlock)callbackBlock;

/*!
 @method
 
 @abstract displays a iOS system style notification with two buttons
 
 @param title           the NSDictionary containing the dialog options
 @param body            the notification message body
 @param buttonLeft      the text of the left button
 @param buttonRight     the text of the right button
 @param callbackBlock   the callback to send after a button on the notification is clicked
 
 @discussion            passes the string of the button clicked to the callbackBlock
 */
-(void) showSystemNotification:(NSString *)title body:(NSString *)body buttonLeft:(NSString *)buttonLeft buttonRight:(NSString *)buttonRight callbackBlock:(ITEActionBlock)callbackBlock;

/*!
 @method
 
 @abstract tracks a link click and passes the redirected URL to the callback
 
 @param webpageURL      the URL that was clicked
 @param callbackBlock   the callback to send after the webpageURL is called
 
 @discussion            passes the string of the redirected URL to the callback, returns the original webpageURL if not an iterable link
 */
+(void) getAndTrackDeeplink:(NSURL *)webpageURL callbackBlock:(ITEActionBlock)callbackBlock;

@end

NS_ASSUME_NONNULL_END
