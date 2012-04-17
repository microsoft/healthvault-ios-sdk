//
//  HVVitalSigns.h
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

@interface HVVitalSigns : HVItemDataTyped
{
@private
    HVDateTime* m_when;
    HVVitalSignResultCollection* m_results;
    NSString* m_site;
    NSString* m_position;
}

@property (readwrite, nonatomic, retain) HVDateTime* when;
@property (readwrite, nonatomic, retain) HVVitalSignResultCollection* results;
@property (readwrite, nonatomic, retain) NSString* site;
@property (readwrite, nonatomic, retain) NSString* position;

@property (readonly, nonatomic) BOOL hasResults;
@property (readonly, nonatomic) HVVitalSignResult* firstResult;

-(id) initWithDate:(NSDate *) date;
-(id) initWithResult:(HVVitalSignResult *) result onDate:(NSDate *) date;

+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
