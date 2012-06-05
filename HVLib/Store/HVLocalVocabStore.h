//
//  HVLocalVocabStore.h
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
//

#import <Foundation/Foundation.h>
#import "HVObjectStore.h"
#import "HVVocab.h"
#import "HVGetVocabTask.h"

//-------------------------
//
// Local Cache of HealthVault vocabularies
//
//-------------------------
@interface HVLocalVocabStore : NSObject
{
@private
    id<HVObjectStore> m_objectStore;
}

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithObjectStore:(id<HVObjectStore>) store;

//-------------------------
//
// Methods
//
//-------------------------

-(BOOL) containsVocabWithID:(HVVocabIdentifier *) vocabID;
-(HVVocabCodeSet *) getVocabWithID:(HVVocabIdentifier *) vocabID;
-(BOOL) putVocab:(HVVocabCodeSet *) vocab withID:(HVVocabIdentifier *) vocabID;
-(void) removeVocabWithID:(HVVocabIdentifier *) vocabID;

//------------
//
// Download Support
//
//------------
// Download the given vocab and save it in the LocalVault
// Use [[HVClient current].localVault getVocab] to load it subsequently
//
-(HVTask *) downloadVocab:(HVVocabIdentifier *) vocab withCallback:(HVTaskCompletion) callback;
-(HVTask *) downloadVocabs:(HVVocabIdentifierCollection *) vocabIDs withCallback:(HVTaskCompletion) callback;

-(void) ensureVocabDownloaded:(HVVocabIdentifier *) vocab; // default - will check for new vocabs once a month
-(void) ensureVocabDownloaded:(HVVocabIdentifier *) vocab maxAge:(NSTimeInterval) ageInSeconds;
-(BOOL) ensureVocabsDownloaded:(HVVocabIdentifierCollection *) vocabIDs maxAge:(NSTimeInterval) ageInSeconds;

//
// Convenience Lookup of codes
//
-(HVVocabItem *) getVocabItemForCode:(NSString *) code inVocab:(HVVocabIdentifier *) vocabID;
-(NSString *) getDisplayTextForCode:(NSString *) code inVocab:(HVVocabIdentifier *) vocabID;

@end
