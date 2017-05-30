//
//  IterableNotificationMetadata.h
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 6/7/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

@import Foundation;

// all params are nonnull, unless annotated otherwise
NS_ASSUME_NONNULL_BEGIN

/**
 `IterableNotificationMetadata` represents the metadata in an Iterable push notification
 */
@interface IterableNotificationMetadata : NSObject

////////////////////
/// @name Properties
////////////////////

/**
 The campaignId of this notification
 */
@property(nonatomic, readonly, copy) NSNumber *campaignId;

/**
 The templateId of this notification
 */
@property(nonatomic, readonly, copy) NSNumber *templateId;

/**
 The messageId of this notification
 */
@property(nonatomic, readonly, copy) NSString *messageId;

/**
 Whether this notification is a ghost push
 */
@property(nonatomic, readonly) BOOL isGhostPush;

//////////////////////////////////////////////////
/// @name Creating an IterableNotificationMetadata
//////////////////////////////////////////////////

/**
 @method
 
 @abstract  Creates an `IterableNotificationMetadata` from a push payload
 
 @param userInfo  The notification payload
 
 @return    an instance of `IterableNotificationMetadata` with the specified properties; `nil` if this isn't an Iterable notification
 
 @warning   `metadataFromLaunchOptions` will return `nil` if `userInfo` isn't an Iterable notification
 */
+ (nullable instancetype)metadataFromLaunchOptions:(NSDictionary *)userInfo;

/**
 @method
 
 @abstract  Creates an `IterableNotificationMetadata` from a inApp notification
 
 @param messageId    The notification messageId
 
 @return    an instance of `IterableNotificationMetadata` with the specified properties; `nil` if this is not a valid InApp notification
 
 @warning   `metadataFromInAppOptions` will return `nil` if messageId is nil
 */
+ (nullable instancetype)metadataFromInAppOptions:(NSString *)messageId;

///////////////////////////
/// @name Utility functions
///////////////////////////

/**
 @method
 
 @return `YES` if this push is a `proof` push; `NO` otherwise
 */
- (BOOL)isProof;

/**
 @method
 
 @return `YES` if this is a test push; `NO` otherwise
 */
- (BOOL)isTestPush;

/**
 @method
 
 @return `YES` if this is a non-ghost, non-proof, non-test real send; `NO` otherwise
 */
- (BOOL)isRealCampaignNotification;

@end

NS_ASSUME_NONNULL_END
