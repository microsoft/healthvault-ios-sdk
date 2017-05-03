//
//  HVPhone.m
//  HVLib
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

#import "HVCommon.h"
#import "HVPhone.h"

static NSString* const c_element_description = @"description";
static NSString* const c_element_isPrimary = @"is-primary";
static NSString* const c_element_number = @"number";

@implementation HVPhone

@synthesize number = m_number;
@synthesize type = m_type;
@synthesize isPrimary = m_isprimary;

-(id)initWithNumber:(NSString *)number
{
    HVCHECK_STRING(number);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.number = number;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}


-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return (m_number) ? m_number : c_emptyString;
}

+(HVVocabIdentifier *)vocabForType
{
    return [[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"phone-types"];        
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_STRING(m_number, HVClientError_InvalidPhone);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_description value:m_type];
    [writer writeElement:c_element_isPrimary content:m_isprimary];
    [writer writeElement:c_element_number value:m_number];
}

-(void)deserialize:(XReader *)reader
{
    m_type = [reader readStringElement:c_element_description];
    m_isprimary = [reader readElement:c_element_isPrimary asClass:[HVBool class]];
    m_number = [reader readStringElement:c_element_number];
}

@end

@implementation HVPhoneCollection

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVPhone class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(HVPhone *)itemAtIndex:(NSUInteger)index
{
    return (HVPhone *) [self objectAtIndex:index];
}

@end
