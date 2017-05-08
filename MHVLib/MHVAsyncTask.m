//
// MHVAsyncTask.m
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

#import "MHVCommon.h"
#import "MHVAsyncTask.h"
#import "MHVClient.h"

// -----------------------------------------------
//
// MHVTask
//
// -----------------------------------------------
@interface MHVTask ()

@property (readwrite, nonatomic) BOOL cancelled;
@property (readwrite, nonatomic) BOOL started;
@property (readwrite, nonatomic) BOOL complete;

@property (readwrite, nonatomic, strong) id exception;
@property (readwrite, nonatomic, weak) MHVTask *parent;

@end

@implementation MHVTask

- (BOOL)hasError
{
    return self.exception != nil;
}

- (BOOL)isDone
{
    return self.cancelled || self.complete;
}

- (id)result
{
    [self checkSuccess];
    return _result;
}

- (instancetype)initWithTaskMethod:(MHVTaskMethod)current
{
    return [self initWithCallback:nil andMethod:current];
}

- (instancetype)initWithCallback:(MHVTaskCompletion)callback
{
    return [self initWithCallback:callback andChildTask:nil];
}

- (instancetype)initWithCallback:(MHVTaskCompletion)callback andMethod:(MHVTaskMethod)method
{
    MHVCHECK_NOTNULL(method);

    self = [super init];
    if (self)
    {
        _callback = callback;
        
        [self setNextMethod:method];
    }

    return self;
}

- (instancetype)initWithCallback:(MHVTaskCompletion)callback andChildTask:(MHVTask *)childTask
{
    self = [super init];
    if (self)
    {
        _callback = callback;
        
        if (childTask)
        {
            [self setNextTask:childTask];
        }
    }

    return self;
}

- (void)start
{
    [self start:^
    {
        [self nextStep];
    }];
}

- (void)start:(MHVAction)startAction
{
    @synchronized(self)
    {
        if (self.isDone)
        {
            return;
        }

        // We'll free ourselves when we are done (see complete method)
        @try
        {
            self.cancelled = FALSE;
            self.started = TRUE;
            self.shouldCompleteInMainThread = [NSThread isMainThread];
            if (startAction)
            {
                startAction();
            }
        }
        @catch (id exception)
        {
            [self handleError:exception];
            @throw;
        }
    }
}

- (void)cancel
{
    @synchronized(self)
    {
        if (self.isDone)
        {
            return;
        }

        self.cancelled = TRUE;
        @try
        {
            if (self.operation && [self.operation respondsToSelector:@selector(cancel)])
            {
                [self.operation performSelector:@selector(cancel)];
                self.operation = nil;
            }
        }
        @catch (id exception)
        {
            // Eat cancellation exceptions, since they are harmless
        }
    }
}

- (void)completeTask
{
    if (self.shouldCompleteInMainThread && ![NSThread isMainThread])
    {
        [self invokeOnMainThread:@selector(completeTask)];
        return;
    }

    @synchronized(self)
    {
        self.operation = nil;

        if (self.isComplete)
        {
            return;
        }

        self.complete = TRUE;
        if (self.isCancelled)
        {
            return;
        }

        @try
        {
            if (self.callback)
            {
                self.callback(self);
            }
        }
        @catch (id exception)
        {
            [self handleError:exception];
        }
    }
}

- (void)handleError:(id)error
{
    self.exception = error;
    [error log];
}

- (void)clearError
{
    self.exception = nil;
}

- (void)checkSuccess
{
    if (self.exception)
    {
        @throw self.exception;
    }
}

- (BOOL)setNextMethod:(MHVTaskMethod)nextMethod
{
    @synchronized(self)
    {
        if (self.isDone)
        {
            return FALSE;
        }

        self.taskMethod = nextMethod;
        return TRUE;
    }
}

- (BOOL)setNextTask:(MHVTask *)nextTask
{
    @synchronized(self)
    {
        if (self.isDone)
        {
            return FALSE;
        }

        if (nextTask.isComplete)
        {
            // Completed synchronously perhaps
            self.exception = nextTask.exception;
            return TRUE;
        }

        self.operation = nextTask;
        if (nextTask)
        {
            //
            // Make this task the completion handler, so we can intercept callbacks and handle exceptions right
            //
            MHVTaskCompletion childCallback = nextTask.callback;
            nextTask.parent = self;
            nextTask.callback = ^(MHVTask *task)
            {
                [task.parent childCompleted:task childCallback:childCallback];
            };
        }

        return TRUE;
    }
}

- (void)startChild:(MHVTask *)childTask
{
    [self setNextTask:childTask];
    [childTask start];
}

- (void)nextStep
{
    @synchronized(self)
    {
        id nextOp = nil;

        @try
        {
            if (self.isComplete)
            {
                return;
            }

            if (!self.isCancelled)
            {
                if (self.operation)
                {
                    nextOp = self.operation;
                }

                if (nextOp)
                {
                    if ([nextOp respondsToSelector:@selector(start)])
                    {
                        [nextOp performSelector:@selector(start)];
                        return;
                    }
                }
                else if (self.taskMethod)
                {
                    [self queueMethod];
                    return;
                }
            }
        }
        @catch (id exception)
        {
            [self handleError:exception];
        }
        @finally
        {
            nextOp = nil;
        }

        [self completeTask];
    }
}

- (void)queueMethod
{
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^(void) {
        [self executeMethod];
    }];

    MHVCHECK_OOM(op);

    self.operation = op;

    [[MHVClient current] queueOperation:op];
}

- (void)executeMethod
{
    MHVTaskMethod method = self.taskMethod;

    @try
    {
        self.taskMethod = nil;
        self.operation = nil;
        if (method)
        {
            method(self);
        }

        [self nextStep];

        return;
    }
    @catch (id exception)
    {
        [self handleError:exception];
    }
    @finally
    {
        method = nil;
    }

    [self completeTask];
}

- (void)childCompleted:(MHVTask *)child childCallback:(MHVTaskCompletion)callback
{
    @try
    {
        self.operation = nil;
        if (callback)
        {
            callback(child);
        }

        [self scheduleNextChildStep];
        [self nextStep];

        return;
    }
    @catch (id exception)
    {
        [self handleError:exception];
    }
    @finally
    {
        child.parent = nil;
    }

    [self completeTask];
}

- (void)scheduleNextChildStep
{
}

@end

// -----------------------------------------------
//
// MHVTaskSequenceRunner
//
// -----------------------------------------------
@interface MHVTaskSequenceRunner : MHVTask

@property (nonatomic, strong) MHVTaskSequence *sequence;

- (instancetype)initWithSequence:(MHVTaskSequence *)sequence;

- (BOOL)moveToNextTask;
- (void)notifyAborted;

@end


// -----------------------------------------------
//
// MHVTaskSequence
//
// -----------------------------------------------
@implementation MHVTaskSequence

- (id)nextObject
{
    return [self nextTask];
}

- (MHVTask *)nextTask
{
    return nil;
}

- (void)onAborted
{
}

+ (MHVTask *)run:(MHVTaskSequence *)sequence callback:(MHVTaskCompletion)callback
{
    MHVTask *task = [MHVTaskSequence newRunTaskFor:sequence callback:callback];

    [task start];

    return task;
}

+ (MHVTask *)newRunTaskFor:(MHVTaskSequence *)sequence callback:(MHVTaskCompletion)callback
{
    MHVTask *task = [[MHVTask alloc] initWithCallback:callback];
    MHVCHECK_NOTNULL(task);

    MHVTaskSequenceRunner *runner = [[MHVTaskSequenceRunner alloc] initWithSequence:sequence];
    MHVCHECK_NOTNULL(runner);

    [task setNextTask:runner];

    return task;
}

@end

@implementation MHVTaskStateMachine

@end

// -----------------------------------------------
//
// MHVTaskSequenceRunner
//
// -----------------------------------------------

@implementation MHVTaskSequenceRunner

- (instancetype)initWithSequence:(MHVTaskSequence *)sequence
{
    MHVCHECK_NOTNULL(sequence);

    self = [super initWithCallback:^(MHVTask *task)
    {
        [task checkSuccess];
    }];
    
    if (self)
    {
        _sequence = sequence;
        self.taskName = sequence.name;
    }
    
    return self;
}

- (void)start
{
    [MHVTaskSequenceRunner setNextTaskInSequence:self];
    [super start];
}

- (void)cancel
{
    [super cancel];
    [self notifyAborted];
}

- (void)scheduleNextChildStep
{
    [MHVTaskSequenceRunner setNextTaskInSequence:self];
}

+ (void)setNextTaskInSequence:(MHVTask *)task
{
    MHVTaskSequenceRunner *runner = (MHVTaskSequenceRunner *)task;
    BOOL isCancelled = TRUE;

    @try
    {
        isCancelled = [runner moveToNextTask];
    }
    @finally
    {
        if (isCancelled)
        {
            [runner notifyAborted];
        }
    }
}

// Return false if aborted -- i.e. cancelled
- (BOOL)moveToNextTask
{
    while (!self.isCancelled)
    {
        MHVTask *nextTask = [self.sequence nextTask];
        if (!nextTask)
        {
            self.operation = nil;
            return FALSE;
        }

        if (![self setNextTask:nextTask] ||
            !nextTask.isComplete ||
            nextTask.hasError)
        {
            return FALSE;
        }

        //
        // Move on to the next state
        //
    }

    return TRUE; // aborted
}

- (void)notifyAborted
{
    safeInvokeAction(^
    {
        [self.sequence onAborted];
    });
}

@end
