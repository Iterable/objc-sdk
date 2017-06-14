//
//  IterableInAppBaseViewController.h
//  Iterable-iOS-SDK
//
//  Created by David Truong on 9/19/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IterableInAppManager.h"
#import "IterableNotificationMetadata.h"

@interface IterableInAppBaseViewController : UIViewController

/**
 @abstract Custom ITEActionBlock
 */
typedef void (^ITEActionBlock)(NSString *);

/**
 @method
 
 @abstract Handles a button click
 
 @param sender the UIButton which called the event
 */
-(void)ITEActionButtonClicked:(UIButton *)sender;

/**
 @method
 
 @abstract Adds a callback value to the list of buttons
 
 @param id the id of the button
 @param actionString the string representing the action button clicked
 */
-(void)ITEAddActionButton:(NSInteger)id actionString:(NSString *)actionString;

/**
 @method
 
 @abstract Sets the data for the viewController
 
 @param callbackBlock the payload data
 */
-(void)ITESetCallback:(ITEActionBlock)callbackBlock;

/**
 @method
 
 @abstract Sets the data for the viewController
 
 @param jsonPayload the payload data
 */
-(void)ITESetData:(NSDictionary *)jsonPayload;

/**
 @method
 
 @abstract Sets the track params for the viewController
 
 @param trackParams the track parameters
 */
-(void)ITESetTrackParams:(IterableNotificationMetadata *)trackParams;


@end
