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
    NSDictionary *titleTextPayload = @{
                                       ITERABLE_IN_APP_TEXT : @"SPOTIFY",
                                       ITERABLE_IN_APP_TEXT_COLOR : @752244479,
                                       ITERABLE_IN_APP_TEXT_FONT : @"Avenir Next"
                                       };
    
    NSDictionary *bodyTextPayload = @{
                                      ITERABLE_IN_APP_TEXT : @"Get Spotify Premium Free for 6 Months with Iterable.",
                                      ITERABLE_IN_APP_TEXT_COLOR : @0xFFFFFFFF,
                                      ITERABLE_IN_APP_TEXT_FONT : @"Avenir Next"
                                      };
    
    NSDictionary *sampleButtonPayload = @{
                                          ITERABLE_IN_APP_TEXT : @"Okay",
                                          ITERABLE_IN_APP_TEXT_COLOR : @255,
                                          ITERABLE_IN_APP_BACKGROUND_COLOR : @752244479,
                                          ITERABLE_IN_APP_TEXT_FONT : @"AvenirNext-Medium",
                                          ITERABLE_IN_APP_BUTTON_ACTION : @"yeehaa"
                                          };
    
    NSDictionary *inAppPayload = @{
                     ITERABLE_IN_APP_TITLE : titleTextPayload,
                     ITERABLE_IN_APP_IMAGE : @"https://developer.spotify.com/wp-content/uploads/2016/07/logo@2x.png",
                     ITERABLE_IN_APP_BODY : bodyTextPayload,
                     ITERABLE_IN_APP_BUTTON : sampleButtonPayload,
                     ITERABLE_IN_APP_BACKGROUND_COLOR: @0x333333EE,
                     ITERABLE_IN_APP_TYPE : type
                     
                     };
    
    [self createNotification:inAppPayload callbackBlock:(actionBlock)callbackBlock];
}

+(void)createNotification:(NSDictionary*)payload callbackBlock:(actionBlock)callbackBlock {
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    IterableInAppBaseViewController *baseNotification;
    
    NSString* type = [payload objectForKey:ITERABLE_IN_APP_TYPE];
    if ([type isEqual:ITERABLE_IN_APP_TYPE_FULL]){
        baseNotification = [[IterableFullScreenViewController alloc] init];
    } else {
        baseNotification = [[IterableAlertViewController alloc] initWithNibName:nil bundle:nil];
    }
    
    [baseNotification setData:payload];
    [baseNotification setCallback:callbackBlock];
    [rootViewController presentViewController:baseNotification animated:YES completion:nil];
}

+(int)getIntFromKey:(NSDictionary*)payload keyString:(NSString*)keyString {
    return [[payload objectForKey:keyString] integerValue];
}

@end

