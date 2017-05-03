//
//  MHVItemView.h
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
#import "MHVType.h"
#import "MHVItemSection.h"

@interface MHVItemView : MHVType
{
@private
    enum MHVItemSection m_sections;
    MHVStringCollection* m_transforms;
    MHVStringCollection* m_typeVersions;
}
@property (readwrite, nonatomic) enum MHVItemSection sections;
@property (readonly, nonatomic) MHVStringCollection* transforms;
@property (readonly, nonatomic) MHVStringCollection* typeVersions;

@end
