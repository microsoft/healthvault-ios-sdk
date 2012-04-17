//
//  HVVocabIdentifier.h
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

@interface HVVocabIdentifier : HVType
{
@private
    NSString* m_name;
    NSString* m_family;
    NSString* m_version;
    NSString* m_lang;
    NSString* m_codeValue;
}

@property (readwrite, nonatomic, retain) NSString* name;
@property (readwrite, nonatomic, retain) NSString* family;
@property (readwrite, nonatomic, retain) NSString* version;
@property (readwrite, nonatomic, retain) NSString* language;
@property (readwrite, nonatomic, retain) NSString* codeValue;

-(id) initWithFamily:(NSString *) family andName:(NSString *) name;

@end
