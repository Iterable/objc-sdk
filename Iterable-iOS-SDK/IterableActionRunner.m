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
        [self callCustomActionIfSpecified:action.data extras:nil];
    }
    else if ([action isOfType:IterableActionTypeDeeplink]) {
        // Open deeplink, use delegate handler
        [self openURL:action.data];
    }
    else if ([action isOfType:IterableActionTypeTextInput]) {
        // Text input. Call a custom action and pass parameters if available
        [self callCustomActionIfSpecified:action.data extras:nil];
    }
}

+ (void)openURL:(NSString *)url {
    [[IterableAPI sharedInstance].urlDelegate handleIterableURL:[NSURL URLWithString:url] extras:nil];
}

+ (void)callCustomActionIfSpecified:(NSString *)data extras:(nullable NSDictionary *)extras {
    if (data.length > 0) {
        [[IterableAPI sharedInstance].customActionDelegate handleIterableCustomAction:data extras:extras];
    }
}

@end
