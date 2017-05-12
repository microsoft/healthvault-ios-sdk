//
//  MHVTypeViewRefresher.m
//  MHVLib
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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
//
//
#import "MHVCommon.h"
#import "MHVClient.h"
#import "MHVTypeViewRefresher.h"
#import "MHVSynchronizedType.h"

@interface MHVMultipleTypeViewRefresher (MHVPrivate)

-(BOOL) initViewList:(NSArray *) views;
-(MHVItemQueryCollection *) collectQueriesForRefreshableViews;
-(BOOL) shouldRefreshView:(id<MHVTypeView>) view;
-(void) refreshComplete:(MHVGetItemsTask *) task;

@end

@implementation MHVMultipleTypeViewRefresher

@synthesize maxAge = m_maxAge;

-(id)init
{
    return [self initWithRecord:nil views:nil andMaxAge:0];
}

-(id)initWithRecord:(MHVRecordReference *)record views:(NSArray *)views andMaxAge:(NSTimeInterval)age
{
    MHVCHECK_NOTNULL(record);
    MHVCHECK_NOTNULL(views);
    
    self = [super init];
    MHVCHECK_SELF;
    
    MHVCHECK_SUCCESS([self initViewList:views]);
    m_record = record;
    m_maxAge = age;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithRecordStore:(MHVLocalRecordStore *)store synchronizedTypeIDs:(NSArray *)typeIDs andMaxAge:(NSTimeInterval)age
{
    MHVCHECK_NOTNULL(store);
    MHVCHECK_NOTNULL(typeIDs);
    
    NSMutableArray* views = [[NSMutableArray alloc] init];
    MHVCHECK_NOTNULL(views);
    
    for (NSString* typeID in typeIDs)
    {
        id<MHVTypeView> view = [store getSynchronizedTypeForTypeID:typeID];
        if (views)
        {
            [views addObject:view];
        }
    }
    return [self initWithRecord:store.record views:views andMaxAge:age];
    
LError:
    MHVALLOC_FAIL;
}


-(MHVTask *)refreshWithCallback:(MHVTaskCompletion)callback
{
    MHVItemQueryCollection* queries = [self collectQueriesForRefreshableViews];
    if ([MHVCollection isNilOrEmpty:queries])
    {
        // Nothing to refresh
        return nil;
    }
    
    MHVTask* refreshTask = [[MHVTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(refreshTask);
    
    MHVGetItemsTask* getItems = [[[MHVClient current] methodFactory] newGetItemsForRecord:m_record queries:queries andCallback:^(MHVTask *task)
    {
        [self refreshComplete:(MHVGetItemsTask *) task];
    }];
    
    MHVCHECK_NOTNULL(getItems);
    [refreshTask setNextTask:getItems];
    
    [refreshTask start];
    
    return refreshTask;

LError:
    return nil;
}

@end

@implementation MHVMultipleTypeViewRefresher (MHVPrivate)

-(BOOL)initViewList:(NSArray *)views
{
    m_views = [[NSMutableDictionary alloc] init];
    MHVCHECK_NOTNULL(m_views);
    
    for (NSUInteger i = 0, count = views.count; i < count; ++i)
    {
        id<MHVTypeView> view = [views objectAtIndex:i];
        NSString* viewName = [NSString stringWithFormat:@"View_%lu", (unsigned long)i];
        MHVCHECK_NOTNULL(viewName);
        
        [m_views setObject:view forKey:viewName];
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(MHVItemQueryCollection *)collectQueriesForRefreshableViews
{
    MHVItemQueryCollection* queries = nil;
    for (NSString* viewName in m_views.keyEnumerator)
    {
        id<MHVTypeView> view = [m_views objectForKey:viewName];
        if (![self shouldRefreshView:view])
        {
            continue;
        }
        
        if (!queries)
        {
            queries = [[MHVItemQueryCollection alloc] init];
            MHVCHECK_NOTNULL(queries);
        }
        
        MHVItemQuery* refreshQuery = [view getQuery];
        MHVCHECK_NOTNULL(refreshQuery);
        
        refreshQuery.name = viewName;
        [queries addObject:refreshQuery];
    }
    
    return queries;
    
LError:
    return nil;
}

-(BOOL)shouldRefreshView:(id<MHVTypeView>)view
{
    if (![view isStale:m_maxAge])
    {
        return FALSE;
    }
    
    if ([view isKindOfClass:[MHVSynchronizedType class]])
    {
        MHVSynchronizedType* st = (MHVSynchronizedType *) view;
        if ([st hasPendingChanges])
        {
            return FALSE;
        }
    }
    
    return TRUE;
}

-(void)refreshComplete:(MHVGetItemsTask *)task
{
    MHVItemQueryResults* results = task.queryResults;
    for (MHVItemQueryResult* result in results.results)
    {
        id<MHVTypeView> view = [m_views objectForKey:result.name];
        
        MHVTypeViewItems* viewKeys = [[MHVTypeViewItems alloc] init];
        if ([viewKeys addQueryResult:result])
        {
            [view replaceKeys:viewKeys];
        }
        
    }
}

@end


