//
//  HVGuid.m
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
#import "HVGuid.h"

// Empty Guid "00000000-0000-0000- 0000-000000000000"

CFUUIDRef newGuidCreate(void)
{
    return CFUUIDCreate(nil);
}

NSString* guidString(void)
{
    CFUUIDRef guid = newGuidCreate();
    if (!guid)
    {
        return nil;
    }
    
    NSString *guidString = guidToString(guid);
    HVReleaseRef(guid);
    
    return guidString;
}

CFUUIDRef parseGuid(NSString *string)
{
    if (!string)
    {
        return nil;
    }
    
    return CFUUIDCreateFromString(nil, (CFStringRef) string);
}

NSString* guidToString(CFUUIDRef guid)
{
    if (!guid)
    {
        return c_emptyString;
    }
    
    return [(NSString *) CFUUIDCreateString(nil, guid) autorelease];    
}


@implementation HVGuid

-(BOOL) hasValue
{
    return (m_guid != nil);
}

-(CFUUIDRef) value
{
    return m_guid;
}

-(void) setValue:(CFUUIDRef)guid
{
    m_guid = HVReplaceRef(m_guid, guid);
}

-(id) initWithNewGuid
{
    CFUUIDRef guidValue = newGuidCreate();
    
    self = [self initWithGuid:guidValue];
    HVReleaseRef(guidValue);
    
    HVCHECK_SELF;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id) initWithGuid:(CFUUIDRef) guid
{   
    HVCHECK_NOTNULL(guid);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_guid = HVRetainRef(guid);
   
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id) initFromString:(NSString *)string
{
    CFUUIDRef guidValue = parseGuid(string);
    HVCHECK_NOTNULL(guidValue);
    
    self = [self initWithGuid:guidValue];
    HVReleaseRef(guidValue);
    
    HVCHECK_SELF;
    
    return self;

LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    HVReleaseRef(m_guid);
    [super dealloc];
}

-(void) deserialize:(XReader *)reader
{
    self.value = [reader readGuid];
}

-(void) serialize:(XWriter *)writer
{
    if (self.hasValue)
    {
        [writer writeGuid:m_guid];
    }
}

-(NSString *) description
{
    return guidToString(m_guid);
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_PTR(m_guid, HVClientError_InvalidGuid);
    
    HVVALIDATE_SUCCESS;
}

@end
