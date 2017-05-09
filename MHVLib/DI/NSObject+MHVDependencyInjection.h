//
// NSObject+MHVDependencyInjection.h
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

#define ResolveProtocol(protocolName) ((id<protocolName>)([NSObject resolveProtocol:@protocol(protocolName)]))
#define ResolveClass(className) ((className *)([NSObject resolveClass:[className class]]))
#define ResolveNewInstanceOfClass(className) ([NSObject resolveNewInstanceOfClass:[className class]])

@interface NSObject (MHVDependencyInjection)


+ (id)injectableInstance;
+ (id)injectableInstanceWithKey:(NSString *)key;
+ (id)resolveClass:(Class)aClass;
+ (id)resolveNewInstanceOfClass:(Class)aClass;
+ (id)resolveProtocol:(Protocol *)aProtocol;


@end
