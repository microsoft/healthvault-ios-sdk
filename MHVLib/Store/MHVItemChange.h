//
//  MHVItemChange.h
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
//

#import <Foundation/Foundation.h>
#import "XLib.h"
#import "MHVItem.h"

enum MHVItemChangeType
{
    MHVItemChangeTypePut,
    MHVItemChangeTypeRemove
};

@interface MHVItemChange : XSerializableType
{
@private
    enum MHVItemChangeType m_changeType;
    NSTimeInterval m_timestamp;
    int m_attempt;

    NSString* m_changeID;
    NSString* m_typeID;
    MHVItemKey* m_key;
    MHVItemKey* m_updatedKey;
    MHVItem* m_localItem;
    MHVItem* m_updatedItem;
}

@property (readonly, nonatomic) enum MHVItemChangeType changeType;
@property (readonly, nonatomic, strong) NSString* changeID;
@property (readonly, nonatomic) NSTimeInterval timestamp;
@property (readonly, nonatomic, strong) NSString* typeID;
@property (readonly, nonatomic, strong) NSString* itemID;
@property (readonly, nonatomic, strong) MHVItemKey* itemKey;

@property (readwrite, nonatomic, strong) MHVItemKey* updatedKey;

// The item whose changes are being comitted. Reserved for internal use only
@property (readwrite, nonatomic, strong) MHVItem* localItem;
@property (readwrite, nonatomic, strong) MHVItem* updatedItem;

@property (readwrite, nonatomic) int attemptCount;

-(id) initWithTypeID:(NSString *) typeID key:(MHVItemKey *) key changeType:(enum MHVItemChangeType) changeType;

-(void) assignNewChangeID;
-(void) assignNewTimestamp;
-(BOOL) isChangeForType:(NSString *) typeID;

+(BOOL) updateChange:(MHVItemChange *) change withTypeID:(NSString *) typeID key:(MHVItemKey *) key changeType:(enum MHVItemChangeType) changeType;
+(NSComparisonResult) compareChange:(MHVItemChange *) x to:(MHVItemChange *) y;

@end
