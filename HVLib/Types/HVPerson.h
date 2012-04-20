//
//  HVPerson.h
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
#import "HVCodableValue.h"
#import "HVContact.h"
#import "HVName.h"

@interface HVPerson : HVType
{
@private
    HVName* m_name;
    NSString* m_organization;
    NSString* m_training;
    NSString* m_id;
    HVContact* m_contact;
    HVCodableValue* m_type;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) Person's name
//
@property (readwrite, nonatomic, retain) HVName* name;
//
// (Optional) 
//
@property (readwrite, nonatomic, retain) NSString* organization;
//
// (Optional) 
//
@property (readwrite, nonatomic, retain) NSString* training;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) NSString* idNumber;
//
// (Optional) Contact information
//
@property (readwrite, nonatomic, retain) HVContact* contact;
//
// (Optional) 
// Vocabulary: person-types
//
@property (readwrite, nonatomic, retain) HVCodableValue* type;

//
// Returns the person's full name, if any
//
-(NSString *) toString;

@end
