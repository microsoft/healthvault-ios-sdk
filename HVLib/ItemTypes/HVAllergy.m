//
//  HVAllergy.m
//  HVLib
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
#import "HVAllergy.h"
#import "HVClient.h"

static NSString* const c_typeid = @"52bf9104-2c5e-4f1f-a66d-552ebcc53df7";
static NSString* const c_typename = @"allergy";

static NSString* const c_element_name = @"name";
static NSString* const c_element_reaction = @"reaction";
static NSString* const c_element_first = @"first-observed";
static NSString* const c_element_allergenType = @"allergen-type";
static NSString* const c_element_allergenCode = @"allergen-code";
static NSString* const c_element_treatmentProvider = @"treatment-provider";
static NSString* const c_element_treatment = @"treatment";
static NSString* const c_element_negated = @"is-negated";

@implementation HVAllergy

@synthesize name = m_name;
@synthesize reaction = m_reaction;
@synthesize firstObserved = m_firstObserved;
@synthesize allergenType = m_allergenType;
@synthesize allergenCode = m_allergenCode;
@synthesize treatmentProvider = m_treatmentProvider;
@synthesize treatment = m_treatment;
@synthesize isNegated = m_isNegated;

-(id)initWithName:(NSString *)name
{
    HVCHECK_NOTNULL(name);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_name = [[HVCodableValue alloc] initWithText:name];
    HVCHECK_NOTNULL(m_name);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_name release];
    [m_reaction release];
    [m_firstObserved release];
    [m_allergenType release];
    [m_allergenCode release];
    [m_treatmentProvider release];
    [m_treatment release];
    [m_isNegated release];
    
    [super dealloc];
}

-(NSDate *)getDate
{
    return (m_firstObserved) ? [m_firstObserved toDate] : nil;
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return (m_firstObserved) ? [m_firstObserved toDateForCalendar:calendar] : nil;
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return (m_name) ? [m_name toString] : c_emptyString;
}

+(HVVocabIdentifier *)vocabForType
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"allergen-type"] autorelease];    
}

+(HVVocabIdentifier *)vocabForReaction
{
    return [[[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"reactions"] autorelease];    
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_name, HVClientError_InvalidAllergy);
    HVVALIDATE_OPTIONAL(m_reaction);
    HVVALIDATE_OPTIONAL(m_firstObserved);
    HVVALIDATE_OPTIONAL(m_allergenType);
    HVVALIDATE_OPTIONAL(m_allergenCode);
    HVVALIDATE_OPTIONAL(m_treatmentProvider);
    HVVALIDATE_OPTIONAL(m_treatment);
    HVVALIDATE_OPTIONAL(m_isNegated);

    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_name, c_element_name);
    HVSERIALIZE(m_reaction, c_element_reaction);
    HVSERIALIZE(m_firstObserved, c_element_first);
    HVSERIALIZE(m_allergenType, c_element_allergenType);
    HVSERIALIZE(m_allergenCode, c_element_allergenCode);
    HVSERIALIZE(m_treatmentProvider, c_element_treatmentProvider);
    HVSERIALIZE(m_treatment, c_element_treatment);
    HVSERIALIZE(m_isNegated, c_element_negated);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_name, c_element_name, HVCodableValue);
    HVDESERIALIZE(m_reaction, c_element_reaction, HVCodableValue);
    HVDESERIALIZE(m_firstObserved, c_element_first, HVApproxDateTime);
    HVDESERIALIZE(m_allergenType, c_element_allergenType, HVCodableValue);
    HVDESERIALIZE(m_allergenCode, c_element_allergenCode, HVCodableValue);
    HVDESERIALIZE(m_treatmentProvider, c_element_treatmentProvider, HVPerson);
    HVDESERIALIZE(m_treatment, c_element_treatment, HVCodableValue);
    HVDESERIALIZE(m_isNegated, c_element_negated, HVBool);
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
    return [[HVItem alloc] initWithType:[HVAllergy typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Allergy", @"Allergy Type Name");
}

@end
