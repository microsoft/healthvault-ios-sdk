//
// MHVTimeTests.m
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <XCTest/XCTest.h>
#import "MHVTime.h"

@interface MHVTimeTests : XCTestCase

@end

@implementation MHVTimeTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEqualValues
{
    MHVTime *time1 = [[MHVTime alloc] initWithHour:10 minute:10];
    MHVTime *time2 = [[MHVTime alloc] initWithHour:10 minute:10];
    
    XCTAssertTrue([time1 isEqual:time2], @"Times should be equal");
    XCTAssertTrue(time1.hash == time2.hash, @"Hashes should be equal");
}

- (void)testDifferentValues
{
    MHVTime *time1 = [[MHVTime alloc] initWithHour:10 minute:10];
    MHVTime *time2 = [[MHVTime alloc] initWithHour:10 minute:9];
    
    XCTAssertFalse([time1 isEqual:time2], @"Times should not be equal");
    XCTAssertFalse(time1.hash == time2.hash, @"Hashes should not be equal");
}

- (void)testEqualValuesSeconds
{
    MHVTime *time1 = [[MHVTime alloc] initWithHour:12 minute:11 second:10];
    MHVTime *time2 = [[MHVTime alloc] initWithHour:12 minute:11 second:10];
    
    XCTAssertTrue([time1 isEqual:time2], @"Times should be equal");
    XCTAssertTrue(time1.hash == time2.hash, @"Hashes should be equal");
}

- (void)testDifferentValuesSeconds
{
    MHVTime *time1 = [[MHVTime alloc] initWithHour:12 minute:11 second:10];
    MHVTime *time2 = [[MHVTime alloc] initWithHour:12 minute:11 second:9];

    XCTAssertFalse([time1 isEqual:time2], @"Times should not be equal");
    XCTAssertFalse(time1.hash == time2.hash, @"Hashes should not be equal");
}

- (void)testEqualValuesMilliseconds
{
    MHVTime *time1 = [[MHVTime alloc] initWithHour:0 minute:0 second:0];
    MHVTime *time2 = [[MHVTime alloc] initWithHour:0 minute:0 second:0];
    [time1 setMillisecond:500];
    [time2 setMillisecond:500];
    
    XCTAssertTrue([time1 isEqual:time2], @"Times should be equal");
    XCTAssertTrue(time1.hash == time2.hash, @"Hashes should be equal");
}

- (void)testDifferentValuesMilliseconds
{
    MHVTime *time1 = [[MHVTime alloc] initWithHour:23 minute:59 second:59];
    MHVTime *time2 = [[MHVTime alloc] initWithHour:23 minute:59 second:59];
    [time1 setMillisecond:9998];
    [time2 setMillisecond:9999];
    
    XCTAssertFalse([time1 isEqual:time2], @"Times should not be equal");
    XCTAssertFalse(time1.hash == time2.hash, @"Hashes should not be equal");
}

@end
