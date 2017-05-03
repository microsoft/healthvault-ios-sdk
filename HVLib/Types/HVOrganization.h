//
//  HVOrganization.h
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
#import "HVType.h"
#import "HVContact.h"
#import "HVCodableValue.h"

@interface HVOrganization : HVType
{
@private
    NSString* m_name;
    HVContact* m_contact;
    HVCodableValue* m_type;
    NSString* m_webSite;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required)
//
@property (readwrite, nonatomic, strong) NSString* name;
//
// (Optional)
//
@property (readwrite, nonatomic, strong) HVContact* contact;
//
// (Optional)
//
@property (readwrite, nonatomic, strong) HVCodableValue* type;
//
// (Optional)
//
@property (readwrite, nonatomic, strong) NSString* website;

-(NSString *) toString;

@end
