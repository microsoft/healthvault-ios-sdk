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

@property (nonatomic, assign) BOOL wasCancelled;

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
- (void)cancel
{
    self.wasCancelled = YES;
}

@end

SPEC_BEGIN(MHVHttpTaskTests)

describe(@"MHVHttpTask", ^
{
    context(@"Progress", ^
            {
                MHVTestURLSessionTask *testSessionTask = [MHVTestURLSessionTask new];

                it(@"should be 0 if no tasks", ^
                   {
                       MHVHttpTask *httpTask = [[MHVHttpTask alloc] initWithURLSessionTask:nil];
                       
                       [[theValue(httpTask.progress) should] equal:@(0.0)];
                   });

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
    
    context(@"Cancel", ^
            {
                it(@"should cancel a single task", ^
                   {
                       MHVTestURLSessionTask *testSessionTask1 = [MHVTestURLSessionTask new];
                       
                       MHVHttpTask *httpTask = [[MHVHttpTask alloc] initWithURLSessionTask:testSessionTask1];
                       
                       [httpTask cancel];
                       
                       [[theValue(testSessionTask1.wasCancelled) should] beYes];
                   });

                it(@"should cancel multiple tasks", ^
                   {
                       MHVTestURLSessionTask *testSessionTask1 = [MHVTestURLSessionTask new];
                       MHVTestURLSessionTask *testSessionTask2 = [MHVTestURLSessionTask new];
                       
                       MHVHttpTask *httpTask = [[MHVHttpTask alloc] initWithURLSessionTask:testSessionTask1];
                       [httpTask addTask:testSessionTask2];
                       
                       [httpTask cancel];
                       
                       [[theValue(testSessionTask1.wasCancelled) should] beYes];
                       [[theValue(testSessionTask2.wasCancelled) should] beYes];
                   });
                
            });
});

SPEC_END
