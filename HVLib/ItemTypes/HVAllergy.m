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
    return [[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"allergen-type"];    
}

+(HVVocabIdentifier *)vocabForReaction
{
    return [[HVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"reactions"];    
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
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name content:m_name];
    [writer writeElement:c_element_reaction content:m_reaction];
    [writer writeElement:c_element_first content:m_firstObserved];
    [writer writeElement:c_element_allergenType content:m_allergenType];
    [writer writeElement:c_element_allergenCode content:m_allergenCode];
    [writer writeElement:c_element_treatmentProvider content:m_treatmentProvider];
    [writer writeElement:c_element_treatment content:m_treatment];
    [writer writeElement:c_element_negated content:m_isNegated];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [reader readElement:c_element_name asClass:[HVCodableValue class]];
    m_reaction = [reader readElement:c_element_reaction asClass:[HVCodableValue class]];
    m_firstObserved = [reader readElement:c_element_first asClass:[HVApproxDateTime class]];
    m_allergenType = [reader readElement:c_element_allergenType asClass:[HVCodableValue class]];
    m_allergenCode = [reader readElement:c_element_allergenCode asClass:[HVCodableValue class]];
    m_treatmentProvider = [reader readElement:c_element_treatmentProvider asClass:[HVPerson class]];
    m_treatment = [reader readElement:c_element_treatment asClass:[HVCodableValue class]];
    m_isNegated = [reader readElement:c_element_negated asClass:[HVBool class]];
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
