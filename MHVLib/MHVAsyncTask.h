//
//  MHVAsyncTask.h
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

#import <Foundation/Foundation.h>
#import "MHVBlock.h"

@class  MHVTask;

typedef BOOL (^MHVTaskMethod) (MHVTask * task);
typedef void (^MHVTaskCompletion) (MHVTask* task);

//-----------------------
//
// Interacting with HealthVault can require a series of nested and/or
// related asynchronous operations. This class makes it easier to compose, manage
// and cancel these operations in a consistent way
//
//-----------------------
@interface MHVTask : NSObject
{
@protected
    NSString* m_taskName;  // Mainly for Debugging and Logging
    
    BOOL m_cancelled;
    BOOL m_completed;
    BOOL m_started;
    
    NSException *m_exception;

    id m_result;
    
    MHVTaskMethod m_taskMethod;
    MHVTaskCompletion m_callback;
    
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
@property (readonly, nonatomic, weak) MHVTask* parent;
//
// This task executes this method asynchronously by queuing an NSBlockOperation
//
@property (readwrite, nonatomic, copy) MHVTaskMethod method;
//
// THE CALLBACK the task calls when it is done. In the callback you typically:
//  1. call task.result to get the task's result, if it returns any
//  2. and/or call [task checkSuccess]  {task.result does it for you}
//
// Either can throw, so make sure you have an exception handler around it
//
@property (readwrite, nonatomic, copy) MHVTaskCompletion callback;
@property (readwrite, nonatomic) BOOL shouldCompleteInMainThread;

-(id) initWith:(MHVTaskMethod) current;
-(id) initWithCallback:(MHVTaskCompletion) callback;
-(id) initWithCallback:(MHVTaskCompletion)callback andMethod:(MHVTaskMethod) method;
-(id) initWithCallback:(MHVTaskCompletion)callback andChildTask:(MHVTask *)childTask;

-(BOOL) setNextMethod:(MHVTaskMethod) nextMethod;
-(BOOL) setNextTask:(MHVTask *) nextTask;

-(void) startChild:(MHVTask *) childTask;

-(void) start;
-(void) start:(MHVAction) startAction;
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
@interface MHVTaskSequence : NSEnumerator
{
@protected
    NSString* m_name;
}

@property (readwrite, nonatomic, strong) NSString* name;

-(MHVTask *) nextTask;
//
// You can override this in your implementation
//
-(void) onAborted;

//
// Use to run the task sequence
//
+(MHVTask *) run:(MHVTaskSequence *)sequence callback:(MHVTaskCompletion) callback;
+(MHVTask *) newRunTaskFor:(MHVTaskSequence *)sequence callback:(MHVTaskCompletion) callback;

@end
//
// Returns an enumeration of tasks
// The task must NOT be started
//
@interface MHVTaskStateMachine : MHVTaskSequence
{
@protected
    int m_stateID;
}

@property (readwrite, nonatomic) int stateID;

@end


