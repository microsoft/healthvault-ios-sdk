//
//  HVConditionEntry.h
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
#import "HVType.h"
#import "HVCodableValue.h"
#import "HVApproxDate.h"

@interface HVConditionEntry : HVType
{
@private
    HVCodableValue* m_name;
    HVApproxDate* m_onsetDate;
    HVApproxDate* m_resolutionDate;
    NSString* m_resolution;
    HVCodableValue* m_occurrence;
    HVCodableValue* m_severity;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required)
// Vocabularies: icd9, snomed
//
@property (readwrite, nonatomic, retain) HVCodableValue* name;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVApproxDate* onsetDate;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVApproxDate* resolutionDate;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) NSString* resolution;
// 
// (Optional)
//
@property (readwrite, nonatomic, retain) HVCodableValue* occurrence;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) HVCodableValue* severity;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithName:(NSString *) name;

//-------------------------
//
// Text
//
//-------------------------
-(NSString *) toString;

@end

@interface HVConditionEntryCollection : HVCollection

@end
