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
