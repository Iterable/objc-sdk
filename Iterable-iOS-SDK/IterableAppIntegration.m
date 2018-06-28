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
#import "IterableActionRunner.h"
#import "IterableLogging.h"

@implementation IterableAppIntegration

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    LogDebug(@"IterableAPI: didReceiveRemoteNotification");
    switch (application.applicationState) {
        case UIApplicationStateActive:
            break;

        case UIApplicationStateBackground:
            break;

        case UIApplicationStateInactive:
            if (@available(iOS 10, *)) {
                // iOS 10+ notification actions are handled by userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:
            } else {
                [self performDefaultNotificationAction:userInfo api:[IterableAPI sharedInstance]];
            }
            break;
    }

    if (completionHandler)
        completionHandler(UIBackgroundFetchResultNoData);
}

+ (void)performDefaultNotificationAction:(NSDictionary *)userInfo api:(IterableAPI *)api {
    NSDictionary *itbl = userInfo[ITBL_PAYLOAD_METADATA];

    // Ignore the notification if we've already processed it from launchOptions while initializing the SDK
    if ([userInfo isEqualToDictionary:[IterableAPI sharedInstance].lastPushPayload]) {
        return;
    }

#ifdef DEBUG
    if (itbl[ITBL_PAYLOAD_DEFAULT_ACTION] == nil && itbl[ITBL_PAYLOAD_ACTION_BUTTONS] == nil) {
        itbl = userInfo;
    }
#endif
    
    IterableAction *action = nil;
    NSDictionary *dataFields = @{ ITBL_KEY_ACTION_IDENTIFIER: ITBL_VALUE_DEFAULT_PUSH_OPEN_ACTION_ID };
    if (itbl[ITBL_PAYLOAD_DEFAULT_ACTION] != nil) {
        action = [IterableAction actionFromDictionary:itbl[ITBL_PAYLOAD_DEFAULT_ACTION]];
    } else {
        action = [self legacyDefaultActionFromPayload:userInfo];
    }

    // Track push open
    [api trackPushOpen:userInfo dataFields:dataFields];

    //Execute the action
    [IterableActionRunner executeAction:action from:IterableActionSourcePush];
}

+ (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    LogDebug(@"IterableAPI: didReceiveNotificationResponse: %@", response);
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSDictionary *itbl = userInfo[ITBL_PAYLOAD_METADATA];
    
    // Ignore the notification if we've already processed it from launchOptions while initializing the SDK
    if ([userInfo isEqualToDictionary:[IterableAPI sharedInstance].lastPushPayload]) {
        if (completionHandler) {
            completionHandler();
        }
        return;
    }

#ifdef DEBUG
    if (itbl[ITBL_PAYLOAD_DEFAULT_ACTION] == nil && itbl[ITBL_PAYLOAD_ACTION_BUTTONS] == nil) {
        itbl = userInfo;
    }
#endif

    NSMutableDictionary *dataFields = [[NSMutableDictionary alloc] init];
    IterableAction *action = nil;

    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        dataFields[ITBL_KEY_ACTION_IDENTIFIER] = ITBL_VALUE_DEFAULT_PUSH_OPEN_ACTION_ID;
        if (itbl[ITBL_PAYLOAD_DEFAULT_ACTION] != nil) {
            action = [IterableAction actionFromDictionary:itbl[ITBL_PAYLOAD_DEFAULT_ACTION]];
        } else {
            action = [self legacyDefaultActionFromPayload:userInfo];
        }
    }
    else if ([response.actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier]) {
        // We don't track dismiss actions yet
    }
    else {
        dataFields[ITBL_KEY_ACTION_IDENTIFIER] = response.actionIdentifier;
        for (NSDictionary *button in itbl[ITBL_PAYLOAD_ACTION_BUTTONS]) {
            if ([response.actionIdentifier isEqualToString:button[ITBL_BUTTON_IDENTIFIER]]) {
                action = [IterableAction actionFromDictionary:button[ITBL_BUTTON_ACTION]];
            }
        }
    }

    if ([response isMemberOfClass:[UNTextInputNotificationResponse class]]) {
        NSString *userText = ((UNTextInputNotificationResponse *)response).userText;
        dataFields[ITBL_KEY_USER_TEXT] = ((UNTextInputNotificationResponse *)response).userText;
        action.userInput = userText;
    }

    // Track push open
    if (dataFields[ITBL_KEY_ACTION_IDENTIFIER] != nil) {
        [[IterableAPI sharedInstance] trackPushOpen:userInfo dataFields:dataFields];
    }
    
    //Execute the action
    [IterableActionRunner executeAction:action from:IterableActionSourcePush];
    
    if (completionHandler) {
        completionHandler();
    }
}

+ (IterableAction *)legacyDefaultActionFromPayload:(NSDictionary *)userInfo {
    if (userInfo[ITBL_PAYLOAD_DEEP_LINK_URL] != nil) {
        return [IterableAction actionOpenUrl:userInfo[ITBL_PAYLOAD_DEEP_LINK_URL]];
    } else {
        return nil;
    }
}

@end
