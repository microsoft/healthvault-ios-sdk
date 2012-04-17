//
//  HVAllergy.h
//  HVLib
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

@interface HVAllergy : HVItemDataTyped
{
@private
    HVCodableValue* m_name;
    HVCodableValue* m_reaction;
    HVApproxDateTime* m_firstObserved;
    HVCodableValue* m_allergenType;
    HVCodableValue* m_allergenCode;
    HVPerson* m_treatmentProvider;
    HVCodableValue* m_treatment;
    HVBool* m_isNegated;
}

@property (readwrite, nonatomic, retain) HVCodableValue* name;
@property (readwrite, nonatomic, retain) HVCodableValue* reaction;
@property (readwrite, nonatomic, retain) HVApproxDateTime* firstObserved;
@property (readwrite, nonatomic, retain) HVCodableValue* allergenType;
@property (readwrite, nonatomic, retain) HVCodableValue* allergenCode;
@property (readwrite, nonatomic, retain) HVPerson* treatmentProvider;
@property (readwrite, nonatomic, retain) HVCodableValue* treatment;
@property (readwrite, nonatomic, retain) HVBool* isNegated;

+(NSString *) typeID;
+(NSString *) XRootElement;

-(NSString *) toString;

+(HVItem *) newItem;

@end
