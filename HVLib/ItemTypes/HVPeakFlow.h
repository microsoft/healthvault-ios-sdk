//
//  HVPeakFlow.h
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
//

#import <Foundation/Foundation.h>
#import "HVTypes.h"

@interface HVPeakFlow : HVItemDataTyped
{
@private
    HVApproxDateTime* m_when;
    HVFlowValue* m_pef;
    HVVolumeValue* m_fev1;
    HVVolumeValue* m_fev6;
    HVCodableValue* m_flags;
}

//
// Required
//
@property (readwrite, nonatomic, strong) HVApproxDateTime* when;
//
// (Optional) liters/second
//
@property (readwrite, nonatomic, strong) HVFlowValue* peakExpiratoryFlow;
//
// (Optiona) Volume in 1 second
//
@property (readwrite, nonatomic, strong) HVVolumeValue* forcedExpiratoryVolume1;
//
// (Optional) Volume in 6 seconds
//
@property (readwrite, nonatomic, strong) HVVolumeValue* forcedExpiratoryVolume6;
//
// (Optional)
//
@property (readwrite, nonatomic, strong) HVCodableValue* flags;

//
// Convenience
//
@property (readwrite, nonatomic, assign) double pefValue;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithDate:(NSDate *) when;

+(HVItem *) newItem;


//-------------------------
//
// Text
//
//-------------------------
-(NSString *) toString;

//-------------------------
//
// Type information
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;

@end
