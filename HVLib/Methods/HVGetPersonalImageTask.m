//
//  HVGetPersonalImageTask.m
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

#import "HVCommon.h"
#import "HVGetPersonalImageTask.h"
#import "HVPersonalImage.h"
#import "HVClient.h"

@interface HVGetPersonalImageTask (HVPrivate)

-(HVGetItemsTask *) newGetItemsTask:(HVRecordReference *) record;
-(void) getItemComplete:(HVTask *) task;

@end

@implementation HVGetPersonalImageTask

-(NSData *)imageData
{
    return (NSData *) self.result;
}


-(id)initWithRecord:(HVRecordReference *)record andCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(record);
    
    self = [super initWithCallback:callback];
    HVCHECK_SELF;
    
    m_record = [record retain];
    
    HVGetItemsTask* getItemsTask = [self newGetItemsTask:record];
    HVCHECK_NOTNULL(getItemsTask);
    
    [self setNextTask:getItemsTask];
    [getItemsTask release];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_record release];
    [super dealloc];
}

@end

@implementation HVGetPersonalImageTask (HVPrivate)

-(HVGetItemsTask *) newGetItemsTask:(HVRecordReference *)record
{
    HVItemQuery *query = [[HVItemQuery alloc] initWithTypeID:HVPersonalImage.typeID];
    HVCHECK_NOTNULL(query);
    
    query.view.sections = HVItemSection_Blobs;
    
    HVGetItemsTask* getItemsTask = [[HVClient current].methodFactory newGetItemsForRecord:record query:query andCallback:^(HVTask *task) {
        [self getItemComplete:task];
    }];
    
    [query release];
    
    return getItemsTask;

LError:
    return nil;
}

-(void)getItemComplete:(HVTask *)task
{
    HVItem* item = ((HVGetItemsTask *) task).firstItemRetrieved;
    if (!item.hasBlobData)
    {
        return;
    }
    
    HVBlobPayloadItem* blob = [item.blobs getDefaultBlob];
    if (!blob)
    {
        return;
    }
    
    [self setNextTask:[blob createDownloadTaskWithCallback:^(HVTask *task) {
        
        self.result = ((HVHttpDownload *) task).result;
        [self complete];
        
    } ]];
}
@end
