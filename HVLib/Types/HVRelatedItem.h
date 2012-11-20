//
//  HVRelatedItem.h
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

#import "HVBaseTypes.h"
#import "HVType.h"
#import "HVItemKey.h"
#import "HVCollection.h"

@class HVItem;

@interface HVRelatedItem : HVType
{
@private
    NSString* m_itemID;
    NSString* m_version;
    HVString255* m_clientID;
    NSString* m_relationship;
}

//
// You can have either a key OR a clientID
//
@property (readwrite, nonatomic, retain) NSString* itemID;
@property (readwrite, nonatomic, retain) NSString* version;
@property (readwrite, nonatomic, retain) HVString255* clientID;

@property (readwrite, nonatomic, retain) NSString* relationship;

-(id) initRelationship:(NSString *) relationship toItemWithKey:(HVItemKey *) key;
-(id) initRelationship:(NSString *)relationship toItemWithClientID:(NSString *) clientID;

+(HVRelatedItem *) relationNamed:(NSString *) name toItemKey:(HVItemKey *) item;
+(HVRelatedItem *) relationNamed:(NSString *) name toItem:(HVItem *) key;

@end

@interface HVRelatedItemCollection : HVCollection

-(NSUInteger) indexOfRelation:(NSString *) name;
-(HVRelatedItem *) addRelation:(NSString *) name toItem:(HVItem *) item;
-(BOOL) ensureRelation:(NSString *) name toItem:(HVItem *) item;

@end