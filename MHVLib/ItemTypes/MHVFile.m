//
//  MHVFile.m
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
//
#import "MHVCommon.h"
#import "MHVFile.h"
#import "MHVBlob.h"
#import "MHVCodableValue.h"

static NSString* const c_typeid = @"bd0403c5-4ae2-4b0e-a8db-1888678e4528";
static NSString* const c_typename = @"file";

static NSString* const c_element_name = @"name";
static NSString* const c_element_size = @"size";
static NSString* const c_element_contentType = @"content-type";

@implementation MHVFile

@synthesize size = m_size;
@synthesize contentType = m_contentType;

-(NSString *)name
{
    return (m_name) ? m_name.value : nil;
}

-(void)setName:(NSString *)name
{
    HVENSURE(m_name, MHVString255);
    m_name.value = name;
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
    return [MHVFile sizeAsString:m_size];
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

-(MHVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_name, HVClientError_InvalidFile);
    HVVALIDATE(m_contentType, HVClientError_InvalidFile);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name content:m_name];
    [writer writeElement:c_element_size intValue:(int)m_size];
    [writer writeElement:c_element_contentType content:m_contentType];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [reader readElement:c_element_name asClass:[MHVString255 class]];
    m_size = [reader readIntElement:c_element_size];
    m_contentType = [reader readElement:c_element_contentType asClass:[MHVCodableValue class]];   
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(MHVItem *) newItem
{
    return [[MHVItem alloc] initWithType:[MHVFile typeID]];
}

+(MHVItem *)newItemWithName:(NSString *)name andContentType:(NSString *)contentType
{
    MHVItem* item = [self newItem];
    if (!item)
    {
        return nil;
    }
    
    MHVFile* file = (MHVFile *) item.data.typed;
    file.name = name;
    file.contentType = [MHVCodableValue fromText:contentType];
        
    return item;
}

@end
