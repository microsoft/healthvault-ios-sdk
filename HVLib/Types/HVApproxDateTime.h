//
//  HVApproxDateTime.h
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
#import "HVType.h"
#import "HVDateTime.h"

@interface HVApproxDateTime : HVType
{
@private
    NSString* m_descriptive;
    HVDateTime* m_dateTime;
}

//
// CHOICE: you can either specify a Description OR a precise DateTime
// You cannot specify both
//
@property (readwrite, nonatomic, retain) NSString* descriptive;
@property (readwrite, nonatomic, retain) HVDateTime* dateTime;

@property (readonly, nonatomic) BOOL isStructured;

-(id) initWithDescription:(NSString *) descr;
-(id) initWithDate:(NSDate *) date;
-(id) initWithDateTime:(HVDateTime *) dateTime;

-(NSString *) toString;
-(NSString *) toStringWithFormat:(NSString *) format;

-(NSDate *) toDate;

@end
