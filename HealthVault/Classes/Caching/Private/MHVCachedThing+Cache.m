//
//  MHVCachedThing+Cache.m
//  MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

#import "MHVCachedThing+Cache.h"
#import "MHVTypes.h"

@implementation MHVCachedThing (Cache)

- (void)populateWithThing:(MHVThing *)thing
{
    self.thingId = [thing.key.thingID lowercaseString];
    self.version = [thing.key.version lowercaseString];
    self.typeId = [thing.type.typeID lowercaseString];
    
    // Don't overwrite existing data with nil
    self.createDate = thing.created.when ?: self.createDate;
    self.createdByAppId = [thing.created.appID.UUIDString lowercaseString] ?: self.createdByAppId;
    self.createdByPersonId = [thing.created.personID.UUIDString lowercaseString] ?: self.createdByPersonId;
    
    self.updateDate = thing.updated.when ?: self.updateDate;
    self.updatedByAppId = [thing.updated.appID.UUIDString lowercaseString] ?: self.updatedByAppId;
    self.updatedByPersonId = [thing.updated.personID.UUIDString lowercaseString] ?: self.updatedByPersonId;
    
    self.effectiveDate = thing.effectiveDate ?: self.effectiveDate;
    
    self.xmlString = [thing toXmlString];
    
    self.isPlaceholder = NO;
}

- (MHVThing *)toThing
{
    return [MHVThing newFromXmlString:self.xmlString];
}

@end
