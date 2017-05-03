//
//  HVAssessment.h
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

@interface HVAssessment : HVItemDataTyped
{
@private
    HVDateTime* m_when;
    NSString* m_name;
    HVCodableValue* m_category;
    HVAssessmentFieldCollection* m_results;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required)
//
@property (readwrite, nonatomic, strong) HVDateTime* when;
//
// (Required)
//
@property (readwrite, nonatomic, strong) NSString* name;
// 
// (Required)
//
@property (readwrite, nonatomic, strong) HVCodableValue* category;
//
// (Required)
//
@property (readwrite, nonatomic, strong) HVAssessmentFieldCollection* results;

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

-(NSString *) toString;

//-------------------------
//
// Type Info
//
//-------------------------

+(NSString *) typeID;
+(NSString *) XRootElement;

@end
