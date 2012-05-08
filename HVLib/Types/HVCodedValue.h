//
//  HVCodedValue.h
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
#import "HVVocabItem.h"

@class HVCodedValueCollection;

//-------------------------
//
// A code from a standard vocabulary
// Includes the code, the vocabulary name, family and version
//
//-------------------------
@interface HVCodedValue : HVType
{
@private
    NSString* m_code;
    NSString* m_vocab;
    NSString* m_family;
    NSString* m_version;    
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) Vocabulary Code
//
@property (readwrite, nonatomic, retain) NSString* code;
//
// (Required)The vocabulary code is from E.g. "Rx Norm Active Medications"
//
@property (readwrite, nonatomic, retain) NSString* vocabularyName;
//
// (Optional) Vocabulary Family. E.g. "RxNorm"
//
@property (readwrite, nonatomic, retain) NSString* vocabularyFamily;
//
// (Optional) Vocabulary Version
//
@property (readwrite, nonatomic, retain) NSString* vocabularyVersion;

//-------------------------
//
// Initializers
//
//-------------------------

-(id) initWithCode:(NSString *) code andVocab:(NSString *) vocab; 
-(id) initWithCode:(NSString *) code vocab:(NSString *) vocab vocabFamily:(NSString *) family vocabVersion:(NSString *) version; 

+(HVCodedValue *) fromCode:(NSString *) code andVocab:(NSString *) vocab; 
+(HVCodedValue *) fromCode:(NSString *) code vocab:(NSString *) vocab vocabFamily:(NSString *) family vocabVersion:(NSString *) version; 

//-------------------------
//
// Methods
//
//-------------------------

-(BOOL) isEqualToCodedValue:(HVCodedValue *) value;
-(BOOL) isEqualToCode:(NSString *) code fromVocab:(NSString *) vocabName;
-(BOOL) isEqual:(id)object;

@end

@interface HVCodedValueCollection : HVCollection 

-(HVCodedValue *) firstCode;

-(HVCodedValue *) itemAtIndex:(NSUInteger) index;
-(NSUInteger) indexOfCode:(HVCodedValue *) code;
-(BOOL) containsCode:(HVCodedValue *) code;

@end
