//
// MHVDIContainer.h
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

#import <Foundation/Foundation.h>
#import "MHVDIMapProtocol.h"
#import "MHVDIObjectDescriptor.h"


@interface MHVDIContainer : NSObject

- (void)registerAllocator:(MHVDIObjectAllocator)allocator forClass:(Class)aClass;
- (void)registerAllocator:(MHVDIObjectAllocator)allocator forClass:(Class)aClass isSingleton:(BOOL)cache;
- (void)registerClass:(Class)aClass forProtocol:(Protocol *)protocol;
- (void)unregisterClass:(Class)aClass;
- (id)objectForClass:(Class)aClass;
- (id)objectForClass:(Class)aClass key:(NSString *)key;
- (id)objectForProtocol:(Protocol *)protocol;

/*
 *  @brief Registers a class for a protocol, without checking if the class conforms to the protocol.
 *         Should only be used for protocols that wrap methods on base UIKit classes!
 *         Such as the notification methods on UIApplication.  This allows the protocol to be mocked
 *         in test cases.
 */
- (void)unsafeRegisterClass:(Class)aClass forProtocol:(Protocol *)protocol;

/*
 *  @brief Resolves a class from the DI map but always creates a new instance (ignores the isSingleton flag). This can be useful for testing purposes.
 */
- (id)newObjectForClass:(Class)aClass;
- (id)newObjectForClass:(Class)aClass key:(NSString *)key;

@end
