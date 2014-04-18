//
//  HVLabTestResultsGroup.h
//  HVLib
//
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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
#import "HVType.h"
#import "HVLabTestResultsDetails.h"
#import "HVOrganization.h"

@class HVLabTestResultsGroupCollection;

@interface HVLabTestResultsGroup : HVType
{
@private
    HVCodableValue* m_groupName;
    HVOrganization* m_laboratory;
    HVCodableValue* m_status;
    HVLabTestResultsGroupCollection* m_subGroups;
    HVLabTestResultsDetailsCollection* m_results;
}

@property (readwrite, nonatomic, retain) HVCodableValue* groupName;
@property (readwrite, nonatomic, retain) HVOrganization* laboratory;
@property (readwrite, nonatomic, retain) HVCodableValue* status;
@property (readwrite, nonatomic, retain) HVLabTestResultsGroupCollection* subGroups;
@property (readwrite, nonatomic, retain) HVLabTestResultsDetailsCollection* results;

@property (readonly, nonatomic) BOOL hasSubGroups;

-(void) addToCollection:(HVLabTestResultsGroupCollection *) groups;

@end

@interface HVLabTestResultsGroupCollection : HVCollection

-(void) addItem:(HVLabTestResultsGroup *) item;
-(HVLabTestResultsGroup *) itemAtIndex:(NSUInteger) index;

-(void) addItemsToCollection:(HVLabTestResultsGroupCollection *) groups;

@end
