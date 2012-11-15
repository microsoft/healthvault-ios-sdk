//
//  GetItems.h
//  HVLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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
#import "HVMethodCallTask.h"
#import "HVItemQuery.h"
#import "HVItemQueryResults.h"

@interface HVGetItemsTask : HVMethodCallTask
{
    HVItemQueryCollection* m_queries;
}

-(id) initWithQuery:(HVItemQuery *) query andCallback:(HVTaskCompletion) callback;

//
// You can send multiple queries to HealthVault in a single HVGetItemsTask
// Use them to reduce the number of round trips you need to make
// For most typical tasks though, you will issue a single query at a time
//
@property (readonly, nonatomic) HVItemQueryCollection* queries;
@property (readonly, nonatomic) HVItemQuery* firstQuery;
//
// When the task completes, retrieve results from this property
// If there was an error - such as network, or error code returned by HealthVault - this
// will throw an Exception (usually HVServerException)
// 
// If you issue just a single query, then you can also use the convenience queryResult property
//
@property (readonly, nonatomic) HVItemQueryResults* queryResults;
//
// Returns the results of the FIRST query in the list of queries you issued
//
@property (readonly, nonatomic) HVItemQueryResult* queryResult;
//
// Returns items retrieved by the FIRST query in the list of queries you issued
//
@property (readonly, nonatomic) HVItemCollection* itemsRetrieved;
//
// Returns the first item retrieved by the FIRST query in the list of issued queries
//
@property (readonly, nonatomic) HVItem* firstItemRetrieved;


@end
