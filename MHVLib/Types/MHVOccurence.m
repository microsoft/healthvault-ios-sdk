//
//  MHVOccurence.m
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

#import "MHVCommon.h"
#import "MHVOccurence.h"

static NSString* const c_element_when = @"when";
static NSString* const c_element_minutes = @"minutes";

@implementation MHVOccurence

@synthesize when = m_when;
@synthesize durationMinutes = m_minutes;


-(id)initForDuration:(int)minutes startingAt:(MHVTime *)time
{
    HVCHECK_NOTNULL(time);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.when = time;
    
    m_minutes = [[MHVNonNegativeInt alloc] initWith:minutes];
    HVCHECK_NOTNULL(m_minutes);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initForDuration:(int)minutes startingAtHour:(int)hour andMinute:(int)minute
{
    MHVTime* time = [[MHVTime alloc] initWithHour:hour minute:minute];
    HVCHECK_NOTNULL(time);
    
    self = [self initForDuration:minutes startingAt:time];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

+(MHVOccurence *)forDuration:(int)minutes atHour:(int)hour andMinute:(int)minute
{
    return [[MHVOccurence alloc] initForDuration:minutes startingAtHour:hour andMinute:minute];
}

-(MHVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_when, HVClientError_InvalidOccurrence);
    HVVALIDATE(m_minutes, HVClientError_InvalidOccurrence);
    
    HVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_when content:m_when];
    [writer writeElement:c_element_minutes content:m_minutes];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [reader readElement:c_element_when asClass:[MHVTime class]];
    m_minutes = [reader readElement:c_element_minutes asClass:[MHVNonNegativeInt class]];    
}

@end

@implementation MHVOccurenceCollection

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [MHVOccurence class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(MHVOccurence *)itemAtIndex:(NSUInteger)index
{
    return (MHVOccurence *) [self objectAtIndex:0];
}
@end
