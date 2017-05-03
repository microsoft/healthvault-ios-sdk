//
//  HVLabTestResults.h
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

@interface HVLabTestResults : HVItemDataTyped
{
@private
    HVApproxDateTime* m_when;
    HVLabTestResultsGroupCollection* m_labGroup;
    HVOrganization* m_orderedBy;
}

@property (readwrite, nonatomic, strong) HVApproxDateTime* when;
@property (readwrite, nonatomic, strong) HVLabTestResultsGroupCollection* labGroup;
@property (readwrite, nonatomic, strong) HVOrganization* orderedBy;
//
// Convenience properties
//
@property (readonly, nonatomic, strong) HVLabTestResultsGroup* firstGroup;
//
// Lab groups can be nested.
// This returns all of them in a single collection
//
-(HVLabTestResultsGroupCollection *) getAllGroups;

//-------------------------
//
// Initializers
//
//-------------------------
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
