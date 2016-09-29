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
                                       ITERABLE_IN_APP_TEXT_COLOR : @0xF6AA5FFF,
                                       //ITERABLE_IN_APP_BACKGROUND_COLOR : [NSNumber numberWithInt:19], //#RGBA
                                       ITERABLE_IN_APP_TEXT_FONT : @"Avenir Next"
                                       };
    
    NSDictionary *bodyTextPayload = @{
                                      ITERABLE_IN_APP_TEXT : @"Sample Image above. Plus a description which can be long and multi line.",
                                      ITERABLE_IN_APP_TEXT_COLOR : @0xF6AA5FFF,
                                      //ITERABLE_IN_APP_BACKGROUND_COLOR : [NSNumber numberWithInt:19] //#RGBA
                                      ITERABLE_IN_APP_TEXT_FONT : @"Avenir Next"
                                      };
    
    
    NSDictionary *sampleButtonPayload = @{
                                          ITERABLE_IN_APP_TEXT : @"Okay",
                                          ITERABLE_IN_APP_TEXT_COLOR : @0xB61A2FFF,
                                          ITERABLE_IN_APP_BACKGROUND_COLOR : @0xF6AA5F33,
                                          ITERABLE_IN_APP_TEXT_FONT : @"Avenir Next",
                                          ITERABLE_IN_APP_BUTTON_ACTION : @"yeehaa"
                                          };
    
    NSDictionary *inAppPayload = @{
                     ITERABLE_IN_APP_TITLE : titleTextPayload,
                     ITERABLE_IN_APP_IMAGE : @"https://s3.amazonaws.com/iterable-android-sdk/Gold+Diamond.png",
                     ITERABLE_IN_APP_BODY : bodyTextPayload,
                     ITERABLE_IN_APP_BUTTON : sampleButtonPayload,
                     ITERABLE_IN_APP_BACKGROUND_COLOR: @0x163A5FFF,
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

