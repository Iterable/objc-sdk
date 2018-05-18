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
    if (completionHandler)
        completionHandler(UIBackgroundFetchResultNoData);
}

+ (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    LogDebug(@"IterableAPI: didReceiveNotificationResponse: %@", response);
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSDictionary *itbl = userInfo[ITBL_PAYLOAD_METADATA];

#ifdef DEBUG
    if (itbl[ITBL_PAYLOAD_DEFAULT_ACTION] == nil && itbl[ITBL_PAYLOAD_ACTION_BUTTONS] == nil) {
        itbl = userInfo;
    }
#endif

    NSMutableDictionary *dataFields = [[NSMutableDictionary alloc] init];
    IterableAction *action = nil;

    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        dataFields[ITBL_KEY_ACTION_IDENTIFIER] = ITBL_VALUE_DEFAULT_PUSH_OPEN_ACTION_ID;
        action = [IterableAction actionFromDictionary:itbl[ITBL_PAYLOAD_DEFAULT_ACTION]];
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

    // Track push open
    if ([response isMemberOfClass:[UNTextInputNotificationResponse class]]) {
        NSString *userText = ((UNTextInputNotificationResponse *)response).userText;
        dataFields[ITBL_KEY_USER_TEXT] = ((UNTextInputNotificationResponse *)response).userText;
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
