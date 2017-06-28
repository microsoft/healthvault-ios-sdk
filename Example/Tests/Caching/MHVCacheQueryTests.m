//
//  MHVCacheQueryTests.m
//  healthvault-ios-sdk
//
//  Created by Nathan Malubay on 6/28/17.
//  Copyright © 2017 namalu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Kiwi.h"

SPEC_BEGIN(MHVCacheQueryTests)

describe(@"MHVCacheQuery", ^
{
    __block MHVCacheQuery *cacheQuery;
    __block MHVThingQuery *thingQuery;
    
    beforeEach(^
    {
        cacheQuery = nil;
        thingQuery = nil;
    });
    
    context(@"when initialized with a nil query", ^
    {
        beforeEach(^
        {
            MHVThingQuery *thingQuery = nil;
            
            cacheQuery = [[MHVCacheQuery alloc] initWithQuery:thingQuery];
        });
        
        it(@"should set the error property to a detailed error", ^
           {
               [[cacheQuery.error should] beNonNil];
               [[cacheQuery.error.localizedDescription should] equal:@"MHVThingCacheQuery was initialized with a nil query parameter."];
           });
        
        it(@"should have a nil predicate property", ^
           {
               [[cacheQuery.predicate should] beNil];
           });
        
        it(@"should set the canQueryCache property to NO", ^
           {
               [[theValue(cacheQuery.canQueryCache) should] beFalse];
           });
        
    });
    
    context(@"when initialized with an invalid query", ^
    {
        beforeEach(^
        {
            MHVThingQuery *thingQuery = [MHVThingQuery new];
            
            [thingQuery.thingIDs addObject:@"TEST_THING_ID"];
            [thingQuery.clientIDs addObject:@"TEST_CLIENT_ID"];
            
            cacheQuery = [[MHVCacheQuery alloc] initWithQuery:thingQuery];
        });
        
        it(@"should set the error property to a detailed error", ^
           {
               [[cacheQuery.error should] beNonNil];
               [[cacheQuery.error.localizedDescription should] equal:@"thingIDs, keys, and clientIDs are mutually exclusive. Only one of these collections can contain elements for a given query."];
           });
        
        it(@"should have a nil predicate property", ^
           {
               [[cacheQuery.predicate should] beNil];
           });
        
        it(@"should set the canQueryCache property to NO", ^
           {
               [[theValue(cacheQuery.canQueryCache) should] beFalse];
           });
        
    });
    
    context(@"when initialized with a query containing a filter with the xpath property set", ^
    {
        beforeEach(^
                   {
                       MHVThingFilter *filter = [MHVThingFilter new];
                       filter.xpath = @"/thing/data-xml";
                       
                       MHVThingQuery *thingQuery = [[MHVThingQuery alloc] initWithFilter:filter];
                       
                       cacheQuery = [[MHVCacheQuery alloc] initWithQuery:thingQuery];
                   });
        
        it(@"should have a nil error property", ^
           {
               [[cacheQuery.error should] beNil];
           });
        
        it(@"should have a nil predicate property", ^
           {
               [[cacheQuery.predicate should] beNil];
           });
        
        it(@"should set the canQueryCache property to NO", ^
           {
               [[theValue(cacheQuery.canQueryCache) should] beFalse];
           });
        
    });
    
    context(@"when initialized with a query containing a view with non standard sections", ^
    {
        beforeEach(^
                   {
                       MHVThingQuery *thingQuery = [MHVThingQuery new];
                       thingQuery.view.sections = MHVThingSection_Blobs;
                       
                       cacheQuery = [[MHVCacheQuery alloc] initWithQuery:thingQuery];
                   });
        
        it(@"should have a nil error property", ^
           {
               [[cacheQuery.error should] beNil];
           });
        
        it(@"should have a nil predicate property", ^
           {
               [[cacheQuery.predicate should] beNil];
           });
        
        it(@"should set the canQueryCache property to NO", ^
           {
               [[theValue(cacheQuery.canQueryCache) should] beFalse];
           });
        
    });
    
    context(@"when initialized with a query containing a view with transforms", ^
    {
        beforeEach(^
                   {
                       MHVThingQuery *thingQuery = [MHVThingQuery new];
                       [thingQuery.view.transforms addObject:@"TEST_TRANSFORM"];
                       
                       cacheQuery = [[MHVCacheQuery alloc] initWithQuery:thingQuery];
                   });
        
        it(@"should have a nil error property", ^
           {
               [[cacheQuery.error should] beNil];
           });
        
        it(@"should have a nil predicate property", ^
           {
               [[cacheQuery.predicate should] beNil];
           });
        
        it(@"should set the canQueryCache property to NO", ^
           {
               [[theValue(cacheQuery.canQueryCache) should] beFalse];
           });
        
    });
    
    context(@"when initialized with a query containing a view with typeVersions", ^
    {
        beforeEach(^
                   {
                       MHVThingQuery *thingQuery = [MHVThingQuery new];
                       [thingQuery.view.typeVersions addObject:@"1.1.1.1"];
                       
                       cacheQuery = [[MHVCacheQuery alloc] initWithQuery:thingQuery];
                   });
        
        it(@"should have a nil error property", ^
           {
               [[cacheQuery.error should] beNil];
           });
        
        it(@"should have a nil predicate property", ^
           {
               [[cacheQuery.predicate should] beNil];
           });
        
        it(@"should set the canQueryCache property to NO", ^
           {
               [[theValue(cacheQuery.canQueryCache) should] beFalse];
           });
        
    });
    
    context(@"when initialized with a filter that has no properties set", ^
    {
        beforeEach(^
        {
            MHVThingQuery *thingQuery = [[MHVThingQuery alloc] initWithFilter:[MHVThingFilter new]];
            
            cacheQuery = [[MHVCacheQuery alloc] initWithQuery:thingQuery];
        });
        
        it(@"should have a vaild predicate", ^
           {
               [[cacheQuery.predicate should] beNonNil];
               [[cacheQuery.predicate.predicateFormat should] equal:@"TRUEPREDICATE"];
           });
        
        it(@"should have a nil error property", ^
           {
               [[cacheQuery.error should] beNil];
           });
        
        it(@"should set the canQueryCache property to YES", ^
           {
               [[theValue(cacheQuery.canQueryCache) should] beTrue];
           });
    });
    
    context(@"when initialized with a filter that has multiple properties set", ^
    {
        beforeEach(^
        {
            MHVThingFilter *filter = [MHVThingFilter new];
            filter.effectiveDateMin = [NSDate dateWithTimeIntervalSince1970:0];
            filter.effectiveDateMax = [NSDate dateWithTimeIntervalSince1970:60*60*24*365];
            filter.createdByAppID = @"TEST_APP_ID";
            filter.createdByPersonID = @"TEST_PERSON_ID";
            
            MHVThingQuery *thingQuery = [[MHVThingQuery alloc] initWithFilter:filter];
            
            cacheQuery = [[MHVCacheQuery alloc] initWithQuery:thingQuery];
        });
        
        it(@"should have a vaild predicate", ^
           {
               [[cacheQuery.predicate should] beNonNil];
               [[cacheQuery.predicate.predicateFormat should] equal:@"effectiveDate >=[c] CAST(-978307200.000000, \"NSDate\") AND effectiveDate <=[c] CAST(-946771200.000000, \"NSDate\") AND createdByAppID ==[c] \"TEST_APP_ID\" AND createdByPersonID ==[c] \"TEST_PERSON_ID\""];
           });
        
        it(@"should have a nil error property", ^
           {
               [[cacheQuery.error should] beNil];
           });
        
        it(@"should set the canQueryCache property to YES", ^
           {
               [[theValue(cacheQuery.canQueryCache) should] beTrue];
           });
    });
    
    context(@"when initialized with multiple filters that have multiple properties set", ^
    {
        beforeEach(^
        {
            MHVThingFilter *filter1 = [MHVThingFilter new];
            filter1.effectiveDateMin = [NSDate dateWithTimeIntervalSince1970:0];
            filter1.effectiveDateMax = [NSDate dateWithTimeIntervalSince1970:60*60*24*365];
            filter1.createdByAppID = @"TEST_APP_ID_1";
            filter1.createdByPersonID = @"TEST_PERSON_ID_1";
            
            MHVThingFilter *filter2 = [MHVThingFilter new];
            filter2.updateDateMin = [NSDate dateWithTimeIntervalSince1970:0];
            filter2.updateDateMax = [NSDate dateWithTimeIntervalSince1970:60*60*24*365];
            filter2.updatedByAppID = @"TEST_APP_ID_2";
            filter2.updatedByPersonID = @"TEST_PERSON_ID_2";
            
            MHVThingFilterCollection *filters = [[MHVThingFilterCollection alloc] initWithArray:@[filter1, filter2]];
            
            MHVThingQuery *thingQuery = [[MHVThingQuery alloc] initWithFilters:filters];
            
            cacheQuery = [[MHVCacheQuery alloc] initWithQuery:thingQuery];
        });
        
        it(@"should have a vaild predicate", ^
           {
               [[cacheQuery.predicate should] beNonNil];
               [[cacheQuery.predicate.predicateFormat should] equal:@"(effectiveDate >=[c] CAST(-978307200.000000, \"NSDate\") AND effectiveDate <=[c] CAST(-946771200.000000, \"NSDate\") AND createdByAppID ==[c] \"TEST_APP_ID_1\" AND createdByPersonID ==[c] \"TEST_PERSON_ID_1\") OR (updatedByAppID ==[c] \"TEST_APP_ID_2\" AND updatedByPersonID ==[c] \"TEST_PERSON_ID_2\" AND updateDate >=[c] CAST(-978307200.000000, \"NSDate\") AND updateDate <=[c] CAST(-946771200.000000, \"NSDate\"))"];
           });
        
        it(@"should have a nil error property", ^
           {
               [[cacheQuery.error should] beNil];
           });
        
        it(@"should set the canQueryCache property to YES", ^
           {
               [[theValue(cacheQuery.canQueryCache) should] beTrue];
           });
    });
    
    context(@"when initialized with a single thing id", ^
    {
        beforeEach(^
        {
            MHVThingQuery *thingQuery = [[MHVThingQuery alloc] initWithThingID:@"TEST_THING_ID"];
            
            cacheQuery = [[MHVCacheQuery alloc] initWithQuery:thingQuery];
        });
        
        it(@"should have a vaild predicate", ^
           {
               [[cacheQuery.predicate should] beNonNil];
               [[cacheQuery.predicate.predicateFormat should] equal:@"thingId ==[c] \"TEST_THING_ID\""];
           });
        
        it(@"should have a nil error property", ^
           {
               [[cacheQuery.error should] beNil];
           });
        
        it(@"should set the canQueryCache property to YES", ^
           {
               [[theValue(cacheQuery.canQueryCache) should] beTrue];
           });
    });
    
    context(@"when initialized with a collection of thing id", ^
    {
        beforeEach(^
        {
            MHVStringCollection *collection = [[MHVStringCollection alloc] initWithArray:@[@"TEST_THING_ID_1", @"TEST_THING_ID_2", @"TEST_THING_ID_3"]];
            
            MHVThingQuery *thingQuery = [[MHVThingQuery alloc] initWithThingIDs:collection];
            
            cacheQuery = [[MHVCacheQuery alloc] initWithQuery:thingQuery];
        });
        
        it(@"should have a vaild predicate", ^
           {
               [[cacheQuery.predicate should] beNonNil];
               [[cacheQuery.predicate.predicateFormat should] equal:@"thingId ==[c] \"TEST_THING_ID_1\" OR thingId ==[c] \"TEST_THING_ID_2\" OR thingId ==[c] \"TEST_THING_ID_3\""];
           });
        
        it(@"should have a nil error property", ^
           {
               [[cacheQuery.error should] beNil];
           });
        
        it(@"should set the canQueryCache property to YES", ^
           {
               [[theValue(cacheQuery.canQueryCache) should] beTrue];
           });
    });
    
    context(@"when initialized with a single thing key", ^
    {
        beforeEach(^
        {
            MHVThingKey *key = [[MHVThingKey alloc] initWithID:@"TEST_THING_ID" andVersion:@"1.1.1.1"];
            
            MHVThingQuery *thingQuery = [[MHVThingQuery alloc] initWithThingKey:key];
            
            cacheQuery = [[MHVCacheQuery alloc] initWithQuery:thingQuery];
        });
        
        it(@"should have a vaild predicate", ^
           {
               [[cacheQuery.predicate should] beNonNil];
               [[cacheQuery.predicate.predicateFormat should] equal:@"thingId ==[c] \"TEST_THING_ID\" AND version ==[c] \"1.1.1.1\""];
           });
        
        it(@"should have a nil error property", ^
           {
               [[cacheQuery.error should] beNil];
           });
        
        it(@"should set the canQueryCache property to YES", ^
           {
               [[theValue(cacheQuery.canQueryCache) should] beTrue];
           });
    });
    
    context(@"when initialized with a multiple thing keys", ^
    {
        beforeEach(^
        {
            MHVThingKey *key1 = [[MHVThingKey alloc] initWithID:@"TEST_THING_ID_1" andVersion:@"1.1.1.1"];
            MHVThingKey *key2 = [[MHVThingKey alloc] initWithID:@"TEST_THING_ID_2" andVersion:@"2.2.2.2"];
            MHVThingKey *key3 = [[MHVThingKey alloc] initWithID:@"TEST_THING_ID_3" andVersion:@"3.3.3.3"];
            
            MHVThingKeyCollection *keys = [[MHVThingKeyCollection alloc] initWithArray:@[key1, key2, key3]];
            
            MHVThingQuery *thingQuery = [[MHVThingQuery alloc] initWithThingKeys:keys];
            
            cacheQuery = [[MHVCacheQuery alloc] initWithQuery:thingQuery];
        });
        
        it(@"should have a vaild predicate", ^
           {
               [[cacheQuery.predicate should] beNonNil];
               [[cacheQuery.predicate.predicateFormat should] equal:@"(thingId ==[c] \"TEST_THING_ID_1\" AND version ==[c] \"1.1.1.1\") OR (thingId ==[c] \"TEST_THING_ID_2\" AND version ==[c] \"2.2.2.2\") OR (thingId ==[c] \"TEST_THING_ID_3\" AND version ==[c] \"3.3.3.3\")"];
           });
        
        it(@"should have a nil error property", ^
           {
               [[cacheQuery.error should] beNil];
           });
        
        it(@"should set the canQueryCache property to YES", ^
           {
               [[theValue(cacheQuery.canQueryCache) should] beTrue];
           });
    });
    
    context(@"when initialized with a multiple thing keys and multiple filters", ^
    {
        beforeEach(^
        {
            MHVThingKey *key1 = [[MHVThingKey alloc] initWithID:@"TEST_THING_ID_1" andVersion:@"1.1.1.1"];
            MHVThingKey *key2 = [[MHVThingKey alloc] initWithID:@"TEST_THING_ID_2" andVersion:@"2.2.2.2"];
            MHVThingKey *key3 = [[MHVThingKey alloc] initWithID:@"TEST_THING_ID_3" andVersion:@"3.3.3.3"];
            
            MHVThingFilter *filter1 = [MHVThingFilter new];
            filter1.effectiveDateMin = [NSDate dateWithTimeIntervalSince1970:0];
            filter1.effectiveDateMax = [NSDate dateWithTimeIntervalSince1970:60*60*24*365];
            filter1.createdByAppID = @"TEST_APP_ID_1";
            filter1.createdByPersonID = @"TEST_PERSON_ID_1";
            
            MHVThingFilter *filter2 = [[MHVThingFilter alloc] initWithTypeID:@"TEST_TYPE_ID_1"];
            filter2.createDateMin = [NSDate dateWithTimeIntervalSince1970:0];
            filter2.createDateMax = [NSDate dateWithTimeIntervalSince1970:60*60*24*365];
            [filter2.typeIDs addObject:@"TEST_TYPE_ID_2"];
            
            MHVThingKeyCollection *keys = [[MHVThingKeyCollection alloc] initWithArray:@[key1, key2, key3]];
            
            MHVThingQuery *thingQuery = [[MHVThingQuery alloc] initWithThingKeys:keys];
            
            [thingQuery.filters addObjectsFromArray:@[filter1, filter2]];
            
            cacheQuery = [[MHVCacheQuery alloc] initWithQuery:thingQuery];
        });
        
        it(@"should have a vaild predicate", ^
           {
               [[cacheQuery.predicate should] beNonNil];
               [[cacheQuery.predicate.predicateFormat should] equal:@"((thingId ==[c] \"TEST_THING_ID_1\" AND version ==[c] \"1.1.1.1\") OR (thingId ==[c] \"TEST_THING_ID_2\" AND version ==[c] \"2.2.2.2\") OR (thingId ==[c] \"TEST_THING_ID_3\" AND version ==[c] \"3.3.3.3\")) AND ((effectiveDate >=[c] CAST(-978307200.000000, \"NSDate\") AND effectiveDate <=[c] CAST(-946771200.000000, \"NSDate\") AND createdByAppID ==[c] \"TEST_APP_ID_1\" AND createdByPersonID ==[c] \"TEST_PERSON_ID_1\") OR ((typeId ==[c] \"TEST_TYPE_ID_1\" OR typeId ==[c] \"TEST_TYPE_ID_2\") AND createDate >=[c] CAST(-978307200.000000, \"NSDate\") AND createDate <=[c] CAST(-946771200.000000, \"NSDate\")))"];
           });
        
        it(@"should have a nil error property", ^
           {
               [[cacheQuery.error should] beNil];
           });
        
        it(@"should set the canQueryCache property to YES", ^
           {
               [[theValue(cacheQuery.canQueryCache) should] beTrue];
           });
    });
    
    context(@"when the maxResults property is set on the thing query", ^
    {
        beforeEach(^
        {
            MHVThingQuery *thingQuery = [[MHVThingQuery alloc] initWithThingID:@"TEST_THING_ID"];
            thingQuery.maxResults = 50;
            
            cacheQuery = [[MHVCacheQuery alloc] initWithQuery:thingQuery];
        });
        
        it(@"should set the fetchLimit property", ^
           {
               [[theValue(cacheQuery.fetchLimit) should] equal:theValue(50)];
           });
        
        it(@"should set the canQueryCache property to YES", ^
           {
               [[theValue(cacheQuery.canQueryCache) should] beTrue];
           });
    });
    
    context(@"when the maxResults property is not set on the thing query", ^
    {
        beforeEach(^
        {
            MHVThingQuery *thingQuery = [[MHVThingQuery alloc] initWithThingID:@"TEST_THING_ID"];
            
            cacheQuery = [[MHVCacheQuery alloc] initWithQuery:thingQuery];
        });
        
        it(@"should set the fetchLimit property", ^
           {
               [[theValue(cacheQuery.fetchLimit) should] equal:theValue(-1)];
           });
        
        it(@"should set the canQueryCache property to YES", ^
           {
               [[theValue(cacheQuery.canQueryCache) should] beTrue];
           });
    });
});

SPEC_END
