//
// MHVUser.m
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

static NSString *const c_element_name = @"name";
static NSString *const c_element_recordarray = @"records";
static NSString *const c_element_record = @"record";
static NSString *const c_element_current = @"current";
static NSString *const c_element_environment = @"environment";
static NSString *const c_element_instanceID = @"instanceID";

@implementation MHVUser

- (BOOL)hasRecords
{
    return (![MHVCollection isNilOrEmpty:self.records]);
}

- (void)setCurrentRecordIndex:(NSInteger)currentIndex
{
    if (currentIndex < 0 || currentIndex > self.records.count)
    {
        currentIndex = 0;
    }

    _currentRecordIndex = currentIndex;
    [self updateHealthVaultCurrentRecord];
}

- (MHVRecord *)currentRecord
{
    if ([MHVCollection isNilOrEmpty:self.records])
    {
        return nil;
    }

    return [self.records objectAtIndex:self.currentRecordIndex];
}

- (BOOL)hasEnvironment
{
    return ![NSString isNilOrEmpty:self.environment];
}

- (BOOL)hasInstanceID
{
    return ![NSString isNilOrEmpty:self.instanceID];
}

- (instancetype)initFromHealthVaultRecords:(NSArray *)recordArray
{
    MHVCHECK_NOTNULL(recordArray);

    self = [super init];
    if (self)
    {
        MHVCHECK_SUCCESS([self updateWithHealthVaultRecords:recordArray]);
    }

    return self;
}

- (BOOL)updateWithHealthVaultRecords:(NSArray *)records
{
    MHVRecord *current = [self currentRecord];

    [self clear];

    self.records = [[MHVRecordCollection alloc] init];
    MHVCHECK_NOTNULL(self.records);

    for (HealthVaultRecord *record in records)
    {
        if (!self.name)
        {
            self.name = record.personName;
        }

        MHVRecord *hvRecord = [[MHVRecord alloc] initWithRecord:record];
        MHVCHECK_NOTNULL(hvRecord);

        if (current && [hvRecord.ID isEqual:current.ID])
        {
            self.currentRecordIndex = self.records.count;
        }

        [self.records addObject:hvRecord];
    }

    return TRUE;
}

- (void)configureCurrentRecordForService:(HealthVaultService *)service
{
    MHVRecord *currentRecord = self.currentRecord;

    if (currentRecord == nil)
    {
        service.currentRecord = nil;
        return;
    }

    HealthVaultRecord *healthVaultRecord = [self newHealthVaultRecord:currentRecord];
    service.currentRecord = healthVaultRecord;
}

- (void)clearRecordsForService:(HealthVaultService *)service
{
    [service.records removeAllObjects];
    service.currentRecord = nil;
}

- (MHVTask *)refreshAuthorizedRecords:(MHVTaskCompletion)callback
{
    MHVTask *refreshTask = [[MHVTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(refreshTask);

    MHVGetAuthorizedPeopleTask *getRecordsTask = [self newGetPeopleTask];
    MHVCHECK_NOTNULL(getRecordsTask);

    [refreshTask setNextTask:getRecordsTask];

    [refreshTask start];

    return refreshTask;
}

- (MHVTask *)authorizeAdditionalRecords:(UIViewController *)parentController andCallback:(MHVTaskCompletion)callback
{
    MHVTask *authTask = [[MHVTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(authTask);

    NSString *urlString = [[MHVClient current].service getUserAuthorizationUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    MHVCHECK_NOTNULL(url);

    MHVAppProvisionController *controller = [[MHVAppProvisionController alloc] initWithAppCreateUrl:url andCallback:^(MHVAppProvisionController *controller)
    {
        if (controller.error)
        {
            [MHVClientException throwExceptionWithError:MHVMAKE_ERROR(MHVClientError_Web)];
        }

        if (authTask.isCancelled || !controller.isSuccess)
        {
            return;
        }

        MHVGetAuthorizedPeopleTask *refreshTask = [self newGetPeopleTask];
        [authTask setNextTask:refreshTask];
        [authTask start];
    }];

    [parentController.navigationController pushViewController:controller animated:TRUE];

    return authTask;
}

- (MHVTask *)removeAuthForRecord:(MHVRecord *)record withCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(record);

    MHVTask *removeAuthTask = [[MHVTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(removeAuthTask);

    MHVRemoveRecordAuthTask *removeRecordAuthTask = [[MHVRemoveRecordAuthTask alloc] initWithRecord:record andCallback:^(MHVTask *task)
    {
        [task checkSuccess];

        MHVGetAuthorizedPeopleTask *refreshTask = [self newGetPeopleTask];
        [task.parent setNextTask:refreshTask];
    }];
    MHVCHECK_NOTNULL(removeRecordAuthTask);

    [removeAuthTask setNextTask:removeRecordAuthTask];
    [removeAuthTask start];

    return removeAuthTask;
}

- (MHVTask *)downloadRecordImageFor:(MHVRecord *)record withCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(record);

    MHVTask *task = [[MHVTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(task);

    MHVGetPersonalImageTask *getImageTask = [[MHVGetPersonalImageTask alloc] initWithRecord:record andCallback:^(MHVTask *task)
    {
        [self imageDownloadComplete:task forRecord:record];
    }];
    MHVCHECK_NOTNULL(getImageTask);

    [task setNextTask:getImageTask];
    [task start];

    return task;
}

- (void)clear
{
    self.name = nil;
    self.records = nil;
    self.currentRecordIndex = 0;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN

    if (self.records)
    {
        for (MHVRecord *record in self.records)
        {
            MHVCHECK_RESULT([record validate]);
        }
    }

    MHVVALIDATE_SUCCESS
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name value:self.name];
    [writer writeElementArray:c_element_recordarray itemName:c_element_record elements:self.records.toArray];
    [writer writeElement:c_element_current intValue:(int)self.currentRecordIndex];
    [writer writeElement:c_element_environment value:self.environment];
    [writer writeElement:c_element_instanceID value:self.instanceID];
}

- (void)deserialize:(XReader *)reader
{
    self.name = [reader readStringElement:c_element_name];
    self.records = (MHVRecordCollection *)[reader readElementArray:c_element_recordarray itemName:c_element_record asClass:[MHVRecord class] andArrayClass:[MHVRecordCollection class]];
    self.currentRecordIndex = [reader readIntElement:c_element_current];
    self.environment = [reader readStringElement:c_element_environment];
    self.instanceID = [reader readStringElement:c_element_instanceID];
}

#pragma mark - Internal methods

- (void)getPeopleComplete:(MHVTask *)task
{
    MHVGetAuthorizedPeopleTask *getPeopleTask = (MHVGetAuthorizedPeopleTask *)task;
    NSArray *persons = getPeopleTask.persons;

    if ([NSArray isNilOrEmpty:persons])
    {
        // NO authorized people! App must be reauthorized
        [self clear];
        [self clearHealthVaultRecords];
        return;
    }

    MHVPersonInfo *person = persons[0];
    [self updateWithPerson:person];
}

- (MHVGetAuthorizedPeopleTask *)newGetPeopleTask
{
    return [[MHVGetAuthorizedPeopleTask alloc] initWithCallback:^(MHVTask *task)
    {
        [self getPeopleComplete:task];
    }];
}

- (BOOL)updateWithPerson:(MHVPersonInfo *)person
{
    MHVCHECK_NOTNULL(person);

    NSUUID *currentRecordID = (self.currentRecord) ? self.currentRecord.ID : nil;
    self.currentRecordIndex = 0;

    self.name = person.name;
    self.records = person.records;

    if ([self hasRecords])
    {
        for (NSUInteger i = 0; i < self.records.count; ++i)
        {
            MHVRecord *record = [self.records objectAtIndex:i];
            
            if (currentRecordID && [record.ID isEqual:currentRecordID])
            {
                self.currentRecordIndex = i;
            }
        }

        [self updateHealthVaultRecords];
    }
    else
    {
        [self clearHealthVaultRecords];
    }

    return TRUE;
}

- (void)imageDownloadComplete:(MHVTask *)task forRecord:(MHVRecord *)record
{
    NSData *imageData = ((MHVGetPersonalImageTask *)task).imageData;

    if (imageData)
    {
        [[[MHVClient current].localVault getRecordStore:record] putPersonalImage:imageData];
    }
    else
    {
        [[[MHVClient current].localVault getRecordStore:record] deletePersonalImage];
    }
}

- (void)updateHealthVaultRecords
{
    [self clearHealthVaultRecords];
    [self updateHealthVaultCurrentRecord];
}

- (void)updateHealthVaultCurrentRecord
{
    [self configureCurrentRecordForService:[MHVClient current].service];
}

- (HealthVaultRecord *)newHealthVaultRecord:(MHVRecord *)record
{
    HealthVaultRecord *healthVaultRecord = [[HealthVaultRecord alloc] init];

    healthVaultRecord.personId = record.personID;
    healthVaultRecord.recordId = record.ID;
    healthVaultRecord.recordName = record.name;
    healthVaultRecord.relationship = record.relationship;

    return healthVaultRecord;
}

- (void)clearHealthVaultRecords
{
    [self clearRecordsForService:[MHVClient current].service];
}

@end
