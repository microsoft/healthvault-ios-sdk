//
//  HVRelative.m
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
#import "HVRelative.h"

static NSString* const c_element_relationship = @"relationship";
static NSString* const c_element_name = @"relative-name";
static NSString* const c_element_dateOfBirth = @"date-of-birth";
static NSString* const c_element_dateOfDeath = @"date-of-death";
static NSString* const c_element_region = @"region-of-origin";

@implementation HVRelative

@synthesize relationship = m_relationship;
@synthesize person = m_person;
@synthesize dateOfBirth = m_dateOfBirth;
@synthesize dateOfDeath = m_dateOfDeath;
@synthesize regionOfOrigin = m_regionOfOrigin;

-(id)initWithRelationship:(NSString *)relationship
{
    return [self initWithPerson:nil andRelationship:[HVCodableValue fromText:relationship]];
}

-(id)initWithPerson:(HVPerson *)person andRelationship :(HVCodableValue *)relationship 
{
    self = [super init];
    HVCHECK_SELF;
    
    if (person)
    {
        self.person = person;
    }
    
    if (relationship)
    {
        self.relationship = relationship;
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_relationship release];
    [m_person release];
    [m_dateOfBirth release];
    [m_dateOfDeath release];
    [m_regionOfOrigin release];
    
    [super dealloc];
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    if (m_person)
    {
        return [m_person toString];
    }
    
    return (m_relationship) ? [m_relationship toString] : c_emptyString;
}

+(HVVocabIdentifier *)vocabForRelationship
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"personal-relationship"] autorelease];
}

+(HVVocabIdentifier *)vocabForRegionOfOrigin
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"family-history-region-of-origin"] autorelease];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_relationship, HVClientError_InvalidRelative);
    HVVALIDATE_OPTIONAL(m_person);
    HVVALIDATE_OPTIONAL(m_dateOfBirth);
    HVVALIDATE_OPTIONAL(m_dateOfDeath);
    HVVALIDATE_OPTIONAL(m_regionOfOrigin);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_relationship content:m_relationship];
    [writer writeElement:c_element_name content:m_person];
    [writer writeElement:c_element_dateOfBirth content:m_dateOfBirth];
    [writer writeElement:c_element_dateOfDeath content:m_dateOfDeath];
    [writer writeElement:c_element_region content:m_regionOfOrigin];
}

-(void)deserialize:(XReader *)reader
{
    m_relationship = [[reader readElement:c_element_relationship asClass:[HVCodableValue class]] retain];
    m_person = [[reader readElement:c_element_name asClass:[HVPerson class]] retain];
    m_dateOfBirth = [[reader readElement:c_element_dateOfBirth asClass:[HVApproxDate class]] retain];
    m_dateOfDeath = [[reader readElement:c_element_dateOfDeath asClass:[HVApproxDate class]] retain];
    m_regionOfOrigin = [[reader readElement:c_element_region asClass:[HVCodableValue class]] retain];    
}

@end
