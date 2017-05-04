//
//  MHVNutritionFact.m
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
#import "MHVNutritionFact.h"

static NSString* const c_element_name = @"name";
static NSString* const c_element_fact = @"fact";

@implementation MHVNutritionFact

@synthesize name = m_name;
@synthesize fact = m_fact;


-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name content:m_name];
    [writer writeElement:c_element_fact content:m_fact];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [reader readElement:c_element_name asClass:[MHVCodableValue class]];
    m_fact = [reader readElement:c_element_fact asClass:[MHVMeasurement class]];
}

@end

@implementation MHVNutritionFactCollection

-(id)init
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.type = [MHVNutritionFact class];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

@end

static NSString* const c_element_nutritionFact = @"nutrition-fact";

@implementation MHVAdditionalNutritionFacts

@synthesize facts = m_facts;


-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_ARRAY(m_facts, MHVClientError_InvalidDietaryIntake);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_nutritionFact elements:m_facts];
}

-(void)deserialize:(XReader *)reader
{
    m_facts = (MHVNutritionFactCollection *)[reader readElementArray:c_element_nutritionFact asClass:[MHVNutritionFact class] andArrayClass:[MHVNutritionFactCollection class]];
}

@end
