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

-(BOOL) isStaleVocabWithID:(HVVocabIdentifier *) vocabID maxAge:(NSTimeInterval) maxAgeSeconds;

-(HVGetVocabTask *) newDownloadVocabTaskForVocab:(HVVocabIdentifier *) vocabID;
-(void) downloadTaskComplete:(HVTask *) task forVocabID:(HVVocabIdentifier *) vocabID;

-(HVGetVocabTask *) newDownloadVocabTaskForVocabs:(HVVocabIdentifierCollection *) vocabIDs;
-(void) downloadTaskComplete:(HVTask *) task forVocabs:(HVVocabIdentifierCollection *) vocabIDs;

@end

@implementation HVLocalVocabStore

@synthesize store = m_objectStore;

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

-(HVTask *)downloadVocabs:(HVVocabIdentifierCollection *)vocabIDs withCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(vocabIDs);
    
    HVGetVocabTask* getVocab = [self newDownloadVocabTaskForVocabs:vocabIDs];    
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
    if ([self isStaleVocabWithID:vocab maxAge:ageInSeconds])
    {
        HVGetVocabTask* task = [[self newDownloadVocabTaskForVocab:vocab] autorelease];        
        [task start];
    }
}

-(BOOL)ensureVocabsDownloaded:(HVVocabIdentifierCollection *)vocabIDs maxAge:(NSTimeInterval)ageInSeconds
{
    HVCHECK_NOTNULL(vocabIDs);
    
    HVVocabIdentifierCollection* vocabsToDownload = nil;
    
    for (NSUInteger i = 0, count = vocabIDs.count; i < count; ++i)
    {
        HVVocabIdentifier* vocabID = [vocabIDs objectAtIndex:i];
        if ([self isStaleVocabWithID:vocabID maxAge:ageInSeconds])
        {
            HVENSURE(vocabsToDownload, HVVocabIdentifierCollection);
            [vocabsToDownload addObject:vocabID];
        }
    }
 
    if (![NSArray isNilOrEmpty:vocabsToDownload])
    {
        HVGetVocabTask* task = [[self newDownloadVocabTaskForVocabs:vocabsToDownload] autorelease];
        [vocabsToDownload release];
        
        HVCHECK_NOTNULL(task);
        
        [task start];
    }
    
    return TRUE;

LError:
    return FALSE;
}

-(HVVocabItem *)getVocabItemForCode:(NSString *)code inVocab:(HVVocabIdentifier *)vocabID
{
    HVVocabCodeSet* vocab  = [self getVocabWithID:vocabID];
    if (!vocab)
    {
        return nil;
    }
    
    return [vocab.items getItemWithCode:code];
}

-(NSString *)getDisplayTextForCode:(NSString *)code inVocab:(HVVocabIdentifier *)vocabID
{
    HVVocabItem* vocabItem = [self getVocabItemForCode:code inVocab:vocabID];
    if (!vocabItem)
    {
        return nil;
    }
    
    return vocabItem.displayText;
}

@end

@implementation HVLocalVocabStore (HVPrivate)

-(BOOL)isStaleVocabWithID:(HVVocabIdentifier *)vocabID maxAge:(NSTimeInterval)maxAgeSeconds
{
    NSString* key = [vocabID toKeyString];
    NSDate* lastUpdate = [m_objectStore updateDateForKey:key];
    if (!lastUpdate || [lastUpdate offsetFromNow] >= maxAgeSeconds)
    {
        return TRUE;
    }
    
    return FALSE;

}

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

-(HVGetVocabTask *)newDownloadVocabTaskForVocabs:(HVVocabIdentifierCollection *)vocabIDs
{
    HVGetVocabTask* task = [[HVGetVocabTask alloc] initWithCallback:^(HVTask *task) {
        
        [self downloadTaskComplete:task forVocabs:vocabIDs];
        
    }];
    
    HVVocabParams* params = [[HVVocabParams alloc] initWithVocabIDs:vocabIDs];
    task.params = params;
    [params release];
    
    return task;
}

-(void)downloadTaskComplete:(HVTask *)task forVocabs:(HVVocabIdentifierCollection *)vocabIDs
{
    @try 
    {
        HVGetVocabTask* getVocab = (HVGetVocabTask *) task;
        HVVocabSetCollection* downloadedVocabs = getVocab.vocabResults.vocabs;
        for (NSUInteger i = 0, count = downloadedVocabs.count; i < count; ++i) 
        {
            HVVocabCodeSet* vocab = [downloadedVocabs objectAtIndex:i];
            if (vocab.isTruncated)
            {
                continue;
            }
            [self putVocab:vocab withID:[vocab getVocabID]];
        }        
    }
    @catch (id exception) 
    {
        [exception log];
    }
}
@end