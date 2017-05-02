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
double mgDLToMmolPerL(double mgDLValue, double molarWeight);
double mmolPerLToMgDL(double mmolPerL, double molarWeight);

//--------------------------------------
//
// MEMORY MANAGEMENT 
// 
//--------------------------------------
#define HVALLOC_FAIL return HVClear(self)

#define HVENSURE(var, className)    if (!var) { var = [[className alloc] init];  } 
                                    

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

//------------------------------------
//
// Notifications
//
//------------------------------------
#define HVDECLARE_NOTIFICATION(var) extern NSString* const var;
#define HVDEFINE_NOTIFICATION(var) NSString* const var = @#var;

@interface NSNotificationCenter (HVExtensions)

- (void)addObserver:(id)observer selector:(SEL)selector name:(NSString *)name;

-(void)postNotificationName:(NSString *)notification sender:(id) sender argName:(NSString *) name argValue:(id) value;
-(void)postNotificationName:(NSString *)notification sender:(id) sender argName:(NSString *) n1 argValue:(id) v1 argName:(NSString *) n2 argValue:(id) v2;

@end
