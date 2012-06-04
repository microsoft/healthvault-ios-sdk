//
//  HVAddress.h
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

@interface HVAddress : HVType
{
@private
    NSString* m_type;
    HVBool* m_isprimary;
    HVStringCollection* m_street;
    NSString* m_city;
    NSString* m_state;
    NSString* m_postalCode;
    NSString* m_country;
    NSString* m_county;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Optional) A description of this address, such as "Home"
//
@property (readwrite, nonatomic, retain) NSString* type;
@property (readwrite, nonatomic, retain) HVBool* isPrimary;
//
// (Required)
//
@property (readwrite, nonatomic, retain) HVStringCollection* street;
//
// (Required)
// 
@property (readwrite, nonatomic, retain) NSString* city;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) NSString* state;
//
// (Required)
//
@property (readwrite, nonatomic, retain) NSString* postalCode;
//
// (Required)
//
@property (readwrite, nonatomic, retain) NSString* country;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) NSString* county;

@property (readonly, nonatomic) BOOL hasStreet;

//-------------------------
//
// Vocabs
//
//-------------------------
+(HVVocabIdentifier *) vocabForCountries;
+(HVVocabIdentifier *) vocabForUSStates;
+(HVVocabIdentifier *) vocabForCanadianProvinces;

//-------------------------
//
// Text
//
//-------------------------
-(NSString *) toString;

@end


//-------------------------
//
// HVAddressCollection
//
//-------------------------

@interface HVAddressCollection : HVCollection

-(HVAddress *) itemAtIndex:(NSUInteger) index;

@end
