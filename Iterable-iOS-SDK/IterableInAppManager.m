//
//  IterableInAppManager.m
//  Iterable-iOS-SDK
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
#import "IterableNotificationMetadata.h"

@interface IterableInAppManager ()

@end

@implementation IterableInAppManager

// documented in IterableInAppManager.h
+(void) showIterableNotification:(NSDictionary*)dialogOptions trackParams:(IterableNotificationMetadata*)trackParams callbackBlock:(ITEActionBlock)callbackBlock{
    if (dialogOptions != NULL) {
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        IterableInAppBaseViewController *baseNotification;
        
        NSString* type = [dialogOptions objectForKey:ITERABLE_IN_APP_TYPE];
        if ([type caseInsensitiveCompare:ITERABLE_IN_APP_TYPE_FULL] == NSOrderedSame){
            baseNotification = [[IterableFullScreenViewController alloc] init];
        } else {
            baseNotification = [[IterableAlertViewController alloc] initWithNibName:nil bundle:nil];
        }
        
        [baseNotification ITESetData:dialogOptions];
        [baseNotification ITESetTrackParams:trackParams];
        [baseNotification ITESetCallback:callbackBlock];
        [rootViewController presentViewController:baseNotification animated:YES completion:nil];
    }
}

// documented in IterableInAppManager.h
+(void) showSystemNotification:(NSString *)title body:(NSString *)body buttonLeft:(NSString *)buttonLeft buttonRight:(NSString *)buttonRight callbackBlock:(ITEActionBlock)callbackBlock{

    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message: body
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    if(buttonLeft != nil) {
        [self addAlertActionButton:alertController keyString:buttonLeft callbackBlock:callbackBlock];
    }
    
    if(buttonRight != nil) {
        [self addAlertActionButton:alertController keyString:buttonRight callbackBlock:callbackBlock];
    }
    
    [rootViewController presentViewController:alertController animated:YES completion:nil];

}

/*
@method
 
@abstract Creates and adds an alert action button to an alertController
 
@param alertController  The alert controller to add the button to
@param keyString        the text of the button
@param callbackBlock    the callback to send after a button on the notification is clicked

@discussion            passes the string of the button clicked to the callbackBlock
*/
+(void)addAlertActionButton:(UIAlertController*)alertController keyString:(NSString*)keyString callbackBlock:(ITEActionBlock)callbackBlock {
    UIAlertAction* button = [UIAlertAction
                              actionWithTitle:keyString
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [alertController dismissViewControllerAnimated:NO completion:nil];
                                  callbackBlock(keyString);
                              }];
    [alertController addAction: button];
}

// documented in IterableInAppManager.h
+(int)getIntColorFromKey:(NSDictionary*)payload keyString:(NSString*)keyString {
    NSString *colorString = [payload objectForKey:keyString];
    
    unsigned result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:colorString];
    
    [scanner setScanLocation:1];
    [scanner scanHexInt:&result];
    
    return result;
}

// documented in IterableInAppManager.h
+ (NSDictionary *) getNextMessageFromPayload:(NSDictionary *) payload {
    NSDictionary *returnDictionary = nil;
    if ([payload objectForKey:ITERABLE_IN_APP_MESSAGE]) {
        NSArray *messageArray = [payload valueForKeyPath:ITERABLE_IN_APP_MESSAGE];
        if (messageArray != nil && messageArray.count >0) {
            returnDictionary = [messageArray objectAtIndex:0];
        }
    }
    return returnDictionary;
}

@end


