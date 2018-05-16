//
//  IterableAction.h
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 5/1/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Dismiss the push, don't bring the app to foreground, execute a custom action if defined */
extern NSString *const IterableActionTypeDismiss;

/** Open the app, execute a custom action if defined */
extern NSString *const IterableActionTypeOpen;

/** Open the app, open the deep link */
extern NSString *const IterableActionTypeDeeplink;

/** Request user input, pass to the custom action handler */
extern NSString *const IterableActionTypeTextInput;

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
 * Possible values: `IterableActionTypeDismiss`, `IterableActionTypeOpen`, `IterableActionTypeDeeplink`,
 * `IterableActionTypeTextInput`
 */
@property(nonatomic, readonly) NSString *type;

/**
 * Additional data, its content depends on the action type
 */
@property(nonatomic, readonly) NSString *data;

////////////////////
/// @name Optional Fields
////////////////////

/** 'Send' button title (textInput type only) */
@property(nonatomic, readonly) NSString *inputTitle;

/** Placeholder for the text (textInput type only) */
@property(nonatomic, readonly) NSString *inputPlaceholder;

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