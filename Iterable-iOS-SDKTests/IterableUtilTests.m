//
//  IterableUtilTests.m
//  Iterable-iOS-SDKTests
//
//  Created by Tapash Majumder on 5/29/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "IterableUtil.h"

@interface IterableUtilTests : XCTestCase

@end

@implementation IterableUtilTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCurrentDate {
    XCTAssertEqualWithAccuracy([NSDate date].timeIntervalSinceReferenceDate, IterableUtil.sharedInstance.currentDate.timeIntervalSinceReferenceDate, 0.001);
}

- (void)testFutureDate {
    NSDate *currentDate = [NSDate date];
    IterableUtil.sharedInstance.currentDate = [currentDate dateByAddingTimeInterval:5*60];
    XCTAssertNotEqualWithAccuracy(currentDate.timeIntervalSinceReferenceDate, IterableUtil.sharedInstance.currentDate.timeIntervalSinceReferenceDate, 0.001);
    
    // now set to null
    IterableUtil.sharedInstance.currentDate = nil;
    XCTAssertEqualWithAccuracy(currentDate.timeIntervalSinceReferenceDate, IterableUtil.sharedInstance.currentDate.timeIntervalSinceReferenceDate, 0.001);
}

@end
