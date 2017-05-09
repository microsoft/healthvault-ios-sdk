//
// NSObject+MHVDependencyInjection.m
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

#import "MHVDIContainer.h"
#import "NSObject+MHVDependencyInjection.h"
#import "MHVInstanceLocator.h"

@implementation NSObject (MHVDependencyInjection)


+ (id)injectableInstance
{
    id object = [[MHVInstanceLocator defaultContainer] objectForClass:self];
    return object;
}

+ (id)injectableInstanceWithKey:(NSString *)key
{
    id object = [[MHVInstanceLocator defaultContainer] objectForClass:self key:key];
    return object;
}

+ (id)resolveClass:(Class)aClass
{
    id object = [[MHVInstanceLocator defaultContainer] objectForClass:aClass];
    return object;
}

+ (id)resolveNewInstanceOfClass:(Class)aClass
{
    id object = [[MHVInstanceLocator defaultContainer] newObjectForClass:aClass];
    return object;
}

+ (id)resolveProtocol:(Protocol *)protocol
{
    id object = [[MHVInstanceLocator defaultContainer] objectForProtocol:protocol];
    return object;
}

@end
