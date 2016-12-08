//
//  IterableInAppManager.h
//  Iterable-iOS-SDK
//
//  Created by David Truong on 9/14/16.
//
//

#import <UIKit/UIKit.h>
#import "IterableConstants.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)((rgbValue & 0xFF)))/255.0 alpha:1.0]

@interface IterableInAppManager : NSObject

////////////////////
/// @name Properties
////////////////////

/**
 An array of action objects representing the actions that the user can take in response to the alert view
 */
@property (nonatomic, readonly) NSArray *actions;

/*!
 @method
 
 @abstract Creates and shows a InApp Notification; with callback handler
 
 @param dialogOptions   the NSDictionary containing the dialog options
 @param callback        the callback to send after a button on the notification is clicked
 */
+(void) showNotification:(NSDictionary *)dialogOptions callbackBlock:(actionBlock)callbackBlock;

/*!
 @method
 
 @abstract Gets the next message from the payload
 
 @param payload         the payload dictionary
 
 @return a NSDictionary containing the InAppMessage parameters
 */
+(NSDictionary *) getNextMessageFromPayload:(NSDictionary *) payload;

/*!
 @method
 
 @abstract Gets the int value of the color from the payload
 
 @param payload          the NSDictionary
 @param keyString        the key to use to lookup the value in the payload dictionary
 
 @return the int color
 */
+(int) getIntColorFromKey:(NSDictionary*)payload keyString:(NSString*)keyString;

@end
