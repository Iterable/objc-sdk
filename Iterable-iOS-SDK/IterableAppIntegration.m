//
//  IterableAppIntegration.m
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 4/24/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#include <asl.h>

#import "IterableAppIntegration.h"
#import "IterableAPI.h"
#import "IterableAction.h"
#import "IterableActionRunner.h"
#import "IterableLogging.h"

@implementation IterableAppIntegration

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    LogDebug(@"IterableAPI: didReceiveRemoteNotification");
    if (completionHandler)
        completionHandler(UIBackgroundFetchResultNoData);
}

+ (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    LogDebug(@"IterableAPI: didReceiveNotificationResponse: %@", response);
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSDictionary *itbl = userInfo;
    NSMutableDictionary *dataFields = [[NSMutableDictionary alloc] init];
    IterableAction *action = nil;

    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        dataFields[@"actionIdentifier"] = @"default";
        action = [IterableAction actionFromDictionary:itbl[@"defaultAction"]];
    }
    else if ([response.actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier]) {
        // We don't track dismiss actions yet
        dataFields[@"actionIdentifier"] = @"dismiss";
    }
    else {
        dataFields[@"actionIdentifier"] = response.actionIdentifier;
        for (NSDictionary *button in itbl[@"actionButtons"]) {
            if ([response.actionIdentifier isEqualToString:button[@"identifier"]]) {
                action = [IterableAction actionFromDictionary:button[@"action"]];
            }
        }
    }

    // Track push open
    if ([response isMemberOfClass:[UNTextInputNotificationResponse class]]) {
        NSString *userText = ((UNTextInputNotificationResponse *)response).userText;
        dataFields[@"userText"] = ((UNTextInputNotificationResponse *)response).userText;
        action.userInput = userText;
    }
    if (action) {
        [[IterableAPI sharedInstance] trackPushOpen:userInfo dataFields:dataFields];
    }
    
    //Execute the action
    [IterableActionRunner executeAction:action];
    
    if (completionHandler)
        completionHandler();
}

@end
