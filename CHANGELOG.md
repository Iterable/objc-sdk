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
