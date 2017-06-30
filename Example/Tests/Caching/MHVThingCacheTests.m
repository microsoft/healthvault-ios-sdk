//
//  MHVThingCacheTests.m
//  healthvault-ios-sdk
//
//  Created by Michael Burford on 6/28/17.
//  Copyright © 2017 namalu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MHVCommon.h"
#import "MHVThingCache.h"
#import "MHVThingCacheDatabaseProtocol.h"
#import "MHVKeychainService.h"
#import "Kiwi.h"

static NSString *kRecordOneUUID = @"11111111-1111-1111-1111-111111111111";
static NSString *kRecordTwoUUID = @"22222222-2222-2222-2222-222222222222";

SPEC_BEGIN(MHVThingCacheTests)

describe(@"MHVThingCache", ^
{
    __block NSString *paramNewRecordId;
    __block NSString *paramFetchRecordId;
    __block KWMock<MHVCachedRecord> *fetchCachedRecordReturn;
    
    MHVConfiguration *configuration = [[MHVConfiguration alloc] init];
    
    KWMock<MHVCachedRecord> *mockRecord = [KWMock mockForProtocol:@protocol(MHVCachedRecord)];
    KWMock<MHVConnectionProtocol> *mockConnection = [KWMock mockForProtocol:@protocol(MHVConnectionProtocol)];
    KWMock<MHVThingCacheDatabaseProtocol> *mockDatabase = [KWMock mockForProtocol:@protocol(MHVThingCacheDatabaseProtocol)];
    
    //Connection mocks
    [mockConnection stub:@selector(configuration) andReturn:configuration];
    
    //Database mocks
    [mockDatabase stub:@selector(newRecord:) withBlock:^id(NSArray *params)
     {
         paramNewRecordId = params[0];
         
         return mockRecord;
     }];
    
    [mockDatabase stub:@selector(deleteRecord:)];
    let(paramDeleteRecordSpy, ^
        {
            return [mockDatabase captureArgument:@selector(deleteRecord:) atIndex:0];
        });

    [mockDatabase stub:@selector(fetchCachedRecord:) withBlock:^id(NSArray *params)
     {
         paramFetchRecordId = params[0];
         
         return fetchCachedRecordReturn;
     }];
    [mockDatabase stub:@selector(fetchCachedRecords:) withBlock:^id(NSArray *params)
     {
         return nil;
     }];
    [mockDatabase stub:@selector(recordIdFromRecord:) withBlock:^id(NSArray *params)
     {
         return nil;
     }];
    [mockDatabase stub:@selector(lastSyncDateFromRecord:) withBlock:^id(NSArray *params)
     {
         return nil;
     }];
    [mockDatabase stub:@selector(lastSequenceNumberFromRecord:) withBlock:^id(NSArray *params)
     {
         return nil;
     }];
    
    let(thingCache, ^
    {
        return [[MHVThingCache alloc] initWithCacheDatabase:mockDatabase
                                                 connection:mockConnection];
    });

    beforeEach(^
               {
                   paramNewRecordId = nil;
                   paramFetchRecordId = nil;
                   fetchCachedRecordReturn = nil;
               });

//#pragma mark - Records
//    
//    context(@"when startSyncingForRecordId is called and no record exists", ^
//            {
//                beforeEach(^
//                           {
//                               [thingCache startSyncingForRecordId:[[NSUUID alloc] initWithUUIDString:kRecordOneUUID]
//                                                        completion:nil];
//                           });
//                
//                it(@"it should make new record in database", ^
//                   {
//                       [[expectFutureValue(paramNewRecordId) shouldEventually] equal:kRecordOneUUID];
//                   });
//            });
//    
//    context(@"when stopSyncingForRecordId is called", ^
//            {
//                beforeEach(^
//                           {
//                               [thingCache stopSyncingForRecordId:[[NSUUID alloc] initWithUUIDString:kRecordOneUUID]];
//                           });
//                
//                it(@"it should remove the record from database", ^
//                   {
//                       [[expectFutureValue(paramDeleteRecordSpy.argument) shouldEventually] equal:kRecordOneUUID];
//                   });
//            });
});

SPEC_END
