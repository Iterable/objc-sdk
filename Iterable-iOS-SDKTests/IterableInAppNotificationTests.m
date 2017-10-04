//
//  IterableInAppNotificationTests.m
//  Iterable-iOS-SDK
//
//  Created by David Truong on 10/3/17.
//  Copyright © 2017 Iterable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IterableInAppHTMLViewController.h"
#import "IterableInAppManager.h"

@interface IterableInAppNotificationTests : XCTestCase

@end

@implementation IterableInAppNotificationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testGetNextNotificationEmpty {
    NSDictionary *payload;
    NSDictionary *message = [IterableInAppManager getNextMessageFromPayload:payload];
    
    //Validate message
}

- (void)testGetNextNotificationOne {
    NSDictionary *payload;
    NSDictionary *message = [IterableInAppManager getNextMessageFromPayload:payload];
    
    //Validate message
}

- (void)testGetNextNotificationMany {
    NSDictionary *payload;
    NSDictionary *message = [IterableInAppManager getNextMessageFromPayload:payload];
    
    //Validate message
}

- (void)testNotificationCreation {
    //call showIterableNotificationHTML with fake data
    //Check the top level dialog
    
    IterableInAppHTMLViewController *baseNotification;
    //    baseNotification = [[IterableInAppHTMLViewController alloc] initWithData:htmlString];
    //
    //
    //    XCTAssertFalse([metadata isRealCampaignNotification]);
}

//Tests for get padding

//
//+(UIEdgeInsets)getPaddingFromPayload:(NSDictionary *)payload {
//    UIEdgeInsets padding = UIEdgeInsetsZero;
//    padding.top = [self decodePadding:[payload objectForKey:@"top"]];
//    padding.left = [self decodePadding:[payload objectForKey:@"left"]];
//    padding.bottom = [self decodePadding:[payload objectForKey:@"bottom"]];
//    padding.right = [self decodePadding:[payload objectForKey:@"right"]];
//    
//    return padding;
//}

//+(double)decodePadding:(NSObject *)value {
//    if ([@"AutoExpand" isEqualToString:[value valueForKey:@"displayOption"]]) {
//        return -1;
//    } else {
//        //TODO: do type check here
//        return [[value valueForKey:@"percentage"] doubleValue];
//    }
//}

- (void)testGetPaddingInvalid {
    NSString *payloadz = @"{ \"inAppDisplaySettings\": { \"top\": {}, \"right\": {}, \"bottom\": {}, \"left\": {} } } }";
    
    NSString *strData = payloadz;
    NSData *webData = [strData dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:webData options:0 error:&error];
    
    UIEdgeInsets insets = [IterableInAppManager getPaddingFromPayload:jsonDict];
    
    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero));
}

- (void)testGetPaddingFull {
    
    NSDictionary *payload = @{ @"top" : @{@"displayOption" : @"AutoExpand"}, @"left" : @{@"percentage" : @"0"}, @"bottom" : @{@"displayOption" : @"AutoExpand"}, @"right" : @{@"percentage" : @"0"}};
    
    UIEdgeInsets insets = [IterableInAppManager getPaddingFromPayload:payload];
    
    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsMake(-1, 0, -1, 0)));
    
    UIEdgeInsets padding = UIEdgeInsetsZero;
        padding.top = [IterableInAppManager decodePadding:[payload objectForKey:@"top"]];
        padding.left = [IterableInAppManager decodePadding:[payload objectForKey:@"left"]];
        padding.bottom = [IterableInAppManager decodePadding:[payload objectForKey:@"bottom"]];
        padding.right = [IterableInAppManager decodePadding:[payload objectForKey:@"right"]];

    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsMake(-1, 0, -1, 0)));
}


- (void)testDecodePadding:(NSObject *)object {
    //UIEdgeInsets padding = UIEdgeInsetsZero;
    //    padding.top = [self decodePadding:[payload objectForKey:@"top"]];
    //    padding.left = [self decodePadding:[payload objectForKey:@"left"]];
    //    padding.bottom = [self decodePadding:[payload objectForKey:@"bottom"]];
    //    padding.right = [self decodePadding:[payload objectForKey:@"right"]];
    
    //NSObject *object = ;
    int padding = [IterableInAppManager decodePadding:object];
    NSLog(@"%d", padding);
    //Validate message
    XCTAssertEqual(padding, 0);
}


- (void)testNotificationPaddingFull {
    INAPP_NOTIFICATION_TYPE notificationType = [IterableInAppHTMLViewController setLocation:UIEdgeInsetsMake(0,0,0,0)];
    XCTAssertEqual(notificationType, INAPP_FULL);
}

- (void)testNotificationPaddingTop {
    INAPP_NOTIFICATION_TYPE notificationType = [IterableInAppHTMLViewController setLocation:UIEdgeInsetsMake(0,0,-1,0)];
    XCTAssertEqual(notificationType, INAPP_TOP);
}

- (void)testNotificationPaddingBottom {
    INAPP_NOTIFICATION_TYPE notificationType = [IterableInAppHTMLViewController setLocation:UIEdgeInsetsMake(-1,0,0,0)];
    XCTAssertEqual(notificationType, INAPP_BOTTOM);
}

- (void)testNotificationPaddingCenter {
    INAPP_NOTIFICATION_TYPE notificationType = [IterableInAppHTMLViewController setLocation:UIEdgeInsetsMake(-1,0,-1,0)];
    XCTAssertEqual(notificationType, INAPP_MIDDLE);
}

- (void)testNotificationPaddingDefault {
    INAPP_NOTIFICATION_TYPE notificationType = [IterableInAppHTMLViewController setLocation:UIEdgeInsetsMake(10,0,20,0)];
    XCTAssertEqual(notificationType, INAPP_MIDDLE);
}


@end
