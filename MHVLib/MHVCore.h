//
// MHVCore.h
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

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

#define IsNsNull(var) (var == [NSNull null])

NSRange MHVMakeRange(NSUInteger i);
NSRange MHVEmptyRange(void);

double roundToPrecision(double value, NSInteger precision);
double mgDLToMmolPerL(double mgDLValue, double molarWeight);
double mmolPerLToMgDL(double mmolPerL, double molarWeight);

// --------------------------------------
//
// MEMORY MANAGEMENT
//
// --------------------------------------
#define MHVALLOC_FAIL return nil

#define MHVENSURE(var, className)    if (!var) { var = [[className alloc] init];  }

// --------------------------------------
//
// Standard NSObject Extensions
//
// --------------------------------------
@interface NSObject (MHVExtensions)

- (void)safeInvoke:(SEL)sel;
- (void)safeInvoke:(SEL)sel withParam:(id)param;

- (void)invokeOnMainThread:(SEL)aSelector;
- (void)invokeOnMainThread:(SEL)aSelector withObject:(id)obj;

- (void)log;
- (NSString *)descriptionForLog;

@end

// ------------------------------------
//
// Notifications
//
// ------------------------------------
#define MHVDECLARE_NOTIFICATION(var) extern NSString * const var;

#define MHVDEFINE_NOTIFICATION(var) NSString * const var = @#var;
