//
//  HVVocabItem.h
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
#import "HVCollection.h"

@interface HVVocabItem : HVType
{
@private
    NSString* m_code;
    NSString* m_displayText;
    NSString* m_abbrv;
    NSString* m_data;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) - Vocabulary Code - such as RxNorm or Snomed code
//
@property (readwrite, nonatomic, retain) NSString* code;
//
// (Required) - Vocab Display Text - the actual text
//
@property (readwrite, nonatomic, retain) NSString* displayText;
//
// (Optional)
//
@property (readwrite, nonatomic, retain) NSString* abbreviation;
//
// (Optional) - additional information about this vocab entry
// E.g. RxNorm can contain information about dosages and strengths
//
@property (readwrite, nonatomic, retain) NSString* dataXml;

-(NSString *) toString;

@end

@interface HVVocabItemCollection : HVCollection 

-(HVVocabItem *) itemAtIndex:(NSUInteger) index;

@end
