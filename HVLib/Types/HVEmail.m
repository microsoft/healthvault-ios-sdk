//
//  HVEmail.m
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
#import "HVEmail.h"

static NSString* const c_element_description = @"description";
static NSString* const c_element_isPrimary = @"is-primary";
static NSString* const c_element_address = @"address";

@implementation HVEmail

@synthesize address = m_address;
@synthesize type = m_type;
@synthesize isPrimary = m_isprimary;

-(id)initWithEmailAddress:(NSString *)email
{
    self = [super init];
    HVCHECK_SELF;
    
    m_address = [[HVEmailAddress alloc] initWith:email];
    HVCHECK_NOTNULL(m_address);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_address release];
    [m_type release];
    [m_isprimary release];
    
    [super dealloc];
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return (m_address) ? m_address.value : c_emptyString;
}

+(HVVocabIdentifier *)vocabForType
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"email-types"] autorelease];        
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_address, HVClientError_InvalidEmail);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_description value:m_type];
    [writer writeElement:c_element_isPrimary content:m_isprimary];
    [writer writeElement:c_element_address content:m_address];
}

-(void)deserialize:(XReader *)reader
{
    m_type = [[reader readStringElement:c_element_description] retain];
    m_isprimary = [[reader readElement:c_element_isPrimary asClass:[HVBool class]] retain];
    m_address = [[reader readElement:c_element_address asClass:[HVEmailAddress class]] retain];
}

@end

@implementation HVEmailCollection

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVEmail class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(HVEmail *)itemAtIndex:(NSUInteger)index
{
    return (HVEmail *) [self objectAtIndex:index];
}

@end

