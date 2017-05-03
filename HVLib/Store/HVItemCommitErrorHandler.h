//
//  HVItemCommitErrorHandler.h
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
//

#import <Foundation/Foundation.h>
#import "HVItemChange.h"
#import "HVServerResponseStatus.h"

@interface HVItemCommitErrorHandler : NSObject
{
@private
    int m_maxAttemptsPerChange;
}

@property (readwrite, nonatomic, assign) int maxAttemptsPerChange;

-(BOOL) isHaltingException:(id) ex;
-(BOOL) shouldRetryChange:(HVItemChange *) change onException:(id) ex;
-(BOOL) shouldCreateNewItemForConflict:(HVItemChange *) change onException:(id) ex;

-(BOOL) isItemKeyNotFoundException:(id) ex;
-(BOOL) isSerializationException:(id) ex;
-(BOOL) isAccessDeniedException:(id) ex;
-(BOOL) isClientException:(id) ex;

-(BOOL) isHttpException:(id) ex;
-(BOOL) isNetworkError:(id) ex;
-(BOOL) isServerException:(id) ex;
-(BOOL) isServerTokenException:(id) ex;

@end
