//
//  HVVocabCodeSet.h
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
#import "HVVocabItem.h"

@interface HVVocabCodeSet : HVType
{
    NSString* m_name;
    NSString* m_family;
    NSString* m_version;
    HVVocabItemCollection* m_items;
    HVBool* m_isTruncated;
}

@property (readwrite, nonatomic, retain) NSString* name;
@property (readwrite, nonatomic, retain) NSString* family;
@property (readwrite, nonatomic, retain) NSString* version;
@property (readwrite, nonatomic, retain) HVVocabItemCollection* items;
@property (readwrite, nonatomic, retain) HVBool* isTruncated;

@property (readonly, nonatomic) BOOL hasItems;

-(NSArray *) displayStrings;
-(void) sortItemsByDisplayText;

@end

@interface HVVocabSetCollection : HVCollection 

-(HVVocabCodeSet *) itemAtIndex:(NSUInteger) index;

@end


@interface HVVocabSearchResults : HVType 
{
    HVVocabCodeSet* m_match;
}

@property (readwrite, nonatomic, retain) HVVocabCodeSet* match;
@property (readonly, nonatomic) BOOL hasMatches;

@end
