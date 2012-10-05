//
//  HVNutritionFact.m
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
#import "HVNutritionFact.h"

static NSString* const c_element_name = @"name";
static NSString* const c_element_fact = @"fact";

@implementation HVNutritionFact

@synthesize name = m_name;
@synthesize fact = m_fact;

-(void)dealloc
{
    [m_name release];
    [m_fact release];
    
    [super dealloc];
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE(m_name, c_element_name);
    HVSERIALIZE(m_fact, c_element_fact);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_name, c_element_name, HVCodableValue);
    HVDESERIALIZE(m_fact, c_element_fact, HVMeasurement);
}

@end

@implementation HVNutritionFactCollection

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVNutritionFact class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

@end

static NSString* const c_element_nutritionFact = @"nutrition-fact";

@implementation HVAdditionalNutritionFacts

@synthesize facts = m_facts;

-(void)dealloc
{
    [m_facts release];
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_ARRAY(m_facts, HVClientError_InvalidDietaryIntake);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_ARRAY(m_facts, c_element_nutritionFact);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_TYPEDARRAY(m_facts, c_element_nutritionFact, HVNutritionFact, HVNutritionFactCollection);
}

@end
