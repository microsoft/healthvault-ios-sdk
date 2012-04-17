//
//  HVPersonInfo.m
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
#import "HVPersonInfo.h"

static NSString* const c_element_id = @"person-id";
static NSString* const c_element_name = @"name";
static NSString* const c_element_settings = @"app-settings";
static NSString* const c_element_selectedID = @"selected-record-id";
static NSString* const c_element_more = @"more-records";
static NSString* const c_element_record = @"record";
static NSString* const c_element_groups = @"groups";
static NSString* const c_element_culture = @"preferred-culture";
static NSString* const c_element_uiculture = @"preferred-uiculture";

@interface HVPersonInfo (HVPrivate) 
-(void) addPersonIDToRecords;
@end

@implementation HVPersonInfo

@synthesize ID = m_id;
@synthesize name = m_name;
@synthesize appSettingsXml = m_appSettingsXml;
@synthesize selectedRecordID = m_selectedRecordID;
@synthesize moreRecords = m_moreRecords;
@synthesize records = m_records;
@synthesize groupsXml = m_groupsXml;
@synthesize preferredCultureXml = m_preferredCultureXml;
@synthesize preferredUICultureXml = m_preferredUICultureXml;

-(BOOL) hasRecords
{
    return !([NSArray isNilOrEmpty:m_records]);
}

-(void) dealloc
{
    [m_id release];
    [m_name release];
    [m_appSettingsXml release];
    [m_selectedRecordID release];
    [m_moreRecords release];
    [m_records release];
    [m_groupsXml release];
    [m_preferredCultureXml release];
    [m_preferredUICultureXml release];
    
    [super dealloc];
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE_STRING(m_id, HVClientError_InvalidPersonInfo);
    HVVALIDATE_ARRAY(m_records, HVClientError_InvalidPersonInfo);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE_STRING(m_id, c_element_id);
    HVSERIALIZE_STRING(m_name, c_element_name);
    HVSERIALIZE_RAW(m_appSettingsXml);
    HVSERIALIZE_STRING(m_selectedRecordID, c_element_selectedID);
    HVSERIALIZE(m_moreRecords, c_element_more);
    HVSERIALIZE_ARRAY(m_records, c_element_record);
    HVSERIALIZE_RAW(m_groupsXml);
    HVSERIALIZE_RAW(m_preferredCultureXml);
    HVSERIALIZE_RAW(m_preferredUICultureXml);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE_STRING(m_id, c_element_id);
    HVDESERIALIZE_STRING(m_name, c_element_name);
    HVDESERIALIZE_RAW(m_appSettingsXml, c_element_settings);
    HVDESERIALIZE_STRING(m_selectedRecordID, c_element_selectedID);
    HVDESERIALIZE(m_moreRecords, c_element_more, HVBool);
    HVDESERIALIZE_TYPEDARRAY(m_records, c_element_record, HVRecord, HVRecordCollection); 
    HVDESERIALIZE_RAW(m_groupsXml, c_element_groups);
    HVDESERIALIZE_RAW(m_preferredCultureXml, c_element_culture);
    HVDESERIALIZE_RAW(m_preferredUICultureXml, c_element_uiculture);
    //
    // Fix up records with personIDs
    //
    [self addPersonIDToRecords];
}

@end

@implementation HVPersonInfo (HVPrivate)

-(void)addPersonIDToRecords
{
    for (HVRecord* record in m_records) 
    {
        record.personID = m_id;
    }
}

@end
