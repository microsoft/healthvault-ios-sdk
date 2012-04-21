//
//  HVRelative.h
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
#import "HVCodableValue.h"
#import "HVPerson.h"
#import "HVApproxDate.h"

@interface HVRelative : HVType
{
@private
    HVCodableValue* m_relationship;
    HVPerson* m_person;
    HVApproxDate* m_dateOfBirth;
    HVApproxDate* m_dateOfDeath;
    HVCodableValue* m_regionOfOrigin;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) - Mom, Dad, uncle etc
// Vocabulary: personal-relationship
//
@property (readwrite, nonatomic, retain) HVCodableValue* relationship;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVPerson* person;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVApproxDate* dateOfBirth;
// 
// (Optional)
//
@property (readwrite, nonatomic, retain) HVApproxDate* dateOfDeath;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVCodableValue* regionOfOrigin;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithRelationship:(NSString *) relationship;
-(id) initWithPerson:(HVPerson *) person andRelationship:(HVCodableValue *) relationship;

//-------------------------
//
// Text
//
//-------------------------
-(NSString *) toString;

@end
