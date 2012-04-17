//
//  HVProcedure.h
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

@interface HVProcedure : HVItemDataTyped
{
@private
    HVApproxDateTime* m_when;
    HVCodableValue* m_name;
    HVCodableValue* m_anatomicLocation;
    HVPerson* m_primaryProvider;
    HVPerson* m_secondaryProvider;
}

//
// Required
//
@property (readwrite, nonatomic, retain) HVCodableValue* name;
//
// Optional
//
@property (readwrite, nonatomic, retain) HVApproxDateTime* when;
@property (readwrite, nonatomic, retain) HVCodableValue* anatomicLocation;
@property (readwrite, nonatomic, retain) HVPerson* primaryProvider;
@property (readwrite, nonatomic, retain) HVPerson* secondaryProvider;

-(id) initWithName:(NSString *) name;

-(NSString *) toString;

+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
