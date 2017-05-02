//
//  HVItemDateAndKey.m
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
#import "HVTypeViewItem.h"

static const xmlChar* x_element_dateShort = XMLSTRINGCONST("dt");

@interface HVTypeViewItem (HVPrivate)

-(void) setDate:(NSDate *) date;

@end

@implementation HVTypeViewItem

@synthesize date = m_date;
@synthesize isLoadPending = m_isLoadPending;

-(id) initWithDate:(NSDate *)date andID:(NSString *)itemID
{
    HVCHECK_NOTNULL(date);
    HVCHECK_NOTNULL(itemID);
    
    self = [super initWithID:itemID];
    HVCHECK_SELF;
    
    self.date = date;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithItem:(HVTypeViewItem *)item
{
    HVCHECK_NOTNULL(item);
    
    self = [super initWithKey:item];
    HVCHECK_SELF;
    
    self.date = item.date;
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithHVItem:(HVItem *)item
{
    HVCHECK_NOTNULL(item);
    
    self = [super initWithKey:item.key];
    HVCHECK_SELF;
    
    self.date = [item getDate];
    
    return self;
    
LError:
    HVALLOC_FAIL;  
}

-(id) initWithPendingItem:(HVPendingItem *)pendingItem
{
    HVCHECK_NOTNULL(pendingItem);
    
    self = [super initWithKey:pendingItem.key];
    HVCHECK_SELF;
    
    self.date = pendingItem.effectiveDate;
    
    return self;
    
LError:
    HVALLOC_FAIL;      
}

-(void) dealloc
{
    [m_date release];
    [super dealloc];
}

-(NSComparisonResult) compareToItem:(HVTypeViewItem *)other
{
    if (!other)
    {
        return NSOrderedDescending;
    }
    
    NSComparisonResult cmp = [m_date compareDescending:other.date];
    if (cmp == NSOrderedSame)
    {
        cmp = -[self.itemID compare:other.itemID];
    }
    
    return cmp;
}

-(NSComparisonResult) compareItemID:(HVTypeViewItem *)other
{
    if (!other)
    {
        return NSOrderedDescending;
    }
    
    return [self.itemID compare:other.itemID];
}

+(NSComparisonResult) compare:(id)x to:(id)y
{
    return [HVTypeViewItem compareItem:(HVTypeViewItem *) x to:(HVTypeViewItem *) y];
}

+(NSComparisonResult) compareItem:(HVTypeViewItem *)x to:(HVTypeViewItem *)y
{
    if (!(x && y))
    {
        return NSOrderedSame;
    }
    if (!x)
    {
        return NSOrderedAscending;
    }
    
    return [x compareToItem:y];
}

+(NSComparisonResult) compareID:(id)x to:(id)y
{
    return [((HVTypeViewItem *) x) compareItemID:(HVTypeViewItem *) y];
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"%@ [%@, %@]", [m_date toStringWithStyle:NSDateFormatterShortStyle], self.itemID, self.version];
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

    HVCLEAR(m_date);
    m_date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:(NSTimeInterval) timespan];
    HVCHECK_OOM(m_date);
}

@end

@implementation HVTypeViewItem (HVPrivate)

-(void)setDate:(NSDate *)date
{
    HVRETAIN(m_date, date);
}

@end
