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
#import "HVItemBlobUploadTask.h"

static const xmlChar* x_element_key = XMLSTRINGCONST("thing-id");
static const xmlChar* x_element_type = XMLSTRINGCONST("type-id");
static NSString* const c_element_state = @"thing-state";
static const xmlChar* x_element_flags = XMLSTRINGCONST("flags");
static const xmlChar* x_element_effectiveDate = XMLSTRINGCONST("eff-date");
static const xmlChar* x_element_created = XMLSTRINGCONST("created");
static const xmlChar* x_element_updated = XMLSTRINGCONST("updated");
static const xmlChar* x_element_data = XMLSTRINGCONST("data-xml");
static const xmlChar* x_element_blobs = XMLSTRINGCONST("blob-payload");  
static const xmlChar* x_element_permissions = XMLSTRINGCONST("eff-permissions");
static const xmlChar* x_element_tags = XMLSTRINGCONST("tags");
static const xmlChar* x_element_signatures = XMLSTRINGCONST("signature-info");
static const xmlChar* x_element_updatedEndDate = XMLSTRINGCONST("updated-end-date");

@implementation HVItem

@synthesize key = m_key;
@synthesize type = m_type;

@synthesize state = m_state;
@synthesize flags = m_flags;

@synthesize effectiveDate = m_effectiveDate;
@synthesize created = m_created;
@synthesize updated = m_updated;

-(BOOL)hasKey
{
    return (m_key != nil);
}

-(BOOL)hasTypeInfo
{
    return (m_type != nil);
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

-(HVBlobPayload *)blobs
{
    HVENSURE(m_blobs, HVBlobPayload);
    return m_blobs;
}

-(void)setBlobs:(HVBlobPayload *)blobs
{
    HVRETAIN(m_blobs, blobs);
}

@synthesize updatedEndDate = m_updatedEndDate;

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

-(BOOL)isReadOnly
{
    return ((m_flags & HVItemFlagImmutable) != 0);
}

-(BOOL)hasUpdatedEndDate
{
    return (self.updatedEndDate && !self.updatedEndDate.isNull);
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

-(NSString *)typeID
{
    return (m_type) ? m_type.typeID : c_emptyString;
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
    [m_blobs release];
    
    [m_updatedEndDate release];
    
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

-(BOOL)removeEndDate
{
    HVRETAIN(m_updatedEndDate, [HVConstrainedXmlDate nullDate]);
    HVCHECK_NOTNULL(m_updatedEndDate);

    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)updateEndDate:(NSDate *)date
{
    HVCHECK_NOTNULL(date);
    
    HVRETAIN(m_updatedEndDate, [HVConstrainedXmlDate fromDate:date]);
    HVCHECK_NOTNULL(m_updatedEndDate);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)updateEndDateWithApproxDate:(HVApproxDateTime *)date
{
    HVCHECK_NOTNULL(date);
    
    if (date.isStructured)
    {
        HVRETAIN(m_updatedEndDate, [HVConstrainedXmlDate fromDate:[date toDate]]);
        HVCHECK_NOTNULL(m_updatedEndDate);
        return TRUE;
    }

    return [self removeEndDate];
    
LError:
    return FALSE;
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

-(BOOL)isType:(NSString *)typeID
{
    if (self.hasTypeInfo)
    {
        return [self.type isType:typeID];
    }
    
    return FALSE;
}

//------------------------
//
// Blob - Helper methods
//
//------------------------
-(HVTask *)updateBlobDataFromRecord:(HVRecordReference *)record andCallback:(HVTaskCompletion)callback
{
    HVCHECK_NOTNULL(m_key);
    HVCHECK_NOTNULL(record);
    //
    // We'll query for the latest blob information for this item
    //
    HVItemQuery *query = [[[HVItemQuery alloc] initWithItemKey:m_key] autorelease];
    HVCHECK_NOTNULL(query);
    query.view.sections = HVItemSection_Blobs;  // Blob data only
        
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

-(HVItemBlobUploadTask *)uploadBlob:(id<HVBlobSource>)data contentType:(NSString *)contentType record:(HVRecordReference *) record andCallback:(HVTaskCompletion)callback
{
    return [self uploadBlob:data forBlobName:c_emptyString contentType:contentType record:record andCallback:callback];
}

-(HVItemBlobUploadTask *)uploadBlob:(id<HVBlobSource>)data forBlobName:(NSString *)name contentType:(NSString *)contentType record:(HVRecordReference *) record andCallback:(HVTaskCompletion)callback
{
    HVItemBlobUploadTask* task = [[self newUploadBlobTask:data forBlobName:name contentType:contentType record:record andCallback:callback] autorelease];
    
    [task start];
    
    return task;
}

-(HVItemBlobUploadTask *)newUploadBlobTask:(id<HVBlobSource>)data forBlobName:(NSString *)name contentType:(NSString *)contentType record:(HVRecordReference *)record andCallback:(HVTaskCompletion)callback
{
    HVBlobInfo* blobInfo = [[HVBlobInfo alloc] initWithName:name andContentType:contentType];
    
    HVItemBlobUploadTask* task = [[HVItemBlobUploadTask alloc] initWithSource:data blobInfo:blobInfo forItem:self record:record andCallback:callback];
    [blobInfo release];
    
    return task;
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
    if (self.hasData)
    {
        item.data = self.data;
    }
    if (self.hasBlobData)
    {
        item.blobs = self.blobs;
    }
    item.updatedEndDate = self.updatedEndDate;
    return item;
}

-(void)prepareForUpdate
{
    self.effectiveDate = nil;
    self.updated = nil;
    if (self.isReadOnly)
    {
        self.data = nil; // Can't update read only dataXml
    }
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
    HVSERIALIZE_X(m_key, x_element_key);
    HVSERIALIZE_X(m_type, x_element_type);
    HVSERIALIZE_ENUM(m_state, c_element_state, HVItemStateToString);
    HVSERIALIZE_INT_X(m_flags, x_element_flags);
    HVSERIALIZE_DATE_X(m_effectiveDate, x_element_effectiveDate);
    HVSERIALIZE_X(m_created, x_element_created);
    HVSERIALIZE_X(m_updated, x_element_updated);
    HVSERIALIZE_X(m_data, x_element_data);
    HVSERIALIZE_X(m_blobs, x_element_blobs);
    HVSERIALIZE_X(m_updatedEndDate, x_element_updatedEndDate);
}

-(void) deserialize:(XReader *)reader
{
    HVDESERIALIZE_X(m_key, x_element_key, HVItemKey);
    HVDESERIALIZE_X(m_type, x_element_type, HVItemType);
    HVDESERIALIZE_ENUM(m_state, c_element_state, HVItemStateFromString);
    HVDESERIALIZE_INT_X(m_flags, x_element_flags);
    HVDESERIALIZE_DATE_X(m_effectiveDate, x_element_effectiveDate);
    HVDESERIALIZE_X(m_created, x_element_created, HVAudit);
    HVDESERIALIZE_X(m_updated, x_element_updated, HVAudit);
    HVDESERIALIZE_X(m_data, x_element_data, HVItemData);
    HVDESERIALIZE_X(m_blobs, x_element_blobs, HVBlobPayload);
    HVDESERIALIZE_IGNORE_X(x_element_permissions);
    HVDESERIALIZE_IGNORE_X(x_element_tags);
    HVDESERIALIZE_IGNORE_X(x_element_signatures);
    HVDESERIALIZE_X(m_updatedEndDate, x_element_updatedEndDate, HVConstrainedXmlDate);
    if (m_updatedEndDate && m_updatedEndDate.isNull)
    {
        HVCLEAR(m_updatedEndDate);
    }
}

-(NSString *)toXmlString
{
    return [self toXmlStringWithRoot:@"info"];
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

-(id)initWithItems:(NSArray *)items
{
    self = [self  init];
    HVCHECK_SELF;
    
    [self addObjectsFromArray:items];
    
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

-(NSMutableDictionary *) newIndexByID
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
    return [[self newIndexByID] autorelease];
}

-(NSUInteger)indexOfTypeID:(NSString *)typeID
{
    for (NSUInteger i = 0, count = m_inner.count; i < count; ++i)
    {
        id obj = [m_inner objectAtIndex:i];
        if (IsNsNull(obj))
        {
            continue;
        }
        
        HVItem* item = (HVItem *) obj;
        if ([item.type.typeID isEqualToString:typeID])
        {
            return i;
        }
    }
    
    return NSNotFound;    
}

-(HVItem *)firstItemOfType:(NSString *)typeID
{
    NSUInteger index = [self indexOfTypeID:typeID];
    if (index != NSNotFound)
    {
        return [m_inner objectAtIndex:index];
    }
    
    return nil;
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

-(BOOL)shallowCloneItems
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        HVItem* clone = [[self itemAtIndex:i] shallowClone];
        HVCHECK_NOTNULL(clone);
        
        [self replaceObjectAtIndex:i withObject:clone];
    }

    return TRUE;
    
LError:
    return FALSE;
}

-(void)prepareForUpdate
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        [[self itemAtIndex:i] prepareForUpdate];
    }    
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

