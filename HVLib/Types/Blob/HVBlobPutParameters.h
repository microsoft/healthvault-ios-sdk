//
//  HVBlobPutParameters.h
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
//

#import <Foundation/Foundation.h>
#import "HVType.h"

@interface HVBlobHashAlgorithmParameters : HVType
{
@private
    NSInteger m_blockSize;
}

@property (readwrite, nonatomic) NSInteger blockSize;

@end

@interface HVBlobPutParameters : HVType
{
@private
    NSString* m_url;
    NSInteger m_chunkSize;
    NSInteger m_maxSize;
    NSString* m_hashAlgorithm;
    HVBlobHashAlgorithmParameters* m_hashParams;
}

@property (readwrite, nonatomic, retain) NSString* url;
@property (readwrite, nonatomic) NSInteger chunkSize;
@property (readwrite, nonatomic) NSInteger maxSize;
@property (readwrite, nonatomic, retain) NSString* hashAlgorithm;
@property (readwrite, nonatomic, retain) HVBlobHashAlgorithmParameters* hashParams;


@end
