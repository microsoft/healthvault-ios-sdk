//
//  HVCondition.h
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
#import "HVVocab.h"

@interface HVCondition : HVItemDataTyped
{
@private
    HVCodableValue* m_name;
    HVApproxDateTime* m_onsetDate;
    HVCodableValue* m_status;
    HVApproxDateTime* m_stopDate;
    NSString* m_stopReason;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) This condition's name
// Vocabularies: icd9cm, Snomed etc
//
@property (readwrite, nonatomic, retain) HVCodableValue* name;
//
// Optional: 
//
@property (readwrite, nonatomic, retain) HVApproxDateTime* onsetDate;
//
// Optional: 'acute', 'chronic' etc
// Vocabulary: condition-occurence
//
@property (readwrite, nonatomic, retain) HVCodableValue* status;
//
// Optional: Has the condition stoped? 
//
@property (readwrite, nonatomic, retain) HVApproxDateTime* stopDate;
//
// Optional
//
@property (readwrite, nonatomic, retain) NSString* stopReason;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithName:(NSString *) name;

//-------------------------
//
// Text
//
//-------------------------
-(NSString *) toString;

//-------------------------
//
// Standard Vocabs
//
//-------------------------
+(HVVocabIdentifier *) vocabForStatus;

//-------------------------
//
// Type Information
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
