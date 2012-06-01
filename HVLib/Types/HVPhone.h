//
//  HVPhone.h
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

#import "HVType.h"
#import "HVBaseTypes.h"
#import "HVCollection.h"
#import "HVVocab.h"

@interface HVPhone : HVType
{
@private
    NSString* m_type;
    HVBool* m_isprimary;
    NSString* m_number;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) Phone number
// Note: the SDK does not validate if the phone number is in valid
// phone number format. 
//
@property (readwrite, nonatomic, retain) NSString* number;
//
// (Optional) A description of this number (Cell, Home, Work)
//
@property (readwrite, nonatomic, retain) NSString* type;
//
// (Optional) 
//
@property (readwrite, nonatomic, retain) HVBool* isPrimary;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithNumber:(NSString *) number;

//-------------------------
//
// Text
//
//-------------------------

-(NSString *) toString;

+(HVVocabIdentifier *) vocabForType;

@end

//-------------------------
//
// HVPhoneCollection
//
//-------------------------
@interface HVPhoneCollection : HVCollection

-(HVPhone *) itemAtIndex:(NSUInteger) index;

@end
