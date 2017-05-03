//
//  HVAsyncTask.h
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

#import <Foundation/Foundation.h>
#import "HVBlock.h"

@class  HVTask;

typedef BOOL (^HVTaskMethod) (HVTask * task);
typedef void (^HVTaskCompletion) (HVTask* task);

//-----------------------
//
// Interacting with HealthVault can require a series of nested and/or
// related asynchronous operations. This class makes it easier to compose, manage
// and cancel these operations in a consistent way
//
//-----------------------
@interface HVTask : NSObject
{
@protected
    NSString* m_taskName;  // Mainly for Debugging and Logging
    
    BOOL m_cancelled;
    BOOL m_completed;
    BOOL m_started;
    
    NSException *m_exception;

    id m_result;
    
    HVTaskMethod m_taskMethod;
    HVTaskCompletion m_callback;
    
    id m_operation;
    
    BOOL m_completeInMainThread;
}

@property (readonly, nonatomic) BOOL hasError;
@property (readonly, nonatomic) BOOL isCancelled;
@property (readonly, nonatomic) BOOL isStarted;
@property (readonly, nonatomic) BOOL isComplete;
@property (readonly, nonatomic) BOOL isDone;
//
// Task name - optional. Good for debugging
//
@property (readwrite, nonatomic, strong) NSString* taskName;
//
// The RESULT of the Async task. Can be null if the task returns nothing.
// The gettor automatically calls [self checkSuccess], which can throw if there was an
// error while executing the asynchronous task
//
@property (readwrite, nonatomic, strong) id result;
//
// Any exception that the may have been thrown when the task ran, possibly in another thread
//
@property (readonly, nonatomic, strong) id exception;
//
// The actual operation being run by this task. Can include a system operation (NSUrlRequest) or (NSBlockOperation),
// OR another task.
//
// We keep a reference in this property and use it to issue nested cancellations
//
@property (readwrite, nonatomic, strong) id operation;
//
// This task's parent task
//
@property (readonly, nonatomic, weak) HVTask* parent;
//
// This task executes this method asynchronously by queuing an NSBlockOperation
//
@property (readwrite, nonatomic, copy) HVTaskMethod method;
//
// THE CALLBACK the task calls when it is done. In the callback you typically:
//  1. call task.result to get the task's result, if it returns any
//  2. and/or call [task checkSuccess]  {task.result does it for you}
//
// Either can throw, so make sure you have an exception handler around it
//
@property (readwrite, nonatomic, copy) HVTaskCompletion callback;
@property (readwrite, nonatomic) BOOL shouldCompleteInMainThread;

-(id) initWith:(HVTaskMethod) current;
-(id) initWithCallback:(HVTaskCompletion) callback;
-(id) initWithCallback:(HVTaskCompletion)callback andMethod:(HVTaskMethod) method;
-(id) initWithCallback:(HVTaskCompletion)callback andChildTask:(HVTask *)childTask;

-(BOOL) setNextMethod:(HVTaskMethod) nextMethod;
-(BOOL) setNextTask:(HVTask *) nextTask;

-(void) startChild:(HVTask *) childTask;

-(void) start;
-(void) start:(HVAction) startAction;
-(void) cancel;
-(void) complete;
-(void) handleError:(id) error;
-(void) clearError;

//
// Tasks run asnchronously. They capture any exceptions in self.exception, then invoke
// the task completion callback.
// This exception is then thrown when you call [task checkSuccess], 
//
-(void) checkSuccess;

@end

//
// A sequence of tasks
//
@interface HVTaskSequence : NSEnumerator
{
@protected
    NSString* m_name;
}

@property (readwrite, nonatomic, strong) NSString* name;

-(HVTask *) nextTask;
//
// You can override this in your implementation
//
-(void) onAborted;

//
// Use to run the task sequence
//
+(HVTask *) run:(HVTaskSequence *)sequence callback:(HVTaskCompletion) callback;
+(HVTask *) newRunTaskFor:(HVTaskSequence *)sequence callback:(HVTaskCompletion) callback;

@end
//
// Returns an enumeration of tasks
// The task must NOT be started
//
@interface HVTaskStateMachine : HVTaskSequence
{
@protected
    int m_stateID;
}

@property (readwrite, nonatomic) int stateID;

@end


