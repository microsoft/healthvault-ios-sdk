//
//  HVMethodFactory.h
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
//

#import <Foundation/Foundation.h>
#import "HVMethods.h"

//
// You can override the methods here to change, intercept or mock the behavior
// You can then assign your custom object to [HVClient current].methodFactory
// 
@interface HVMethodFactory : NSObject

-(HVGetItemsTask *) newGetItemsForRecord:(HVRecordReference *) record queries:(HVItemQueryCollection *)queries andCallback:(HVTaskCompletion)callback;

-(HVPutItemsTask *) newPutItemsForRecord:(HVRecordReference *) record items:(HVItemCollection *)items andCallback:(HVTaskCompletion)callback;
-(HVRemoveItemsTask *)newRemoveItemsForRecord:(HVRecordReference *) record keys:(HVItemKeyCollection *)keys andCallback:(HVTaskCompletion)callback;

@end

@interface HVMethodFactory (HVMethodFactoryExtensions)

-(HVGetItemsTask *) newGetItemsForRecord:(HVRecordReference *) record query:(HVItemQuery *)query andCallback:(HVTaskCompletion)callback;
-(HVPutItemsTask *) newPutItemForRecord:(HVRecordReference *) record item:(HVItem *) item andCallback:(HVTaskCompletion) callback;

@end
