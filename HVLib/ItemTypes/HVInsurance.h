//
//  HVInsurance.h
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

@interface HVInsurance : HVItemDataTyped
{
@private
    NSString* m_planName;
    HVCodableValue* m_coverageType;
    NSString* m_carrierID;
    NSString* m_groupNum;
    NSString* m_planCode;
    NSString* m_subscriberID;
    NSString* m_personCode;
    NSString* m_subscriberName;
    HVDateTime* m_subsriberDOB;
    HVBool* m_isPrimary;
    HVDateTime* m_expirationDate;
    HVContact* m_contact;
}

//------------------
//
// Data
//
//-------------------
//
// (Optional) - Display Name for the plan
//
@property (readwrite, nonatomic, retain) NSString* planName;
//
// (Optional) - type of coverage E.g. 'Medical'
//
@property (readwrite, nonatomic, retain) HVCodableValue* coverageType;
//
// (Optional)- carrier id
//
@property (readwrite, nonatomic, retain) NSString* carrierID;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) NSString* groupNum;
//
// (Optional) Plan code or prefix, such as MSJ
//
@property (readwrite, nonatomic, retain) NSString* planCode;
//
// (Optional) 
//
@property (readwrite, nonatomic, retain) NSString* subscriberID;
//
// (Optional) Person code OR SUFFIX. E.g. 01 = Subscriber
//
@property (readwrite, nonatomic, retain) NSString* personCode;
@property (readwrite, nonatomic, retain) NSString* subsriberName;
//
// 
@property (readwrite, nonatomic, retain) HVDateTime* subscriberDOB;
@property (readwrite, nonatomic, retain) HVBool* isPrimary;
//
// (Optional) - When coverage expires
//
@property (readwrite, nonatomic, retain) HVDateTime* expirationDate;
//
// (Optional) - Contact info
//
@property (readwrite, nonatomic, retain) HVContact* contact;

//-------------------------
//
// Initializers
//
//-------------------------
+(HVItem *) newItem;

-(NSString *) toString;

//-------------------------
//
// Type information
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;


@end
