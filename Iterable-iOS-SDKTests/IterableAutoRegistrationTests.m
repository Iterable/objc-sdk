//
//  IterableAutoRegistrationTests.m
//  Iterable-iOS-SDKTests
//
//  Created by Victor Babenko on 8/15/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "IterableTestUtils.h"
#import "IterableUtil.h"
#import "IterableAPI.h"

@interface IterableAutoRegistrationTests : XCTestCase

@end

@implementation IterableAutoRegistrationTests {
    id utilMock;
    id applicationMock;
    IterableAPI *apiMock;
    IterableConfig *config;
}

- (void)setUp {
    [super setUp];
    [IterableTestUtils clearApiInstance];
    [IterableTestUtils resetUserDefaults];
    utilMock = OCMClassMock([IterableUtil class]);
    applicationMock = OCMPartialMock([UIApplication sharedApplication]);
    config = [[IterableConfig alloc] init];
}

- (void)tearDown {
    [super tearDown];

    [utilMock stopMocking];
    [applicationMock stopMocking];
}

- (void)initIterableApi {
    [IterableTestUtils clearApiInstance];
    [IterableAPI initializeWithApiKey:@"apiKey" launchOptions:nil config:config];
    apiMock = [OCMockObject partialMockForObject:IterableAPI.sharedInstance];
}

- (void)testSetEmailWithAutomaticPushRegistration {
    OCMExpect([utilMock hasNotificationPermissionWithCallback:([OCMArg invokeBlockWithArgs:@YES, nil])]);
    config.autoPushRegistration = YES;
    [self initIterableApi];

    // Check that setEmail calls registerForRemoteNotifications
    OCMExpect([applicationMock registerForRemoteNotifications]);
    [IterableAPI.sharedInstance setEmail:@"test@email.com"];
    OCMVerifyAllWithDelay(applicationMock, 0.1);
    
    // Check that setEmail:nil disables the device
    [IterableAPI.sharedInstance setEmail:nil];
    OCMVerify([apiMock disableDeviceForCurrentUser]);
}

- (void)testSetEmailWithoutAutomaticPushRegistration {
    OCMExpect([utilMock hasNotificationPermissionWithCallback:([OCMArg invokeBlockWithArgs:@YES, nil])]);
    config.autoPushRegistration = NO;
    [self initIterableApi];

    // Check that setEmail doesn't call registerForRemoteNotifications or disableDeviceForCurrentUser
    OCMReject([applicationMock registerForRemoteNotifications]);
    OCMReject([apiMock disableDeviceForCurrentUser]);
    [IterableAPI.sharedInstance setEmail:@"test@email.com"];
    [IterableAPI.sharedInstance setEmail:nil];
}

- (void)testSetUserIdWithAutomaticPushRegistration {
    OCMExpect([utilMock hasNotificationPermissionWithCallback:([OCMArg invokeBlockWithArgs:@YES, nil])]);
    config.autoPushRegistration = YES;
    [self initIterableApi];

    // Check that setUserId calls registerForRemoteNotifications
    OCMExpect([applicationMock registerForRemoteNotifications]);
    [IterableAPI.sharedInstance setUserId:@"userId"];
    OCMVerifyAllWithDelay(applicationMock, 0.1);

    // Check that setUserId:nil disables the device
    [IterableAPI.sharedInstance setUserId:nil];
    OCMVerify([apiMock disableDeviceForCurrentUser]);
}

- (void)testSetUserIdWithoutAutomaticPushRegistration {
    OCMExpect([utilMock hasNotificationPermissionWithCallback:([OCMArg invokeBlockWithArgs:@YES, nil])]);
    config.autoPushRegistration = NO;
    [self initIterableApi];

    // Check that setUserId doesn't call registerForRemoteNotifications or disableDeviceForCurrentUser
    OCMReject([applicationMock registerForRemoteNotifications]);
    OCMReject([apiMock disableDeviceForCurrentUser]);
    [IterableAPI.sharedInstance setUserId:@"userId"];
    [IterableAPI.sharedInstance setUserId:nil];
}

- (void)testNoAutomaticRegistrationWithoutPermissions {
    OCMExpect([utilMock hasNotificationPermissionWithCallback:([OCMArg invokeBlockWithArgs:@NO, nil])]);
    config.autoPushRegistration = YES;
    [self initIterableApi];
    
    OCMReject([applicationMock registerForRemoteNotifications]);
    [IterableAPI.sharedInstance setEmail:@"test@email.com"];
}

- (void)testAutomaticPushRegistrationOnInit {
    [applicationMock stopMocking];
    OCMExpect([utilMock hasNotificationPermissionWithCallback:([OCMArg invokeBlockWithArgs:@YES, nil])]);
    config.autoPushRegistration = YES;
    [self initIterableApi];
    [IterableAPI.sharedInstance setEmail:@"test@email.com"];
    
    applicationMock = OCMPartialMock([UIApplication sharedApplication]);
    OCMExpect([applicationMock registerForRemoteNotifications]);
    [self initIterableApi];
    OCMVerifyAllWithDelay(applicationMock, 0.1);
}



@end
