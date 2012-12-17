//
//  HVAsyncTask.m
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

#import "HVCommon.h"
#import "HVAsyncTask.h"
#import "HVClient.h"

@interface HVTask (HVPrivate)

-(void) setException:(NSException *) error;
-(void) setParent:(HVTask *) task;

-(void) nextStep;

-(void) queueMethod;
-(void) executeMethod;
-(void) childCompleted:(HVTask *) task childCallback:(HVTaskCompletion) callback;

@end

@implementation HVTask

@synthesize isCancelled = m_cancelled;
@synthesize isStarted = m_started;
@synthesize isComplete = m_completed;

@synthesize taskName = m_taskName;
@synthesize exception = m_exception;
@synthesize result = m_result;
@synthesize method = m_taskMethod;
@synthesize callback = m_callback;

@synthesize operation = m_operation;
@synthesize parent = m_parent;

-(BOOL)hasError
{
    return (m_exception != nil);
}

-(BOOL)isDone
{
    return (m_cancelled || m_completed);
}

-(id) result
{
    [self checkSuccess];
    return m_result;
}

-(id) init
{
    return [self initWith:nil];  // this will cause an init failure, which is what we want
}

-(id)initWith:(HVTaskMethod)current
{
    return [self initWithCallback:nil andMethod:current];
}

-(id) initWithCallback:(HVTaskCompletion)callback
{
    return [self initWithCallback:callback andChildTask:nil];
}

-(id)initWithCallback:(HVTaskCompletion)callback andMethod:(HVTaskMethod)method
{
    HVCHECK_NOTNULL(method);
    
    self = [super init];
    HVCHECK_SELF;
    
    if (callback)
    {
        self.callback = callback;
        HVCHECK_NOTNULL(m_callback);
    }
    
    [self setNextMethod:method];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithCallback:(HVTaskCompletion)callback andChildTask:(HVTask *)childTask
{
    self = [super init];
    HVCHECK_SELF;
    
    if (callback)
    {
        self.callback = callback;
        HVCHECK_NOTNULL(m_callback);
    }
    
    if (childTask)
    {
        [self setNextTask:childTask];
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

//
// Override - useful for debugging memory leaks
//
- (oneway void)release
{
    [super release];
}

//
// Override - useful for debugging memory leaks
//
-(id) retain
{
    return [super retain];
}

-(void) dealloc
{
    [m_taskName release];
    
    [m_exception release];
    [m_result release];
    
    [m_taskMethod release];
    [m_callback release];
    
    [m_operation release];
    [m_parent release];
    
    [super dealloc];
}

-(void) start
{
    @synchronized(self)
    {
        [self retain]; // We'll free ourselves when we are done (see complete method)
        @try 
        {
            m_cancelled = FALSE;
            m_started = TRUE;
           
            [self nextStep];
        }
        @catch (id exception) 
        {
            [self handleError:exception];
            [self release];
            @throw;
        }
    }
}

-(void) cancel
{
    @synchronized(self)
    {
        if (self.isDone)
        {
            return;
        }
        
        m_cancelled = TRUE;
        @try 
        {
            if (m_operation && [m_operation respondsToSelector:@selector(cancel)])
            {
                [m_operation performSelector:@selector(cancel)];
                self.operation = nil;
            }
        }
        @catch (id exception) 
        {
            // Eat cancellation exceptions, since they are harmless
        }
        
        [self release];
    }
}

-(void) complete
{
    @synchronized(self)
    {
        self.operation = nil;
        
        if (m_completed)
        {
            return;
        }
        
        m_completed = TRUE;
        if (m_cancelled)
        {
            return;
        }
        
        @try 
        {
            if (m_callback)
            {
                m_callback(self);
            }
        }
        @catch (id exception) 
        {
            [exception log];
        }
 
        [self release];
    }    
}

-(void) handleError:(id)error
{
    self.exception = error;
}

-(void)checkSuccess
{
    if (m_exception)
    {
        @throw m_exception;
    }   
}

-(BOOL) setNextMethod:(HVTaskMethod) nextMethod
{
    @synchronized(self)
    {
        if (self.isDone)
        {
            return FALSE;
        }
        
        self.method = nextMethod;
        return TRUE;
    }
}

-(BOOL)setNextTask:(HVTask *) nextTask
{
    @synchronized(self)
    {
        if (self.isDone)
        {
            return FALSE;
        }
        
        self.operation = nextTask;
        //
        // Make this task the completion handler, so we can intercept callbacks and handle exceptions right
        //
        HVTaskCompletion childCallback = [nextTask.callback retain];     
        nextTask.parent = self;
        nextTask.callback = ^(HVTask *task) 
        {
            [task.parent childCompleted:task childCallback:childCallback];
        };       
        [childCallback release];
        
        return TRUE;
    }    
}

-(void) startChild:(HVTask *)childTask
{
    [self setNextTask:childTask];
    [childTask start];
}

@end

@implementation HVTask (HVPrivate)

-(void)setException:(id)error
{
    HVRETAIN(m_exception, error);
}

-(void)setParent:(HVTask *)task
{
    HVRETAIN(m_parent, task);
}

-(void) nextStep
{
    @synchronized(self)
    {        
        id nextOp = nil;
        @try 
        {     
            if (m_completed)
            {
                return;
            }
            
            if (!m_cancelled)
            {
                if (m_operation)
                {
                    nextOp = [m_operation retain];
                }
                if (nextOp)
                {
                    self.operation = nil;
                    if ([nextOp respondsToSelector:@selector(start)])
                    {
                        [nextOp performSelector:@selector(start)];
                        return;
                    }
                }
                else if (m_taskMethod)
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
            [nextOp release];
        }
       
        [self complete];
    }
}

-(void ) queueMethod
{
    NSBlockOperation* op = [NSBlockOperation blockOperationWithBlock:^(void) { [self executeMethod];}];
    HVCHECK_OOM(op);
    
    self.operation = op;
    
    [[HVClient current] queueOperation:op];
}

-(void)executeMethod
{
    HVTaskMethod method = [m_taskMethod retain];
    @try 
    {
        self.method = nil;
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
        [method release];
    }
    
    [self complete];
    
}

-(void) childCompleted:(HVTask *)child childCallback:(HVTaskCompletion)callback
{
    @try 
    {
        if (callback)
        {
            callback(child);
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
        [child setParent:nil];
    }
    
    [self complete];
} 

@end