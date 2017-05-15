//
//  GetThings.h
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
#import "MHVThingQuery.h"
#import "MHVThingQueryResults.h"

@interface MHVGetThingsTask : MHVMethodCallTask
{
    MHVThingQueryCollection* m_queries;
}

-(id) initWithQuery:(MHVThingQuery *) query andCallback:(MHVTaskCompletion) callback;
-(id) initWithQueries:(MHVThingQueryCollection *) queries andCallback:(MHVTaskCompletion) callback;

//
// You can send multiple queries to HealthVault in a single MHVGetThingsTask
// Use them to reduce the number of round trips you need to make
// For most typical tasks though, you will issue a single query at a time
//
@property (readonly, nonatomic, strong) MHVThingQueryCollection* queries;
@property (readonly, nonatomic, strong) MHVThingQuery* firstQuery;
//
// When the task completes, retrieve results from this property
// If there was an error - such as network, or error code returned by HealthVault - this
// will throw an Exception (usually MHVServerException)
// 
// If you issue just a single query, then you can also use the convenience queryResult property
//
@property (readonly, nonatomic, strong) MHVThingQueryResults* queryResults;
//
// Returns the results of the FIRST query in the list of queries you issued
//
@property (readonly, nonatomic, strong) MHVThingQueryResult* queryResult;
//
// Returns things retrieved by the FIRST query in the list of queries you issued
//
@property (readonly, nonatomic, strong) MHVThingCollection* thingsRetrieved;
//
// Returns the first thing retrieved by the FIRST query in the list of issued queries
//
@property (readonly, nonatomic, strong) MHVThing* firstThingRetrieved;

+(MHVGetThingsTask *) newForRecord:(MHVRecordReference *) record query:(MHVThingQuery *)query andCallback:(MHVTaskCompletion)callback;
+(MHVGetThingsTask *) newForRecord:(MHVRecordReference *) record queries:(MHVThingQueryCollection *)queries andCallback:(MHVTaskCompletion)callback;

@end
