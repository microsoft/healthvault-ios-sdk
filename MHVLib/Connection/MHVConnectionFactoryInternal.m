//
//  MHVConnectionFactoryInternal.m
//  MHVLib
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

#import "MHVConnectionFactoryInternal.h"
#import "MHVValidator.h"
#import "NSError+MHVError.h"
#import "MHVSodaConnection.h"

@interface MHVConnectionFactoryInternal ()

@property (nonatomic, strong) dispatch_queue_t connectionQueue;
@property (nonatomic, strong) NSMutableArray *completions;

@end

@implementation MHVConnectionFactoryInternal

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _connectionQueue = dispatch_queue_create("MHVConnectionFactoryInternal.connectionQueue", DISPATCH_QUEUE_SERIAL);
        _completions = [NSMutableArray new];
    }
    
    return self;
}

- (void)getOrCreatSodaConnectionWithConfiguration:(MHVConfiguration *_Nonnull)configuration
                                       completion:(void(^_Nonnull)(id<MHVSodaConnectionProtocol> _Nullable connection, NSError *_Nullable error))completion
{
    dispatch_async(self.connectionQueue, ^
    {
        MHVASSERT_PARAMETER(configuration);
        MHVASSERT_PARAMETER(completion);
        
        // The completion parameter is required. Return if it is not present.
        if (!completion)
        {
            return;
        }
        
        // The configuration parameter is required. Complete with an error if it is not present
        if (!configuration)
        {
            completion(nil, [NSError MVHInvalidParameter]);
        }
        
        // Add completions to the completions array
        if (completion)
        {
            [self.completions addObject:completion];
        }
        
        
        
        
    });
}

@end
