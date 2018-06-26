# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
#### Added
- nothing yet

#### Removed
- nothing yet

#### Changed
- nothing yet

#### Fixed
- nothing yet

## [5.0.0](https://github.com/Iterable/iterable-ios-sdk/releases/tag/5.0.0)
#### Added
- Added support for push action buttons
- Added a new SDK initialization method that takes `IterableConfig` object with configuration options
- User ID/email is now decoupled from SDK initialization. It can be changed by calling `setEmail:` or `setUserId:` on the `IterableAPI` instance.
- Added automatic detection of APNS/APNS_SANDBOX, as long as both `pushIntegrationName` and `sandboxPushIntegrationName` are set in `IterableConfig`
- The SDK now stores attribution data within 24 hours of opening the app from a push notififcation or from a Universal Link in an email
- Added two delegates: `IterableUrlDelegate` and `IterableCustomActionDelegate` that can be used to customize URL and custom action handling for push notifications

#### Changed
- Old initialization methods (`sharedInstanceWithApiKey:`) are now deprecated
- Old `registerToken` methods are now deprecated

#### Fixed
- Added safety checks for cases when email or userId is nil

#### Migration Notes
1. Replace `[IterableAPI sharedInstanceWithApiKey:...]` with the following:
```objective-c
IterableConfig *config = [[IterableConfig alloc] init];
config.pushIntegrationName = "myPushIntegration_Prod";
config.sandboxPushIntegrationName = "myPushIntegration_Dev";
config.urlDelegate = self;          // If you want to handle URLs coming from push notifications
[IterableAPI initializeWithApiKey:@"YOUR API KEY" launchOptions:launchOptions config:config];
```
2. Since both pushIntegrationName and sandboxPushIntegrationName are now set in the configuration, call `[[IterableAPI sharedInstance] registerToken:token]` when registering the token, and it will choose the correct integration name automatically.
3. `[IterableAPI clearSharedInstance]` will do nothing if you initialize the SDK with the new initialization method. If you were previously calling `[IterableAPI clearSharedInstance]` to reinitialize the API with a new user, just call `setEmail:` or `setUserId:` instead.
4. User email/userId is now persisted, so you'll only need to call `setEmail:` or `setUserId:` when the user logs in or logs out.
5. The SDK now tracks push opens automatically, as long as calls to `userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:` are passed to it. See README for instructions. Once it is set up, remove all direct calls to `trackPushOpen:`.

## [4.4.7](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.4.7)
#### Fixed
- Fixed an unhandled exception in response handling on network errors

## [4.4.6](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.4.6)
#### Added
- Added the `updateEmail` function to update the user's email.

#### Fixed
- SDK methods now properly handle 4xx and 5xx status codes, calling onFailure with the error message received from the server.

## [4.4.5](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.4.5)
#### Fixed
- Fixed missing compiled version of the IterableDeeplinkManager.

## [4.4.4](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.4.4)
#### Changed
- Changed logic for `getAndTrackDeeplink` to not follow re-directs and return the first url redirect location instead.

## [4.4.3](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.4.3)
#### Fixed
- Fixes nil data in sendRequest onFailureHandler

## [4.4.2](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.4.2)
#### Fixed
- Fixes outdated artifacts file for `updateSubscriptions` release

## [4.4.1](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.4.1)
#### Added
- Added the `updateSubscriptions` function to create to modify channel, list, and message subscription preferences.

## [4.4.0](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.4.0)
#### Added
- Added the `showIterableNotificationHTML` function to create html based in-app notifications

#### Changed
- Changed the `spawnInAppNotification` function to parse html formatted notifications.

## [4.3.3](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.3.3)
#### Added
- Added the `clearSharedInstance` function to reset the stored Iterable instance.
- Added the `updateUser` function to add or modify user Fields.

#### Changed
- Changed the `spawnInAppNotification` function to automatically consume messages from the user messages queue.

#### Fixed
- Fixed missing header files for constants.

## [4.3.2](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.3.2)
#### Added
- Added the `inAppConsume` function to remove in-app messages from the user queue.

#### Changed
- Changed the `spawnInAppNotification` function to automatically consume messages from the user messages queue.

#### Fixed
- Fixed url query string parameter encoding for get requests.

## [4.3.1](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.3.1)
#### Fixed
- Fixed rendering of In-App notification to be on top of other views.

## [4.3.0](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.3.0)
#### Added
- added the `getAndTrackDeeplink` function to track links sent by Iterable and retrieves the destination deeplink url

## [4.2.0](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.2.0)
#### Added
- added support for In-App Notifications with different views layouts
	- Full screen 
	- Bottom
	- Center
	- Top
- includes tracking for In-App opens and clicks
- includes support for GET requests
- added support for system styled dialogs
- Prefixed common method names

## [4.1.1](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.1.1)
#### Fixed
- included the latest artifacts


## [4.1.0](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.1.0)
#### Added
- added in new overloaded function for `initWithApiKey` to allow for custom launchOptions not passed from `application:didFinishLaunchingWithOptions`

## [4.0.2](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.0.2)
#### Fixed
- include the latest artifacts

## [4.0.1](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.0.1)
#### Added
- added back in `initWithApiKey`


## [4.0.0](https://github.com/Iterable/iterable-ios-sdk/releases/tag/4.0.0)
#### Added
- added `userId` property
- added new overloaded function for sharedInstanceWithApiKey to pass in a userId instead of an email.

#### Removed
- removed header for `initWithApiKey`

#### Changed
- changed the arguments of the following apis to use `userId` if an `email` does not exist: `track`, `trackPushOpen`, `registerToken`, and `disableDevice`.

## [3.1.1](https://github.com/Iterable/iterable-ios-sdk/releases/tag/3.1.1)
_Released on 2016-09-08_

#### Added
- now includes transactionIds along with push notifications

## [3.1.0](https://github.com/Iterable/iterable-ios-sdk/releases/tag/3.1.0)
 _Released on 2016-07-19_

#### Added
- now includes disableDevice API

#### Removed
- removed device name from `registerToken` call as it might contain user sensitive data (the user's name)


## [3.0.1](https://github.com/Iterable/iterable-ios-sdk/releases/tag/3.0.1)
 _Released on 2016-06-22_
 
#### Fixed
- removed JSONModel from dependencies in Podspec
 
 
## [3.0.0](https://github.com/Iterable/iterable-ios-sdk/releases/tag/3.0.0)
 _Released on 2016-06-22_
 
#### Added
- now comes with compiled universal static library and public headers in the `Artifacts` directory
 
#### Changed
- `registerToken` no longer checks the token to be 32 bytes/64 hex chars
- `JSONModel` removed from project; no longer needs any outside libraries; some `CommerceItem`/`trackPurchase` APIs changed as a result of this
- removed `Pods` integration

#### Fixed
- `registerToken` now calls the failure handler if an invalid `PushServicePlatform` is passed in
 

## [2.1.0](https://github.com/Iterable/iterable-ios-sdk/releases/tag/2.1.0)
 _Released on 2016-06-07_
 
#### Added
- completion handler blocks for all the Iterable APIs
- class to represent Iterable notification metadata

#### Changed
- no longer tracks push opens from test and proof pushes

#### Fixed
- no longer tracks push opens from ghost pushes


## [2.0.1](https://github.com/Iterable/iterable-ios-sdk/releases/tag/2.0.1)
 _Released on 2016-06-06_
  
#### Changed
- NSURLConnection is deprecated as of iOS9; this release drops in its replacement, NSURLSession


## [2.0.0](https://github.com/Iterable/iterable-ios-sdk/releases/tag/2.0.0)
 _Released on 2016-06-02_

#### Added
- fleshed out README
- added CHANGELOG
- added CONTRIBUTING
- new logging system
- nullability annotations
- overrides/defaults for methods that take nullable params

#### Removed
- unessential logging in non-DEBUG builds

#### Changed
- updated pod version to 7.0 (from 5.0) in preparation for NSURLSession
- logging changes


## [1.0.0](https://github.com/Iterable/iterable-ios-sdk/releases/tag/1.0.0)
 _Released on 2016-05-25_
 
#### Added 
- Unit tests for several internal methods
- More documentation
