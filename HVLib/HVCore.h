//
//  HVCore.h
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
#import <CoreFoundation/CoreFoundation.h>

#define IsNsNull(var) (var == [NSNull null])

NSRange HVMakeRange(NSUInteger i);
NSRange HVEmptyRange(void);

double roundToPrecision(double value, NSInteger precision);

//--------------------------------------
//
// MEMORY MANAGEMENT 
// 
//--------------------------------------
#define HVALLOC_FAIL return HVClear(self)

#define HVENSURE(var, className)    if (!var) { var = [[className alloc] init];  } 
                                    
#define HVASSIGN(var, newVar)   var = HVAssign(var, newVar)
#define HVRETAIN(var, newVar)   HVSetVar(&var, newVar)
#define HVCLEAR(var) var = HVClear(var)
#define HVSET(var, value) HVSetVar(&var, value)
#define HVSETIF(var, value) HVSetVarIfNotNil(&var, value)

id HVClear(id obj);
id HVAssign(id original, id newObj);
void HVSetVar(id* var, id value);
void HVSetVarIfNotNil(id* var, id value);

CFTypeRef HVReplaceRef(CFTypeRef ref, CFTypeRef newRef);
CFTypeRef HVRetainRef(CFTypeRef cf);
void HVReleaseRef(CFTypeRef cf);

//--------------------------------------
//
// Standard NSObject Extensions 
//
//--------------------------------------
@interface NSObject (HVExtensions)

-(void) safeInvoke:(SEL) sel;
-(void) safeInvoke:(SEL) sel withParam:(id) param;

-(void) invokeOnMainThread:(SEL)aSelector;
-(void) invokeOnMainThread:(SEL)aSelector withObject:(id) obj;

-(void) log;
-(NSString *) descriptionForLog;

@end

//--------------------------------------
//
// Alerts
// 
//--------------------------------------
