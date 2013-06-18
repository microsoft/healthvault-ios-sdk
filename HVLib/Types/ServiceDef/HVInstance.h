//
//  HVInstance.h
//  HVLib
//
//  Copyright (c) 2013 Microsoft Corporation. All rights reserved.
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
//

#import "HVType.h"

@interface HVInstance : HVType
{
@private
    NSString* m_id;
    NSString* m_name;
    NSString* m_description;
    NSString* m_platformUrl;
    NSString* m_shellUrl;
}

@property (readwrite, nonatomic, retain) NSString* instanceID;
@property (readwrite, nonatomic, retain) NSString* name;
@property (readwrite, nonatomic, retain) NSString* instanceDescription;
@property (readwrite, nonatomic, retain) NSString* platformUrl;
@property (readwrite, nonatomic, retain) NSString* shellUrl;

@end

@interface HVInstanceCollection : HVCollection

-(HVInstance *) indexOfInstance:(NSUInteger) index;

-(NSInteger) indexOfInstanceNamed:(NSString *) name;
-(NSInteger) indexOfInstanceWithID:(NSString *) instanceID;

@end
