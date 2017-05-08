//
// MHVItem.m
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

static NSString* const c_element_state = @"thing-state";

static const xmlChar  *x_element_key = XMLSTRINGCONST("thing-id");
static const xmlChar  *x_element_type = XMLSTRINGCONST("type-id");
static const xmlChar  *x_element_flags = XMLSTRINGCONST("flags");
static const xmlChar  *x_element_effectiveDate = XMLSTRINGCONST("eff-date");
static const xmlChar  *x_element_created = XMLSTRINGCONST("created");
static const xmlChar  *x_element_updated = XMLSTRINGCONST("updated");
static const xmlChar  *x_element_data = XMLSTRINGCONST("data-xml");
static const xmlChar  *x_element_blobs = XMLSTRINGCONST("blob-payload");
static const xmlChar  *x_element_permissions = XMLSTRINGCONST("eff-permissions");
static const xmlChar  *x_element_tags = XMLSTRINGCONST("tags");
static const xmlChar  *x_element_signatures = XMLSTRINGCONST("signature-info");
static const xmlChar  *x_element_updatedEndDate = XMLSTRINGCONST("updated-end-date");

@implementation MHVItem

- (BOOL)hasKey
{
    return self.key != nil;
}

- (BOOL)hasTypeInfo
{
    return self.type != nil;
}

- (BOOL)hasData
{
    return self.data != nil;
}

- (BOOL)hasTypedData
{
    return self.hasData && self.data.hasTyped;
}

- (BOOL)hasCommonData
{
    return self.hasData && self.data.hasCommon;
}

- (BOOL)hasBlobData
{
    return self.blobs.hasItems;
}

- (BOOL)isReadOnly
{
    return (self.flags & MHVItemFlagImmutable) != 0;
}

- (BOOL)hasUpdatedEndDate
{
    return self.updatedEndDate && !self.updatedEndDate.isNull;
}

- (NSString *)note
{
    return self.hasCommonData ? self.data.common.note : nil;
}

- (void)setNote:(NSString *)note
{
    self.data.common.note = note;
}

- (NSString *)itemID
{
    if (!self.key)
    {
        return @"";
    }

    return self.key.itemID;
}

- (NSString *)typeID
{
    return self.type != nil ? self.type.typeID : @"";
}

- (instancetype)initWithType:(NSString *)typeID
{
    MHVItemDataTyped *data = [[MHVTypeSystem current] newFromTypeID:typeID];

    if (data)
    {
        self = [self initWithTypedData:data];
        
        return self;
    }

    return nil;
}

- (instancetype)initWithTypedData:(MHVItemDataTyped *)data
{
    if (!data)
    {
        MHVASSERT_PARAMETER(data);
        return nil;
    }

    self = [super init];
    
    if (self)
    {
        _type = [[MHVItemType alloc] initWithTypeID:data.type];
        _data = [[MHVItemData alloc] init];
        _data.typed = data;
    }

    return self;
}

- (instancetype)initWithTypedDataClassName:(NSString *)name
{
    NSString *typeID = [[MHVTypeSystem current] getTypeIDForClassName:name];

    if (typeID)
    {
         return [self initWithType:typeID];
    }

    return nil;
}

- (instancetype)initWithTypedDataClass:(Class)cls
{
    return [self initWithTypedDataClassName:NSStringFromClass(cls)];
}

- (BOOL)setKeyToNew
{
    MHVItemKey *newKey = [MHVItemKey newLocal];

    if (newKey)
    {
        self.key = newKey;
        
        return YES;
    }

    return NO;
}

- (BOOL)ensureKey
{
    if (!self.key)
    {
        return [self setKeyToNew];
    }

    return YES;
}

- (BOOL)ensureEffectiveDate
{
    if (!self.effectiveDate)
    {
        NSDate *newDate = [self.data.typed getDate];
        
        if (!newDate)
        {
            newDate = [NSDate date];
        }

        self.effectiveDate = newDate;
    }

    return self.effectiveDate != nil;
}

- (BOOL)removeEndDate
{
    self.updatedEndDate = [MHVConstrainedXmlDate nullDate];

    return self.updatedEndDate != nil;
}

- (BOOL)updateEndDate:(NSDate *)date
{
    if (!date)
    {
        MHVASSERT_PARAMETER(date);
        return NO;
    }

    self.updatedEndDate = [MHVConstrainedXmlDate fromDate:date];
    
    return self.updatedEndDate != nil;
}

- (BOOL)updateEndDateWithApproxDate:(MHVApproxDateTime *)date
{
    if (!date)
    {
        MHVASSERT_PARAMETER(date);
        return NO;
    }

    if (date.isStructured)
    {
        self.updatedEndDate = [MHVConstrainedXmlDate fromDate:[date toDate]];
        
        return self.updatedEndDate != nil;
    }

    return [self removeEndDate];
}

- (NSDate *)getDate
{
    if (self.hasTypedData)
    {
        NSDate *date = [self.data.typed getDate];
        if (date)
        {
            return date;
        }
    }

    if (self.effectiveDate)
    {
        return self.effectiveDate;
    }

    return nil;
}

- (BOOL)isVersion:(NSString *)version
{
    if (self.hasKey && self.key.hasVersion)
    {
        return [self.key.version isEqualToString:version];
    }

    return NO;
}

- (BOOL)isType:(NSString *)typeID
{
    if (self.hasTypeInfo)
    {
        return [self.type isType:typeID];
    }

    return NO;
}

// ------------------------
//
// Blob - Helper methods
//
// ------------------------
- (MHVTask *)updateBlobDataFromRecord:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback
{
    if (!record)
    {
        MHVASSERT_PARAMETER(record);
        return nil;
    }
    
    if (self.key)
    {
        //
        // We'll query for the latest blob information for this item
        //
        MHVItemQuery *query = [[MHVItemQuery alloc] initWithItemKey:self.key];
        MHVCHECK_NOTNULL(query);
        query.view.sections = MHVItemSection_Blobs;  // Blob data only
        
        MHVGetItemsTask *getItemsTask = [[MHVClient current].methodFactory newGetItemsForRecord:record query:query andCallback:^(MHVTask *task) {
            MHVItem *blobItem = ((MHVGetItemsTask *)task).firstItemRetrieved;
            self.blobs = blobItem.blobs;
        }];
        MHVCHECK_NOTNULL(getItemsTask);
        
        MHVTask *getBlobTask = [[MHVTask alloc] initWithCallback:callback andChildTask:getItemsTask];
        MHVCHECK_NOTNULL(getBlobTask);
        
        [getBlobTask start];
        
        return getBlobTask;
    }

    return nil;
}

- (MHVItemBlobUploadTask *)uploadBlob:(id<MHVBlobSource>)data contentType:(NSString *)contentType record:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback
{
    return [self uploadBlob:data forBlobName:c_emptyString contentType:contentType record:record andCallback:callback];
}

- (MHVItemBlobUploadTask *)uploadBlob:(id<MHVBlobSource>)data forBlobName:(NSString *)name contentType:(NSString *)contentType record:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback
{
    MHVItemBlobUploadTask *task = [self newUploadBlobTask:data forBlobName:name contentType:contentType record:record andCallback:callback];

    [task start];

    return task;
}

- (MHVItemBlobUploadTask *)newUploadBlobTask:(id<MHVBlobSource>)data forBlobName:(NSString *)name contentType:(NSString *)contentType record:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback
{
    MHVBlobInfo *blobInfo = [[MHVBlobInfo alloc] initWithName:name andContentType:contentType];

    MHVItemBlobUploadTask *task = [[MHVItemBlobUploadTask alloc] initWithSource:data blobInfo:blobInfo forItem:self record:record andCallback:callback];

    return task;
}

- (MHVItem *)shallowClone
{
    MHVItem *item = [[MHVItem alloc] init];

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

- (void)prepareForUpdate
{
    self.effectiveDate = nil;
    self.updated = nil;
    if (self.isReadOnly)
    {
        self.data = nil; // Can't update read only dataXml
    }
}

- (void)prepareForNew
{
    self.effectiveDate = nil;
    self.updated = nil;
    self.created = nil;
    self.key = nil;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;

    MHVVALIDATE_OPTIONAL(self.key);
    MHVVALIDATE_OPTIONAL(self.type);
    MHVVALIDATE_OPTIONAL(self.data);
    MHVVALIDATE_OPTIONAL(self.blobs);

    MHVVALIDATE_SUCCESS;
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_key content:self.key];
    [writer writeElementXmlName:x_element_type content:self.type];
    [writer writeElement:c_element_state value:MHVItemStateToString(self.state)];
    [writer writeElementXmlName:x_element_flags intValue:self.flags];
    [writer writeElementXmlName:x_element_effectiveDate dateValue:self.effectiveDate];
    [writer writeElementXmlName:x_element_created content:self.created];
    [writer writeElementXmlName:x_element_updated content:self.updated];
    [writer writeElementXmlName:x_element_data content:self.data];
    [writer writeElementXmlName:x_element_blobs content:self.blobs];
    [writer writeElementXmlName:x_element_updatedEndDate content:self.updatedEndDate];
}

- (void)deserialize:(XReader *)reader
{
    self.key = [reader readElementWithXmlName:x_element_key asClass:[MHVItemKey class]];
    self.type = [reader readElementWithXmlName:x_element_type asClass:[MHVItemType class]];

    NSString *state = [reader readStringElement:c_element_state];
    if (state)
    {
        self.state = MHVItemStateFromString(state);
    }

    self.flags = [reader readIntElementXmlName:x_element_flags];
    self.effectiveDate = [reader readDateElementXmlName:x_element_effectiveDate];
    self.created = [reader readElementWithXmlName:x_element_created asClass:[MHVAudit class]];
    self.updated = [reader readElementWithXmlName:x_element_updated asClass:[MHVAudit class]];
    self.data = [reader readElementWithXmlName:x_element_data asClass:[MHVItemData class]];
    self.blobs = [reader readElementWithXmlName:x_element_blobs asClass:[MHVBlobPayload class]];
    [reader skipElementWithXmlName:x_element_permissions];
    [reader skipElementWithXmlName:x_element_tags];
    [reader skipElementWithXmlName:x_element_signatures];
    self.updatedEndDate = [reader readElementWithXmlName:x_element_updatedEndDate asClass:[MHVConstrainedXmlDate class]];
    
    if (self.updatedEndDate && self.updatedEndDate.isNull)
    {
        self.updatedEndDate = nil;
    }
}

- (NSString *)toXmlString
{
    return [self toXmlStringWithRoot:@"info"];
}

+ (MHVItem *)newFromXmlString:(NSString *)xml
{
    return (MHVItem *)[NSObject newFromString:xml withRoot:@"info" asClass:[MHVItem class]];
}

@end

static NSString *const c_element_item = @"thing";

@interface MHVItemCollection ()

@property (nonatomic, strong) NSMutableArray *inner;

@end

@implementation MHVItemCollection

- (instancetype)init
{
    return [self initWithItem:nil];
}

- (instancetype)initWithItem:(MHVItem *)item
{
    self = [super init];

    if (self)
    {
        _inner = [[NSMutableArray alloc] init];
        
        self.type = [MHVItem class];

        if (item)
        {
            [self addObject:item];
        }
    }

    return self;
}

- (instancetype)initWithItems:(NSArray *)items
{
    self = [super init];
    
    if (self)
    {
        _inner = [[NSMutableArray alloc] initWithArray:items];
    }

    return self;
}

- (void)addItem:(MHVItem *)item
{
    return [super addObject:item];
}

- (MHVItem *)itemAtIndex:(NSUInteger)index
{
    return (MHVItem *)[self objectAtIndex:index];
}

- (BOOL)containsItemID:(NSString *)itemID
{
    return [self indexOfItemID:itemID] != NSNotFound;
}

- (NSUInteger)indexOfItemID:(NSString *)itemID
{
    for (NSUInteger i = 0; i < self.count; ++i)
    {
        id obj = [self objectAtIndex:i];
        
        if (obj== [NSNull null])
        {
            continue;
        }

        MHVItem *item = (MHVItem *)obj;
        if ([item.itemID isEqualToString:itemID])
        {
            return i;
        }
    }

    return NSNotFound;
}

- (NSMutableDictionary *)newIndexByID
{
    NSMutableDictionary *index = [[NSMutableDictionary alloc] initWithCapacity:self.count];

    for (NSUInteger i = 0; i < self.count; ++i)
    {
        id obj = [self objectAtIndex:i];
        
        if (obj== [NSNull null])
        {
            continue;
        }

        MHVItem *item = (MHVItem *)obj;
        [index setObject:item forKey:item.key.itemID];
    }

    return index;
}

- (NSMutableDictionary *)getItemsIndexedByID
{
    return [self newIndexByID];
}

- (NSUInteger)indexOfTypeID:(NSString *)typeID
{
    for (NSUInteger i = 0; i < self.count; ++i)
    {
        id obj = [self objectAtIndex:i];
        
        if (obj== [NSNull null])
        {
            continue;
        }

        MHVItem *item = (MHVItem *)obj;
        if ([item.type.typeID isEqualToString:typeID])
        {
            return i;
        }
    }

    return NSNotFound;
}

- (MHVItem *)firstItemOfType:(NSString *)typeID
{
    NSUInteger index = [self indexOfTypeID:typeID];

    if (index != NSNotFound)
    {
        return [self objectAtIndex:index];
    }

    return nil;
}

+ (MHVStringCollection *)idsFromItems:(NSArray *)items
{
    if (!items)
    {
        return nil;
    }

    MHVStringCollection *copy = [[MHVStringCollection alloc] init];
    for (MHVItem *item in items)
    {
        [copy addObject:item.itemID];
    }

    return copy;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN

    MHVVALIDATE_ARRAY(self, MHVClientError_InvalidItemList);

    MHVVALIDATE_SUCCESS
}

- (BOOL)shallowCloneItems
{
    for (NSUInteger i = 0; i < self.count; ++i)
    {
        MHVItem *clone = [[self itemAtIndex:i] shallowClone];
        
        if (!clone)
        {
            return NO;
        }

        [self replaceObjectAtIndex:i withObject:clone];
    }

    return YES;
}

- (void)prepareForUpdate
{
    for (NSUInteger i = 0; i < self.count; ++i)
    {
        [[self itemAtIndex:i] prepareForUpdate];
    }
}

- (void)prepareForNew
{
    for (NSUInteger i = 0; i < self.count; ++i)
    {
        [[self itemAtIndex:i] prepareForNew];
    }
}

- (void)serializeAttributes:(XWriter *)writer
{
}

- (void)deserializeAttributes:(XReader *)reader
{
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_item elements:self.toArray];
}

- (void)deserialize:(XReader *)reader
{
    _inner = [reader readElementArray:c_element_item asClass:[MHVItem class]];
}

@end
