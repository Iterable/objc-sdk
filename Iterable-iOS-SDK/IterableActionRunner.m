//
//  IterableActionRunner.m
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 5/1/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import "IterableActionRunner.h"
#import "IterableAPI.h"
#import "IterableAPI+Internal.h"
#import "IterableLogging.h"
#import "IterableActionContext.h"

@implementation IterableActionRunner

+ (BOOL)executeAction:(IterableAction *)action from:(IterableActionSource)source {
    // Do not handle actions and try to open Safari for URLs unless the SDK is initialized with a new init method
    if ([IterableAPI sharedInstance].sdkCompatEnabled) {
        return NO;
    }

    IterableActionContext *context = [IterableActionContext contextWithAction:action source:source];

    if ([action isOfType:IterableActionTypeOpenUrl]) {
        // Open deeplink, use delegate handler
        return [self openURL:[NSURL URLWithString:action.data] context:context];
    }
    else {
        // Call a custom action if available
        return [self callCustomActionIfSpecified:action context:context];
    }
}

+ (BOOL)openURL:(NSURL *)url context:(IterableActionContext *)context {
    if (url == nil) {
        return NO;
    }
    
    if ([[IterableAPI sharedInstance].config.urlDelegate handleIterableURL:url context:context]) {
        return YES;
    }

    if (context.source == IterableActionSourcePush) {
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
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
            return YES;
        }
    }
    return NO;
}

+ (BOOL)callCustomActionIfSpecified:(IterableAction *)action context:(IterableActionContext *)context {
    if (action.type.length > 0) {
        return [[IterableAPI sharedInstance].config.customActionDelegate handleIterableCustomAction:action context:context];
    }
    return NO;
}

@end
