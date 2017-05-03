//
//  HVBasicDemographics.h
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

enum HVGender 
{
    HVGenderNone = 0,
    HVGenderFemale,
    HVGenderMale
};

NSString* stringFromGender(enum HVGender gender);
enum HVGender stringToGender(NSString* genderString);

//
// Basic demographics contain less private information about the person - and may be
// easier for the user to share with others. 
//
// HVPersonalDemographics contains more personal information that the user may wish to
// keep entirely private. 
//
@interface HVBasicDemographics : HVItemDataTyped
{
@private
    enum HVGender m_gender;
    HVYear* m_birthYear;
    HVCodableValue* m_country;
    NSString* m_postalCode;
    NSString* m_city;
    HVCodableValue* m_state;
    HVInt* m_firstDOW;
    NSString* m_languageXml;
}

//-------------------------
//
// Data
//
//-------------------------
//
// ALL fields are optional
//
@property (readwrite, nonatomic) enum HVGender gender;
@property (readwrite, nonatomic, strong) HVYear* birthYear;
@property (readwrite, nonatomic, strong) HVCodableValue* country;
@property (readwrite, nonatomic, strong) NSString* postalCode;
@property (readwrite, nonatomic, strong) NSString* city;
@property (readwrite, nonatomic, strong) HVCodableValue* state;
@property (readwrite, nonatomic, strong) NSString* languageXml;

//-------------------------
//
// Initializers
//
//-------------------------
+(HVItem *) newItem;

//-------------------------
//
// Text
//
//-------------------------
-(NSString *) genderAsString;

//-------------------------
//
// Vocab
//
//-------------------------
+(HVVocabIdentifier *) vocabForGender;

//-------------------------
//
// Type Information
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;

@end
