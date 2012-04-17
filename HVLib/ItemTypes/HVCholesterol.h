//
//  HVCholesterol.h
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

@interface HVCholesterol : HVItemDataTyped
{
@private
    HVDate* m_date;
    HVInt* m_ldl;
    HVInt* m_hdl;
    HVInt* m_total;
    HVInt* m_triglycerides;
}

@property (readwrite, nonatomic, retain) HVDate* when;
@property (readwrite, nonatomic, retain) HVInt* ldl;
@property (readwrite, nonatomic, retain) HVInt* hdl;
@property (readwrite, nonatomic, retain) HVInt* total;
@property (readwrite, nonatomic, retain) HVInt* triglycerides;

@property (readwrite, nonatomic) int ldlValue;
@property (readwrite, nonatomic) int hdlValue;
@property (readwrite, nonatomic) int totalValue;
@property (readwrite, nonatomic) int triglyceridesValue;

//
// Creates a string for ldl/hdl
//
-(NSString *) toString;
-(NSString *) toStringWithFormat:(NSString *) format;

+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
