//
//  MHVThingDateAndKey.m
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
#import "MHVTypeViewThing.h"

static const xmlChar* x_element_dateShort = XMLSTRINGCONST("dt");

@interface MHVTypeViewThing (MHVPrivate)

-(void) setDate:(NSDate *) date;

@end

@implementation MHVTypeViewThing

@synthesize date = m_date;
@synthesize isLoadPending = m_isLoadPending;

-(id) initWithDate:(NSDate *)date andID:(NSString *)thingID
{
    MHVCHECK_NOTNULL(date);
    MHVCHECK_NOTNULL(thingID);
    
    self = [super initWithID:thingID];
    MHVCHECK_SELF;
    
    self.date = date;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithThing:(MHVTypeViewThing *)thing
{
    MHVCHECK_NOTNULL(thing);
    
    self = [super initWithKey:thing];
    MHVCHECK_SELF;
    
    self.date = thing.date;
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithMHVThing:(MHVThing *)thing
{
    MHVCHECK_NOTNULL(thing);
    
    self = [super initWithKey:thing.key];
    MHVCHECK_SELF;
    
    self.date = [thing getDate];
    
    return self;
    
LError:
    MHVALLOC_FAIL;  
}

-(id) initWithPendingThing:(MHVPendingThing *)pendingThing
{
    MHVCHECK_NOTNULL(pendingThing);
    
    self = [super initWithKey:pendingThing.key];
    MHVCHECK_SELF;
    
    self.date = pendingThing.effectiveDate;
    
    return self;
    
LError:
    MHVALLOC_FAIL;      
}


-(NSComparisonResult) compareToThing:(MHVTypeViewThing *)other
{
    if (!other)
    {
        return NSOrderedDescending;
    }
    
    NSComparisonResult cmp = [m_date compareDescending:other.date];
    if (cmp == NSOrderedSame)
    {
        cmp = -[self.thingID compare:other.thingID];
    }
    
    return cmp;
}

-(NSComparisonResult) compareThingID:(MHVTypeViewThing *)other
{
    if (!other)
    {
        return NSOrderedDescending;
    }
    
    return [self.thingID compare:other.thingID];
}

+(NSComparisonResult) compare:(id)x to:(id)y
{
    return [MHVTypeViewThing compareThing:(MHVTypeViewThing *) x to:(MHVTypeViewThing *) y];
}

+(NSComparisonResult) compareThing:(MHVTypeViewThing *)x to:(MHVTypeViewThing *)y
{
    if (!(x && y))
    {
        return NSOrderedSame;
    }
    if (!x)
    {
        return NSOrderedAscending;
    }
    
    return [x compareToThing:y];
}

+(NSComparisonResult) compareID:(id)x to:(id)y
{
    return [((MHVTypeViewThing *) x) compareThingID:(MHVTypeViewThing *) y];
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"%@ [%@, %@]", [m_date toStringWithStyle:NSDateFormatterShortStyle], self.thingID, self.version];
}

-(void) serialize:(XWriter *)writer
{
    [super serialize:writer];
    
    if (m_date)
    {
        double timespan = (double) [m_date timeIntervalSinceReferenceDate];
        [writer writeElementXmlName:x_element_dateShort doubleValue:timespan];
    }
}

-(void) deserialize:(XReader *)reader
{
    [super deserialize:reader];
    
    double timespan = [reader readNextDouble];

    m_date = nil;
    m_date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:(NSTimeInterval) timespan];
    MHVCHECK_OOM(m_date);
}

@end

@implementation MHVTypeViewThing (MHVPrivate)

-(void)setDate:(NSDate *)date
{
    m_date = date;
}

@end
