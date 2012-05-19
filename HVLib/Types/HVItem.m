//
//  HVItem.m
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
#import "HVItem.h"
#import "HVClient.h"

static NSString* const c_element_key = @"thing-id";
static NSString* const c_element_type = @"type-id";
static NSString* const c_element_state = @"thing-state";
static NSString* const c_element_flags = @"flags";
static NSString* const c_element_effectiveDate = @"eff-date";
static NSString* const c_element_created = @"created";
static NSString* const c_element_updated = @"updated";
static NSString* const c_element_data = @"data-xml";
static NSString* const c_element_blobs = @"blob-payload";  

@implementation HVItem

@synthesize key = m_key;
@synthesize type = m_type;

@synthesize state = m_state;
@synthesize flags = m_flags;

@synthesize effectiveDate = m_effectiveDate;
@synthesize created = m_created;
@synthesize updated = m_updated;

@synthesize data = m_data;
@synthesize blobs = m_blobs;

-(BOOL)hasKey
{
    return (m_key != nil);
}

-(BOOL) hasData
{
    return (m_data != nil);
}

-(HVItemData *) data
{
    HVENSURE(m_data, HVItemData);
    return m_data;
}

-(void) setData:(HVItemData *)data
{
    HVRETAIN(m_data, data);
}

-(BOOL) hasTypedData
{
    return (self.hasData && self.data.hasTyped);
}

-(BOOL)hasCommonData
{
    return (self.hasData && self.data.hasCommon);
}

-(BOOL)hasBlobData
{
    return (m_blobs && m_blobs.hasItems);
}

-(NSString *)note
{
    return (self.hasCommonData) ? self.data.common.note : nil;
}

-(void)setNote:(NSString *)note
{
    self.data.common.note = note;
}

-(NSString *) itemID
{
    if (!m_key)
    {
        return c_emptyString;
    }
    
    return m_key.itemID;
}

-(id) initWithType:(NSString *)typeID
{
    HVItemDataTyped* data = [[HVTypeSystem current] newFromTypeID:typeID];
    HVCHECK_NOTNULL(data);
    
    self = [self initWithTypedData:data];
    [data release];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id) initWithTypedData:(HVItemDataTyped *)data
{
    HVCHECK_NOTNULL(data);
    
    self = [super init];
    HVCHECK_SELF;
        
    m_type = [[HVItemType alloc] initWithTypeID:data.type];
    HVCHECK_NOTNULL(m_type);
    
    m_data = [[HVItemData alloc] init];
    HVCHECK_NOTNULL(m_data);
    
    m_data.typed = data;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithTypedDataClassName:(NSString *)name
{
    NSString* typeID = [[HVTypeSystem current] getTypeIDForClassName:name];
    HVCHECK_NOTNULL(typeID);
    
    return [self initWithType:typeID];
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithTypedDataClass:(Class)cls
{
    return [self initWithTypedDataClassName:NSStringFromClass(cls)];
}

-(void) dealloc
{
    [m_key  release];
    [m_type release];
    [m_effectiveDate release];
    
    [m_created release];
    [m_updated release];
    
    [m_data release];
    
    [super dealloc];
}

-(BOOL)setKeyToNew
{
    HVItemKey* newKey = [[HVItemKey alloc] initNew];
    HVCHECK_NOTNULL(newKey);
    
    self.key = newKey;
    [newKey release];
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)ensureKey
{
    if (!m_key)
    {
        return [self setKeyToNew];
    }
    
    return TRUE;
}

-(NSDate *)getDate
{
    if (self.hasTypedData)
    {
        NSDate *date = [m_data.typed getDate];
        if (date)
        {
            return date;
        }
    }

    if (m_effectiveDate)
    {
        return m_effectiveDate;
    }
    

    return nil;
}

-(BOOL)isVersion:(NSString *)version
{
    if (self.hasKey && m_key.hasVersion)
    {
        return [m_key.version isEqualToString:version];       
    }
    
    return FALSE;
}

-(HVTask *)updateBlobData:(HVTaskCompletion)callback
{
    return [self updateBlobDataFromRecord:nil andCallback:callback];
}

-(HVTask *)updateBlobDataFromRecord:(HVRecordReference *)record andCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(m_key);
    if (!record)
    {
        record = [HVClient current].currentRecord;
    }

    HVItemQuery *query = [[[HVItemQuery alloc] initWithItemKey:m_key] autorelease];
    HVCHECK_NOTNULL(query);
    
    query.view.sections = HVItemSection_Blobs;
        
    HVGetItemsTask* getItemsTask = [[[HVGetItemsTask alloc] initWithQuery:query andCallback:^(HVTask *task) {
        
        HVItem* blobItem = ((HVGetItemsTask *) task).firstItemRetrieved;
        HVRETAIN(m_blobs, blobItem.blobs);
        
    } ] autorelease];
    
    HVCHECK_NOTNULL(getItemsTask);
    getItemsTask.record = record;

    HVTask* getBlobTask = [[[HVTask alloc] initWithCallback:callback andChildTask:getItemsTask] autorelease];
    HVCHECK_NOTNULL(getBlobTask);

    [getBlobTask start];
    
    return getBlobTask;
    
LError:
    return nil;
}

-(HVItem *)shallowClone
{
    HVItem* item = [[[HVItem alloc] init] autorelease];
    item.key = self.key;
    item.type = self.type;
    item.state = self.state;
    item.flags = self.flags;
    item.effectiveDate = self.effectiveDate;
    item.created = self.created;
    item.updated = self.updated;
    item.data = self.data;
    item.blobs = self.blobs;
    
    return item;
}

-(void)clearSystemFields
{
    self.effectiveDate = nil;
    self.updated = nil;
    self.updated = nil;
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE_OPTIONAL(m_key);
    HVVALIDATE_OPTIONAL(m_type);
    HVVALIDATE_OPTIONAL(m_data);
    HVVALIDATE_OPTIONAL(m_blobs);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void) serialize:(XWriter *)writer
{
    HVSERIALIZE(m_key, c_element_key);
    HVSERIALIZE(m_type, c_element_type);
    HVSERIALIZE_ENUM(m_state, c_element_state, HVItemStateToString);
    HVSERIALIZE_INT(m_flags, c_element_flags);
    HVSERIALIZE_DATE(m_effectiveDate, c_element_effectiveDate);
    HVSERIALIZE(m_created, c_element_created);
    HVSERIALIZE(m_updated, c_element_updated);
    HVSERIALIZE(m_data, c_element_data);
    HVSERIALIZE(m_blobs, c_element_blobs);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE(m_key, c_element_key, HVItemKey);
    HVDESERIALIZE(m_type, c_element_type, HVItemType);
    HVDESERIALIZE_ENUM(m_state, c_element_state, HVItemStateFromString);
    HVDESERIALIZE_INT(m_flags, c_element_flags);
    HVDESERIALIZE_DATE(m_effectiveDate, c_element_effectiveDate);
    HVDESERIALIZE(m_created, c_element_created, HVAudit);
    HVDESERIALIZE(m_updated, c_element_updated, HVAudit);
    HVDESERIALIZE(m_data, c_element_data, HVItemData);
    HVDESERIALIZE(m_blobs, c_element_blobs, HVBlobPayload);
}

-(NSString *)toXmlString
{
    return [XSerializer serializeToString:self withRoot:@"info"];
}

+(HVItem *)newFromXmlString:(NSString *) xml
{
    return (HVItem *) [NSObject newFromString:xml withRoot:@"info" asClass:[HVItem class]];
}

@end

static NSString* const c_element_item = @"thing";

@implementation HVItemCollection

-(id) init
{
    return [self initwithItem:nil];
}

-(id)initwithItem:(HVItem *)item
{
    self = [super init];
    HVCHECK_SELF;

    self.type = [HVItem class];
    
    if (item)
    {
        [self addObject:item];
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(HVItem *)itemAtIndex:(NSUInteger)index
{
    return (HVItem *) [self objectAtIndex:index];
}

-(BOOL)containsItemID:(NSString *)itemID
{
    return ([self indexOfItemID:itemID] != NSNotFound);
}

-(NSUInteger)indexOfItemID:(NSString *)itemID
{
    for (NSUInteger i = 0, count = m_inner.count; i < count; ++i)
    {
        id obj = [m_inner objectAtIndex:i];
        if (IsNsNull(obj))
        {
            continue;
        }
        
        HVItem* item = (HVItem *) obj;
        if ([item.itemID isEqualToString:itemID])
        {
            return i;
        }
    }

    return NSNotFound;
}

-(NSMutableDictionary *)createIndexByID
{
    NSMutableDictionary* index = [[NSMutableDictionary alloc] initWithCapacity:self.count];
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        id obj = [m_inner objectAtIndex:i];
        if (IsNsNull(obj))
        {
            continue;
        }
        
        HVItem* item = (HVItem *) obj;
        [index setObject:item forKey:item.key.itemID];
    }
    
    return index;
}

-(NSMutableDictionary *)getItemsIndexedByID
{
    return [[self createIndexByID] autorelease];
}

+(HVStringCollection *)idsFromItems:(NSArray *)items
{
    if (!items)
    {
        return nil;
    }
    
    HVStringCollection* copy =[[[HVStringCollection alloc] init] autorelease];
    for (HVItem* item in items)
    {
        [copy addObject:item.itemID];
    }
    
    return copy;
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE_ARRAY(m_inner, HVClientError_InvalidItemList);

    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serializeAttributes:(XWriter *)writer
{
    
}
-(void)deserializeAttributes:(XReader *)reader
{
    
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_ARRAY(m_inner, c_element_item);
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_ARRAY(m_inner, c_element_item, HVItem);
}

@end

