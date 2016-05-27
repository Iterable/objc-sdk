[![CocoaPods](https://img.shields.io/cocoapods/v/IterableSDK.svg?style=flat)](https://cocoapods.org/pods/IterableSDK)
[![License](https://img.shields.io/cocoapods/l/IterableSDK.svg?style=flat)](https://opensource.org/licenses/MIT)
[![Docs](https://img.shields.io/cocoapods/metrics/doc-percent/IterableSDK.svg?style=flat)](http://cocoadocs.org/docsets/IterableSDK)

# Iterable iOS SDK

`iterable-ios-sdk` is an Objective-C implementation of an iOS client for Iterable, for iOS versions 7.0 and higher.

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
If your project is built with `Swift`, you will need a `bridging header`. See [here](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) for more information on how to create one.

# Using the SDK

The steps using the SDK can be summarized as such:

1. Once you know the email of the user, created a shared instance of an `IterableAPI` using 
```
[IterableAPI sharedInstanceWithApiKey:(NSString *)apiKey andEmail:(NSString *)email launchOptions:(NSDictionary *)launchOptions]
```
The `apiKey` should correspond to the API key of your project in Iterable. If you'd like, you can specify a different `apiKey` depending on whether you're building in `DEBUG` or `PRODUCTION`, and point the SDK to the relevant Iterable project.
Ideally, you will call this from inside `application:didFinishLaunchingWithOptions:` and pass in `launchOptions`. This will let the SDK automatically track a push open for you if the application was launched from a remote Iterable push notification. 
This method creates a singleton `IterableAPI` for your use. You can retrieve it later with `[IterableAPI sharedInstance]`. If retrieving it later, be sure that you have either instantiated it earlier, or check for a non-nil return value. 

2. Register for remote notifications - more notes coming

3. Send the token to Iterable via `registerDeviceToken` - more notes coming

Congratulations! You can now send remote push notifications to your device from Iterable!

# Additional Information

See our [setup guide](http://support.iterable.com/hc/en-us/articles/204780589-Push-Notification-Setup-iOS-and-Android-) for more information.

Also see our [push notification setup FAQs](http://support.iterable.com/hc/en-us/articles/206791196-Push-Notification-Setup-FAQ-s).

# License

The MIT License

See [LICENSE](https://github.com/Iterable/iterable-ios-sdk/blob/master/LICENSE)

## Want to Contribute?

This library is open source, and we will look at pull requests!

See [CONTRIBUTING](CONTRIBUTING.md) for more information.
