[![CocoaPods](https://img.shields.io/cocoapods/v/IterableSDK.svg?style=flat)](https://cocoapods.org/pods/IterableSDK)
[![License](https://img.shields.io/cocoapods/l/IterableSDK.svg?style=flat)](https://opensource.org/licenses/MIT)
[![Docs](https://img.shields.io/cocoapods/metrics/doc-percent/IterableSDK.svg?style=flat)](http://cocoadocs.org/docsets/IterableSDK)
[![Build Status](https://travis-ci.org/Iterable/iterable-ios-sdk.svg?branch=master)](https://travis-ci.org/Iterable/iterable-ios-sdk)

# Iterable iOS SDK

`iterable-ios-sdk` is an Objective-C implementation of an iOS client for Iterable, for iOS versions 7.0 and higher.

# Setting up a push integration in Iterable

Before you even start with the SDK, you will need to 

1. Set your application up to receive push notifications, and 
2. Set up a push integration in Iterable. This allows Iterable to communicate on your behalf with Apple's Push Notification Service

If you haven't yet done so, you will need to enable push notifications for your application. This can be done by toggling `Push Notifications` under your target's `Capabilities` in Xcode. You can also do it directly in the app center on Apple's member center; go to `Identifiers -> App IDs -> select your app`. You should see `Push Notifications` under `Application Services`. Hit `Edit` and enable `Push Notifications`.

You will also need to generate an SSL certificate and private key for use with the push service. See the links at the end of this section for more information on how to do that.

Once you have your APNS certificates set up, go to `Integrations -> Mobile Push` in Iterable. When creating an integration, you will need to pick a name and a platform. The name is entirely up to you; it will be the `appName` when you use `registerToken` in our SDK. The platform can be `APNS` or `APNS_SANDBOX`; these correspond to the production and sandbox platforms. Your application will generate a different token depending on whether it is built using a development certificate or a distribution provisioning profile.

![Creating an integration in Iterable](http://support.iterable.com/hc/en-us/article_attachments/202957719/Screen_Shot_2015-07-30_at_3.15.56_PM.png)

For more information, see

* [Configuring Push Notifications](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/AddingCapabilities/AddingCapabilities.html#//apple_ref/doc/uid/TP40012582-CH26-SW6)
* [Creating Certificates](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/MaintainingCertificates/MaintainingCertificates.html#//apple_ref/doc/uid/TP40012582-CH31-SW32)
* [Amazon's Guide to Creating Certificates](http://docs.aws.amazon.com/sns/latest/dg/mobile-push-apns.html)

Congratulations, you've configured your mobile application to receive push notifications! Now, let's set up the Iterable SDK...

# Automatic Installation (via CocoaPods)

Iterable supports [CocoaPods](https://cocoapods.org) for easy installation. If you don't have it yet, you can install it with `Ruby` by running:
```
$ sudo gem install cocoapods 
```

To include the Iterable SDK in your project, you need to add it to your `Podfile`. If you don't have a `Podfile` yet, you can create one by running:
```
$ pod init
```

To add the Iterable pod to your target, edit the `Podfile` and include this line under the target:
```
pod 'IterableSDK'
```

Now, you need to tell Cocoapods to install the dependencies:
```
$ pod install
```

Congratulations! You have now imported the Iterable SDK into your project! 

> &#x2139; If your project is built with `Swift`, you will need a `bridging header`. See [here](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) for more information on how to create one.

# Manual Installation

In the `Artifacts` directory, you can find the compiled static library and headers. To include it in your project...

1. Add the headers to your header search paths. `Build Settings` -> `Search Paths` -> `Header Search Paths`. Enter the location where you put the SDK's headers. You should enable recursive (and it'll add `**` to the end of the path).
2. Link your project against Iterable's SDK. There are two ways to do this.
  1. Go to `Build Phases` -> `Link Binary With Libraries` and select `libIterable-iOS-SDK.a`, ***OR***
  2. Go to `Build Settings` -> `Search Paths` -> `Library Search Paths`, and enter the location where `libIterable-iOS-SDK.a` resides. Next, tell your project that it should look for `Iterable-iOS-SDK` during the linking phase by going to `Build Settings` -> `Linking` -> `Other Linker Flags`, and add `-lIterable-iOS-SDK` 
3. Go to `Build Settings` -> `Linking` -> `Other Linker Flags`, and add `-ObjC`. It is required for the `NSData+Conversion.h` category to be picked up properly during linking. For more information, see [this](https://developer.apple.com/library/mac/qa/qa1490/_index.html).

# Using the SDK

1. On application launch (`application:didFinishLaunchingWithOptions:`), initialize the Iterable SDK:

```objective-c
IterableConfig *config = [[IterableConfig alloc] init];
config.pushIntegrationName = "myPushIntegration";
[IterableAPI initializeWithApiKey:@"<your-api-key>" launchOptions:launchOptions config:config];
```
  * The `apiKey` should correspond to the API key of your project in Iterable. If you'd like, you can specify a different `apiKey` depending on whether you're building in `DEBUG` or `PRODUCTION`, and point the SDK to the relevant Iterable project.
  * Ideally, you will call this from inside `application:didFinishLaunchingWithOptions:` and pass in `launchOptions`. This will let the SDK automatically track a push open for you if the application was launched from a remote Iterable push notification. 
  * This method creates a singleton `IterableAPI` for your use. You can retrieve it later with `[IterableAPI sharedInstance]`. If retrieving it later, be sure that you have either instantiated it earlier, or check for a non-nil return value.

2. Once you know the email *(Preferred)* or userId of the user, call `setEmail:` or `setUserId:`
  * EMAIL: `[[IterableAPI sharedInstance] setEmail:@"email@example.com"];`
  * USERID: `[[IterableAPI sharedInstance] setUserId:@"userId"];`
	  * If you are setting a userId, an existing user must already exist for that userId 
	  * It is preferred that you use Email since that doesn't require an additional lookup by userId call on the backend.

3. **Register for remote notifications**  
   Since iOS 10, the preferred way is to use `UserNotifications` framework. See [Asking Permission to Use Notifications](https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications?language=objc) and [Registering Your App with APNs](https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns?language=objc) from Apple's documentation.
   1. Request authorization to display notifications via `UNUserNotificationCenter`'s [requestAuthorizationWithOptions:completionHandler:](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/1649527-requestauthorizationwithoptions?language=objc). The first time you call this method, iOS will prompt the user to allow the specified interactions. The OS will asynchronously let you know the user's choices via the provided callback block.    
	 For iOS < 10, call `UIApplication`'s [registerUserNotificationSettings:](https://developer.apple.com/documentation/uikit/uiapplication/1622932-registerusernotificationsettings?language=objc)
   2. Call `UIApplication`'s [registerForRemoteNotifications](https://developer.apple.com/documentation/uikit/uiapplication/1623078-registerforremotenotifications?language=objc) method to register your app for remote notifications.
   3. Use your app delegate’s [application:didRegisterForRemoteNotificationsWithDeviceToken:](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622958-application?language=objc) method to receive the device token needed to deliver remote notifications. Use the [application:didFailToRegisterForRemoteNotificationsWithError:](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622962-application?language=objc) method to process errors.


   > &#x26A0; Device registration will fail if user email or userId is not set. If you're calling `setEmail:` or `setUserId:` after the app is launched (i.e. when the user logs in), make sure you call [registerForRemoteNotifications](https://developer.apple.com/documentation/uikit/uiapplication/1623078-registerforremotenotifications?language=objc) again to register the device with the logged in user.

4. **Send the token to Iterable**  
   Use the SDK's `- (void)registerToken:(NSData *)token` to send the token to Iterable   
   This will register the token with the integration passed in `pushIntegrationName`. If you also pass `sandboxPushIntegrationName`, Iterable SDK will try to determine the APNS environment from the provisioning profile and register the device with the correct integration (APNS or APNS_SANDBOX).     
   ***Device tokens can change, so your app needs to reregister every time it is launched and pass the received token back to your server***. Don't cache your token on the device; send it every time you receive one. 
   This is the practice recommended by Apple; see the documentation [here](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW25). Specifically,
   
   > &#x26A0; Device tokens can change, so your app needs to reregister every time it is launched and pass the received token back to your server. If you fail to update the device token, remote notifications might not make their way to the user’s device. Device tokens always change when the user restores backup data to a new device or computer or reinstalls the operating system. When migrating data to a new device or computer, the user must launch your app once before remote notifications can be delivered to that device.
   
   > &#x26A0; Never cache a device token; always get the token from the system whenever you need it. If your app previously registered for remote notifications, calling the registerForRemoteNotifications method again does not incur any additional overhead, and iOS returns the existing device token to your app delegate immediately. In addition, iOS calls your delegate method any time the device token changes, not just in response to your app registering or re-registering.
   
5. **Handling push interactions**
	When the user taps on the notification or one of the action buttons, the system calls `UNUserNotificationCenterDelegate`'s [userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:](https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate/1649501-usernotificationcenter?language=objc). Pass this call to `IterableAppIntegration` to track push open event and perform the associated action (see below for custom action and URL delegates).

#### Putting it all together:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // other setup tasks here....
    
    // Initialize Iterable SDK
    IterableConfig *config = [[IterableConfig alloc] init];
    config.pushIntegrationName = "myPushIntegration_Prod";
    config.sandboxPushIntegrationName = "myPushIntegration_Dev";
    [IterableAPI initializeWithApiKey:@"YOUR API KEY" launchOptions:launchOptions config:config];
 
    if (@available(iOS 10, *)) {
    	UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error){
             if(!error){
                 [[UIApplication sharedApplication] registerForRemoteNotifications];
             }
         }];  
    } else {
	    UIUserNotificationType types = UIUserNotificationTypeBadge |
	                 UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
	    UIUserNotificationSettings *mySettings =
	                [UIUserNotificationSettings settingsForTypes:types categories:nil];
	    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    	[[UIApplication sharedApplication] registerForRemoteNotifications];
    }
 
    // Register for remote notifications.
}
 
// Handle remote notification registration.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token {
    [[IterableAPI sharedInstance] registerToken:token];
}
 
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error in registration for remote notifications. Error: %@", error);
}

// This is necessary for push notifications to work while the app is in foreground
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    completionHandler(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound);
}

// Pass the notification response (tap on the notification or one of the buttons) to the Iterable SDK so it can track the push open event and perform the associated action
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    [IterableAppIntegration userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
}

// This method will be called when the notification is opened on iOS < 10
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	[IterableAppIntegration application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

```

Congratulations! You can now send remote push notifications to your device from Iterable!

#### Iterable Notifications

All notifications from Iterable will come with a field called `itbl` in the payload. This field will contain a dictionary of data for Iterable's use. You can access it directly, but you should avoid doing so, as those fields might change. As of now, the fields include

*  `campaignId` - the campaign id (in Iterable). Not relevant for proof and test pushes.
*  `templateId` - the template id (in Iterable). Not relevant for test pushes.
*  `messageId` - the message id (in Iterable).
*  `isGhostPush` - whether this is a ghost push. See section below on uninstall tracking.

#### Uninstall Tracking

Iterable will track uninstalls with no additional work by you. 

This is implemented by sending a second push notification some time (currently, twelve hours) after the original campaign. If we receive feedback that the device's token is no longer valid, we assign an uninstall to the device, attributing it to the most recent campaign within twelve hours. An "real" campaign send (as opposed to the later "ghost" send) can also trigger recording an uninstall. In this case, if there was no previous campaign within the attribution period, an uninstall will still be tracked, but it will not be attributed to any campaign.

These "ghost" notifications will **not** automatically create a notification on the device. In fact, your application won't even be notified at all, unless you've enabled background mode. If you'd like your application to receive and act on these "ghost" pushes, you can enable background mode (this won't make the notifications show up; it'll just let your app handle them). To do this, go to your target in Xcode, then go to `Capabilities -> Background Modes` and enable `Background fetch` and `Remote notifications`.

After enabling background mode, you will need to implement a different method instead of `application:didReceiveRemoteNotification:`; this method is [application:didReceiveRemoteNotification:fetchCompletionHandler:](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplicationDelegate_Protocol/#//apple_ref/occ/intfm/UIApplicationDelegate/application:didReceiveRemoteNotification:fetchCompletionHandler:). This method, unlike `application:didReceiveRemoteNotification:`, will be called regardless of whether your application is running in the foreground or background. Once you are done, don't forget to call the completion handler with a `UIBackgroundFetchResult`. For more information on background mode notifications, see the `Discussion` under the [documentation for the method](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplicationDelegate_Protocol/#//apple_ref/occ/intfm/UIApplicationDelegate/application:didReceiveRemoteNotification:fetchCompletionHandler:).

#### Disabling push notifications to a device

When a user logs out, you typically want to disable push notifications to that user/device. This can be accomplished by calling `disableDeviceForCurrentUser`. Please note that it will only attempt to disable the device if you have previously called `registerToken`.

In order to re-enable push notifcations to that device, simply call `registerToken` as usual when the user logs back in.

#### InApp Notifications
To display the user's InApp notifications call `spawnInAppNotification` with a defined `ITEActionBlock` callback handler. When a user clicks a button on the notification, the defined handler is called and passed the action name defined in the InApp template.

InApp opens and button clicks are automatically tracked when the notification is called via `spawnInAppNotification`. Using `spawnInAppNotification` the notification is consumed and removed from the user's in-app messages queue. If you want to retain the messages on the queue, look at using `getInAppMessages` directly. If you use `getInAppMessages` you will need to manage the in-app opens manually in the callback handler.

#### Tracking and Updating User Fields

Custom events can be tracked using the `track` function and user fields can be modified using the `updateUser` function.


# Deep Linking
#### Handling links from push notifications
Push notifications and action buttons may have `openUrl` actions attached to them. When a URL is specified, the SDK first calls `urlDelegate` specified in your `IterableConfig` object. You can use this delegate to handle `openUrl` actions the same way as you handle normal deep links. If the delegate is not set or returns NO, the SDK will open Safari with that URL.

#### Handling email links
For Universal Links to work with link rewriting in emails, you need to set up apple-app-site-association file in the Iterable project. More instructions here: [Setting up iOS Universal Links](https://support.iterable.com/hc/en-us/articles/115000440206-Setting-up-iOS-Universal-Links)

From your `UIApplicationDelegate`'s [application:continueUserActivity:restorationHandler:](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623072-application?language=objc) call `resolveApplinkURL` along with a callback to handle the original deeplink url. You can use this method for any incoming URLs, as it will execute the callback without changing the URL for non-Iterable URLs.

Swift:

```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                  restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    
    IterableAPI.resolveApplinkURL(userActivity.webpageURL!, callback: {
        (originalURL) in
            //Handle Original URL deeplink here
    });
    return true
}
```

Objective-C:

```objective-c
- (BOOL)application:(UIApplication *)application
 		continueUserActivity(NSUserActivity *)userActivity 
 		restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    
    [IterableAPI resolveApplinkURL:userActivity.webpageURL callback:^(NSURL* originalURL) {
       //Handle Original URL deeplink here
    }];
    
    return true;
}
```


# Rich Push Notifications
Push notifications may contain media attachments with images, animated gifs or video, and with an upcoming update, there will be a way to create action buttons. For this to work within your app, you need to create a Notification Service Extension. More instructions here: [Rich Push Notifications in iOS 10 and Android - Media Attachments](https://support.iterable.com/hc/en-us/articles/115003982203-Rich-Push-Notifications-in-iOS-10-and-Android-Media-Attachments).   
Iterable SDK provides an implementation that handles media attachments and action buttons, so you'll only need to inherit from it:
###### Podfile

```
// If the target name for the notification extension is 'MyAppNotificationExtension'
target 'MyAppNotificationExtension' do
    pod 'IterableAppExtensions'
end
```

###### NotificationService.h

```objective-c
#import <UserNotifications/UserNotifications.h>
#import <IterableAppExtensions/IterableExtensions.h>

@interface NotificationService : ITBNotificationServiceExtension

@end
```

# Additional Information

See our [setup guide](http://support.iterable.com/hc/en-us/articles/204780589-Push-Notification-Setup-iOS-and-Android-) for more information.

Also see our [push notification setup FAQs](http://support.iterable.com/hc/en-us/articles/206791196-Push-Notification-Setup-FAQ-s).

# License

The MIT License

See [LICENSE](https://github.com/Iterable/iterable-ios-sdk/blob/master/LICENSE)

## Want to Contribute?

This library is open source, and we will look at pull requests!

See [CONTRIBUTING](CONTRIBUTING.md) for more information.
