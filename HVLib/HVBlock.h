//
//  HVBlock.h
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

#import <Foundation/Foundation.h>

//--------------------------------------
//
// Standard Lambda definitions
//
//--------------------------------------
typedef void (^HVAction) (void);
typedef BOOL (^HVPredicate) (void);
typedef void (^HVNotify) (id sender);
typedef BOOL (^HVHandler) (id value);
typedef BOOL (^HVFilter) (id value);
typedef id (^HVFunc) (id value);
typedef id (^HVFactory) (id key);


void safeInvokeAction(HVAction action);
void safeInvokeActionInMainThread(HVAction action);
void safeInvokeActionEx(HVAction action, BOOL useMainThread);
BOOL safeInvokePredicate(HVPredicate predicate);
void safeInvokeNotify(HVNotify notify, id sender);
BOOL safeInvokeHandler(HVHandler handler, id value);