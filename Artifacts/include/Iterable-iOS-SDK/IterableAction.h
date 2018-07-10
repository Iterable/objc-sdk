//
//  IterableAction.h
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 5/1/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Open the URL or deep link */
extern NSString *const IterableActionTypeOpenUrl;

/**
 `IterableAction` represents an action defined as a response to user events.
 It is currently used in push notification actions (open push & action buttons).
 */
@interface IterableAction : NSObject

////////////////////
/// @name Properties
////////////////////

/**
 * Action type
 *
 * If `IterableActionTypeOpenUrl`, the SDK will call `IterableURLDelegate` and then try to open the URL if
 * the delegate returned NO or was not set.
 *
 * For other types, `IterableCustomActionDelegate` will be called.
 */
@property(nonatomic, readonly) NSString *type;

/**
 * Additional data, its content depends on the action type
 */
@property(nonatomic, readonly) NSString *data;

////////////////////
/// @name Optional Fields
////////////////////

/** The text response typed by the user */
@property(nonatomic, readwrite) NSString *userInput;

////////////////////
/// @name Creating IterableAction
////////////////////

/**
 * Creates a new `IterableAction` from a dictionary
 * @param dictionary Dictionary containing action data
 * @return `IterableAction` instance
 */
+ (instancetype)actionFromDictionary:(NSDictionary *)dictionary;

/**
 * Creates a new `IterableAction` with type `IterableActionTypeOpenUrl`
 * and the specified URL
 * @param url URL to open
 * @return `IterableAction` instance
 */
+ (instancetype)actionOpenUrl:(NSString *)url;

////////////////////
/// @name Methods
////////////////////

/**
 * Checks whether this action is of a specific type
 * @param type Action type to match against
 * @return Boolean indicating whether the action type matches the one passed to this method
 */
- (BOOL)isOfType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END