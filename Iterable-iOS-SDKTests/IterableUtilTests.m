//
//  IterableUtilTests.m
//  Iterable-iOS-SDKTests
//
//  Created by Tapash Majumder on 5/29/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

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
    XCTAssertEqualWithAccuracy([NSDate date].timeIntervalSinceReferenceDate, IterableUtil.currentDate.timeIntervalSinceReferenceDate, 0.1);
}

- (void)testFutureDate {
    id utilMock = OCMClassMock([IterableUtil class]);
    OCMExpect([utilMock currentDate]).andReturn([NSDate dateWithTimeIntervalSinceNow:5*60]);
    XCTAssertNotEqualWithAccuracy([NSDate timeIntervalSinceReferenceDate], IterableUtil.currentDate.timeIntervalSinceReferenceDate, 0.1);
    
    // Stop mocking date
    [utilMock stopMocking];
    
    XCTAssertEqualWithAccuracy([NSDate timeIntervalSinceReferenceDate], IterableUtil.currentDate.timeIntervalSinceReferenceDate, 0.1);
    
}

@end
