//
//  IterableInAppManager.m
//  Pods
//
//  Created by David Truong on 9/14/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "IterableInAppManager.h"

#import "IterableInAppBaseViewController.h"
#import "IterableAlertView.h"
#import "IterableAlertViewController.h"
#import "IterableFullScreenViewController.h"



#import "IterableConstants.h"

@interface IterableInAppManager ()

@end

@implementation IterableInAppManager

+(void)showNotification:(NSString*)type callbackBlock:(actionBlock)callbackBlock{
    //TODO:Get payload from Iterable Server
    //getNextNotification;

    NSDictionary *titleTextPayload = @{
                                       ITERABLE_IN_APP_TEXT : @"ITERABLE",
                                       ITERABLE_IN_APP_TEXT_COLOR : [NSNumber numberWithInt:22],
                                       ITERABLE_IN_APP_BACKGROUND_COLOR : [NSNumber numberWithInt:19], //#RGBA
                                       ITERABLE_IN_APP_TEXT_FONT : @"Avenir Next"
                                       };
    
    NSDictionary *bodyTextPayload = @{
                                      ITERABLE_IN_APP_TEXT : @"Sample Image above. Plus a description which can be long and multi line.",
                                      ITERABLE_IN_APP_TEXT_COLOR : [NSNumber numberWithInt:22],
                                      ITERABLE_IN_APP_BACKGROUND_COLOR : [NSNumber numberWithInt:19] //#RGBA
                                      };
    
    
    NSDictionary *sampleButtonPayload = @{
                                          ITERABLE_IN_APP_TEXT : @"Okay",
                                          ITERABLE_IN_APP_TEXT_COLOR : [NSNumber numberWithInt:22],
                                          ITERABLE_IN_APP_BACKGROUND_COLOR : [NSNumber numberWithInt:19] //#RGBA
                                          };
    
    NSDictionary *inAppPayload = @{
                     ITERABLE_IN_APP_TITLE : titleTextPayload,
                     ITERABLE_IN_APP_IMAGE : @"https://s3.amazonaws.com/iterable-android-sdk/Gold+Diamond.png",
                     ITERABLE_IN_APP_BODY : bodyTextPayload,
                     ITERABLE_IN_APP_BUTTON : sampleButtonPayload,
                     ITERABLE_IN_APP_TYPE : type
                     
                     };
    
    [self createNotification:inAppPayload callbackBlock:(actionBlock)callbackBlock];
}

+(void)createNotification:(NSDictionary*)payload callbackBlock:(actionBlock)callbackBlock {
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    NSString* type = payload[ITERABLE_IN_APP_TYPE];
    
    if ([type isEqual:ITERABLE_IN_APP_TYPE_FULL]){
        IterableFullScreenViewController *vc = [[IterableFullScreenViewController alloc] init];
        
        [vc setData:payload];
        [vc setCallback:callbackBlock];
        [rootViewController presentViewController:vc animated:YES completion:NULL];
    } else {
        IterableAlertViewController *alertViewController = [[IterableAlertViewController alloc] initWithNibName:nil bundle:nil];
        
        //Parse out payload to set these values
        alertViewController.title = NSLocalizedString(@"Iterable", nil);
        alertViewController.message = NSLocalizedString(@"Integer posuere erat a ante venenatis dapibus posuere velit aliquet.", nil);
        
        alertViewController.buttonCornerRadius = 20.0f;
        
        alertViewController.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:18.0f];
        alertViewController.messageFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
        alertViewController.buttonTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:alertViewController.buttonTitleFont.pointSize];
        alertViewController.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:alertViewController.cancelButtonTitleFont.pointSize];
        
        alertViewController.alertViewBackgroundColor = [UIColor colorWithWhite:0.19f alpha:1.0f];
        alertViewController.alertViewCornerRadius = 10.0f;
        
        alertViewController.titleColor = [UIColor colorWithRed:0.42f green:0.78 blue:0.32f alpha:1.0f];
        alertViewController.messageColor = [UIColor colorWithWhite:0.92f alpha:1.0f];
        
        alertViewController.buttonColor = [UIColor colorWithRed:0.42f green:0.78 blue:0.32f alpha:1.0f];
        alertViewController.buttonTitleColor = [UIColor colorWithWhite:0.19f alpha:1.0f];
        
        alertViewController.cancelButtonColor = [UIColor colorWithRed:0.42f green:0.78 blue:0.32f alpha:1.0f];
        alertViewController.cancelButtonTitleColor = [UIColor colorWithWhite:0.19f alpha:1.0f];
        
        [alertViewController addAction:[IterableAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                                      style:UIAlertActionStyleDefault
                                                                    actionName:@"ok"
                                        ]];
        
        [alertViewController addAction:[IterableAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                      style:UIAlertActionStyleCancel
                                                                 actionName:@"cancel"]];
        
        //Set Notification Location
        if ([type isEqual:ITERABLE_IN_APP_TYPE_TOP]) {
            [((IterableAlertView *) alertViewController.view) setLocation:NotifLocationTop];
        } else if ([type isEqual:ITERABLE_IN_APP_TYPE_BOTTOM]) {
            [((IterableAlertView *) alertViewController.view) setLocation:NotifLocationBottom];
        }else {
            [((IterableAlertView *) alertViewController.view) setLocation:NotifLocationCenter];
        }
    
        [alertViewController setCallback:callbackBlock];
        [rootViewController presentViewController:alertViewController animated:YES completion:nil];
    }
}

@end
