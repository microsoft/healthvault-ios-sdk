//
//  HVCore.m
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

#import "HVCore.h"
#import "HVValidator.h"

NSRange HVMakeRange(NSUInteger i)
{
    return NSMakeRange(i, 1);
}

NSRange HVEmptyRange(void)
{
    return NSMakeRange(0, 0);
}

double roundToPrecision(double value, NSInteger precision)
{
    double places = pow(10, precision);
    return round(value * places) / places;
}

id HVClear(id obj)
{
    if (obj)
    {
        [obj release];
    }
    return nil;
}

id HVAssign(id original, id newObj)
{
    [original release];
    return newObj;
}

void HVSetVar(id* var, id value)
{
    if (*var)
    {
        [(*var) release];
        *var = nil;
    }
    *var = [value retain];
}

void HVSetVarIfNotNil(id *var, id value)
{
    if (value)
    {
        HVSetVar(var, value);
    }
}

CFTypeRef HVReplaceRef(CFTypeRef cf, CFTypeRef newRef)
{
    HVReleaseRef(cf);
    return HVRetainRef(newRef);
}

CFTypeRef HVRetainRef(CFTypeRef cf)
{
    if (cf)
    {
        CFRetain(cf);
    }
    
    return cf;
}

void HVReleaseRef(CFTypeRef cf)
{
    if (cf)
    {
        CFRelease(cf);
    }
}

@implementation NSObject (HVExtensions)

-(void) safeInvoke:(SEL)sel
{
    if ([self respondsToSelector:sel])
    {
        @try 
        {
            [self performSelector:sel];
        }
        @catch (id ex) 
        {
            [ex log];
        }
        
    }     
}

-(void) safeInvoke:(SEL)sel withParam:(id)param
{
    if ([self respondsToSelector:sel])
    {
        @try 
        {
            [self performSelector:sel withObject:param];
        }
        @catch (id ex) 
        {
            [ex log];
        }
    } 
}

-(void)invokeOnMainThread:(SEL)aSelector
{
    [self performSelectorOnMainThread:aSelector withObject:nil waitUntilDone:FALSE];
}

-(void)invokeOnMainThread:(SEL)aSelector withObject:(id)obj
{
    [self performSelectorOnMainThread:aSelector withObject:obj waitUntilDone:FALSE];    
}

-(void)log
{
    @try
    {
        HVLogEvent([self descriptionForLog]);
    }
    @catch (id ex) 
    {
        
    }
}

-(NSString *)descriptionForLog
{
    if ([self respondsToSelector:@selector(detailedDescription)])
    {
        return [self performSelector:@selector(detailedDescription)];
    }
    else if ([self respondsToSelector:@selector(description)])
    {
        return [self description];
    }
    else 
    {
        return NSStringFromClass([self class]);
    }    
}

@end
