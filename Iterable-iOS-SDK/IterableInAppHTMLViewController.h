//
//  IterableInAppHTMLViewController.h
//  Pods
//
//  Created by David Truong on 9/8/17.
//
//

#import <UIKit/UIKit.h>
#import "IterableConstants.h"
#import "IterableNotificationMetadata.h"

@interface IterableInAppHTMLViewController : UIViewController

/**
 @abstract Custom ITEActionBlock
 */
typedef void (^ITEActionBlock)(NSString *);

typedef enum {
    INAPP_FULL,
    INAPP_TOP,
    INAPP_CENTER,
    INAPP_BOTTOM
} INAPP_NOTIFICATION_TYPE;

/**
 @method
 
 @abstract constructs an inapp notification with via html
 
 @param htmlString the html string
 */
- (IterableInAppHTMLViewController*)initWithData:htmlString;

/**
 @method
 
 @abstract Sets the padding
 
 @param insetPadding the padding
 
 @discussion defaults to 0 for left/right if left+right >100
 */
-(void)ITESetPadding:(UIEdgeInsets)insetPadding;

/**
 @method
 
 @abstract Sets the callback
 
 @param callbackBlock the payload data
 */
-(void)ITESetCallback:(ITEActionBlock)callbackBlock;

/**
 @method
 
 @abstract Sets the track parameters
 
 @param trackParams the track parameters
 */
-(void)ITESetTrackParams:(IterableNotificationMetadata *)trackParams;

/**
 @method
 
 @abstract gets the html string
 
 @return a NSString of the html
 */
-(NSString *)getHtml;

/**
 @method
 
 @abstract gets the location from a inset data
 
 @return the location as an INAPP_NOTIFICATION_TYPE
 */
+(INAPP_NOTIFICATION_TYPE)setLocation:(UIEdgeInsets) insetPadding;

@end
