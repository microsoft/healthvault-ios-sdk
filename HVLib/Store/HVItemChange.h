//
//  HVItemChange.h
//  HVLib
//
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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
//

#import <Foundation/Foundation.h>
#import "XLib.h"
#import "HVItem.h"

enum HVItemChangeType
{
    HVItemChangeTypePut,
    HVItemChangeTypeRemove
};

@interface HVItemChange : XSerializableType
{
@private
    enum HVItemChangeType m_changeType;
    NSTimeInterval m_timestamp;
    int m_attempt;

    NSString* m_changeID;
    NSString* m_typeID;
    HVItemKey* m_key;
    HVItemKey* m_updatedKey;
    HVItem* m_localItem;
    HVItem* m_updatedItem;
}

@property (readonly, nonatomic) enum HVItemChangeType changeType;
@property (readonly, nonatomic) NSString* changeID;
@property (readonly, nonatomic) NSTimeInterval timestamp;
@property (readonly, nonatomic) NSString* typeID;
@property (readonly, nonatomic) NSString* itemID;
@property (readonly, nonatomic) HVItemKey* itemKey;

@property (readwrite, nonatomic, retain) HVItemKey* updatedKey;

// The item whose changes are being comitted. Reserved for internal use only
@property (readwrite, nonatomic, retain) HVItem* localItem;
@property (readwrite, nonatomic, retain) HVItem* updatedItem;

@property (readwrite, nonatomic) int attemptCount;

-(id) initWithTypeID:(NSString *) typeID key:(HVItemKey *) key changeType:(enum HVItemChangeType) changeType;

-(void) assignNewChangeID;
-(void) assignNewTimestamp;
-(BOOL) isChangeForType:(NSString *) typeID;

+(BOOL) updateChange:(HVItemChange *) change withTypeID:(NSString *) typeID key:(HVItemKey *) key changeType:(enum HVItemChangeType) changeType;
+(NSComparisonResult) compareChange:(HVItemChange *) x to:(HVItemChange *) y;

@end
