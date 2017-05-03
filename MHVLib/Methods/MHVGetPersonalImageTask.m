//
//  MHVGetPersonalImageTask.m
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

#import "MHVCommon.h"
#import "MHVGetPersonalImageTask.h"
#import "MHVPersonalImage.h"
#import "MHVClient.h"

@interface MHVGetPersonalImageTask (HVPrivate)

-(MHVGetItemsTask *) newGetItemsTask:(MHVRecordReference *) record;
-(void) getItemComplete:(MHVTask *) task;

@end

@implementation MHVGetPersonalImageTask

-(NSData *)imageData
{
    return (NSData *) self.result;
}


-(id)initWithRecord:(MHVRecordReference *)record andCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(record);
    
    self = [super initWithCallback:callback];
    HVCHECK_SELF;
    
    m_record = record;
    
    MHVGetItemsTask* getItemsTask = [self newGetItemsTask:record];
    HVCHECK_NOTNULL(getItemsTask);
    
    [self setNextTask:getItemsTask];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}


@end

@implementation MHVGetPersonalImageTask (HVPrivate)

-(MHVGetItemsTask *) newGetItemsTask:(MHVRecordReference *)record
{
    MHVItemQuery *query = [[MHVItemQuery alloc] initWithTypeID:MHVPersonalImage.typeID];
    HVCHECK_NOTNULL(query);
    
    query.view.sections = HVItemSection_Blobs;
    
    MHVGetItemsTask* getItemsTask = [[MHVClient current].methodFactory newGetItemsForRecord:record query:query andCallback:^(MHVTask *task) {
        [self getItemComplete:task];
    }];
    
    
    return getItemsTask;

LError:
    return nil;
}

-(void)getItemComplete:(MHVTask *)task
{
    MHVItem* item = ((MHVGetItemsTask *) task).firstItemRetrieved;
    if (!item.hasBlobData)
    {
        return;
    }
    
    MHVBlobPayloadItem* blob = [item.blobs getDefaultBlob];
    if (!blob)
    {
        return;
    }
    
    [self setNextTask:[blob createDownloadTaskWithCallback:^(MHVTask *task) {
        
        self.result = ((MHVHttpDownload *) task).result;
        [self complete];
        
    } ]];
}
@end
