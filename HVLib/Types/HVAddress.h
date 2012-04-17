//
//  HVAddress.h
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

#import "HVType.h"
#import "HVBaseTypes.h"
#import "HVCollection.h"

@interface HVAddress : HVType
{
@private
    NSString* m_description;
    HVBool* m_isprimary;
    HVStringCollection* m_street;
    NSString* m_city;
    NSString* m_state;
    NSString* m_postalCode;
    NSString* m_country;
    NSString* m_county;
}

@property (readwrite, nonatomic, retain) NSString* description;
@property (readwrite, nonatomic, retain) HVBool* isPrimary;
@property (readwrite, nonatomic, retain) HVStringCollection* street;
@property (readwrite, nonatomic, retain) NSString* city;
@property (readwrite, nonatomic, retain) NSString* state;
@property (readwrite, nonatomic, retain) NSString* postalCode;
@property (readwrite, nonatomic, retain) NSString* country;
@property (readwrite, nonatomic, retain) NSString* county;

@property (readonly, nonatomic) BOOL hasStreet;


@end

@interface HVAddressCollection : HVCollection

@end
