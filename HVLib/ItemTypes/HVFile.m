//
//  HVFile.m
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
//
#import "HVCommon.h"
#import "HVFile.h"
#import "HVBlob.h"
#import "HVCodableValue.h"

static NSString* const c_typeid = @"bd0403c5-4ae2-4b0e-a8db-1888678e4528";
static NSString* const c_typename = @"file";

static NSString* const c_element_name = @"name";
static NSString* const c_element_size = @"size";
static NSString* const c_element_contentType = @"content-type";

@implementation HVFile

@synthesize size = m_size;
@synthesize contentType = m_contentType;

-(NSString *)name
{
    return (m_name) ? m_name.value : nil;
}

-(void)setName:(NSString *)name
{
    HVENSURE(m_name, HVString255);
    m_name.value = name;
}

-(void)dealloc
{
    [m_name release];
    [m_contentType release];
    
    [super dealloc];
}

-(NSString *)toString
{
    return self.name;
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)sizeAsString
{
    return [HVFile sizeAsString:m_size];
}

+(NSString *)sizeAsString:(long)size
{
    if (size < 1024)
    {
        return [NSString localizedStringWithFormat:@"%d %@", (int)size, NSLocalizedString(@"bytes", @"Size in bytes")];
    }
    
    if (size < (1024 * 1024))
    {
        return [NSString localizedStringWithFormat:@"%.1f %@", ((double) size)/ 1024, NSLocalizedString(@"KB", @"Size in KB")];
    }
    
    return [NSString localizedStringWithFormat:@"%.1f %@", ((double) size)/ (1024 * 1024), NSLocalizedString(@"MB", @"Size in MB")];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_name, HVClientError_InvalidFile);
    HVVALIDATE(m_contentType, HVClientError_InvalidFile);
    
    HVVALIDATE_SUCCESS
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name content:m_name];
    [writer writeElement:c_element_size intValue:(int)m_size];
    [writer writeElement:c_element_contentType content:m_contentType];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [[reader readElement:c_element_name asClass:[HVString255 class]] retain];
    m_size = [reader readIntElement:c_element_size];
    m_contentType = [[reader readElement:c_element_contentType asClass:[HVCodableValue class]] retain];   
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(HVItem *) newItem
{
    return [[HVItem alloc] initWithType:[HVFile typeID]];
}

+(HVItem *)newItemWithName:(NSString *)name andContentType:(NSString *)contentType
{
    HVItem* item = [self newItem];
    HVCHECK_NOTNULL(item);
    
    HVFile* file = (HVFile *) item.data.typed;
    file.name = name;
    file.contentType = [HVCodableValue fromText:contentType];
        
    return item;
    
LError:
    return item;
}

@end
