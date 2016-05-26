//
//  IterableAPITests.m
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 5/25/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "IterableAPI.h"

@interface IterableAPI (Test)
+ (NSString*)pushServicePlatformToString:(PushServicePlatform)pushServicePlatform;
@end

@interface IterableAPITests : XCTestCase
@end

@implementation IterableAPITests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPushServicePlatformToString {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTAssertEqualObjects(@"APNS", [IterableAPI pushServicePlatformToString:APNS]);
    XCTAssertEqualObjects(@"APNS_SANDBOX", [IterableAPI pushServicePlatformToString:APNS_SANDBOX]);
}

@end
