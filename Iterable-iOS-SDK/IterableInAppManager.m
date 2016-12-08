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

@interface IterableInAppManager ()

@end

@implementation IterableInAppManager

// documented in IterableInAppManager.h
+(void) showNotification:(NSDictionary*)dialogOptions callbackBlock:(actionBlock)callbackBlock{
    if (dialogOptions != NULL) {
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        IterableInAppBaseViewController *baseNotification;
        
        NSString* type = [dialogOptions objectForKey:ITERABLE_IN_APP_TYPE];
        if ([type caseInsensitiveCompare:ITERABLE_IN_APP_TYPE_FULL] == NSOrderedSame){
            baseNotification = [[IterableFullScreenViewController alloc] init];
        } else {
            baseNotification = [[IterableAlertViewController alloc] initWithNibName:nil bundle:nil];
        }
        
        //TODO: add in view tracking
        
        [baseNotification setData:dialogOptions];
        [baseNotification setCallback:callbackBlock];
        [rootViewController presentViewController:baseNotification animated:YES completion:nil];
    }
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
        NSDictionary *message = [messageArray objectAtIndex:0];
        if (message != nil) {
            returnDictionary = [message valueForKeyPath:ITERABLE_IN_APP_CONTENT];
        }
        
    }
    return returnDictionary;
}

@end

