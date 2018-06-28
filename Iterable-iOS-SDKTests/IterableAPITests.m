//
//  IterableAPITests.m
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 5/25/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <asl.h>
#import <OHHTTPStubs.h>
#import <OHHTTPStubs/NSURLRequest+HTTPBodyTesting.h>

#import "IterableAPI.h"
#import "IterableAPI+Internal.h"
#import "IterableDeeplinkManager.h"
#import "IterableActionContext.h"
#import "NSData+Conversion.h"

static CGFloat const IterableNetworkResponseExpectationTimeout = 5.0;

// category to "expose" private methods; see http://stackoverflow.com/questions/1098550/unit-testing-of-private-methods-in-xcode
@interface IterableAPI (Test)
+ (NSString *)pushServicePlatformToString:(PushServicePlatform)pushServicePlatform;
+ (NSString *)dictToJson:(NSDictionary *)dict;
+ (NSString *)userInterfaceIdiomEnumToString:(UIUserInterfaceIdiom)idiom;

- (NSString *)encodeURLParam:(NSString *)paramValue;
@end

@interface IterableAPITests : XCTestCase
@end

@implementation IterableAPITests

NSString *redirectRequest = @"https://httpbin.org/redirect-to?url=http://example.com";
NSString *exampleUrl = @"http://example.com";

NSString *googleHttps = @"https://www.google.com";
NSString *googleHttp = @"http://www.google.com";
NSString *iterableRewriteURL = @"http://links.iterable.com/a/60402396fbd5433eb35397b47ab2fb83?_e=joneng%40iterable.com&_m=93125f33ba814b13a882358f8e0852e0";
NSString *iterableNoRewriteURL = @"http://links.iterable.com/u/60402396fbd5433eb35397b47ab2fb83?_e=joneng%40iterable.com&_m=93125f33ba814b13a882358f8e0852e0";

- (void)setUp {
    [super setUp];

    [IterableAPI sharedInstanceWithApiKey:@"" andEmail:@"" launchOptions:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSdkInitializedWithNil {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        XCTAssert(false, @"API calls should not be made without an email or userId");
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:kCFStringEncodingUTF8] statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];

    IterableAPI.sharedInstance.sdkCompatEnabled = YES;
    [IterableAPI clearSharedInstance];
    [IterableAPI sharedInstanceWithApiKey:@"" andEmail:nil launchOptions:nil];
    [[IterableAPI sharedInstance] track:@"testEvent"];
    [[IterableAPI sharedInstance] trackInAppOpen:@"12345"];
    [[IterableAPI sharedInstance] inAppConsume:@"12345"];
    [[IterableAPI sharedInstance] trackInAppClick:@"12345" buttonURL:@""];
    [[IterableAPI sharedInstance] registerToken:[[NSData alloc] init] appName:@"appName" pushServicePlatform:APNS_SANDBOX];
    [[IterableAPI sharedInstance] disableDeviceForCurrentUser];
    [[IterableAPI sharedInstance] updateUser:@{} mergeNestedObjects:NO onSuccess:nil onFailure:nil];
    [[IterableAPI sharedInstance] updateEmail:@"" onSuccess:nil onFailure:nil];
    [[IterableAPI sharedInstance] trackPushOpen:@{}];
    [[IterableAPI sharedInstance] trackPurchase:@10 items:@[]];
    
    [IterableAPI clearSharedInstance];
    [IterableAPI sharedInstanceWithApiKey:@"" andUserId:nil launchOptions:nil];
    [[IterableAPI sharedInstance] track:@"testEvent"];
    [[IterableAPI sharedInstance] trackInAppOpen:@"12345"];
    [[IterableAPI sharedInstance] inAppConsume:@"12345"];
    [[IterableAPI sharedInstance] trackInAppClick:@"12345" buttonURL:@""];
    [[IterableAPI sharedInstance] registerToken:[[NSData alloc] init] appName:@"appName" pushServicePlatform:APNS_SANDBOX];
    [[IterableAPI sharedInstance] disableDeviceForCurrentUser];
    [[IterableAPI sharedInstance] updateUser:@{} mergeNestedObjects:NO onSuccess:nil onFailure:nil];
    [[IterableAPI sharedInstance] updateEmail:@"" onSuccess:nil onFailure:nil];
    [[IterableAPI sharedInstance] trackPushOpen:@{}];
    [[IterableAPI sharedInstance] trackPurchase:@10 items:@[]];
    
    [IterableAPI clearSharedInstance];
    [OHHTTPStubs removeAllStubs];
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

- (void)testUniversalDeepLinkRewrite {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    NSURL *iterableLink = [NSURL URLWithString:iterableRewriteURL];
    ITEActionBlock aBlock = ^(NSString* redirectUrl) {
        XCTAssertEqualObjects(@"https://links.iterable.com/api/docs#!/email", redirectUrl);
        XCTAssertTrue([NSThread isMainThread], "The callback must be called on the main thread");
        [expectation fulfill];
    };
    [IterableAPI getAndTrackDeeplink:iterableLink callbackBlock:aBlock];
    
    [self waitForExpectationsWithTimeout:IterableNetworkResponseExpectationTimeout handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testUniversalDeepLinkNoRewrite {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    NSURL *normalLink = [NSURL URLWithString:iterableNoRewriteURL];
    ITEActionBlock uBlock = ^(NSString* redirectUrl) {
        XCTAssertEqualObjects(iterableNoRewriteURL, redirectUrl);
        [expectation fulfill];
    };
    [IterableAPI getAndTrackDeeplink:normalLink callbackBlock:uBlock];
    
    [self waitForExpectationsWithTimeout:IterableNetworkResponseExpectationTimeout handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testHandleUniversalLinkRewrite {
    id urlDelegateMock = OCMProtocolMock(@protocol(IterableURLDelegate));
    OCMExpect([urlDelegateMock handleIterableURL:[OCMArg isEqual:[NSURL URLWithString:@"https://links.iterable.com/api/docs#!/email"]]
                                         context:[OCMArg checkWithBlock:^BOOL(IterableActionContext *context) {
        return [context.action isOfType:IterableActionTypeOpenUrl];
    }]]);
    
    IterableAPI.sharedInstance.sdkCompatEnabled = YES;
    [IterableAPI clearSharedInstance];
    IterableConfig *config = [[IterableConfig alloc] init];
    config.urlDelegate = urlDelegateMock;
    [IterableAPI initializeWithApiKey:@"" launchOptions:nil config:config];
    
    NSURL *iterableLink = [NSURL URLWithString:iterableRewriteURL];
    [IterableAPI handleUniversalLink:iterableLink];
    
    OCMVerifyAllWithDelay(urlDelegateMock, IterableNetworkResponseExpectationTimeout);
}

- (void)testDeepLinkAttributionInfo {
    NSNumber *campaignId = [NSNumber numberWithLong:83306];
    NSNumber *templateId = [NSNumber numberWithInt:124348];
    NSString *messageId = @"93125f33ba814b13a882358f8e0852e0";
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    NSURL *normalLink = [NSURL URLWithString:iterableRewriteURL];
    ITEActionBlock uBlock = ^(NSString* redirectUrl) {
        XCTAssertEqualObjects(IterableAPI.sharedInstance.attributionInfo.campaignId, campaignId);
        XCTAssertEqualObjects(IterableAPI.sharedInstance.attributionInfo.templateId, templateId);
        XCTAssertEqualObjects(IterableAPI.sharedInstance.attributionInfo.messageId, messageId);
        [expectation fulfill];
    };
    [IterableAPI getAndTrackDeeplink:normalLink callbackBlock:uBlock];
    
    [self waitForExpectationsWithTimeout:IterableNetworkResponseExpectationTimeout handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testNoURLRedirect {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    NSURL *redirectLink = [NSURL URLWithString:redirectRequest];
    ITEActionBlock redirectBlock = ^(NSString* redirectUrl) {
        [expectation fulfill];
        XCTAssertNotEqual(exampleUrl, redirectUrl);
        XCTAssertEqualObjects(redirectRequest, redirectUrl);
    };
    [IterableAPI getAndTrackDeeplink:redirectLink callbackBlock:redirectBlock];
    
    [self waitForExpectationsWithTimeout:IterableNetworkResponseExpectationTimeout handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testUniversalDeepLinkHttp {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    NSURL *googleHttpLink = [NSURL URLWithString:googleHttps];
    ITEActionBlock googleHttpBlock = ^(NSString* redirectUrl) {
        [expectation fulfill];
        XCTAssertEqualObjects(googleHttps, redirectUrl);
        XCTAssertNotEqual(googleHttp, redirectUrl);
    };
    [IterableAPI getAndTrackDeeplink:googleHttpLink callbackBlock:googleHttpBlock];
    
    [self waitForExpectationsWithTimeout:IterableNetworkResponseExpectationTimeout handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testUniversalDeepLinkHttps {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    NSString *googleHttps = @"https://www.google.com";
    
    NSURL *googleHttpsLink = [NSURL URLWithString:googleHttps];
    ITEActionBlock googleHttpsBlock = ^(NSString* redirectUrl) {
        [expectation fulfill];
        XCTAssertEqualObjects(googleHttps, redirectUrl);
    };
    [IterableAPI getAndTrackDeeplink:googleHttpsLink callbackBlock:googleHttpsBlock];
    
    [self waitForExpectationsWithTimeout:IterableNetworkResponseExpectationTimeout handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testURLQueryParamRewrite {
    [IterableAPI sharedInstanceWithApiKey:@"" andEmail:@"" launchOptions:nil];
    
    NSCharacterSet* set = [NSCharacterSet URLQueryAllowedCharacterSet];
    
    NSMutableString* strSet =[NSMutableString string];
    for (int plane = 0; plane <= 16; plane++) {
        if ([set hasMemberInPlane:plane]) {
            UTF32Char c;
            for (c = plane << 16; c < (plane+1) << 16; c++) {
                if ([set longCharacterIsMember:c]) {
                    UTF32Char c1 = OSSwapHostToLittleInt32(c);
                    NSString *s = [[NSString alloc] initWithBytes:&c1 length:4 encoding:NSUTF32LittleEndianStringEncoding];
                    [strSet appendString:s];
                }
            }
        }
    }
    
    //Test full set of possible URLQueryAllowedCharacterSet characters
    NSString* encodedSet = [[IterableAPI sharedInstance] encodeURLParam:strSet];
    XCTAssertNotEqual(encodedSet, strSet);
    XCTAssert([encodedSet isEqualToString:@"!$&'()*%2B,-./0123456789:;=?@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~"]);
    
    NSString* encoded = [[IterableAPI sharedInstance] encodeURLParam:@"you+me@iterable.com"];
    XCTAssertNotEqual(encoded, @"you+me@iterable.com");
    XCTAssert([encoded isEqualToString:@"you%2Bme@iterable.com"]);
    
    NSString* emptySet = [[IterableAPI sharedInstance] encodeURLParam:@""];
    XCTAssertEqual(emptySet, @"");
    XCTAssert([emptySet isEqualToString:@""]);
    
    NSString* nilSet = [[IterableAPI sharedInstance] encodeURLParam:nil];
    XCTAssertEqual(nilSet, nil);
}

- (void)testRegisterToken {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Request is sent"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        [expectation fulfill];
        NSDictionary *json = [NSJSONSerialization
                              JSONObjectWithData:request.OHHTTPStubs_HTTPBody
                              options:0 error:nil];
        XCTAssertEqualObjects(json[@"email"], @"user@example.com");
        XCTAssertEqualObjects(json[@"device"][@"applicationName"], @"pushIntegration");
        XCTAssertEqualObjects(json[@"device"][@"platform"], @"APNS_SANDBOX");
        XCTAssertEqualObjects(json[@"device"][@"token"], [[@"token" dataUsingEncoding:kCFStringEncodingUTF8] ITEHexadecimalString]);
        return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:kCFStringEncodingUTF8] statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    IterableAPI.sharedInstance.sdkCompatEnabled = YES;
    [IterableAPI clearSharedInstance];
    IterableConfig *config = [[IterableConfig alloc] init];
    config.pushIntegrationName = @"pushIntegration";
    [IterableAPI initializeWithApiKey:@"apiKey" launchOptions:nil config:config];
    [[IterableAPI sharedInstance] setEmail:@"user@example.com"];
    [[IterableAPI sharedInstance] registerToken:[@"token" dataUsingEncoding:kCFStringEncodingUTF8]];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    [OHHTTPStubs removeAllStubs];
}

- (void)testEmailUserIdPersistence {
    IterableAPI.sharedInstance.sdkCompatEnabled = YES;
    [IterableAPI clearSharedInstance];
    [IterableAPI initializeWithApiKey:@"apiKey" launchOptions:nil];
    [[IterableAPI sharedInstance] setEmail:@"test@email.com"];
    
    IterableAPI.sharedInstance.sdkCompatEnabled = YES;
    [IterableAPI clearSharedInstance];
    [IterableAPI initializeWithApiKey:@"apiKey" launchOptions:nil];
    XCTAssertEqualObjects([IterableAPI sharedInstance].email, @"test@email.com");
    XCTAssertNil([IterableAPI sharedInstance].userId);
    
    [[IterableAPI sharedInstance] setUserId:@"testUserId"];
    IterableAPI.sharedInstance.sdkCompatEnabled = YES;
    [IterableAPI clearSharedInstance];
    [IterableAPI initializeWithApiKey:@"apiKey" launchOptions:nil];
    XCTAssertEqualObjects([IterableAPI sharedInstance].userId, @"testUserId");
    XCTAssertNil([IterableAPI sharedInstance].email);
}

@end
