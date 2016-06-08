# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
#### Added
- completion handler blocks for all the Iterable APIs
- class to represent Iterable notification metadata

#### Removed
- nothing yet

#### Changed
- no longer tracks push opens from test pushes, proofs

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
