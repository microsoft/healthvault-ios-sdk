//
//  MHVUser.m
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
#import "MHVUser.h"
#import "MHVRecord.h"
#import "MHVGetAuthorizedPeopleTask.h"
#import "MHVClient.h"
#import "MHVAsyncTask.h"
#import "MHVAppProvisionController.h"
#import "MHVRemoveRecordAuthTask.h"

static NSString* const c_element_name = @"name";
static NSString* const c_element_recordarray = @"records";
static NSString* const c_element_record = @"record";
static NSString* const c_element_current = @"current";
static NSString* const c_element_environment = @"environment";
static NSString* const c_element_instanceID = @"instanceID";

@interface MHVUser (MHVPrivate)

-(void) getPeopleComplete:(MHVTask *) task;
-(MHVGetAuthorizedPeopleTask *) newGetPeopleTask;

-(BOOL) updateWithPerson:(MHVPersonInfo *) person;

-(void)imageDownloadComplete:(MHVTask *)task forRecord:(MHVRecord *)record;

-(void) updateLegacyRecords;
-(void) updateLegacyCurrentRecord;
-(HealthVaultRecord *) newLegacyRecord:(MHVRecord *) record;
-(void) clearLegacyRecords;

@end

@implementation MHVUser

@synthesize name = m_name;
@synthesize records = m_records;
@synthesize currentRecordIndex = m_currentIndex;
@synthesize environment = m_environment;
@synthesize instanceID = m_instanceID;

-(BOOL)hasRecords
{
    return (![NSArray isNilOrEmpty:m_records]);
}

-(void)setCurrentRecordIndex:(NSInteger)currentIndex
{
    if (currentIndex < 0 || currentIndex > m_records.count)
    {
        currentIndex = 0;
    }
    
    m_currentIndex = currentIndex;
    [self updateLegacyCurrentRecord];
}

-(MHVRecord *)currentRecord
{
    if ([NSArray isNilOrEmpty:m_records])
    {
        return nil;
    }
    
    return [m_records objectAtIndex:m_currentIndex];
}

-(BOOL)hasEnvironment
{
    return ![NSString isNilOrEmpty:m_environment];
}

-(BOOL)hasInstanceID
{
    return ![NSString isNilOrEmpty:m_instanceID];
}

-(id)initFromLegacyRecords:(NSArray *)recordArray
{
    MHVCHECK_NOTNULL(recordArray);
    
    self = [super init];
    MHVCHECK_SELF;
    
    MHVCHECK_SUCCESS([self updateWithLegacyRecords:recordArray]);
        
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(BOOL)updateWithLegacyRecords:(NSArray *)records
{
    MHVRecord* current = [self currentRecord];
    
    [self clear];
    
    m_records = [[MHVRecordCollection alloc] init];
    MHVCHECK_NOTNULL(m_records);
    
    for (HealthVaultRecord *record in records) 
    {
        if (!m_name)
        {
            m_name = record.personName;
        }
        
        MHVRecord* hvRecord = [[MHVRecord alloc] initWithRecord:record];
        MHVCHECK_NOTNULL(hvRecord);
    
        if (current && [hvRecord.ID isEqualToString:current.ID])
        {
            m_currentIndex = m_records.count;
        }

        [m_records addObject:hvRecord];        
    }
    
    return TRUE;
    
LError:
    return FALSE;    
}

-(void) configureCurrentRecordForService:(HealthVaultService *)service
{
    MHVRecord* currentRecord = self.currentRecord;
    if (currentRecord == nil)
    {
        service.currentRecord = nil;
        return;
    }
    
    HealthVaultRecord* legacyRecord = [self newLegacyRecord:currentRecord];
    service.currentRecord = legacyRecord;
}

-(void)clearRecordsForService:(HealthVaultService *)service
{
    [service.records removeAllObjects];
    service.currentRecord = nil;
}

-(MHVTask *)refreshAuthorizedRecords:(MHVTaskCompletion)callback
{
    MHVTask* refreshTask = [[MHVTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(refreshTask);
    
    MHVGetAuthorizedPeopleTask* getRecordsTask = [self newGetPeopleTask];
    MHVCHECK_NOTNULL(getRecordsTask);
    
    [refreshTask setNextTask:getRecordsTask];
    
    [refreshTask start];
    
    return refreshTask;
    
LError:
    return nil;
}

-(MHVTask *)authorizeAdditionalRecords:(UIViewController *)parentController andCallback:(MHVTaskCompletion)callback
{
    MHVTask* authTask = [[MHVTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(authTask);
    
    NSString* urlString = [[MHVClient current].service getUserAuthorizationUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    MHVCHECK_NOTNULL(url);
    
    MHVAppProvisionController* controller = [[MHVAppProvisionController alloc] initWithAppCreateUrl:url andCallback:^(MHVAppProvisionController *controller) {
                
        if (controller.error)
        {
            [MHVClientException throwExceptionWithError:MHVMAKE_ERROR(MHVClientError_Web)];
        }
        
        if (authTask.isCancelled || !controller.isSuccess)
        {
            return;
        }
        
        MHVGetAuthorizedPeopleTask* refreshTask = [self newGetPeopleTask];
        [authTask setNextTask:refreshTask];
        [authTask start];
    }];
    
    [parentController.navigationController pushViewController:controller animated:TRUE];

    return authTask;
    
LError:
    return nil;
}

-(MHVTask *)removeAuthForRecord:(MHVRecord *)record withCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(record);
    
    MHVTask* removeAuthTask = [[MHVTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(removeAuthTask);
    
    MHVRemoveRecordAuthTask* removeRecordAuthTask = [[MHVRemoveRecordAuthTask alloc] initWithRecord:record andCallback:^(MHVTask *task) {
        
        [task checkSuccess];
        
        MHVGetAuthorizedPeopleTask* refreshTask = [self newGetPeopleTask];
        [task.parent setNextTask:refreshTask];
        
    }];
    MHVCHECK_NOTNULL(removeRecordAuthTask);
    
    [removeAuthTask setNextTask:removeRecordAuthTask];
    [removeAuthTask start];
    
    return removeAuthTask;
    
LError:
    return nil;
}

-(MHVTask *)downloadRecordImageFor:(MHVRecord *)record withCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(record);
    
    MHVTask* task = [[MHVTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(task);
    
    MHVGetPersonalImageTask* getImageTask = [[MHVGetPersonalImageTask alloc] initWithRecord:record andCallback:^(MHVTask *task) {
        [self imageDownloadComplete:task forRecord:record];
    }];
    MHVCHECK_NOTNULL(getImageTask);
    
    [task setNextTask:getImageTask];
    [task start];
    
LError:
    return nil;
}

-(void)clear
{
    m_name = nil;
    m_records = nil;
    m_currentIndex = 0;    
}

-(MHVClientResult *) validate
{
    MHVVALIDATE_BEGIN
    
    if (m_records)
    {
        for (MHVRecord *record in m_records) 
        {
            MHVCHECK_RESULT([record validate]);
        }
    }
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name value:m_name];
    [writer writeElementArray:c_element_recordarray itemName:c_element_record elements:m_records];
    [writer writeElement:c_element_current intValue:(int)m_currentIndex];
    [writer writeElement:c_element_environment value:m_environment];
    [writer writeElement:c_element_instanceID value:m_instanceID];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [reader readStringElement:c_element_name];
    m_records = (MHVRecordCollection *)[reader readElementArray:c_element_recordarray itemName:c_element_record asClass:[MHVRecord class] andArrayClass:[MHVRecordCollection class]];
    
    NSInteger index = 0;
    index = [reader readIntElement:c_element_current];
    m_currentIndex = index;
    
    m_environment = [reader readStringElement:c_element_environment];
    m_instanceID = [reader readStringElement:c_element_instanceID];
}

@end

@implementation MHVUser (MHVPrivate)

-(void)getPeopleComplete:(MHVTask *)task
{
    MHVGetAuthorizedPeopleTask* getPeopleTask = (MHVGetAuthorizedPeopleTask *) task;
    NSArray* persons = getPeopleTask.persons;
    if ([NSArray isNilOrEmpty:persons])
    {
        // NO authorized people! App must be reauthorized
        [self clear];
        [self clearLegacyRecords];
        return;
    }
    
    MHVPersonInfo* person = [persons objectAtIndex:0];
    [self updateWithPerson:person];
}

-(MHVGetAuthorizedPeopleTask *)newGetPeopleTask
{
    return [[MHVGetAuthorizedPeopleTask alloc] initWithCallback:^(MHVTask *task) {
        [self getPeopleComplete:task];        
    }];
    
}

-(BOOL) updateWithPerson:(MHVPersonInfo *) person
{
    MHVCHECK_NOTNULL(person);
    
    NSString* currentRecordID = (self.currentRecord) ? self.currentRecord.ID : nil;
    m_currentIndex = 0;
    
    self.name = person.name;
    self.records = person.records;
    
    if ([self hasRecords])
    {
        for (NSUInteger i = 0, count = m_records.count; i < count; ++i)
        {
            MHVRecord* record = [m_records itemAtIndex:i];
            if (currentRecordID && [record.ID isEqualToString:currentRecordID])
            {
                m_currentIndex = i;
            }
        }
        [self updateLegacyRecords];
    }
    else 
    {
        [self clearLegacyRecords];
    }
    
    return TRUE;
    
LError:
    return FALSE;    
    
}

-(void)imageDownloadComplete:(MHVTask *)task forRecord:(MHVRecord *)record
{
    NSData* imageData = ((MHVGetPersonalImageTask *) task).imageData;
    if (imageData)
    {
        [[[MHVClient current].localVault getRecordStore:record] putPersonalImage:imageData];
    }
    else
    {
        [[[MHVClient current].localVault getRecordStore:record] deletePersonalImage];
    }
}

-(void)updateLegacyRecords
{
    [self clearLegacyRecords];    
    [self updateLegacyCurrentRecord];
}

-(void)updateLegacyCurrentRecord
{
    [self configureCurrentRecordForService:[MHVClient current].service];
}

-(HealthVaultRecord *)newLegacyRecord:(MHVRecord *)record
{
    HealthVaultRecord* legacyRecord = [[HealthVaultRecord alloc] init];
    legacyRecord.personId = record.personID;
    legacyRecord.recordId = record.ID;
    legacyRecord.recordName = record.name;
    legacyRecord.relationship = record.relationship;
    
    return legacyRecord;
}

-(void)clearLegacyRecords
{
    [self clearRecordsForService:[MHVClient current].service];
}

@end
