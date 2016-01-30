//
//  HVTypeViewRefresher.m
//  HVLib
//
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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
#import "HVCommon.h"
#import "HVClient.h"
#import "HVTypeViewRefresher.h"
#import "HVSynchronizedType.h"

@interface HVMultipleTypeViewRefresher (HVPrivate)

-(BOOL) initViewList:(NSArray *) views;
-(HVItemQueryCollection *) collectQueriesForRefreshableViews;
-(BOOL) shouldRefreshView:(id<HVTypeView>) view;
-(void) refreshComplete:(HVGetItemsTask *) task;

@end

@implementation HVMultipleTypeViewRefresher

@synthesize maxAge = m_maxAge;

-(id)init
{
    return [self initWithRecord:nil views:nil andMaxAge:0];
}

-(id)initWithRecord:(HVRecordReference *)record views:(NSArray *)views andMaxAge:(NSTimeInterval)age
{
    HVCHECK_NOTNULL(record);
    HVCHECK_NOTNULL(views);
    
    self = [super init];
    HVCHECK_SELF;
    
    HVCHECK_SUCCESS([self initViewList:views]);
    HVRETAIN(m_record, record);
    m_maxAge = age;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithRecordStore:(HVLocalRecordStore *)store synchronizedTypeIDs:(NSArray *)typeIDs andMaxAge:(NSTimeInterval)age
{
    HVCHECK_NOTNULL(store);
    HVCHECK_NOTNULL(typeIDs);
    
    NSMutableArray* views = [[[NSMutableArray alloc] init] autorelease];
    HVCHECK_NOTNULL(views);
    
    for (NSString* typeID in typeIDs)
    {
        id<HVTypeView> view = [store getSynchronizedTypeForTypeID:typeID];
        if (views)
        {
            [views addObject:view];
        }
    }
    return [self initWithRecord:store.record views:views andMaxAge:age];
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_record release];
    [m_views release];
    
    [super dealloc];
}

-(HVTask *)refreshWithCallback:(HVTaskCompletion)callback
{
    HVItemQueryCollection* queries = [self collectQueriesForRefreshableViews];
    if ([NSArray isNilOrEmpty:queries])
    {
        // Nothing to refresh
        return nil;
    }
    
    HVTask* refreshTask = [[[HVTask alloc] initWithCallback:callback] autorelease];
    HVCHECK_NOTNULL(refreshTask);
    
    HVGetItemsTask* getItems = [[[HVClient current] methodFactory] newGetItemsForRecord:m_record queries:queries andCallback:^(HVTask *task)
    {
        [self refreshComplete:(HVGetItemsTask *) task];
    }];
    
    HVCHECK_NOTNULL(getItems);
    [refreshTask setNextTask:getItems];
    [getItems release];
    
    [refreshTask start];
    
    return refreshTask;

LError:
    return nil;
}

@end

@implementation HVMultipleTypeViewRefresher (HVPrivate)

-(BOOL)initViewList:(NSArray *)views
{
    m_views = [[NSMutableDictionary alloc] init];
    HVCHECK_NOTNULL(m_views);
    
    for (NSUInteger i = 0, count = views.count; i < count; ++i)
    {
        id<HVTypeView> view = [views objectAtIndex:i];
        NSString* viewName = [NSString stringWithFormat:@"View_%lu", (unsigned long)i];
        HVCHECK_NOTNULL(viewName);
        
        [m_views setObject:view forKey:viewName];
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(HVItemQueryCollection *)collectQueriesForRefreshableViews
{
    HVItemQueryCollection* queries = nil;
    for (NSString* viewName in m_views.keyEnumerator)
    {
        id<HVTypeView> view = [m_views objectForKey:viewName];
        if (![self shouldRefreshView:view])
        {
            continue;
        }
        
        if (!queries)
        {
            queries = [[[HVItemQueryCollection alloc] init] autorelease];
            HVCHECK_NOTNULL(queries);
        }
        
        HVItemQuery* refreshQuery = [view getQuery];
        HVCHECK_NOTNULL(refreshQuery);
        
        refreshQuery.name = viewName;
        [queries addItem:refreshQuery];
    }
    
    return queries;
    
LError:
    return nil;
}

-(BOOL)shouldRefreshView:(id<HVTypeView>)view
{
    if (![view isStale:m_maxAge])
    {
        return FALSE;
    }
    
    if ([view isKindOfClass:[HVSynchronizedType class]])
    {
        HVSynchronizedType* st = (HVSynchronizedType *) view;
        if ([st hasPendingChanges])
        {
            return FALSE;
        }
    }
    
    return TRUE;
}

-(void)refreshComplete:(HVGetItemsTask *)task
{
    HVItemQueryResults* results = task.queryResults;
    for (HVItemQueryResult* result in results.results)
    {
        id<HVTypeView> view = [m_views objectForKey:result.name];
        
        HVTypeViewItems* viewKeys = [[HVTypeViewItems alloc] init];
        if ([viewKeys addQueryResult:result])
        {
            [view replaceKeys:viewKeys];
        }
        
        [viewKeys release];
    }
}

@end


