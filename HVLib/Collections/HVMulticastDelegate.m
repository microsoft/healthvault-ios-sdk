//
//  HVMulticastDelegate.m
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
#import "HVMulticastDelegate.h"

@implementation HVMulticastDelegate

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    m_delegates = [[NSMutableArray alloc] init];
    HVCHECK_NOTNULL(m_delegates);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_delegates release];
    [super dealloc];
}

-(void) subscribe:(id)delegate
{
    if (!delegate)
    {
        return;
    }
    @synchronized(m_delegates)
    {
        [m_delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    }
}

-(void) unsubscribe:(id)delegate
{
    @synchronized(m_delegates)
    {
        for (NSUInteger i = 0, count = m_delegates.count; i < count; ++i)
        {
            id d = ((NSValue *)[m_delegates objectAtIndex:i]).nonretainedObjectValue;
            if (delegate == d)
            {
                [m_delegates removeObjectAtIndex:i];
                return;
            }
        }
    }
}

-(void) invoke:(SEL)sel withParam:(id)param
{
    @synchronized(m_delegates)
    {
        for (NSUInteger i = 0, count = m_delegates.count; i < count; ++i)
        {
            id delegate = ((NSValue *)[m_delegates objectAtIndex:i]).nonretainedObjectValue;
            if ([delegate respondsToSelector:sel])
            {
                [delegate performSelector:sel withObject:param];
            }
        }
    }
}

-(void)invoke:(SEL)sel withParam:(id)param withParam:(id)param2
{
    @synchronized(m_delegates)
    {
        for (NSUInteger i = 0, count = m_delegates.count; i < count; ++i)
        {
            id delegate = ((NSValue *)[m_delegates objectAtIndex:i]).nonretainedObjectValue;
            if ([delegate respondsToSelector:sel])
            {
                [delegate performSelector:sel withObject:param withObject:param];
            }
        }
    }
}

@end
