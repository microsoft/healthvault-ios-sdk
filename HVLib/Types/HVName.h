//
//  HVName.h
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

@interface HVName : HVType
{
@private
    NSString* m_full;
    HVCodableValue* m_title;
    NSString* m_first;
    NSString* m_middle;
    NSString* m_last;
    HVCodableValue* m_suffix;
}

//
// Required
//
@property (readwrite, nonatomic, retain) NSString* fullName;
//
// Optional
//
@property (readwrite, nonatomic, retain) HVCodableValue* title;
@property (readwrite, nonatomic, retain) NSString* first;
@property (readwrite, nonatomic, retain) NSString* middle;
@property (readwrite, nonatomic, retain) NSString* last;
@property (readwrite, nonatomic, retain) HVCodableValue* suffix;

// Returns the full name
-(NSString *) toString;

@end
