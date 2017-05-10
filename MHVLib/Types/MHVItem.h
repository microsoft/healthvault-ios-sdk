//
// MHVItem.h
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

#import <Foundation/Foundation.h>
#import "MHVType.h"
#import "MHVItemKey.h"
#import "MHVItemType.h"
#import "MHVItemState.h"
#import "MHVAudit.h"
#import "MHVItemData.h"
#import "MHVBlobPayload.h"
#import "MHVBlobSource.h"
#import "MHVAsyncTask.h"
#import "MHVApproxDateTime.h"

@class MHVRecordReference;
@class MHVItemBlobUploadTask;

enum MHVItemFlags
{
    MHVItemFlagNone = 0x00,
    MHVItemFlagPersonal = 0x01,      // Item is only accessible to custodians
    MHVItemFlagDownVersioned = 0x02, // Item converted from a newer format to an older format [cannot update]
    MHVItemFlagUpVersioned = 0x04,   // Item converted from an older format to a new format [can update]
    MHVItemFlagImmutable = 0x10      // Item is locked and cannot be modified, except for updated-end-date
};

// -------------------------
//
// A single Item ("thing") in a record
// Each item has:
// - Key and Version
// - Metadata, such as creation dates
// - Xml Data
// - Typed data [e.g. Medication, Allergy, Exercise etc.] with associated MHV Schemas
// - Common data [Related Items, Notes, tags, extensions...]
// - Blob Data
// - A collection of named blob streams.
//
// -------------------------
@interface MHVItem : MHVType

// -------------------------
//
// Data
//
// -------------------------

//
// (Optional) The key for this item (id + version)
// All existing items that have been successfully committed to HealthVault
// will always have a key.
//
@property (readwrite, nonatomic, strong) MHVItemKey *key;

@property (readwrite, nonatomic, strong) MHVItemType *type;

@property (readwrite, nonatomic) MHVItemState state;
//
// (Optional) See MHVItemFlags enumeration...
//
@property (readwrite, nonatomic) int flags;
//
//
// The effective date impacts the default sort order of returned results
//
@property (readwrite, nonatomic, strong) NSDate *effectiveDate;

@property (readwrite, nonatomic, strong) MHVAudit *created;
@property (readwrite, nonatomic, strong) MHVAudit *updated;
//
// (Optional) Structured data for this item. May be null if you did not
// ask for Core data (see MHVItemSection) when you issued a query for items
//
@property (readwrite, nonatomic, strong) MHVItemData *data;
//
// (Optional) Information about unstructured blob streams associated with this item
// May be null if you did not ask for Blob information (see MHVItemSectionBlob)
//
@property (readwrite, nonatomic, strong) MHVBlobPayload *blobs;

// (Optional) RAW Xml - see HealthVault Thing schema
@property (readwrite, nonatomic, strong) NSString *effectivePermissionsXml;

// (Optional) Tags associated with this item
@property (readwrite, nonatomic, strong) MHVStringZ512 *tags;

// (Optional) Signature. Raw Xml
@property (readwrite, nonatomic, strong) NSString *signatureInfoXml;

// (Optional) Some items are immutable (locked). Users an still update the "effective"
// end date of some item - such as the date they stopped taking a medication
@property (readwrite, nonatomic, strong) MHVConstrainedXmlDate *updatedEndDate;

// -----------------------
//
// Convenience Properties
//
// ------------------------
@property (readonly, nonatomic, strong) NSString *itemID;
@property (readonly, nonatomic, strong) NSString *typeID;
//
// (Optional) All items can have arbitrary notes...
// References data.common.note
//
@property (readwrite, nonatomic, strong) NSString *note;

//
// Convenience
//
@property (readonly, nonatomic) BOOL hasKey;
@property (readonly, nonatomic) BOOL hasTypeInfo;
@property (readonly, nonatomic) BOOL hasData;
@property (readonly, nonatomic) BOOL hasTypedData;
@property (readonly, nonatomic) BOOL hasCommonData;
@property (readonly, nonatomic) BOOL hasBlobData;
@property (readonly, nonatomic) BOOL isReadOnly;
@property (readonly, nonatomic) BOOL hasUpdatedEndDate;

// -------------------------
//
// Initializers
//
// -------------------------

- (instancetype)initWithType:(NSString *)typeID;
- (instancetype)initWithTypedData:(MHVItemDataTyped *)data;
- (instancetype)initWithTypedDataClassName:(NSString *)name;
- (instancetype)initWithTypedDataClass:(Class)cls;

// -------------------------
//
// Serialization
//
// -------------------------
- (NSString *)toXmlString;
+ (MHVItem *)newFromXmlString:(NSString *)xml;

// -------------------------
//
// Methods
//
// -------------------------
//
// Does a SHALLOW CLONE.
// You get a new MHVItem but pointed at all the same internal objects
//
- (MHVItem *)shallowClone;
//
// Sometimes you will take an existing item object, edit it inline and them PUT it back to HealthVault
// Call this to clear fields that are typically set by the MHV service
// - EffectiveDate, UpdateDate, etc...
//
// NOTE: if you call MHVRecordReference::update, this method will get called automatically
//
- (void)prepareForUpdate;
//
// After this call, if you put the item into HealthVault, you will add a new item
//
- (void)prepareForNew;

- (BOOL)setKeyToNew;
- (BOOL)ensureKey;
- (BOOL)ensureEffectiveDate;

- (BOOL)removeEndDate;
- (BOOL)updateEndDate:(NSDate *)date;
- (BOOL)updateEndDateWithApproxDate:(MHVApproxDateTime *)date;

- (NSDate *)getDate;

- (BOOL)isVersion:(NSString *)version;
- (BOOL)isType:(NSString *)typeID;

// -------------------------
//
// Blob
//
// -------------------------
//
// Refreshes information about blobs associated with this item
//
- (MHVTask *)updateBlobDataFromRecord:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback;
//
// Upload data into the default blob and put the item...
//
- (MHVItemBlobUploadTask *)uploadBlob:(id<MHVBlobSourceProtocol>)data contentType:(NSString *)contentType record:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback;
- (MHVItemBlobUploadTask *)uploadBlob:(id<MHVBlobSourceProtocol>)data forBlobName:(NSString *)name contentType:(NSString *)contentType record:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback;

- (MHVItemBlobUploadTask *)newUploadBlobTask:(id<MHVBlobSourceProtocol>)data forBlobName:(NSString *)name contentType:(NSString *)contentType record:(MHVRecordReference *)record andCallback:(MHVTaskCompletion)callback;

@end

// -------------------------
//
// A serializable collection of items
//
// -------------------------
@interface MHVItemCollection : MHVCollection <XSerializable>

- (instancetype)initWithItem:(MHVItem *)item;
- (instancetype)initWithItems:(NSArray *)items;

- (void)addItem:(MHVItem *)item;
- (MHVItem *)itemAtIndex:(NSUInteger)index;

- (BOOL)containsItemID:(NSString *)itemID;
- (NSUInteger)indexOfItemID:(NSString *)itemID;

- (NSMutableDictionary *)newIndexByID;
- (NSMutableDictionary *)getItemsIndexedByID;

- (NSUInteger)indexOfTypeID:(NSString *)typeID;
- (MHVItem *)firstItemOfType:(NSString *)typeID;

+ (MHVStringCollection *)idsFromItems:(NSArray *)items;

- (MHVClientResult *)validate;

- (BOOL)shallowCloneItems;
- (void)prepareForUpdate;
- (void)prepareForNew;

@end
