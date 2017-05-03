//
//  HVVitalSigns.h
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

@interface HVVitalSigns : HVItemDataTyped
{
@private
    HVDateTime* m_when;
    HVVitalSignResultCollection* m_results;
    NSString* m_site;
    NSString* m_position;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) When the vital sign was taken
//
@property (readwrite, nonatomic, strong) HVDateTime* when;
//
// (Optional)
//
@property (readwrite, nonatomic, strong) HVVitalSignResultCollection* results;
//
// (Optional)
//
@property (readwrite, nonatomic, strong) NSString* site;
@property (readwrite, nonatomic, strong) NSString* position;

@property (readonly, nonatomic) BOOL hasResults;
@property (readonly, nonatomic, strong) HVVitalSignResult* firstResult;

//-------------------------
//
// Initializers
//
//-------------------------

-(id) initWithDate:(NSDate *) date;
-(id) initWithResult:(HVVitalSignResult *) result onDate:(NSDate *) date;

+(HVItem *) newItem;

//-------------------------
//
// Type Info
//
//-------------------------

+(NSString *) typeID;
+(NSString *) XRootElement;

@end
