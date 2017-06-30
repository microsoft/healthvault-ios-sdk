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
    self.thingId = thing.key.thingID;
    self.version = thing.key.version;
    self.thingType = thing.type.typeID;
    
    self.createDate = thing.created.when;
    self.createdByAppId = thing.created.appID.UUIDString;
    self.createdByPersonId = thing.created.personID.UUIDString;
    self.effectiveDate = thing.effectiveDate;
    self.updateDate = thing.updated.when;
    self.updatedByAppId = thing.updated.appID.UUIDString;
    self.updatedByPersonId = thing.updated.personID.UUIDString;
    
    self.xmlString = [thing toXmlString];
}

- (MHVThing *)toThing
{
    return [MHVThing newFromXmlString:self.xmlString];
}

@end
