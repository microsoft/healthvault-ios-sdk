//
//  MHVThingChange.h
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
#import "MHVThing.h"

enum MHVThingChangeType
{
    MHVThingChangeTypePut,
    MHVThingChangeTypeRemove
};

@interface MHVThingChange : XSerializableType
{
@private
    enum MHVThingChangeType m_changeType;
    NSTimeInterval m_timestamp;
    int m_attempt;

    NSString* m_changeID;
    NSString* m_typeID;
    MHVThingKey* m_key;
    MHVThingKey* m_updatedKey;
    MHVThing* m_localThing;
    MHVThing* m_updatedThing;
}

@property (readonly, nonatomic) enum MHVThingChangeType changeType;
@property (readonly, nonatomic, strong) NSString* changeID;
@property (readonly, nonatomic) NSTimeInterval timestamp;
@property (readonly, nonatomic, strong) NSString* typeID;
@property (readonly, nonatomic, strong) NSString* thingID;
@property (readonly, nonatomic, strong) MHVThingKey* thingKey;

@property (readwrite, nonatomic, strong) MHVThingKey* updatedKey;

// The thing whose changes are being comitted. Reserved for internal use only
@property (readwrite, nonatomic, strong) MHVThing* localThing;
@property (readwrite, nonatomic, strong) MHVThing* updatedThing;

@property (readwrite, nonatomic) int attemptCount;

-(id) initWithTypeID:(NSString *) typeID key:(MHVThingKey *) key changeType:(enum MHVThingChangeType) changeType;

-(void) assignNewChangeID;
-(void) assignNewTimestamp;
-(BOOL) isChangeForType:(NSString *) typeID;

+(BOOL) updateChange:(MHVThingChange *) change withTypeID:(NSString *) typeID key:(MHVThingKey *) key changeType:(enum MHVThingChangeType) changeType;
+(NSComparisonResult) compareChange:(MHVThingChange *) x to:(MHVThingChange *) y;

@end
