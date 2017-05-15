//
// MHVMethodFactory.h
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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
#import "MHVMethods.h"

//
// You can override the methods here to change, intercept or mock the behavior
// You can then assign your custom object to [MHVClient current].methodFactory
//
@interface MHVMethodFactory : NSObject

- (MHVGetThingsTask *)newGetThingsForRecord:(MHVRecordReference *)record queries:(MHVThingQueryCollection *)queries andCallback:(MHVTaskCompletion)callback;

- (MHVPutThingsTask *)newPutThingsForRecord:(MHVRecordReference *)record things:(MHVThingCollection *)things andCallback:(MHVTaskCompletion)callback;
- (MHVRemoveThingsTask *)newRemoveThingsForRecord:(MHVRecordReference *)record keys:(MHVThingKeyCollection *)keys andCallback:(MHVTaskCompletion)callback;

@end

@interface MHVMethodFactory (MHVMethodFactoryExtensions)

- (MHVGetThingsTask *)newGetThingsForRecord:(MHVRecordReference *)record query:(MHVThingQuery *)query andCallback:(MHVTaskCompletion)callback;
- (MHVPutThingsTask *)newPutThingForRecord:(MHVRecordReference *)record thing:(MHVThing *)thing andCallback:(MHVTaskCompletion)callback;

@end
