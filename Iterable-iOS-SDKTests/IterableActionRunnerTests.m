//
//  IterableActionRunnerTests.m
//  Iterable-iOS-SDKTests
//
//  Created by Victor Babenko on 5/14/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "IterableAPI.h"

@interface IterableActionRunnerTests : XCTestCase

@end

@implementation IterableActionRunnerTests

- (void)setUp {
    [super setUp];
    [IterableAPI sharedInstanceWithApiKey:@"" andEmail:@"" launchOptions:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    /*id actionRunnerMock = OCMClassMock([IterableActionRunner class]);
    id apiMock = OCMPartialMock(IterableAPI.sharedInstance);
    [IterableAPI sharedInstanceWithApiKey:@"" andEmail:@"" launchOptions:nil];
    
    NSDictionary *userInfo = @{
                               @"itbl": @{
                                       @"actionButtons": @[@{
                                                               @"identifier": @"buttonIdentifier",
                                                               @"action": @{
                                                                       @"type": @"dismiss",
                                                                       @"data": @"customAction"
                                                                       }
                                                               }]
                                       }
                               };
    
    UNNotificationResponse *response = [self notificationResponseWithUserInfo:userInfo actionIdentifier:@"buttonIdentifier"];
    
    [IterableAppIntegration userNotificationCenter:nil didReceiveNotificationResponse:response withCompletionHandler:^{
        
    }];
    
    OCMVerify([actionRunnerMock executeAction:[OCMArg checkWithBlock:^BOOL(IterableAction *action) {
        XCTAssertEqual(action.type, IterableActionTypeDismiss);
        XCTAssertEqual(action.data, @"customAction");
        return YES;
    }]]);
    
    OCMVerify([apiMock trackPushOpen:[OCMArg isNotNil] dataFields:[OCMArg isNotNil]]);
    
    [actionRunnerMock stopMocking];
    [apiMock stopMocking];*/
}

@end
