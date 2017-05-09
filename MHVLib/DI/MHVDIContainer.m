//
// MHVDIContainer.m
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

static NSString *const kDefaultAllocatorKey = @"MHVDIMapDefaultAllocatorKey";

@interface MHVDIContainer ()

@property (nonatomic, strong)    NSMutableDictionary        *allocatorMap;
@property (nonatomic, strong)    NSMutableDictionary        *protocolMap;
@property (nonatomic, assign)    BOOL                       isInitiated;

@end

@implementation MHVDIContainer

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.allocatorMap = [NSMutableDictionary new];
        self.protocolMap = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)registerAllocator:(MHVDIObjectAllocator)allocator forClass:(Class)aClass
{
    [self registerAllocator:allocator forClass:aClass isSingleton:NO];
}

- (void)registerAllocator:(MHVDIObjectAllocator)allocator forClass:(Class)aClass isSingleton:(BOOL)cache
{
    NSParameterAssert(allocator);
    NSParameterAssert(aClass);
    
    MHVDIObjectDescriptor *descriptor = [[MHVDIObjectDescriptor alloc] initWithAllocator:allocator object:nil isSingleton:cache];
    [self.allocatorMap setObject:descriptor forKey:NSStringFromClass(aClass)];
}

- (void)registerClass:(Class)aClass forProtocol:(Protocol *)protocol
{
    NSParameterAssert(aClass);
    NSParameterAssert(protocol);
    
    if (![aClass conformsToProtocol:protocol])
    {
        NSAssert(NO, @"%@ does not conform to %@ protocol.", NSStringFromClass(aClass), NSStringFromProtocol(protocol));
        
        return;
    }
    
    NSString *protoName = NSStringFromProtocol(protocol);
    self.protocolMap[protoName] = aClass;
}

- (void)unsafeRegisterClass:(Class)aClass forProtocol:(Protocol *)protocol
{
    //!! Should only be used for protocols that wrap methods on base UIKit classes
    //!! For all others, user registerClass to confirm the class conforms to the protocol
    NSParameterAssert(aClass);
    NSParameterAssert(protocol);
    
    NSString *protoName = NSStringFromProtocol(protocol);
    self.protocolMap[protoName] = aClass;
}

- (void)unregisterClass:(Class)aClass
{
    NSParameterAssert(aClass);
    
    [self.allocatorMap removeObjectForKey:NSStringFromClass(aClass)];
}


- (id)objectForClass:(Class)aClass
{
    return [self objectForClass:aClass key:kDefaultAllocatorKey];
}


- (id)objectForClass:(Class)aClass key:(NSString *)key
{
    NSParameterAssert(aClass);
    
    MHVDIObjectDescriptor *descriptor = [self.allocatorMap objectForKey:NSStringFromClass(aClass)];
    if(!descriptor)
    {
        @throw [NSException exceptionWithName:@"classNotRegisteredForKey" reason:[NSString stringWithFormat:@"Class %@ not registered with DI container.", NSStringFromClass(aClass)] userInfo:nil];
        return nil;
    }
    
    //If already exists or not singleton, can return without any extra @synchronized overhead
    if(descriptor.isSingleton && descriptor.object)
    {
        return descriptor.object;
    }
    if(!descriptor.isSingleton)
    {
        return descriptor.allocator(key);
    }
    
    @synchronized(aClass)
    {
        //Check again, in case thread B was blocked by another thread A that just allocated the object they both want
        if(descriptor.isSingleton && descriptor.object)
        {
            return descriptor.object;
        }
        
        descriptor.object = descriptor.allocator(key);
        
        return descriptor.object;
    }
}


/*
 *  Resolves a class from the DI map but always creates a new instance (ignores the isSingleton flag). This can be useful for testing purposes.
 */
- (id)newObjectForClass:(Class)aClass
{
    return [self newObjectForClass:aClass key:kDefaultAllocatorKey];
}


- (id)newObjectForClass:(Class)aClass key:(NSString *)key
{
    NSParameterAssert(aClass);
    
    MHVDIObjectDescriptor *descriptor = [self.allocatorMap objectForKey:NSStringFromClass(aClass)];
    if(!descriptor)
    {
        @throw [NSException exceptionWithName:@"classNotRegistered" reason:[NSString stringWithFormat:@"Class %@ not registered with DI container.", NSStringFromClass(aClass)] userInfo:nil];
        return nil;
    }
    
    id newObject = descriptor.allocator(key);
    return newObject;
}


- (id)objectForProtocol:(Protocol *)protocol
{
    NSParameterAssert(protocol);
    
    NSString *protoName = NSStringFromProtocol(protocol);
    Class registeredClass = self.protocolMap[protoName];
    if(!registeredClass)
    {
        @throw [NSException exceptionWithName:@"protocolNotRegistered" reason:[NSString stringWithFormat:@"Protocol %@ not registered with DI container.", protoName] userInfo:nil];
        return nil;
    }
    
    return [self objectForClass:registeredClass];
}


@end
