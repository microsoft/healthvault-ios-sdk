//
//  HVCodedValue.h
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

@class HVCodedValueCollection;

@interface HVCodedValue : HVType
{
@private
    NSString* m_code;
    NSString* m_vocab;
    NSString* m_family;
    NSString* m_version;    
}
//
// Required
//
@property (readwrite, nonatomic, retain) NSString* code;
@property (readwrite, nonatomic, retain) NSString* vocabularyName;
//
// Optional
//
@property (readwrite, nonatomic, retain) NSString* vocabularyFamily;
@property (readwrite, nonatomic, retain) NSString* vocabularyVersion;

-(id) initWithCode:(NSString *) value andVocab:(NSString *) vocab; 

@end

@interface HVCodedValueCollection : HVCollection 

@end
