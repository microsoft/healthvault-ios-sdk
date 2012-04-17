//
//  HVImmunization.h
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
#import "HVTypes.h"

@interface HVImmunization : HVItemDataTyped
{
    HVCodableValue* m_name;
    HVApproxDateTime* m_administeredDate;
    HVPerson* m_administrator;
    HVCodableValue* m_manufacturer;
    NSString* m_lot;
    HVCodableValue* m_route;
    HVApproxDate* m_expiration;
    NSString* m_sequence;
    HVCodableValue* m_anatomicSurface;
    NSString* m_adverseEvent;
    NSString* m_consent;
}

@property (readwrite, nonatomic, retain) HVCodableValue* name;
@property (readwrite, nonatomic, retain) HVApproxDateTime* administeredDate;
@property (readwrite, nonatomic, retain) HVPerson* administrator;
@property (readwrite, nonatomic, retain) HVCodableValue* manufacturer;
@property (readwrite, nonatomic, retain) NSString* lot;
@property (readwrite, nonatomic, retain) HVCodableValue* route;
@property (readwrite, nonatomic, retain) HVApproxDate* expiration;
@property (readwrite, nonatomic, retain) NSString* sequence;
@property (readwrite, nonatomic, retain) HVCodableValue* anatomicSurface;
@property (readwrite, nonatomic, retain) NSString* adverseEvent;
@property (readwrite, nonatomic, retain) NSString* consent;

-(id) initWithName:(NSString *) name;

-(NSString *) toString;

+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
