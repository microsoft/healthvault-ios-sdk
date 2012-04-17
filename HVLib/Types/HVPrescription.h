//
//  HVPrescription.h
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


#import "HVType.h"
#import "HVBaseTypes.h"
#import "HVPerson.h"
#import "HVApproxDateTime.h"
#import "HVApproxMeasurement.h"
#import "HVCodableValue.h"
#import "HVDate.h"

@interface HVPrescription : HVType
{
@private
    HVPerson* m_prescriber;
    HVApproxDateTime* m_datePrescribed;
    HVApproxMeasurement* m_amount;
    HVCodableValue* m_substitution;
    HVNonNegativeInt* m_refills;
    HVPositiveInt* m_daysSupply;
    HVDate* m_expiration;
    HVCodableValue* m_instructions;
}
//
// Required
//
@property (readwrite, nonatomic, retain) HVPerson* prescriber;
//
// Optional
//
@property (readwrite, nonatomic, retain) HVApproxDateTime* datePrescribed;
@property (readwrite, nonatomic, retain) HVApproxMeasurement* amount;
@property (readwrite, nonatomic, retain) HVCodableValue* substitution;
@property (readwrite, nonatomic) int refills;
@property (readwrite, nonatomic) int daysSupply;
@property (readwrite, nonatomic, retain) HVDate* expirationDate;
@property (readwrite, nonatomic, retain) HVCodableValue* instructions;


@end
