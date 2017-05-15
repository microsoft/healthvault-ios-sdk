//
//  MHVLocalVocabStore.h
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
//

#import <Foundation/Foundation.h>
#import "MHVObjectStore.h"
#import "MHVVocab.h"
#import "MHVGetVocabTask.h"

//-------------------------
//
// Local Cache of HealthVault vocabularies
//
//-------------------------
@interface MHVLocalVocabStore : NSObject
{
@private
    id<MHVObjectStore> m_objectStore;
}

@property (readonly, nonatomic, strong) id<MHVObjectStore> store;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithObjectStore:(id<MHVObjectStore>) store;

//-------------------------
//
// Methods
//
//-------------------------

-(BOOL) containsVocabWithID:(MHVVocabIdentifier *) vocabID;
-(MHVVocabCodeSet *) getVocabWithID:(MHVVocabIdentifier *) vocabID;
-(BOOL) putVocab:(MHVVocabCodeSet *) vocab withID:(MHVVocabIdentifier *) vocabID;
-(void) removeVocabWithID:(MHVVocabIdentifier *) vocabID;

//------------
//
// Download Support
//
//------------
// Download the given vocab and save it in the LocalVault
// Use [[MHVClient current].localVault getVocab] to load it subsequently
//
-(MHVTask *) downloadVocab:(MHVVocabIdentifier *) vocab withCallback:(MHVTaskCompletion) callback;
-(MHVTask *) downloadVocabs:(MHVVocabIdentifierCollection *) vocabIDs withCallback:(MHVTaskCompletion) callback;

-(void) ensureVocabDownloaded:(MHVVocabIdentifier *) vocab; // default - will check for new vocabs once a month
-(void) ensureVocabDownloaded:(MHVVocabIdentifier *) vocab maxAge:(NSTimeInterval) ageInSeconds;
-(BOOL) ensureVocabsDownloaded:(MHVVocabIdentifierCollection *) vocabIDs maxAge:(NSTimeInterval) ageInSeconds;

//
// Convenience Lookup of codes
//
-(MHVVocabThing *) getVocabThingForCode:(NSString *) code inVocab:(MHVVocabIdentifier *) vocabID;
-(NSString *) getDisplayTextForCode:(NSString *) code inVocab:(MHVVocabIdentifier *) vocabID;

@end
