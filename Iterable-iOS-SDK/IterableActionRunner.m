//
//  IterableActionRunner.m
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 5/1/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import "IterableActionRunner.h"
#import "IterableAPI.h"
#import "IterableLogging.h"

@implementation IterableActionRunner

+ (void)executeAction:(IterableAction *)action {
    if ([action isOfType:IterableActionTypeOpenUrl]) {
        // Open deeplink, use delegate handler
        [self openURL:[NSURL URLWithString:action.data] action:action];
    }
    else {
        // Call a custom action if available
        [self callCustomActionIfSpecified:action];
    }
}

+ (void)openURL:(NSURL *)url action:(IterableAction *)action {
    if (url == nil) {
        return;
    }
    
    if ([[IterableAPI sharedInstance].urlDelegate handleIterableURL:url fromAction:action]) {
        return;
    }

    // Open http/https links in the browser
    NSString *scheme = url.scheme;
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url
                                               options:@{}
                                               completionHandler:^(BOOL success) {
                                                   if (!success) {
                                                       LogError(@"Could not open the URL: %@", url.absoluteString);
                                                   }
                                               }];
        }
        else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

+ (void)callCustomActionIfSpecified:(IterableAction *)action {
    if (action.type.length > 0) {
        [[IterableAPI sharedInstance].customActionDelegate handleIterableCustomAction:action];
    }
}

@end
