//
//  IterableAppExtensionsTests.m
//  IterableAppExtensionsTests
//
//  Created by Victor Babenko on 4/18/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ITBNotificationServiceExtension.h"

@interface IterableAppExtensionsTests : XCTestCase

@property (nonatomic) ITBNotificationServiceExtension *extension;

@end

@implementation IterableAppExtensionsTests

- (void)setUp {
    [super setUp];
    self.extension = [[ITBNotificationServiceExtension alloc] init];
}

- (void)tearDown {
    self.extension = nil;
    [super tearDown];
}

- (void)testPushIncorrectAttachemnt {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.userInfo = @{
                         @"itbl" : @{
                                 @"messageId": @"12345",
                                 @"attachment-url": @"Invalid URL!"
                                 }
                         };
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"request" content:content trigger:nil];
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"contentHandler is called"];
    
    [self.extension didReceiveNotificationRequest:request withContentHandler:^(UNNotificationContent *contentToDeliver) {
        XCTAssertEqual(contentToDeliver.attachments.count, 0);
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:5.0];
}

- (void)testPushImageAttachemnt {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.userInfo = @{
        @"itbl" : @{
            @"messageId": @"12345",
            @"attachment-url": @"https://iterable.com/wp-content/uploads/2016/12/Iterable_Logo_transparent-tight.png"
        }
    };
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"request" content:content trigger:nil];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"contentHandler is called"];

    [self.extension didReceiveNotificationRequest:request withContentHandler:^(UNNotificationContent *contentToDeliver) {
        XCTAssertEqual(contentToDeliver.attachments.count, 1);
        XCTAssertNotNil(contentToDeliver.attachments.firstObject.URL);
        XCTAssertEqualObjects(contentToDeliver.attachments.firstObject.URL.scheme, @"file");
        XCTAssertEqualObjects(contentToDeliver.attachments.firstObject.type, (NSString *)kUTTypePNG);
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:5.0];
}

- (void)testPushVideoAttachment {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.userInfo = @{
                         @"itbl" : @{
                                 @"messageId": @"12345",
                                 @"attachment-url": @"https://framework.realtime.co/blog/img/ios10-video.mp4"
                                 }
                         };
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"request" content:content trigger:nil];
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"contentHandler is called"];
    
    [self.extension didReceiveNotificationRequest:request withContentHandler:^(UNNotificationContent *contentToDeliver) {
        XCTAssertEqual(contentToDeliver.attachments.count, 1);
        XCTAssertNotNil(contentToDeliver.attachments.firstObject.URL);
        XCTAssertEqualObjects(contentToDeliver.attachments.firstObject.URL.scheme, @"file");
        XCTAssertEqualObjects(contentToDeliver.attachments.firstObject.type, (NSString *)kUTTypeMPEG4);
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:5.0];
}

- (void)testPushDynamicCategory {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.userInfo = @{
                         @"itbl" : @{
                                 @"messageId": [[NSUUID UUID] UUIDString],
                                 @"actionButtons": @[@{
                                            @"identifier": @"openAppButton",
                                            @"title": @"Open App",
                                            @"action": @{
                                                    @"type": @"open"
                                            }
                                    }, @{
                                            @"identifier": @"deeplinkButton",
                                            @"title": @"Open Deeplink",
                                            @"action": @{
                                                    @"type": @"deeplink",
                                                    @"data": @"http://maps.apple.com/?ll=37.7828,-122.3984"
                                            }
                                    }, @{
                                            @"identifier": @"silentActionButton",
                                            @"title": @"Silent Action",
                                            @"action": @{
                                                    @"type": @"dismiss",
                                                    @"data": @"customActionName"
                                            }
                                    }, @{
                                            @"identifier": @"textInputButton",
                                            @"title": @"Text input",
                                            @"action": @{
                                                    @"type": @"textInput",
                                                    @"inputTitle": @"Send",
                                                    @"inputPlaceholder": @"Type your message here"
                                            }
                                    }]
                                 }
                         };
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"request" content:content trigger:nil];
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"contentHandler is called"];
    
    [self.extension didReceiveNotificationRequest:request withContentHandler:^(UNNotificationContent *contentToDeliver) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
            [center getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> * _Nonnull categories) {
                UNNotificationCategory *createdCategory = nil;
                for (UNNotificationCategory *category in categories) {
                    if ([category.identifier isEqualToString:content.userInfo[@"itbl"][@"messageId"]])
                        createdCategory = category;
                }
                XCTAssertNotNil(createdCategory);
                
                NSArray *buttons = content.userInfo[@"itbl"][@"actionButtons"];
                XCTAssertEqual(createdCategory.actions.count, 4);
                for (int i = 0; i < 4; i++) {
                    XCTAssertEqualObjects(createdCategory.actions[i].title, buttons[i][@"title"]);
                }
                
                [expectation fulfill];
            }];
        });
    }];
    
    [self waitForExpectations:@[expectation] timeout:5.0];
}

- (void)testPushDestructiveActionButton {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.userInfo = @{
                         @"itbl" : @{
                                 @"messageId": [[NSUUID UUID] UUIDString],
                                 @"actionButtons": @[@{
                                                         @"identifier": @"destructiveButton",
                                                         @"title": @"Unsubscribe",
                                                         @"destructive": @YES,
                                                         @"action": @{
                                                                 @"type": @"open"
                                                                 }
                                                         }]
                                 }
                         };
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"request" content:content trigger:nil];
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"contentHandler is called"];
    
    [self.extension didReceiveNotificationRequest:request withContentHandler:^(UNNotificationContent *contentToDeliver) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
            [center getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> * _Nonnull categories) {
                UNNotificationCategory *createdCategory = nil;
                for (UNNotificationCategory *category in categories) {
                    if ([category.identifier isEqualToString:content.userInfo[@"itbl"][@"messageId"]])
                        createdCategory = category;
                }
                XCTAssertNotNil(createdCategory);
                
                XCTAssertEqual(createdCategory.actions.count, 1);
                XCTAssertTrue(createdCategory.actions.firstObject.options & UNNotificationActionOptionDestructive, "Action is destructive");
                
                [expectation fulfill];
            }];
        });
    }];
    
    [self waitForExpectations:@[expectation] timeout:5.0];
}

- (void)testPushActionButtons {

}

@end
