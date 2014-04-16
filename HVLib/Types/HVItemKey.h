//
//  HVItemKey.h
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

@interface HVItemKey : HVType
{
@private
    NSString* m_id;
    NSString* m_version;
}

@property (readwrite, nonatomic, retain) NSString* itemID;
@property (readwrite, nonatomic, retain) NSString* version;
@property (readonly, nonatomic) BOOL hasVersion;

-(id) initNew;
-(id) initWithID:(NSString *) itemID;
-(id) initWithID:(NSString *) itemID andVersion:(NSString *) version;
-(id) initWithKey:(HVItemKey *) key;

-(BOOL) isVersion:(NSString *) version;
-(BOOL) isLocal;

-(BOOL) isEqualToKey:(HVItemKey *) key;

+(HVItemKey *) local;
+(HVItemKey *) newLocal;

@end

@interface HVItemKeyCollection : HVCollection <XSerializable>

-(id) initWithKey:(HVItemKey *) key;

-(void) addItem:(HVItemKey *) key;

-(HVItemKey *) firstKey;
-(HVItemKey *) itemAtIndex:(NSUInteger) index;

-(HVClientResult *) validate;

@end