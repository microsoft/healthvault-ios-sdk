//
//  HVPrescription.m
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
#import "HVPrescription.h"

static NSString* const c_element_prescribedBy = @"prescribed-by";
static NSString* const c_element_datePrescribed = @"date-prescribed";
static NSString* const c_element_amount = @"amount-prescribed";
static NSString* const c_element_substitution = @"substitution";
static NSString* const c_element_refills = @"refills";
static NSString* const c_element_supply = @"days-supply";
static NSString* const c_element_expiration = @"prescription-expiration";
static NSString* const c_element_instructions = @"instructions";

@implementation HVPrescription

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
        HVENSURE(m_refills, HVNonNegativeInt);
        m_refills.value = refills;
    }
    else
    {
        HVCLEAR(m_refills);
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
        HVENSURE(m_daysSupply, HVPositiveInt);
        m_daysSupply.value = daysSupply;
    }
    else
    {
        HVCLEAR(m_daysSupply);
    }
}

-(void)dealloc
{
    [m_prescriber release];
    [m_datePrescribed release];
    [m_amount release];
    [m_substitution release];
    [m_refills release];
    [m_daysSupply release];
    [m_expiration release];
    [m_instructions release];
    [super dealloc];
}

-(HVClientResult *)validate
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
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_prescriber, c_element_prescribedBy);
    HVSERIALIZE(m_datePrescribed, c_element_datePrescribed);
    HVSERIALIZE(m_amount, c_element_amount);
    HVSERIALIZE(m_substitution, c_element_substitution);
    HVSERIALIZE(m_refills, c_element_refills);
    HVSERIALIZE(m_daysSupply, c_element_supply);
    HVSERIALIZE(m_expiration, c_element_expiration);
    HVSERIALIZE(m_instructions, c_element_instructions);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_prescriber, c_element_prescribedBy, HVPerson);
    HVDESERIALIZE(m_datePrescribed, c_element_datePrescribed, HVApproxDateTime);
    HVDESERIALIZE(m_amount, c_element_amount, HVApproxMeasurement);
    HVDESERIALIZE(m_substitution, c_element_substitution, HVCodableValue);
    HVDESERIALIZE(m_refills, c_element_refills, HVNonNegativeInt);
    HVDESERIALIZE(m_daysSupply, c_element_supply, HVPositiveInt);
    HVDESERIALIZE(m_expiration, c_element_expiration, HVDate);
    HVDESERIALIZE(m_instructions, c_element_instructions, HVCodableValue);
}

@end
