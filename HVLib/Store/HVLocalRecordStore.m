//
//  HVLocalRecordStore.m
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
#import "HVLocalRecordStore.h"
#import "HVTypeView.h"
#import "HVSynchronizedStore.h"

static NSString* const c_view = @"view";

@interface HVLocalRecordStore (HVPrivate)
-(NSString *) makeViewKey:(NSString *) name;
@end

@implementation HVLocalRecordStore

@synthesize record = m_record;
@synthesize metadata = m_metadata;
@synthesize data = m_data;

-(id)initForRecord:(HVRecordReference *)record overRoot:(id<HVObjectStore>)root
{
    HVCHECK_NOTNULL(record);
    HVCHECK_NOTNULL(root);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_root = [root newChildStore:record.ID];
    HVCHECK_NOTNULL(m_root);
    
    m_metadata = [m_root newChildStore:@"Metadata"];
    HVCHECK_NOTNULL(m_metadata);
    
    id<HVObjectStore> dataStore = [m_root newChildStore:@"Data"];
    HVCHECK_NOTNULL(dataStore);
    
    m_data = [[HVSynchronizedStore alloc] initOverStore:dataStore];
    [dataStore release];
    HVCHECK_NOTNULL(m_data);
    
    HVRETAIN(m_record, record);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_record release];
    [m_root release];
    [m_metadata release];
    [m_data release];
    [super dealloc];
}

-(HVTypeView *)loadView:(NSString *)name
{
    HVTypeView* view = [m_metadata getObjectWithKey:[self makeViewKey:name] name:c_view andClass:[HVTypeView class]];
    if (view)
    {
        view.store = self;
    }
    return view;
}

-(BOOL)saveView:(HVTypeView *)view name:(NSString *)name
{
    return [m_metadata putObject:view withKey:[self makeViewKey:name] andName:c_view];
}

-(void)deleteView:(NSString *)name
{
    [m_metadata deleteKey:[self makeViewKey:name]];
}

@end

@implementation HVLocalRecordStore (HVPrivate)

-(NSString *)makeViewKey:(NSString *)name
{
    return [name stringByAppendingString:c_view];
}

@end
