//
//  MHVRecord.m
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
#import "MHVRecord.h"
#import "MHVPersonalImage.h"
#import "MHVBlobPayloadItem.h"

static NSString* const c_element_displayname = @"display-name";
static NSString* const c_element_relationship = @"rel-name";
static NSString* const c_element_auth_action = @"app-record-auth-action";

@implementation MHVRecord

@synthesize name = m_name;
@synthesize displayName = m_displayName;
@synthesize relationship = m_relationship;

-(id)initWithRecord:(HealthVaultRecord *)record
{
    MHVCHECK_NOTNULL(record);
    
    self = [super init];
    MHVCHECK_SELF;
    
    self.ID = record.recordId;
    self.personID = record.personId;
    self.name = record.recordName;
    self.displayName = record.displayName;
    self.relationship = record.relationship;
    self.authStatus = record.authStatus;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(MHVGetPersonalImageTask *)downloadPersonalImageWithCallback:(MHVTaskCompletion)callback
{
    MHVGetPersonalImageTask* task = [[MHVGetPersonalImageTask alloc] initWithRecord:self andCallback:callback];
    MHVCHECK_NOTNULL(task);
    
    [task start];
    return task;
    
LError:
    return nil;
}

-(MHVClientResult *)validate
{    
    MHVVALIDATE_BEGIN;
    
    MHVCHECK_RESULT([super validate]);
    
    MHVVALIDATE_STRING(m_name, MHVClientError_InvalidRecord);
    
    MHVVALIDATE_SUCCESS;
}

-(void) serializeAttributes:(XWriter *)writer
{
    [super serializeAttributes:writer];
    
    [writer writeAttribute:c_element_displayname value:m_displayName];
    [writer writeAttribute:c_element_relationship value:m_relationship];
    [writer writeAttribute:c_element_auth_action value:self.authStatus];
}

-(void)serialize:(XWriter *)writer
{
    [writer writeText:m_name];
}

-(void) deserializeAttributes:(XReader *)reader
{
    [super deserializeAttributes:reader];
    
    m_displayName = [reader readAttribute:c_element_displayname];
    m_relationship = [reader readAttribute:c_element_relationship];
    self.authStatus = [reader readAttribute:c_element_auth_action];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [reader readValue];
}

@end

@implementation MHVRecordCollection

-(id) init
{
    return [self initWithRecordArray:nil];
}

-(id)initWithRecordArray:(NSArray *)records
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.type = [MHVRecord class];
    
    if (records)
    {
        for (HealthVaultRecord* record in records) 
        {
            MHVRecord *hvRecord = [[MHVRecord alloc] initWithRecord:record];
            [self addObject:hvRecord];
        }
    }
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(MHVRecord *)itemAtIndex:(NSUInteger)index
{
    return (MHVRecord *) [m_inner objectAtIndex:index];
}

-(NSInteger)indexOfRecordID:(NSString *)recordID
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        MHVRecord* record = [self itemAtIndex:i];
        if ([record.ID isEqualToString:recordID])
        {
            return i;
        }
    }
    
    return NSNotFound;
}

@end

