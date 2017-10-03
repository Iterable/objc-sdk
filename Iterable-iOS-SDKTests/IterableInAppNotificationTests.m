//
//  IterableInAppNotificationTests.m
//  Iterable-iOS-SDK
//
//  Created by David Truong on 10/3/17.
//  Copyright © 2017 Iterable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IterableInAppHTMLViewController.h"
#import "IterableInAppHTMLViewController.h"

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

- (void)testNotificationCreation {
//call showIterableNotificationHTML with fake data
    //Check the top level dialog
    
    IterableInAppHTMLViewController *baseNotification;
//    baseNotification = [[IterableInAppHTMLViewController alloc] initWithData:htmlString];
//
//    
//    XCTAssertFalse([metadata isRealCampaignNotification]);
}

- (void)testNotificationPaddingFull {
    IterableInAppHTMLViewController *baseNotification;
    baseNotification = [[IterableInAppHTMLViewController alloc] initWithData:@""];
    
    INAPP_NOTIFICATION_TYPE notificationType = [IterableInAppHTMLViewController setLocation:UIEdgeInsetsMake(0,0,0,0)];
    
    XCTAssertEqual(notificationType, INAPP_FULL);
}

- (void)testNotificationPaddingTop {
    IterableInAppHTMLViewController *baseNotification;
    baseNotification = [[IterableInAppHTMLViewController alloc] initWithData:@""];
    
    INAPP_NOTIFICATION_TYPE notificationType = [IterableInAppHTMLViewController setLocation:UIEdgeInsetsMake(0,0,-1,0)];
    
    XCTAssertEqual(notificationType, INAPP_TOP);
}

- (void)testNotificationPaddingBottom {
    IterableInAppHTMLViewController *baseNotification;
    baseNotification = [[IterableInAppHTMLViewController alloc] initWithData:@""];
    
    INAPP_NOTIFICATION_TYPE notificationType = [IterableInAppHTMLViewController setLocation:UIEdgeInsetsMake(-1,0,0,0)];
    
    XCTAssertEqual(notificationType, INAPP_BOTTOM);
}

- (void)testNotificationPaddingCenter {
    IterableInAppHTMLViewController *baseNotification;
    baseNotification = [[IterableInAppHTMLViewController alloc] initWithData:@""];
    
    INAPP_NOTIFICATION_TYPE notificationType = [IterableInAppHTMLViewController setLocation:UIEdgeInsetsMake(-1,0,-1,0)];
    
    XCTAssertEqual(notificationType, INAPP_MIDDLE);
}

- (void)testNotificationPaddingDefault {
    IterableInAppHTMLViewController *baseNotification;
    baseNotification = [[IterableInAppHTMLViewController alloc] initWithData:@""];
    
    INAPP_NOTIFICATION_TYPE notificationType = [IterableInAppHTMLViewController setLocation:UIEdgeInsetsMake(10,0,20,0)];
    
    XCTAssertEqual(notificationType, INAPP_MIDDLE);
}


@end
