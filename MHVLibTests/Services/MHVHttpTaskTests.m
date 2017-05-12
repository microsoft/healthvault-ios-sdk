//
//  MHVHttpTaskTests.m
//  MHVLib
//
//  Created by Michael Burford on 5/11/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MHVHttpTask.h"
#import "Kiwi.h"

@interface MHVTestURLSessionTask : NSURLSessionTask

@end

@implementation MHVTestURLSessionTask

// Can't mock the int64_t return values, so subclass NSURLSessionTask and override
- (int64_t)countOfBytesSent
{
    return 50;
}
- (int64_t)countOfBytesExpectedToSend
{
    return 100;
}
- (int64_t)countOfBytesReceived
{
    return 1000;
}
- (int64_t)countOfBytesExpectedToReceive
{
    return 2000;
}

@end

SPEC_BEGIN(MHVHttpTaskTests)

describe(@"MHVHttpTask", ^
{
    context(@"Progress", ^
            {
                MHVTestURLSessionTask *testSessionTask = [MHVTestURLSessionTask new];

                it(@"should be calculated from task sizes", ^
                   {
                       MHVHttpTask *httpTask = [[MHVHttpTask alloc] initWithURLSessionTask:testSessionTask];
                       
                       [[theValue(httpTask.progress) should] equal:@(0.5)];
                   });

                it(@"should be calculated from total size and bytes sent", ^
                   {
                       MHVHttpTask *httpTask = [[MHVHttpTask alloc] initWithURLSessionTask:testSessionTask totalSize:200];
                       
                       [[theValue(httpTask.progress) should] equal:@(0.25)];
                   });
            });
});

SPEC_END
