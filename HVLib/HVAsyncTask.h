//
//  HVAsyncTask.h
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

@class  HVTask;

typedef BOOL (^HVTaskMethod) (HVTask * task);
typedef void (^HVTaskCompletion) (HVTask* task);

@interface HVTask : NSObject
{
    NSString* m_taskName;  // Mainly for Debugging and Logging
    
    BOOL m_cancelled;
    BOOL m_completed;
    BOOL m_started;
    
    NSException *m_exception;

    id m_result;
    
    HVTaskMethod m_taskMethod;
    HVTaskCompletion m_callback;
    
    id m_operation;
    HVTask *m_parent; 
}

@property (readonly, nonatomic) BOOL hasError;
@property (readonly, nonatomic) BOOL isCancelled;
@property (readonly, nonatomic) BOOL isStarted;
@property (readonly, nonatomic) BOOL isComplete;
@property (readonly, nonatomic) BOOL isDone;

@property (readwrite, nonatomic, retain) NSString* taskName;
@property (readwrite, nonatomic, retain) id result;
@property (readonly, nonatomic, retain) id exception;
@property (readwrite, nonatomic, retain) id operation;

@property (readonly, nonatomic) HVTask* parent;
@property (readwrite, nonatomic, copy) HVTaskMethod method;
@property (readwrite, nonatomic, copy) HVTaskCompletion callback;

-(id) initWith:(HVTaskMethod) current;
-(id) initWithCallback:(HVTaskCompletion) callback;
-(id) initWithCallback:(HVTaskCompletion)callback andMethod:(HVTaskMethod) method;
-(id) initWithCallback:(HVTaskCompletion)callback andChildTask:(HVTask *)childTask;

-(BOOL) setNextMethod:(HVTaskMethod) nextMethod;
-(BOOL) setNextTask:(HVTask *) nextTask;

-(void) startChild:(HVTask *) childTask;

-(void) start;
-(void) cancel;
-(void) complete;
-(void) handleError:(id) error;

-(void) checkSuccess;

@end