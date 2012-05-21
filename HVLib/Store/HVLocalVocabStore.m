//
//  HVLocalVocabStore.m
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
#import "HVLocalVocabStore.h"

@interface HVLocalVocabStore (HVPrivate)

-(HVGetVocabTask *) newDownloadVocabTaskForVocab:(HVVocabIdentifier *) vocabID;
-(void) downloadTaskComplete:(HVTask *) task forVocabID:(HVVocabIdentifier *) vocabID;

@end

@implementation HVLocalVocabStore

-(id)initWithObjectStore:(id<HVObjectStore>)store
{
    HVCHECK_NOTNULL(store);
    
    self = [super init];
    HVCHECK_SELF;
    
    HVRETAIN(m_objectStore, store);
    
    return self;

LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_objectStore release];
    [super dealloc];
}

-(BOOL)containsVocabWithID:(HVVocabIdentifier *)vocabID
{
    NSString* key = [vocabID toKeyString];
    return [m_objectStore keyExists:key];
}

-(HVVocabCodeSet *)getVocabWithID:(HVVocabIdentifier *)vocabID
{
    NSString* key = [vocabID toKeyString];
    return [m_objectStore getObjectWithKey:key name:@"vocab" andClass:[HVVocabCodeSet class]];
}

-(BOOL)putVocab:(HVVocabCodeSet *)vocab withID:(HVVocabIdentifier *)vocabID
{
    NSString* key = [vocabID toKeyString];
    return [m_objectStore putObject:vocab withKey:key andName:@"vocab"];
}

-(void)removeVocabWithID:(HVVocabIdentifier *)vocabID
{
    NSString* key = [vocabID toKeyString];
    [m_objectStore deleteKey:key];
}

-(HVTask *)downloadVocab:(HVVocabIdentifier *)vocab withCallback:(HVTaskCompletion)callback
{
    HVGetVocabTask* getVocab = [self newDownloadVocabTaskForVocab:vocab];    
    HVCHECK_NOTNULL(getVocab);
    
    HVTask* downloadTask = [[[HVTask alloc] initWithCallback:callback andChildTask:getVocab] autorelease];
    [getVocab release];
    
    HVCHECK_NOTNULL(downloadTask);
    
    [downloadTask start];
    
    return downloadTask;
    
LError:
    return nil;
}

-(void)ensureVocabDownloaded:(HVVocabIdentifier *)vocab
{
    [self ensureVocabDownloaded:vocab maxAge:60 * 24 * 3600]; // Every 60 days - these many seconds
}

-(void)ensureVocabDownloaded:(HVVocabIdentifier *)vocab maxAge:(NSTimeInterval)ageInSeconds
{
    NSString* key = [vocab toKeyString];
    NSDate* lastUpdate = [m_objectStore updateDateForKey:key];
    
    if (!lastUpdate || [lastUpdate offsetFromNow] >= ageInSeconds)
    {
        HVGetVocabTask* task = [[self newDownloadVocabTaskForVocab:vocab] autorelease];
        
        [task start];
    }
}

@end

@implementation HVLocalVocabStore (HVPrivate)

-(HVGetVocabTask *)newDownloadVocabTaskForVocab:(HVVocabIdentifier *)vocabID
{
    return [[HVGetVocabTask alloc] initWithVocabID:vocabID andCallback:^(HVTask *task) {
        
        [self downloadTaskComplete:task forVocabID:vocabID];
        
    }];
}
-(void)downloadTaskComplete:(HVTask *)task forVocabID:(HVVocabIdentifier *)vocabID
{
    @try 
    {
        HVGetVocabTask* getVocab = (HVGetVocabTask *) task;
        [self putVocab:getVocab.vocabulary withID:vocabID];
    }
    @catch (id exception) 
    {
        [exception log];
    }
}

@end