//
//  HVCodableValue.h
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
#import "HVType.h"
#import "HVCodedValue.h"

//-------------------------
//
// A Text value with an optional set of associated vocabulary codes
// E.g. the name of a medication, with optional RXNorm codes
//
//-------------------------
@interface HVCodableValue : HVType
{
@private
    NSString* m_text;
    HVCodedValueCollection* m_codes;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required)
//
@property (readwrite, nonatomic, strong) NSString* text;
//
// (Optional)
//
@property (readwrite, nonatomic, strong) HVCodedValueCollection* codes;
//
// Convenience properties
//
@property (readonly, nonatomic) BOOL hasCodes;
@property (readonly, nonatomic, strong) HVCodedValue* firstCode;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithText:(NSString *) textValue;
-(id) initWithText:(NSString *)textValue andCode:(HVCodedValue *) code;
-(id) initWithText:(NSString *)textValue code:(NSString *) code andVocab:(NSString *) vocab;

+(HVCodableValue *) fromText:(NSString *) textValue;
+(HVCodableValue *) fromText:(NSString *)textValue andCode:(HVCodedValue *) code;
+(HVCodableValue *) fromText:(NSString *)textValue code:(NSString *) code andVocab:(NSString *) vocab;

//-------------------------
//
// Methods
//
//-------------------------

-(BOOL) containsCode:(HVCodedValue *) code;
-(BOOL) addCode:(HVCodedValue *) code;
-(void) clearCodes;

-(HVCodableValue *) clone;

//-------------------------
//
// Text
//
//-------------------------
-(NSString *) toString;
//
// Expects a format containing @%
//
-(NSString *) toStringWithFormat:(NSString *) format;
//
// Does a trimmed case insensitive comparison
//
-(BOOL) matchesDisplayText:(NSString *) text;

@end

@interface HVCodableValueCollection : HVCollection

-(void) addItem:(HVCodableValue *) value;
-(HVCodableValue *) itemAtIndex:(NSUInteger) index;

@end
