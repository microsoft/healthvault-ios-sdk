//
//  MHVBlock.m
//  MHVLib
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

#import "MHVCommon.h"
#import "MHVBlock.h"

void safeInvokeAction(MHVAction action)
{
    if (action)
    {
        @try
        {
            action();
        }
        @catch(id ex)
        {
            [ex log];
        }
    }
}

void safeInvokeActionInMainThread(MHVAction action)
{
    NSBlockOperation* op = [NSBlockOperation blockOperationWithBlock:^(void){ 
        @try 
        {
            if (action)
            {
                action();
            }
        }
        @catch (id ex) 
        {
            [ex log];
        }
    }];
    
    @try
    {
        [[NSOperationQueue mainQueue] addOperation:op];
    }
    @catch (id exception)
    {
        [exception log];
    }
}

void safeInvokeActionEx(MHVAction action, BOOL useMainThread)
{
    if (useMainThread)
    {
        safeInvokeActionInMainThread(action);
    }
    else
    {
        safeInvokeAction(action);
    }
}

BOOL safeInvokePredicate(MHVPredicate predicate)
{
    if (predicate)
    {
        @try
        {
            return predicate();
        }
        @catch(id ex)
        {
            [ex log];
        }
    }
    
    return FALSE;
}

void safeInvokeNotify(MHVNotify notify, id sender)
{
    if (notify)
    {
        @try
        {
            notify(sender);
        }
        @catch(id ex)
        {
            [ex log];
        }
    }
}

BOOL safeInvokeHandler(MHVHandler handler, id value)
{
    if (handler)
    {
        @try
        {
            return handler(value);
        }
        @catch(id ex)
        {
            [ex log];
        }
    }
    
    return false;
}
