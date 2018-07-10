//
//  IterableAppIntegration.h
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 4/24/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface IterableAppIntegration : NSObject

/*!
 * This method handles incoming Iterable notifications and actions for iOS < 10
 * Call it from your app delegate's application:didReceiveRemoteNotification:fetchCompletionHandler:.
 *
 * @param application UIApplication singleton object
 * @param userInfo NSDictionary containing the notification data
 * @param completionHandler Completion handler passed from the original call. Iterable will call the completion handler
 * automatically if you pass one. If you handle completionHandler in the app code, pass a nil value to this argument.
 */
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

/*!
 * This method handles user actions on incoming Iterable notifications
 * Call it from your notification center delegate's userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:.
 *
 * @param center UNUserNotificationCenter singleton object
 * @param response Notification response containing the user action and notification data. Passed from the original call.
 * @param completionHandler Completion handler passed from the original call. Iterable will call the completion handler
 * automatically if you pass one. If you handle completionHandler in the app code, pass a nil value to this argument.
 */
+ (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler NS_AVAILABLE_IOS(10_0);

@end
