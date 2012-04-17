//
//  HVBasicDemographics.h
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

enum HVGender 
{
    HVGender_None = 0,
    HVGender_Female,
    HVGender_Male
};

NSString* stringFromGender(enum HVGender gender);
enum HVGender stringToGender(NSString* genderString);
    
@interface HVBasicDemographics : HVItemDataCommon
{
@private
    enum HVGender m_gender;
    HVYear* m_birthYear;
    HVCodableValue* m_country;
    NSString* m_postalCode;
    NSString* m_city;
    NSString* m_state;
    int m_firstDOW;
    NSString* m_languageXml;
}

@property (readwrite, nonatomic) enum HVGender gender;
@property (readwrite, nonatomic, retain) HVYear* birthYear;
@property (readwrite, nonatomic, retain) HVCodableValue* country;
@property (readwrite, nonatomic, retain) NSString* postalCode;
@property (readwrite, nonatomic, retain) NSString* city;
@property (readwrite, nonatomic, retain) NSString* state;
@property (readwrite, nonatomic, retain) NSString* languageXml;

+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
