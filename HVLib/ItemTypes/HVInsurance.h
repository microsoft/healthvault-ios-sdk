//
//  HVInsurance.h
//  HVLib
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

#import <Foundation/Foundation.h>
#import "HVTypes.h"
#import "HVVocab.h"

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
@property (readwrite, nonatomic, strong) NSString* planName;
//
// (Optional) - type of coverage E.g. 'Medical'
//
@property (readwrite, nonatomic, strong) HVCodableValue* coverageType;
//
// (Optional)- carrier id
//
@property (readwrite, nonatomic, strong) NSString* carrierID;
//
// (Optional)
//
@property (readwrite, nonatomic, strong) NSString* groupNum;
//
// (Optional) Plan code or prefix, such as MSJ
//
@property (readwrite, nonatomic, strong) NSString* planCode;
//
// (Optional) 
//
@property (readwrite, nonatomic, strong) NSString* subscriberID;
//
// (Optional) Person code OR SUFFIX. E.g. 01 = Subscriber
//
@property (readwrite, nonatomic, strong) NSString* personCode;
@property (readwrite, nonatomic, strong) NSString* subscriberName;
//
// 
@property (readwrite, nonatomic, strong) HVDateTime* subscriberDOB;
@property (readwrite, nonatomic, strong) HVBool* isPrimary;
//
// (Optional) - When coverage expires
//
@property (readwrite, nonatomic, strong) HVDateTime* expirationDate;
//
// (Optional) - Contact info
//
@property (readwrite, nonatomic, strong) HVContact* contact;

//-------------------------
//
// Initializers
//
//-------------------------
+(HVItem *) newItem;

-(NSString *) toString;

//-------------------------
//
// Vocabulary
//
//-------------------------
+(HVVocabIdentifier *) vocabForCoverage;

//-------------------------
//
// Type information
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;


@end
