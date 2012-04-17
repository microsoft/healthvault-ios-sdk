//
//  HVUser.m
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
#import "HVUser.h"
#import "HVRecord.h"
#import "HVGetAuthorizedPeopleTask.h"
#import "HVClient.h"
#import "HVAsyncTask.h"
#import "HVAppProvisionController.h"

static NSString* const c_element_name = @"name";
static NSString* const c_element_recordarray = @"records";
static NSString* const c_element_record = @"record";
static NSString* const c_element_current = @"current";

@interface HVUser (HVPrivate)

-(void) getPeopleComplete:(HVTask *) task;
-(HVGetAuthorizedPeopleTask *) createGetPeopleTask;
-(void) updateLegacyCurrentRecord;
-(BOOL) updateWithPerson:(HVPersonInfo *) person;

@end

@implementation HVUser

@synthesize name = m_name;
@synthesize records = m_records;
@synthesize currentIndex = m_currentIndex;

-(BOOL)hasRecords
{
    return (![NSArray isNilOrEmpty:m_records]);
}

-(void)setCurrentIndex:(NSInteger)currentIndex
{
    if (currentIndex < 0 || currentIndex > m_records.count)
    {
        currentIndex = 0;
    }
    
    m_currentIndex = currentIndex;
    [self updateLegacyCurrentRecord];
}

-(HVRecord *)currentRecord
{
    return m_records ? [m_records objectAtIndex:m_currentIndex] : nil;
}

-(id)initFromLegacyRecords:(NSArray *)recordArray
{
    HVCHECK_NOTNULL(recordArray);
    
    self = [super init];
    HVCHECK_SELF;
    
    HVCHECK_SUCCESS([self updateWithLegacyRecords:recordArray]);
        
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_name release];
    [m_records release];
    [super dealloc];
}

-(BOOL)updateWithLegacyRecords:(NSArray *)records
{
    HVRecord* current = [self currentRecord];
    
    HVCLEAR(m_name);
    HVCLEAR(m_records);
    
    m_records = [[HVRecordCollection alloc] init];
    HVCHECK_NOTNULL(m_records);
    
    for (HealthVaultRecord *record in records) 
    {
        if (!m_name)
        {
            HVRETAIN(m_name, record.personName);
        }
        
        HVRecord* hvRecord = [[HVRecord alloc] initWithRecord:record];
        HVCHECK_NOTNULL(hvRecord);
    
        if (hvRecord.ID == current.ID)
        {
            m_currentIndex = m_records.count;
        }

        [m_records addObject:hvRecord];        
    }
    
    return TRUE;
    
LError:
    return FALSE;    
}

-(HVTask *)refreshAuthorizedRecords:(HVTaskCompletion)callback
{
    HVTask* refreshTask = [[[HVTask alloc] initWithCallback:callback] autorelease];
    HVCHECK_NOTNULL(refreshTask);
    
    HVGetAuthorizedPeopleTask* getRecordsTask = [self createGetPeopleTask];    
    HVCHECK_NOTNULL(getRecordsTask);
    
    [refreshTask setNextTask:getRecordsTask];
    [getRecordsTask release];
    
    [refreshTask start];
    
    return refreshTask;
    
LError:
    return nil;
}

-(HVTask *)authorizeAdditionalRecords:(UIViewController *)parentController andCallback:(HVTaskCompletion)callback
{
    HVTask* authTask = [[[HVTask alloc] initWithCallback:callback] autorelease];
    HVCHECK_NOTNULL(authTask);
    
    NSString* urlString = [[HVClient current].service getUserAuthorizationUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    HVCHECK_NOTNULL(url);
    
    HVAppProvisionController* controller = [[HVAppProvisionController alloc] initWithAppCreateUrl:url andCallback:^(HVAppProvisionController *controller) {
        
        if (controller.error)
        {
            [HVClientException throwExceptionWithError:HVMAKE_ERROR(HVClientError_Web)];
        }
        
        if (authTask.isCancelled || !controller.isSuccess)
        {
            return;
        }
        
        HVGetAuthorizedPeopleTask* refreshTask = [self createGetPeopleTask];
        [authTask setNextTask:refreshTask];
        [authTask start];
    }];
    
    [parentController.navigationController pushViewController:controller animated:TRUE];
    [controller release];

    return authTask;
    
LError:
    return nil;
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN
    
    if (m_records)
    {
        for (HVRecord *record in m_records) 
        {
            HVCHECK_RESULT([record validate]);
        }
    }
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL 
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_STRING(m_name, c_element_name);
    HVSERIALIZE_ARRAYNESTED(m_records, c_element_recordarray, c_element_record);
    HVSERIALIZE_INT(m_currentIndex, c_element_current);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_STRING(m_name, c_element_name);
    HVDESERIALIZE_TYPEDARRAYNESTED(m_records, c_element_recordarray, c_element_record, HVRecord, HVRecordCollection);
    
    int index = 0;
    HVDESERIALIZE_INT(index, c_element_current);
    self.currentIndex = index;  // to make sure the index is valid
}

@end

@implementation HVUser (HVPrivate)

-(void)getPeopleComplete:(HVTask *)task
{
    HVGetAuthorizedPeopleTask* getPeopleTask = (HVGetAuthorizedPeopleTask *) task;
    NSArray* persons = getPeopleTask.persons;
    if ([NSArray isNilOrEmpty:persons])
    {
        return;
    }
    
    HVPersonInfo* person = [persons objectAtIndex:0];
    [self updateWithPerson:person];
}

-(HVGetAuthorizedPeopleTask *)createGetPeopleTask
{
    return [[HVGetAuthorizedPeopleTask alloc] initWithCallback:^(HVTask *task) {
        [self getPeopleComplete:task];        
    }];
    
}

-(void)updateLegacyCurrentRecord
{
    HVRecord* currentRecord = self.currentRecord;
    
    HealthVaultRecord* legacyRecord = [[HealthVaultRecord alloc] init];
    legacyRecord.personId = currentRecord.personID;
    legacyRecord.recordId = currentRecord.ID;
    legacyRecord.recordName = currentRecord.name;
    legacyRecord.relationship = currentRecord.relationship;
    
    [HVClient current].service.currentRecord = legacyRecord;
    [legacyRecord release];
}

-(BOOL) updateWithPerson:(HVPersonInfo *) person
{
    HVCHECK_NOTNULL(person);
    
    NSString* currentRecordID = (self.currentRecord) ? self.currentRecord.ID : nil;
    m_currentIndex = 0;
    
    self.name = person.name;
    self.records = person.records;
    
    for (NSUInteger i = 0, count = m_records.count; i < count; ++i)
    {
        HVRecord* record = [m_records itemAtIndex:i];
        if (currentRecordID && record.ID == currentRecordID)
        {
            m_currentIndex = i;
        }
    }
    
    [self updateLegacyCurrentRecord];
    return TRUE;
    
LError:
    return FALSE;    
    
}

@end
