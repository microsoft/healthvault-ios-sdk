//
//  GetItems.h
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

#import <Foundation/Foundation.h>
#import "MHVMethodCallTask.h"
#import "MHVItemQuery.h"
#import "MHVItemQueryResults.h"

@interface MHVGetItemsTask : MHVMethodCallTask
{
    MHVItemQueryCollection* m_queries;
}

-(id) initWithQuery:(MHVItemQuery *) query andCallback:(HVTaskCompletion) callback;
-(id) initWithQueries:(MHVItemQueryCollection *) queries andCallback:(HVTaskCompletion) callback;

//
// You can send multiple queries to HealthVault in a single MHVGetItemsTask
// Use them to reduce the number of round trips you need to make
// For most typical tasks though, you will issue a single query at a time
//
@property (readonly, nonatomic, strong) MHVItemQueryCollection* queries;
@property (readonly, nonatomic, strong) MHVItemQuery* firstQuery;
//
// When the task completes, retrieve results from this property
// If there was an error - such as network, or error code returned by HealthVault - this
// will throw an Exception (usually MHVServerException)
// 
// If you issue just a single query, then you can also use the convenience queryResult property
//
@property (readonly, nonatomic, strong) MHVItemQueryResults* queryResults;
//
// Returns the results of the FIRST query in the list of queries you issued
//
@property (readonly, nonatomic, strong) MHVItemQueryResult* queryResult;
//
// Returns items retrieved by the FIRST query in the list of queries you issued
//
@property (readonly, nonatomic, strong) MHVItemCollection* itemsRetrieved;
//
// Returns the first item retrieved by the FIRST query in the list of issued queries
//
@property (readonly, nonatomic, strong) MHVItem* firstItemRetrieved;

+(MHVGetItemsTask *) newForRecord:(MHVRecordReference *) record query:(MHVItemQuery *)query andCallback:(HVTaskCompletion)callback;
+(MHVGetItemsTask *) newForRecord:(MHVRecordReference *) record queries:(MHVItemQueryCollection *)queries andCallback:(HVTaskCompletion)callback;

@end
