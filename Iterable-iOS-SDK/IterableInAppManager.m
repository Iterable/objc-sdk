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
#import "IterableInAppHTMLViewController.h"

@interface IterableInAppManager ()

@end

@implementation IterableInAppManager

// documented in IterableInAppManager.h
+(void) showIterableNotification:(NSDictionary*)dialogOptions trackParams:(IterableNotificationMetadata*)trackParams callbackBlock:(ITEActionBlock)callbackBlock{
    if (dialogOptions != NULL) {
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        if([rootViewController isKindOfClass:[UIViewController class]])
        {
            while (rootViewController.presentedViewController != nil)
            {
                rootViewController = rootViewController.presentedViewController;
            }
        }
        
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
        [rootViewController showViewController:baseNotification sender:self];
    }
}

// documented in IterableInAppManager.h
+(void) showIterableNotificationHTML:(NSString*)htmlString trackParams:(IterableNotificationMetadata*)trackParams callbackBlock:(ITEActionBlock)callbackBlock backgroundAlpha:(double)backgroundAlpha padding:(UIEdgeInsets)padding{
    if (htmlString != NULL) {
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        if([rootViewController isKindOfClass:[UIViewController class]])
        {
            while (rootViewController.presentedViewController != nil)
            {
                rootViewController = rootViewController.presentedViewController;
            }
        }
        
        IterableInAppHTMLViewController *baseNotification;
        baseNotification = [[IterableInAppHTMLViewController alloc] initWithData:htmlString];
        [baseNotification ITESetTrackParams:trackParams];
        [baseNotification ITESetCallback:callbackBlock];
        [baseNotification ITESetPadding:padding];
        
        rootViewController.definesPresentationContext = YES;
        //TODO: change background opacity here
        baseNotification.view.backgroundColor = [UIColor colorWithWhite:0 alpha:backgroundAlpha];;
        baseNotification.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        [rootViewController presentViewController:baseNotification animated:NO completion:nil];
    }
}

// documented in IterableInAppManager.h
+(void) showIterableNotificationHTML:(NSString*)htmlString callbackBlock:(ITEActionBlock)callbackBlock{
    [IterableInAppManager showIterableNotificationHTML:htmlString trackParams:nil callbackBlock:callbackBlock backgroundAlpha:0 padding:UIEdgeInsetsZero];
}

// documented in IterableInAppManager.h
+(void) showSystemNotification:(NSString *)title body:(NSString *)body buttonLeft:(NSString *)buttonLeft buttonRight:(NSString *)buttonRight callbackBlock:(ITEActionBlock)callbackBlock{
    
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    if([rootViewController isKindOfClass:[UIViewController class]])
    {
        while (rootViewController.presentedViewController != nil)
        {
            rootViewController = rootViewController.presentedViewController;
        }
    }
    
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
    
    [rootViewController showViewController:alertController sender:self];
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
    if (colorString != nil && colorString.length > 0) {
        NSScanner *scanner = [NSScanner scannerWithString:colorString];
    
        [scanner setScanLocation:1];
        [scanner scanHexInt:&result];
    }
    
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

+(UIEdgeInsets)getPaddingFromPayload:(NSDictionary *)payload {
    UIEdgeInsets padding = UIEdgeInsetsZero;
    padding.top = [self decodePadding:[payload objectForKey:@"top"]];
    padding.left = [self decodePadding:[payload objectForKey:@"left"]];
    padding.bottom = [self decodePadding:[payload objectForKey:@"bottom"]];
    padding.right = [self decodePadding:[payload objectForKey:@"right"]];
    
    return padding;
}

+(double)decodePadding:(NSObject *)value {
    if ([@"AutoExpand" isEqualToString:[value valueForKey:@"displayOption"]]) {
        return -1;
    } else {
        //TODO: do type check here
        return [[value valueForKey:@"percentagesdf"] doubleValue];
    }
}


@end


