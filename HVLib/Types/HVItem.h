//
//  HVItem.h
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

#import <Foundation/Foundation.h>
#import "HVType.h"
#import "HVItemKey.h"
#import "HVItemType.h"
#import "HVItemState.h"
#import "HVAudit.h"
#import "HVItemData.h"
#import "HVBlobPayload.h"
#import "HVBlobSource.h"
#import "HVAsyncTask.h"

@class HVRecordReference;
@class HVItemBlobUploadTask;

enum HVItemFlags
{
    HVItemFlagNone = 0x00,
    HVItemFlagPersonal = 0x01,  // Item is only accessible to custodians
    HVItemFlagDownVersioned = 0x02, // Item converted from a newer format to an older format [cannot update]
    HVItemFlagUpVersioned = 0x04    // Item converted from an older format to a new format [can update]
};

//-------------------------
//
// A single Item ("thing") in a record
// Each item has:
//   - Key and Version 
//   - Metadata, such as creation dates
//   - Xml Data
//      - Typed data [e.g. Medication, Allergy, Exercise etc.] with associated HV Schemas
//      - Common data [Related Items, Notes, tags, extensions...] 
//   - Blob Data
//      - A collection of named blob streams. 
//
//-------------------------
@interface HVItem : HVType
{
@private
    HVItemKey* m_key;
    HVItemType* m_type;
    enum HVItemState m_state;
    int m_flags;
    NSDate* m_effectiveDate;
    HVAudit* m_created;
    HVAudit* m_updated;    
    HVItemData* m_data;
    HVBlobPayload* m_blobs;
}

//-------------------------
//
// Data
//
//-------------------------

//
// (Optional) The key for this item (id + version)
// All existing items that have been successfully committed to HealthVault
// will always have a key. 
//
@property (readwrite, nonatomic, retain) HVItemKey* key;

@property (readwrite, nonatomic, retain) HVItemType* type;

@property (readwrite, nonatomic) enum HVItemState state;
//
// (Optional) See HVItemFlags enumeration...
//
@property (readwrite, nonatomic) int flags;
//
// 
// The effective date impacts the default sort order of returned results
//
@property (readwrite, nonatomic, retain) NSDate* effectiveDate;

@property (readwrite, nonatomic, retain) HVAudit* created;
@property (readwrite, nonatomic, retain) HVAudit* updated;
//
// (Optional) Structured data for this item. May be null if you did not 
// ask for Core data (see enum HVItemSection) when you issued a query for items
//
@property (readwrite, nonatomic, retain) HVItemData* data;
//
// (Optional) Information about unstructured blob streams associated with this item
// May be null if you did not ask for Blob information (see enum HVItemSectionBlob)
//
@property (readwrite, nonatomic, retain) HVBlobPayload* blobs;

//-----------------------
//
// Convenience Properties
//
//------------------------
@property (readonly, nonatomic) NSString* itemID;
//
// (Optional) All items can have arbitrary notes...
// References data.common.note 
//
@property (readwrite, nonatomic, retain) NSString* note;

//
// Convenience
//
@property (readonly, nonatomic) BOOL hasKey;
@property (readonly, nonatomic) BOOL hasData;
@property (readonly, nonatomic) BOOL hasTypedData;
@property (readonly, nonatomic) BOOL hasCommonData;
@property (readonly, nonatomic) BOOL hasBlobData;

//-------------------------
//
// Initializers
//
//-------------------------

-(id) initWithType:(NSString *) typeID;
-(id) initWithTypedData:(HVItemDataTyped *) data;
-(id) initWithTypedDataClassName:(NSString *) name;
-(id) initWithTypedDataClass:(Class) cls;

//-------------------------
//
// Serialization
//
//-------------------------
-(NSString *) toXmlString;
+(HVItem *) newFromXmlString:(NSString *) xml;

//-------------------------
//
// Methods
//
//-------------------------
//
// Does a SHALLOW CLONE. 
// You get a new HVItem but pointed at all the same internal objects
//
-(HVItem*) shallowClone;
//
// Call this to clear fields that are typically set by the HV service
// - EffectiveDate, UpdateDate, etc...
// You will want to do this if you fetch an item from HV, update it and then
// do a put. 
//
-(void) prepareForUpdate; 

-(BOOL) setKeyToNew;
-(BOOL) ensureKey;

-(NSDate *) getDate;

-(BOOL) isVersion:(NSString *) version;

//-------------------------
//
// Blob
//
//-------------------------
//
// Refreshes information about blobs associated with this item
//
-(HVTask *) updateBlobDataFromRecord:(HVRecordReference *) record andCallback:(HVTaskCompletion) callback;
//
// Upload data into the default blob and put the item...
//
-(HVItemBlobUploadTask *) uploadBlob:(id<HVBlobSource>) data contentType:(NSString *) contentType record:(HVRecordReference *) record andCallback:(HVTaskCompletion) callback;
-(HVItemBlobUploadTask *) uploadBlob:(id<HVBlobSource>) data forBlobName:(NSString *) name contentType:(NSString *) contentType record:(HVRecordReference *) record andCallback:(HVTaskCompletion) callback;

@end

//-------------------------
//
// A serializable collection of items
//
//-------------------------
@interface HVItemCollection : HVCollection <XSerializable>

-(id) initwithItem:(HVItem *) item;
-(id) initWithItems:(NSArray *) items;

-(HVItem *) itemAtIndex:(NSUInteger) index;

-(BOOL) containsItemID:(NSString *) itemID;
-(NSUInteger) indexOfItemID:(NSString *) itemID;

-(NSMutableDictionary *) newIndexByID;
-(NSMutableDictionary *) getItemsIndexedByID;

-(NSUInteger) indexOfTypeID:(NSString *) typeID;
-(HVItem *) firstItemOfType:(NSString *) typeID;

+(HVStringCollection *) idsFromItems:(NSArray *) items;

-(HVClientResult *) validate;
-(BOOL) shallowCloneItems;
-(void) prepareForUpdate;

@end
