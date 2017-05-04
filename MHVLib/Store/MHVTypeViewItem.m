//
//  MHVItemDateAndKey.m
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
#import "MHVTypeViewItem.h"

static const xmlChar* x_element_dateShort = XMLSTRINGCONST("dt");

@interface MHVTypeViewItem (MHVPrivate)

-(void) setDate:(NSDate *) date;

@end

@implementation MHVTypeViewItem

@synthesize date = m_date;
@synthesize isLoadPending = m_isLoadPending;

-(id) initWithDate:(NSDate *)date andID:(NSString *)itemID
{
    MHVCHECK_NOTNULL(date);
    MHVCHECK_NOTNULL(itemID);
    
    self = [super initWithID:itemID];
    MHVCHECK_SELF;
    
    self.date = date;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithItem:(MHVTypeViewItem *)item
{
    MHVCHECK_NOTNULL(item);
    
    self = [super initWithKey:item];
    MHVCHECK_SELF;
    
    self.date = item.date;
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithMHVItem:(MHVItem *)item
{
    MHVCHECK_NOTNULL(item);
    
    self = [super initWithKey:item.key];
    MHVCHECK_SELF;
    
    self.date = [item getDate];
    
    return self;
    
LError:
    MHVALLOC_FAIL;  
}

-(id) initWithPendingItem:(MHVPendingItem *)pendingItem
{
    MHVCHECK_NOTNULL(pendingItem);
    
    self = [super initWithKey:pendingItem.key];
    MHVCHECK_SELF;
    
    self.date = pendingItem.effectiveDate;
    
    return self;
    
LError:
    MHVALLOC_FAIL;      
}


-(NSComparisonResult) compareToItem:(MHVTypeViewItem *)other
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

-(NSComparisonResult) compareItemID:(MHVTypeViewItem *)other
{
    if (!other)
    {
        return NSOrderedDescending;
    }
    
    return [self.itemID compare:other.itemID];
}

+(NSComparisonResult) compare:(id)x to:(id)y
{
    return [MHVTypeViewItem compareItem:(MHVTypeViewItem *) x to:(MHVTypeViewItem *) y];
}

+(NSComparisonResult) compareItem:(MHVTypeViewItem *)x to:(MHVTypeViewItem *)y
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
    return [((MHVTypeViewItem *) x) compareItemID:(MHVTypeViewItem *) y];
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

    m_date = nil;
    m_date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:(NSTimeInterval) timespan];
    MHVCHECK_OOM(m_date);
}

@end

@implementation MHVTypeViewItem (MHVPrivate)

-(void)setDate:(NSDate *)date
{
    m_date = date;
}

@end
