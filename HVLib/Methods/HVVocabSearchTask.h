//
//  HVSearchVocabTask.h
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

#import "HVMethodCallTask.h"
#import "HVVocabIdentifier.h"
#import "HVVocabSearchParams.h"
#import "HVVocabCodeSet.h"

//-------------------------
//
// Search a given vocabulary
// Supports various options such as free text search
// Ideal for auto-complete scenarios
//
//-------------------------
@interface HVVocabSearchTask : HVMethodCallTask
{
@private
    HVVocabIdentifier* m_vocabID;
    HVVocabSearchParams* m_params;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) - vocabulary being searched
//
@property (readwrite, nonatomic, retain) HVVocabIdentifier* vocabID;
//
// (Required) - search parameters
//
@property (readwrite, nonatomic, retain) HVVocabSearchParams* params;
//
// RESULT - use this property to retrieve results when the task completes
//
@property (readonly, nonatomic) HVVocabCodeSet* searchResult;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithVocab:(HVVocabIdentifier *) vocab searchText:(NSString*) text andCallback:(HVTaskCompletion) callback;

+(HVVocabSearchTask *) searchForText:(NSString *) text inVocabFamily:(NSString *) family vocabName:(NSString *) name callback:(HVTaskCompletion) callback;

+(HVVocabSearchTask *) searchForText:(NSString *) text inVocab:(HVVocabIdentifier *) vocab callback:(HVTaskCompletion) callback;

+(HVVocabSearchTask *) searchMedications:(NSString *) text callback:(HVTaskCompletion) callback;

@end
