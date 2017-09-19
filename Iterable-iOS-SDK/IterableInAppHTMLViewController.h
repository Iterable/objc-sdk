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
    INAPP_MIDDLE,
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
 */
-(void)ITESetPadding:(UIEdgeInsets)insetPadding;

/**
 @method
 
 @abstract Sets the data for the viewController
 
 @param callbackBlock the payload data
 */
-(void)ITESetCallback:(ITEActionBlock)callbackBlock;

/**
 @method
 
 @abstract Sets the track params for the viewController
 
 @param trackParams the track parameters
 */
-(void)ITESetTrackParams:(IterableNotificationMetadata *)trackParams;


@end
