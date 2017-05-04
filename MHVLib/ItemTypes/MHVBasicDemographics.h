//
//  MHVBasicDemographics.h
//  MHVLib
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
#import "MHVTypes.h"
#import "MHVVocab.h"

enum MHVGender 
{
    MHVGenderNone = 0,
    MHVGenderFemale,
    MHVGenderMale
};

NSString* stringFromGender(enum MHVGender gender);
enum MHVGender stringToGender(NSString* genderString);

//
// Basic demographics contain less private information about the person - and may be
// easier for the user to share with others. 
//
// MHVPersonalDemographics contains more personal information that the user may wish to
// keep entirely private. 
//
@interface MHVBasicDemographics : MHVItemDataTyped
{
@private
    enum MHVGender m_gender;
    MHVYear* m_birthYear;
    MHVCodableValue* m_country;
    NSString* m_postalCode;
    NSString* m_city;
    MHVCodableValue* m_state;
    MHVInt* m_firstDOW;
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
@property (readwrite, nonatomic) enum MHVGender gender;
@property (readwrite, nonatomic, strong) MHVYear* birthYear;
@property (readwrite, nonatomic, strong) MHVCodableValue* country;
@property (readwrite, nonatomic, strong) NSString* postalCode;
@property (readwrite, nonatomic, strong) NSString* city;
@property (readwrite, nonatomic, strong) MHVCodableValue* state;
@property (readwrite, nonatomic, strong) NSString* languageXml;

//-------------------------
//
// Initializers
//
//-------------------------
+(MHVItem *) newItem;

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
+(MHVVocabIdentifier *) vocabForGender;

//-------------------------
//
// Type Information
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;

@end
