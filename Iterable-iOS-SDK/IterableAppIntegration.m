//
//  IterableAppIntegration.m
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 4/24/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import "IterableAppIntegration.h"

@implementation IterableAppIntegration

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"IterableAPI: didReceiveRemoteNotification");
    if (completionHandler)
        completionHandler(UIBackgroundFetchResultNoData);
}

+ (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    NSLog(@"IterableAPI: didReceiveNotificationResponse: %@", response);
    if (completionHandler)
        completionHandler();
}

@end
