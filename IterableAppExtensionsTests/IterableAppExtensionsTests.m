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
    [super tearDown];
    self.extension = nil;
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

}

/*
 * {
  "actionButtons": [
    {
      "actionIdentifier": "customInteralAppAction",
      "actionTitle": "Open App",
      "actionType": "actionOpen"
    },
    {
      "actionIdentifier": "http://maps.apple.com/?ll=37.7828,-122.3984",
      "actionTitle": "Open Maps",
      "actionType": "actionDeeplink"
    },
    {
      "actionIdentifier": "https://iterable.com/",
      "actionTitle": "Silent Action: Snooze",
      "actionType": "snooze",
      "silentNotification": "true"
    },
    {
      "actionIdentifier": "Chat",
      "actionTitle": "Ask support a question",
      "actionType": "textInput",
      "textInputString": "Type question here",
      "textInputTitle": "Send"
    }
  ],
  "defaultAction": {
    "actionIdentifier": "customInteralAppAction",
    "actionType": "actionOpen"
  }
}
 */

/*!
 @method
 
 @abstract Gets the list of InAppMessages
 
 @param count  the number of messages to fetch
 */
- (void)testPushDynamicCategory {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.userInfo = @{
                         @"itbl" : @{
                                 @"messageId": [[NSUUID UUID] UUIDString],
                                 @"actionButtons": @[@{
                                            @"actionIdentifier": @"openAppButton",
                                            @"title": @"Open App",
                                            @"actionType": @"open"
                                    }, @{
                                            @"actionIdentifier": @"dismissButton",
                                            @"title": @"Open Maps",
                                            @"actionType": @"dismiss",
                                            @"actionData": @"http://maps.apple.com/?ll=37.7828,-122.3984"
                                    }, @{
                                            @"actionIdentifier": @"customActionSnooze",
                                            @"title": @"Silent Action",
                                            @"actionType": @"silentAction"
                                    }, @{
                                            @"actionIdentifier": @"Chat",
                                            @"title": @"Text input",
                                            @"actionType": @"textInput",
                                            @"textInputString": @"Type text here",
                                            @"textInputTitle": @"Send"
                                    }]
                                 }
                         };
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"request" content:content trigger:nil];
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"contentHandler is called"];
    
    [self.extension didReceiveNotificationRequest:request withContentHandler:^(UNNotificationContent *contentToDeliver) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
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

- (void)testPushActionButtons {

}

@end
