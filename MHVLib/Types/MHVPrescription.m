//
//  MHVPrescription.m
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
#import "MHVPrescription.h"

static NSString* const c_element_prescribedBy = @"prescribed-by";
static NSString* const c_element_datePrescribed = @"date-prescribed";
static NSString* const c_element_amount = @"amount-prescribed";
static NSString* const c_element_substitution = @"substitution";
static NSString* const c_element_refills = @"refills";
static NSString* const c_element_supply = @"days-supply";
static NSString* const c_element_expiration = @"prescription-expiration";
static NSString* const c_element_instructions = @"instructions";

@implementation MHVPrescription

@synthesize prescriber = m_prescriber;
@synthesize datePrescribed = m_datePrescribed;
@synthesize amount = m_amount;
@synthesize substitution = m_substitution;
@synthesize expirationDate = m_expiration;
@synthesize instructions = m_instructions;

-(int)refills
{
    return (m_refills) ? m_refills.value : -1;
}

-(void)setRefills:(int)refills
{
    if (refills >= 0)
    {
        HVENSURE(m_refills, MHVNonNegativeInt);
        m_refills.value = refills;
    }
    else
    {
        m_refills = nil;
    }
}

-(int)daysSupply
{
    return (m_daysSupply) ? m_daysSupply.value : -1;
}

-(void)setDaysSupply:(int)daysSupply
{
    if (daysSupply >= 0)
    {
        HVENSURE(m_daysSupply, MHVPositiveInt);
        m_daysSupply.value = daysSupply;
    }
    else
    {
        m_daysSupply = nil;
    }
}


-(MHVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_prescriber, HVClientError_InvalidPrescription);
    HVVALIDATE_OPTIONAL(m_datePrescribed);
    HVVALIDATE_OPTIONAL(m_amount);
    HVVALIDATE_OPTIONAL(m_substitution);
    HVVALIDATE_OPTIONAL(m_refills);
    HVVALIDATE_OPTIONAL(m_daysSupply);
    HVVALIDATE_OPTIONAL(m_expiration);
    HVVALIDATE_OPTIONAL(m_instructions);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_prescribedBy content:m_prescriber];
    [writer writeElement:c_element_datePrescribed content:m_datePrescribed];
    [writer writeElement:c_element_amount content:m_amount];
    [writer writeElement:c_element_substitution content:m_substitution];
    [writer writeElement:c_element_refills content:m_refills];
    [writer writeElement:c_element_supply content:m_daysSupply];
    [writer writeElement:c_element_expiration content:m_expiration];
    [writer writeElement:c_element_instructions content:m_instructions];
}

-(void)deserialize:(XReader *)reader
{
    m_prescriber = [reader readElement:c_element_prescribedBy asClass:[MHVPerson class]];
    m_datePrescribed = [reader readElement:c_element_datePrescribed asClass:[MHVApproxDateTime class]];
    m_amount = [reader readElement:c_element_amount asClass:[MHVApproxMeasurement class]];
    m_substitution = [reader readElement:c_element_substitution asClass:[MHVCodableValue class]];
    m_refills = [reader readElement:c_element_refills asClass:[MHVNonNegativeInt class]];
    m_daysSupply = [reader readElement:c_element_supply asClass:[MHVPositiveInt class]];
    m_expiration = [reader readElement:c_element_expiration asClass:[MHVDate class]];
    m_instructions = [reader readElement:c_element_instructions asClass:[MHVCodableValue class]];
}

@end
