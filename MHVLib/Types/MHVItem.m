//
//  MHVItem.m
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
#import "MHVItem.h"
#import "MHVClient.h"
#import "MHVItemBlobUploadTask.h"

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

@implementation MHVItem

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

-(MHVItemData *) data
{
    MHVENSURE(m_data, MHVItemData);
    return m_data;
}

-(void) setData:(MHVItemData *)data
{
    m_data = data;
}

-(MHVBlobPayload *)blobs
{
    MHVENSURE(m_blobs, MHVBlobPayload);
    return m_blobs;
}

-(void)setBlobs:(MHVBlobPayload *)blobs
{
    m_blobs = blobs;
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
    return ((m_flags & MHVItemFlagImmutable) != 0);
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
    MHVItemDataTyped* data = [[MHVTypeSystem current] newFromTypeID:typeID];
    MHVCHECK_NOTNULL(data);
    
    self = [self initWithTypedData:data];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id) initWithTypedData:(MHVItemDataTyped *)data
{
    MHVCHECK_NOTNULL(data);
    
    self = [super init];
    MHVCHECK_SELF;
        
    m_type = [[MHVItemType alloc] initWithTypeID:data.type];
    MHVCHECK_NOTNULL(m_type);
    
    m_data = [[MHVItemData alloc] init];
    MHVCHECK_NOTNULL(m_data);
    
    m_data.typed = data;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithTypedDataClassName:(NSString *)name
{
    NSString* typeID = [[MHVTypeSystem current] getTypeIDForClassName:name];
    MHVCHECK_NOTNULL(typeID);
    
    return [self initWithType:typeID];
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithTypedDataClass:(Class)cls
{
    return [self initWithTypedDataClassName:NSStringFromClass(cls)];
}


-(BOOL)setKeyToNew
{
    MHVItemKey* newKey = [MHVItemKey newLocal];
    MHVCHECK_NOTNULL(newKey);
    
    self.key = newKey;
    
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

-(BOOL)ensureEffectiveDate
{
    if (!m_effectiveDate)
    {
        NSDate* newDate = [m_data.typed getDate];
        if (!newDate)
        {
            newDate = [NSDate date];
        }
        m_effectiveDate = newDate;
    }
    
    return (m_effectiveDate != nil);
}

-(BOOL)removeEndDate
{
    m_updatedEndDate = [MHVConstrainedXmlDate nullDate];
    MHVCHECK_NOTNULL(m_updatedEndDate);

    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)updateEndDate:(NSDate *)date
{
    MHVCHECK_NOTNULL(date);
    
    m_updatedEndDate = [MHVConstrainedXmlDate fromDate:date];
    MHVCHECK_NOTNULL(m_updatedEndDate);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(BOOL)updateEndDateWithApproxDate:(MHVApproxDateTime *)date
{
    MHVCHECK_NOTNULL(date);
    
    if (date.isStructured)
    {
        m_updatedEndDate = [MHVConstrainedXmlDate fromDate:[date toDate]];
        MHVCHECK_NOTNULL(m_updatedEndDate);
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
-(MHVTask *)updateBlobDataFromRecord:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(m_key);
    MHVCHECK_NOTNULL(record);
    //
    // We'll query for the latest blob information for this item
    //
    MHVItemQuery *query = [[MHVItemQuery alloc] initWithItemKey:m_key];
    MHVCHECK_NOTNULL(query);
    query.view.sections = MHVItemSection_Blobs;  // Blob data only
    
    MHVGetItemsTask* getItemsTask = [[MHVClient current].methodFactory newGetItemsForRecord:record query:query andCallback:^(MHVTask *task) {

        MHVItem* blobItem = ((MHVGetItemsTask *) task).firstItemRetrieved;
        m_blobs = blobItem.blobs;
    
    }];
    MHVCHECK_NOTNULL(getItemsTask);

    MHVTask* getBlobTask = [[MHVTask alloc] initWithCallback:callback andChildTask:getItemsTask];
    MHVCHECK_NOTNULL(getBlobTask);

    [getBlobTask start];
    
    return getBlobTask;
    
LError:
    return nil;
}

-(MHVItemBlobUploadTask *)uploadBlob:(id<MHVBlobSource>)data contentType:(NSString *)contentType record:(MHVRecordReference *) record andCallback:(MHVTaskCompletion)callback
{
    return [self uploadBlob:data forBlobName:c_emptyString contentType:contentType record:record andCallback:callback];
}

-(MHVItemBlobUploadTask *)uploadBlob:(id<MHVBlobSource>)data forBlobName:(NSString *)name contentType:(NSString *)contentType record:(MHVRecordReference *) record andCallback:(MHVTaskCompletion)callback
{
    MHVItemBlobUploadTask* task = [self newUploadBlobTask:data forBlobName:name contentType:contentType record:record andCallback:callback];
    
    [task start];
    
    return task;
}

-(MHVItemBlobUploadTask *)newUploadBlobTask:(id<MHVBlobSource>)data forBlobName:(NSString *)name contentType:(NSString *)contentType record:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback
{
    MHVBlobInfo* blobInfo = [[MHVBlobInfo alloc] initWithName:name andContentType:contentType];
    
    MHVItemBlobUploadTask* task = [[MHVItemBlobUploadTask alloc] initWithSource:data blobInfo:blobInfo forItem:self record:record andCallback:callback];
    
    return task;
}

-(MHVItem *)shallowClone
{
    MHVItem* item = [[MHVItem alloc] init];
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

-(void)prepareForNew
{
    self.effectiveDate = nil;
    self.updated = nil;
    self.created = nil;
    self.key = nil;
}

-(MHVClientResult *) validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE_OPTIONAL(m_key);
    MHVVALIDATE_OPTIONAL(m_type);
    MHVVALIDATE_OPTIONAL(m_data);
    MHVVALIDATE_OPTIONAL(m_blobs);
    
    MHVVALIDATE_SUCCESS;
}

-(void) serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_key content:m_key];
    [writer writeElementXmlName:x_element_type content:m_type];
    [writer writeElement:c_element_state value:MHVItemStateToString(m_state)];
    [writer writeElementXmlName:x_element_flags intValue:m_flags];
    [writer writeElementXmlName:x_element_effectiveDate dateValue:m_effectiveDate];
    [writer writeElementXmlName:x_element_created content:m_created];
    [writer writeElementXmlName:x_element_updated content:m_updated];
    [writer writeElementXmlName:x_element_data content:m_data];
    [writer writeElementXmlName:x_element_blobs content:m_blobs];
    [writer writeElementXmlName:x_element_updatedEndDate content:m_updatedEndDate];
}

-(void) deserialize:(XReader *)reader
{
    m_key = [reader readElementWithXmlName:x_element_key asClass:[MHVItemKey class]];
    m_type = [reader readElementWithXmlName:x_element_type asClass:[MHVItemType class]];
    
    NSString* state = [reader readStringElement:c_element_state];
    if (state)
    {
        m_state = MHVItemStateFromString(state);
    }

    m_flags = [reader readIntElementXmlName:x_element_flags];
    m_effectiveDate = [reader readDateElementXmlName:x_element_effectiveDate];
    m_created = [reader readElementWithXmlName:x_element_created asClass:[MHVAudit class]];
    m_updated = [reader readElementWithXmlName:x_element_updated asClass:[MHVAudit class]];
    m_data = [reader readElementWithXmlName:x_element_data asClass:[MHVItemData class]];
    m_blobs = [reader readElementWithXmlName:x_element_blobs asClass:[MHVBlobPayload class]];
    [reader skipElementWithXmlName:x_element_permissions];
    [reader skipElementWithXmlName:x_element_tags];
    [reader skipElementWithXmlName:x_element_signatures];
    m_updatedEndDate = [reader readElementWithXmlName:x_element_updatedEndDate asClass:[MHVConstrainedXmlDate class]];
    if (m_updatedEndDate && m_updatedEndDate.isNull)
    {
        m_updatedEndDate = nil;
    }
}

-(NSString *)toXmlString
{
    return [self toXmlStringWithRoot:@"info"];
}

+(MHVItem *)newFromXmlString:(NSString *) xml
{
    return (MHVItem *) [NSObject newFromString:xml withRoot:@"info" asClass:[MHVItem class]];
}

@end

static NSString* const c_element_item = @"thing";

@implementation MHVItemCollection

-(id) init
{
    return [self initWithItem:nil];
}

-(id)initWithItem:(MHVItem *)item
{
    self = [super init];
    MHVCHECK_SELF;

    self.type = [MHVItem class];
    
    if (item)
    {
        [self addObject:item];
    }
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithItems:(NSArray *)items
{
    self = [self  init];
    MHVCHECK_SELF;
    
    [self addObjectsFromArray:items];
    
    return self;
LError:
    MHVALLOC_FAIL;
}

-(void)addItem:(MHVItem *)item
{
    return [super addObject:item];
}

-(MHVItem *)itemAtIndex:(NSUInteger)index
{
    return (MHVItem *) [self objectAtIndex:index];
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
        
        MHVItem* item = (MHVItem *) obj;
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
        
        MHVItem* item = (MHVItem *) obj;
        [index setObject:item forKey:item.key.itemID];
    }
    
    return index;
}

-(NSMutableDictionary *)getItemsIndexedByID
{
    return [self newIndexByID];
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
        
        MHVItem* item = (MHVItem *) obj;
        if ([item.type.typeID isEqualToString:typeID])
        {
            return i;
        }
    }
    
    return NSNotFound;    
}

-(MHVItem *)firstItemOfType:(NSString *)typeID
{
    NSUInteger index = [self indexOfTypeID:typeID];
    if (index != NSNotFound)
    {
        return [m_inner objectAtIndex:index];
    }
    
    return nil;
}

+(MHVStringCollection *)idsFromItems:(NSArray *)items
{
    if (!items)
    {
        return nil;
    }
    
    MHVStringCollection* copy =[[MHVStringCollection alloc] init];
    for (MHVItem* item in items)
    {
        [copy addObject:item.itemID];
    }
    
    return copy;
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE_ARRAY(m_inner, MHVClientError_InvalidItemList);

    MHVVALIDATE_SUCCESS
}

-(BOOL)shallowCloneItems
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        MHVItem* clone = [[self itemAtIndex:i] shallowClone];
        MHVCHECK_NOTNULL(clone);
        
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

-(void)prepareForNew
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        [[self itemAtIndex:i] prepareForNew];
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
    [writer writeElementArray:c_element_item elements:m_inner];
}

-(void)deserialize:(XReader *)reader
{
    m_inner = [reader readElementArray:c_element_item asClass:[MHVItem class]];
}

@end

