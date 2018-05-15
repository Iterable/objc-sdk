//
//  IterableNotificationResponseTests.m
//  Iterable-iOS-SDKTests
//
//  Created by Victor Babenko on 5/14/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "IterableAppIntegration.h"
#import "IterableActionRunner.h"
#import "IterableAPI.h"

@interface IterableNotificationResponseTests : XCTestCase

@end

@implementation IterableNotificationResponseTests

- (void)setUp {
    [super setUp];
    [IterableAPI sharedInstanceWithApiKey:@"" andEmail:@"" launchOptions:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (UNNotificationResponse *)notificationResponseWithUserInfo:(NSDictionary *)userInfo actionIdentifier:(NSString *)actionIdentifier {
    UNNotification *notification = [UNNotification alloc];
    UNNotificationRequest *notificationRequest = [UNNotificationRequest alloc];
    UNNotificationContent *notificationContent = [UNNotificationContent alloc];
    UNNotificationResponse *notificationResponse = [UNNotificationResponse alloc];
    
    [notificationResponse setValue:actionIdentifier forKeyPath:@"actionIdentifier"];
    [notificationResponse setValue:notification forKeyPath:@"notification"];
    
    [notificationRequest setValue:[UNPushNotificationTrigger alloc] forKey:@"trigger"];
    
    [notification setValue:notificationRequest forKeyPath:@"request"];
    [notificationRequest setValue:notificationContent forKeyPath:@"content"];
    [notificationContent setValue:userInfo forKey:@"userInfo"];
    
    return notificationResponse;
}

- (void)testOpenPushWithCustomAction {
    id actionRunnerMock = OCMClassMock([IterableActionRunner class]);
    id apiMock = OCMPartialMock(IterableAPI.sharedInstance);
    
    NSDictionary *userInfo = @{
                               @"itbl": @{
                                   @"defaultAction": @{
                                           @"type": @"open",
                                           @"data": @"customAction"
                                           }
                                   }
                               };

    UNNotificationResponse *response = [self notificationResponseWithUserInfo:userInfo actionIdentifier:UNNotificationDefaultActionIdentifier];

    [IterableAppIntegration userNotificationCenter:nil didReceiveNotificationResponse:response withCompletionHandler:^{
        
    }];

    OCMVerify([actionRunnerMock executeAction:[OCMArg checkWithBlock:^BOOL(IterableAction *action) {
        XCTAssertEqual(action.type, IterableActionTypeOpen);
        XCTAssertEqual(action.data, @"customAction");
        return YES;
    }]]);
    
    OCMVerify([apiMock trackPushOpen:[OCMArg isNotNil] dataFields:[OCMArg isNotNil]]);
    
    [actionRunnerMock stopMocking];
    [apiMock stopMocking];
}

- (void)testActionButtonDismiss {
    id actionRunnerMock = OCMClassMock([IterableActionRunner class]);
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
    [apiMock stopMocking];
}


@end
