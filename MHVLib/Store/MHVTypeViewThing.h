//
//  MHVThingDateAndKey.h
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
#import "MHVTypes.h"

@interface MHVTypeViewThing : MHVThingKey
{
    NSDate* m_date;
    BOOL m_isLoadPending;
}

@property (readonly, nonatomic, strong) NSDate* date;
@property (readwrite, nonatomic) BOOL isLoadPending;

-(id) initWithDate:(NSDate *) date andID:(NSString*) thingID;
-(id) initWithThing:(MHVTypeViewThing *) thing;
-(id) initWithMHVThing:(MHVThing *) thing;
-(id) initWithPendingThing:(MHVPendingThing *) pendingThing;

-(NSComparisonResult) compareToThing:(MHVTypeViewThing *) other;  //sorts Descending
-(NSComparisonResult) compareThingID:(MHVTypeViewThing *) other;

+(NSComparisonResult) compare:(id) x to:(id) y;
+(NSComparisonResult) compareThing:(MHVTypeViewThing *) x to:(MHVTypeViewThing *) y;
+(NSComparisonResult) compareID:(id) x to:(id) y;

@end
