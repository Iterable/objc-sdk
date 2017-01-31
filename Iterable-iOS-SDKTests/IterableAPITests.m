//
//  IterableAPITests.m
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 5/25/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <asl.h>

#import "IterableAPI.h"

// category to "expose" private methods; see http://stackoverflow.com/questions/1098550/unit-testing-of-private-methods-in-xcode
@interface IterableAPI (Test)
+ (NSString *)pushServicePlatformToString:(PushServicePlatform)pushServicePlatform;
+ (NSString *)dictToJson:(NSDictionary *)dict;
+ (NSString *)userInterfaceIdiomEnumToString:(UIUserInterfaceIdiom)idiom;
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
    XCTAssertEqualObjects(@"APNS", [IterableAPI pushServicePlatformToString:APNS]);
    XCTAssertEqualObjects(@"APNS_SANDBOX", [IterableAPI pushServicePlatformToString:APNS_SANDBOX]);
    XCTAssertNil([IterableAPI pushServicePlatformToString:231097]);
}

- (void)testDictToJson {
    NSDictionary *args = @{
                           @"email": @"ilya@iterable.com",
                           @"device": @{
                                   @"token": @"foo",
                                   @"platform": @"bar",
                                   @"applicationName": @"baz",
                                   @"dataFields": @{
                                           @"name": @"green",
                                           @"localizedModel": @"eggs",
                                           @"userInterfaceIdiom": @"and",
                                           @"identifierForVendor": @"ham",
                                           @"systemName": @"iterable",
                                           @"systemVersion": @"is",
                                           @"model": @"awesome"
                                           }
                                   }
                           };
    NSString *result = [IterableAPI dictToJson:args];
    NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    XCTAssertEqualObjects(args, json);
    
    NSString *expected = @"{\"email\":\"ilya@iterable.com\",\"device\":{\"applicationName\":\"baz\",\"dataFields\":{\"systemName\":\"iterable\",\"model\":\"awesome\",\"localizedModel\":\"eggs\",\"userInterfaceIdiom\":\"and\",\"systemVersion\":\"is\",\"name\":\"green\",\"identifierForVendor\":\"ham\"},\"token\":\"foo\",\"platform\":\"bar\"}}";
    
    id object = [NSJSONSerialization
                 JSONObjectWithData:[expected dataUsingEncoding:NSUTF8StringEncoding]
                 options:0
                 error:nil];
    XCTAssertEqualObjects(args, object);
    XCTAssertEqualObjects(args, json);
}

- (void)testUserInterfaceIdionEnumToString {
    XCTAssertEqualObjects(@"Phone", [IterableAPI userInterfaceIdiomEnumToString:UIUserInterfaceIdiomPhone]);
    XCTAssertEqualObjects(@"Pad", [IterableAPI userInterfaceIdiomEnumToString:UIUserInterfaceIdiomPad]);
    // we don't care about TVs for now
    XCTAssertEqualObjects(@"Unspecified", [IterableAPI userInterfaceIdiomEnumToString:UIUserInterfaceIdiomTV]);
    XCTAssertEqualObjects(@"Unspecified", [IterableAPI userInterfaceIdiomEnumToString:UIUserInterfaceIdiomUnspecified]);
    XCTAssertEqualObjects(@"Unspecified", [IterableAPI userInterfaceIdiomEnumToString:192387]);
}

- (void)testUniversalDeepLinkRewriting {
    NSURL *iterableLink = [NSURL URLWithString:@"http://links.iterable.com/a/60402396fbd5433eb35397b47ab2fb83?_e=joneng%40iterable.com&_m=93125f33ba814b13a882358f8e0852e0"];
    
    XCTestExpectation *expectation =
    [self expectationWithDescription:@"High Expectations"];
    ITEActionBlock aBlock = ^(NSString* redirectUrl) {
        [expectation fulfill];
        XCTAssertEqualObjects(@"https://links.iterable.com/api/docs#!/email", redirectUrl);
        
    };
    [IterableAPI getAndTrackDeeplink:iterableLink callbackBlock:aBlock];

    NSURL *normalLink = [NSURL URLWithString:@"http://links.iterable.com/u/60402396fbd5433eb35397b47ab2fb83?_e=joneng%40iterable.com&_m=93125f33ba814b13a882358f8e0852e0"];
    
    ITEActionBlock uBlock = ^(NSString* redirectUrl) {
        XCTAssertEqualObjects(@"http://links.iterable.com/u/60402396fbd5433eb35397b47ab2fb83?_e=joneng%40iterable.com&_m=93125f33ba814b13a882358f8e0852e0", redirectUrl);
        
    };
    [IterableAPI getAndTrackDeeplink:normalLink callbackBlock:uBlock];
    
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

@end
