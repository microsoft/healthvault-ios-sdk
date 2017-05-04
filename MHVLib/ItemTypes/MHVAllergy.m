//
//  MHVAllergy.m
//  MHVLib
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

#import "MHVCommon.h"
#import "MHVAllergy.h"
#import "MHVClient.h"

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

@implementation MHVAllergy

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
    MHVCHECK_NOTNULL(name);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_name = [[MHVCodableValue alloc] initWithText:name];
    MHVCHECK_NOTNULL(m_name);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
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

+(MHVVocabIdentifier *)vocabForType
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"allergen-type"];    
}

+(MHVVocabIdentifier *)vocabForReaction
{
    return [[MHVVocabIdentifier alloc] initWithFamily:c_hvFamily andName:@"reactions"];    
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE(m_name, MHVClientError_InvalidAllergy);
    MHVVALIDATE_OPTIONAL(m_reaction);
    MHVVALIDATE_OPTIONAL(m_firstObserved);
    MHVVALIDATE_OPTIONAL(m_allergenType);
    MHVVALIDATE_OPTIONAL(m_allergenCode);
    MHVVALIDATE_OPTIONAL(m_treatmentProvider);
    MHVVALIDATE_OPTIONAL(m_treatment);
    MHVVALIDATE_OPTIONAL(m_isNegated);

    MHVVALIDATE_SUCCESS
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
    m_name = [reader readElement:c_element_name asClass:[MHVCodableValue class]];
    m_reaction = [reader readElement:c_element_reaction asClass:[MHVCodableValue class]];
    m_firstObserved = [reader readElement:c_element_first asClass:[MHVApproxDateTime class]];
    m_allergenType = [reader readElement:c_element_allergenType asClass:[MHVCodableValue class]];
    m_allergenCode = [reader readElement:c_element_allergenCode asClass:[MHVCodableValue class]];
    m_treatmentProvider = [reader readElement:c_element_treatmentProvider asClass:[MHVPerson class]];
    m_treatment = [reader readElement:c_element_treatment asClass:[MHVCodableValue class]];
    m_isNegated = [reader readElement:c_element_negated asClass:[MHVBool class]];
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
    return [[MHVItem alloc] initWithType:[MHVAllergy typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Allergy", @"Allergy Type Name");
}

@end
