[![CocoaPods](https://img.shields.io/cocoapods/v/IterableSDK.svg?style=flat)](https://cocoapods.org/pods/IterableSDK)
[![License](https://img.shields.io/cocoapods/l/IterableSDK.svg?style=flat)](https://opensource.org/licenses/MIT)
[![Docs](https://img.shields.io/cocoapods/metrics/doc-percent/IterableSDK.svg?style=flat)](http://cocoadocs.org/docsets/IterableSDK/2.0.0/)

# Iterable iOS SDK

`iterable-ios-sdk` is an Objective-C implementation of an iOS client for Iterable, for iOS versions 7.0 and higher.

# Setting up a push integration in Iterable

Before you even start with the SDK, you will need to 

1. Set your application up to receive push notifications, and 
2. Set up a push integration in Iterable. This allows Iterable to communicate on your behalf with Apple's Push Notification Service

If you haven't yet done so, you will need to enable push notifications for your application. This can be done by toggling `Push Notifications` under your target's `Capabilities` in Xcode. You can also do it directly in the app center on Apple's member center; go to `Identifiers -> App IDs -> select your app`. You should see `Push Notifications` under `Application Services`. Hit `Edit` and enable `Push Notifications`.

You will also need to generate an SSL certificate and private key for use with the push service. See the links at the end of this section for more information on how to do that.

Once you have your APNS certificates set up, go to `Integrations -> Mobile Push` in Iterable. When creating an integration, you will need to pick a name and a platform. The name is entirely up to you; it will be the `appName` when you use `registerToken` in our SDK. The platform can be `APNS` or `APNS_SANDBOX`; these correspond to the production and sandbox platforms. Your application will generate a different token depending on whether it is built using a development certificate or a distribution provisioning profile.

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

> If your project is built with `Swift`, you will need a `bridging header`. See [here](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) for more information on how to create one.

# Using the SDK

1. Once you know the email of the user, **create a shared instance of an `IterableAPI`**
  * use `[IterableAPI sharedInstanceWithApiKey:(NSString *)apiKey andEmail:(NSString *)email launchOptions:(NSDictionary *)launchOptions]` to create an `IterableAPI`
  * The `apiKey` should correspond to the API key of your project in Iterable. If you'd like, you can specify a different `apiKey` depending on whether you're building in `DEBUG` or `PRODUCTION`, and point the SDK to the relevant Iterable project.
  * Ideally, you will call this from inside `application:didFinishLaunchingWithOptions:` and pass in `launchOptions`. This will let the SDK automatically track a push open for you if the application was launched from a remote Iterable push notification. 
  * This method creates a singleton `IterableAPI` for your use. You can retrieve it later with `[IterableAPI sharedInstance]`. If retrieving it later, be sure that you have either instantiated it earlier, or check for a non-nil return value. 

2. **Register for remote notifications**  
   See [Registering for Remote Notifications](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW2) from Apple's documentation.
  1. Register your app’s supported interaction types via `UIApplication`'s [registerUserNotificationSettings:](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplication_Class/index.html#//apple_ref/occ/instm/UIApplication/registerUserNotificationSettings:). The first time you call this method, iOS will prompt the user to allow the specified interactions. The OS will asynchronously let you know the user's choices via [application:didRegisterUserNotificationSettings:](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplicationDelegate_Protocol/index.html#//apple_ref/occ/intfm/UIApplicationDelegate/application:didRegisterUserNotificationSettings:).
  2. Call `UIApplication`'s [registerForRemoteNotifications](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplication_Class/index.html#//apple_ref/occ/instm/UIApplication/registerForRemoteNotifications) method to register your app for remote notifications.
  3. Use your app delegate’s [application:didRegisterForRemoteNotificationsWithDeviceToken:](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplicationDelegate_Protocol/index.html#//apple_ref/occ/intfm/UIApplicationDelegate/application:didRegisterForRemoteNotificationsWithDeviceToken:) method to receive the device token needed to deliver remote notifications. Use the [application:didFailToRegisterForRemoteNotificationsWithError:](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplicationDelegate_Protocol/index.html#//apple_ref/occ/intfm/UIApplicationDelegate/application:didFailToRegisterForRemoteNotificationsWithError:) method to process errors.

3. **Send the token to Iterable**  
   Use the SDK's `- (void)registerToken:(NSData *)token appName:(NSString *)appName pushServicePlatform:(PushServicePlatform)pushServicePlatform` to send the token to Iterable   
   ***Device tokens can change, so your app needs to reregister every time it is launched and pass the received token back to your server***. Don't cache your token on the device; send it every time you receive one. 

#### Putting it all together:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // other setup tasks here....
 
    // Register the supported interaction types.
    UIUserNotificationType types = UIUserNotificationTypeBadge |
                 UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings =
                [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
 
    // Register for remote notifications.
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}
 
// Handle remote notification registration.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token {
    self.registered = YES; // if you wanted to track whether you've registered for push, this is the place to do it

    NSString *applicationName = @"YOUR ITERABLE PUSH INTEGRATION NAME"; // the application name configured in Iterable when setting up your push credentials
    PushServicePlatform platform = APNS_SANDBOX; // use APNS for production
    IterableAPI *iterable = [IterableAPI sharedInstance]; // you should call sharedInstanceWithApiKey before this
    if (iterable != nil) {
        // if you have in-app options to disable push notifications, don't call registerToken if the user disabled notifications (as registerToken will add and enable the device)
        [iterable registerToken:token appName:applicationName pushServicePlatform:psp]; // register the token with Iterable
    }    
}
 
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error in registration for remote notifications. Error: %@", error);
}
```

Congratulations! You can now send remote push notifications to your device from Iterable!

# Receiving Remote Push Notifications

Application Running? | In foreground? | Notification Shown? | Delegate | When | Notes
--- | --- | --- | --- | --- | ---
Yes | Yes | No | `application:didReceiveRemoteNotification:` | Immediately | call `trackPushOpen` and pass in `userInfo`
Yes | No | Yes | `application:didReceiveRemoteNotification:` | On Notification Click | call `trackPushOpen` and pass in `userInfo`
No | N/A | Yes | `application:didFinishLaunchingWithOptions:` | On Notification Click | instantiate an `IterableAPI` and pass in `launchOptions`; a push open will be tracked automatically

For more information about local and remote notifications, and which callbacks will be called under which circumstances, see [Local and Remote Notifications in Depth](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/WhatAreRemoteNotif.html#//apple_ref/doc/uid/TP40008194-CH102-SW1).

# Additional Information

See our [setup guide](http://support.iterable.com/hc/en-us/articles/204780589-Push-Notification-Setup-iOS-and-Android-) for more information.

Also see our [push notification setup FAQs](http://support.iterable.com/hc/en-us/articles/206791196-Push-Notification-Setup-FAQ-s).

# License

The MIT License

See [LICENSE](https://github.com/Iterable/iterable-ios-sdk/blob/master/LICENSE)

## Want to Contribute?

This library is open source, and we will look at pull requests!

See [CONTRIBUTING](CONTRIBUTING.md) for more information.
