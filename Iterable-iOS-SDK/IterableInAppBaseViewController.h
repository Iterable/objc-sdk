//
//  IterableInAppBaseViewController.h
//  Iterable-iOS-SDK
//
//  Created by David Truong on 9/19/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IterableInAppBaseViewController : UIViewController

typedef void (^actionBlock)(NSString *);

/**
 @method
 
 @abstract Handles a button click
 
 @param sender the UIButton which called the event
 */
-(void)actionButtonClicked:(UIButton *)sender;

/**
 @method
 
 @abstract Adds a callback value to the list of buttons
 
 @param id the id of the button
 @param actionString the string representing the action button clicked
 */
-(void)addActionButton:(NSInteger)id actionString:(NSString *)actionStringValue;

/**
 @method
 
 @abstract Sets the data for the viewController
 
 @param jsonPayload the payload data
 */
-(void)setCallback:(actionBlock)callbackBlock;

/**
 @method
 
 @abstract Sets the data for the viewController
 
 @param jsonPayload the payload data
 */
-(void)setData:(NSDictionary *)jsonPayload;

@end
