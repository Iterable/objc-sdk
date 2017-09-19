//
//  IterableInAppManager.h
//  Iterable-iOS-SDK
//
//  Created by David Truong on 9/14/16.
//
//

#import <UIKit/UIKit.h>
#import "IterableConstants.h"
#import "IterableNotificationMetadata.h"

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
 @param trackParams     The track params for the notification
 @param callbackBlock        the callback to send after a button on the notification is clicked
 */
+(void) showIterableNotification:(NSDictionary *)dialogOptions trackParams:(IterableNotificationMetadata *)trackParams callbackBlock:(ITEActionBlock)callbackBlock;

/*!
 @method
 
 @abstract Creates and shows a HTML InApp Notification with trackParameters, backgroundColor with callback handler
 
 @param htmlString      The NSString containing the dialog HTML
 @param trackParams     The track params for the notification
 @param callbackBlock   The callback to send after a button on the notification is clicked
 @param backgroundColor The background color behind the notification
 @param padding         The padding around the notification
 */
+(void) showIterableNotificationHTML:(NSString *)htmlString trackParams:(IterableNotificationMetadata*)trackParams callbackBlock:(ITEActionBlock)callbackBlock backgroundColor:(UIColor *)backgroundColor padding:(UIEdgeInsets)padding;

/*!
 @method
 
 @abstract Creates and shows a HTML InApp Notification; with callback handler
 
 @param htmlString   the NSString containing the dialog HTML
 @param callbackBlock        the callback to send after a button on the notification is clicked
 */
+(void) showIterableNotificationHTML:(NSString *)htmlString callbackBlock:(ITEActionBlock)callbackBlock;


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
+(void) showSystemNotification:(NSString *)title body:(NSString *)body buttonLeft:(NSString *)buttonLeft buttonRight:(NSString *)buttonRight callbackBlock:(ITEActionBlock)callbackBlock;

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

+(UIEdgeInsets) getPaddingFromPayload:(NSDictionary*)payload;


@end
