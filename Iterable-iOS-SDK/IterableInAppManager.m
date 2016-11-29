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

+(void) showNotification:(NSDictionary*)dialogOptions{
    NSDictionary *dialogParameters = [self getNextMessageFromPayload:dialogOptions];

    
    //NSString *type=[dialogParameters valueForKeyPath:@"content.displayType"];

    [self createNotification:dialogParameters callbackBlock:nil];
}

+(void)showNotification:(NSString*)type callbackBlock:(actionBlock)callbackBlock{
    //Sample json used to test
    NSDictionary *titleTextPayload = @{
                                       ITERABLE_IN_APP_TEXT : @"ITERABLE",
                                       ITERABLE_IN_APP_TEXT_COLOR : @752244479,
                                       ITERABLE_IN_APP_TEXT_FONT : @"Avenir Next"
                                       };
    
    NSDictionary *bodyTextPayload = @{
                                      ITERABLE_IN_APP_TEXT : @"Try out the new Iterable in app notifications.",
                                      ITERABLE_IN_APP_TEXT_COLOR : @0xFFFFFFFF,
                                      ITERABLE_IN_APP_TEXT_FONT : @"Avenir Next"
                                      };
    
    NSDictionary *buttonContent = @{
                                    ITERABLE_IN_APP_TEXT : @"Okay",
                                    ITERABLE_IN_APP_TEXT_COLOR : @255,
                                    ITERABLE_IN_APP_TEXT_FONT : @"AvenirNext-Medium"
                                      };
    
    NSDictionary *sampleButtonPayload = @{
                                          ITERABLE_IN_APP_BACKGROUND_COLOR : @752244479,
                                          ITERABLE_IN_APP_BUTTON_ACTION : @"okay",
                                          ITERABLE_IN_APP_BUTTON_CONTENT: @"buttonContent"
                                          };
    
    NSDictionary *sampleButtonPayload2 = @{
                                          ITERABLE_IN_APP_TEXT : @"Cancel",
                                          ITERABLE_IN_APP_TEXT_COLOR : @255,
                                          ITERABLE_IN_APP_BACKGROUND_COLOR : @0xFF0000FF,
                                          ITERABLE_IN_APP_TEXT_FONT : @"AvenirNext-Medium",
                                          ITERABLE_IN_APP_BUTTON_ACTION : @"cancel"
                                          };
    
    NSArray *buttons = @[sampleButtonPayload, sampleButtonPayload2];
    
    NSDictionary *inAppPayload = @{
                     ITERABLE_IN_APP_TITLE : titleTextPayload,
                     //ITERABLE_IN_APP_IMAGE : @"https://s3.amazonaws.com/iterable-android-sdk/Gold+Diamond.png",
                      ITERABLE_IN_APP_IMAGE : @"https://t3.kn3.net/taringa/8/4/3/4/8/5/WandaTiraFinolis/FBE.png",
                     ITERABLE_IN_APP_BODY : bodyTextPayload,
                     ITERABLE_IN_APP_BUTTON : buttons,
                     ITERABLE_IN_APP_BACKGROUND_COLOR: @0x333333EE,
                     ITERABLE_IN_APP_TYPE : type
                     };
    
    [self createNotification:inAppPayload callbackBlock:(actionBlock)callbackBlock];
}

+(void)createNotification:(NSDictionary*)payload callbackBlock:(actionBlock)callbackBlock {
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    IterableInAppBaseViewController *baseNotification;
    
    NSString* type = [payload objectForKey:ITERABLE_IN_APP_TYPE];
    if ([type caseInsensitiveCompare:ITERABLE_IN_APP_TYPE_FULL] == NSOrderedSame){
        baseNotification = [[IterableFullScreenViewController alloc] init];
    } else {
        baseNotification = [[IterableAlertViewController alloc] initWithNibName:nil bundle:nil];
    }
    
    //TODO: add in view tracking
    
    [baseNotification setData:payload];
    [baseNotification setCallback:callbackBlock];
    [rootViewController presentViewController:baseNotification animated:YES completion:nil];
}

+(int)getIntColorFromKey:(NSDictionary*)payload keyString:(NSString*)keyString {
    NSString *colorString = [payload objectForKey:keyString];
    
    unsigned result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:colorString];
    
    [scanner setScanLocation:1];
    [scanner scanHexInt:&result];
    
    return result;
}

+ (NSDictionary *) getNextMessageFromPayload:(NSDictionary *) payload {
    //TODO: error checking for empty list of inapp messages
    NSDictionary *dict=[payload valueForKeyPath:@"inAppMessages"][0][@"content"];
    return dict;
}

+ (UIColor *)colorWithHexString:(NSString *)str {
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long col = strtol(cStr+1, NULL, 16);
    
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];

}

@end

