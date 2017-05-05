//
// MHVCollection.h
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
//

#import <Foundation/Foundation.h>


//
// Collections allow objects of a particular type only
// They enforce the type
//
@interface MHVCollection : NSMutableArray

@property (readwrite, nonatomic, strong) Class  type;

// -----------------
//
// Text
//
// -----------------
- (NSString *)toString;

@end

@interface MHVStringCollection : MHVCollection

- (BOOL)containsString:(NSString *)value;
- (NSUInteger)indexOfString:(NSString *)value;
- (NSUInteger)indexOfString:(NSString *)value startingAt:(NSUInteger)index;
- (BOOL)removeString:(NSString *)value;

//
// NOTE: these do a linear N^2 scan
//
- (MHVStringCollection *)selectStringsFoundInSet:(NSArray *)testSet;
- (MHVStringCollection *)selectStringsNotFoundInSet:(NSArray *)testSet;

@end
