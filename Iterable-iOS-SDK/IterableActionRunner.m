//
//  IterableActionRunner.m
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 5/1/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import "IterableActionRunner.h"
#import "IterableAPI.h"

@implementation IterableActionRunner

+ (void)executeAction:(IterableAction *)action {
    if ([action isOfType:IterableActionTypeOpen] || [action isOfType:IterableActionTypeDismiss]) {
        // Call a custom action if it is available
        [self callCustomActionIfSpecified:action.data];
    }
    else if ([action isOfType:IterableActionTypeDeeplink]) {
        // Open deeplink, use delegate handler
        [self openURL:action.data];
    }
    else if ([action isOfType:IterableActionTypeTextInput]) {
        // Text input. Call a custom action and pass parameters if available
        // TODO: pass extras?
        [self callCustomActionIfSpecified:action.data];
    }
}

+ (void)openURL:(NSString *)url {
    if ([url hasPrefix:@"http"]) {
        // This looks like a Universal link. Simulate it internally.
        /*NSUserActivity* userActivity = [[NSUserActivity alloc] initWithActivityType:NSUserActivityTypeBrowsingWeb];
        userActivity.webpageURL = url;
        [[UIApplication sharedApplication].delegate application:[UIApplication sharedApplication] continueUserActivity:userActivity restorationHandler:nil];*/
    }
    [[IterableAPI sharedInstance].urlDelegate handleIterableURL:[NSURL URLWithString:url] extras:nil];
}

+ (void)callCustomActionIfSpecified:(NSString *)data {
    // TODO: pass extras here?
    if (data.length > 0) {
        [[IterableAPI sharedInstance].customActionDelegate handleIterableCustomAction:data];
    }
}

@end
