//
//  HVCodableValue.h
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
@property (readwrite, nonatomic, retain) NSString* text;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVCodedValueCollection* codes;
//
// Convenience properties
//
@property (readonly, nonatomic) BOOL hasCodes;
@property (readonly, nonatomic) HVCodedValue* firstCode;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithText:(NSString *) textValue;
-(id) initWithText:(NSString *)textValue andCode:(HVCodedValue *) code;
-(id) initWithText:(NSString *)textValue code:(NSString *) code andVocab:(NSString *) vocab;

-(NSString *) toString;

@end

@interface HVCodableValueCollection : HVCollection

-(HVCodableValue *) itemAtIndex:(NSUInteger) index;

@end
