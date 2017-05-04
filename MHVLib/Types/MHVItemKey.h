//
//  MHVItemKey.h
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

#import <Foundation/Foundation.h>
#import "MHVType.h"

@interface MHVItemKey : MHVType
{
@private
    NSString* m_id;
    NSString* m_version;
}

@property (readwrite, nonatomic, strong) NSString* itemID;
@property (readwrite, nonatomic, strong) NSString* version;
@property (readonly, nonatomic) BOOL hasVersion;

-(id) initNew;
-(id) initWithID:(NSString *) itemID;
-(id) initWithID:(NSString *) itemID andVersion:(NSString *) version;
-(id) initWithKey:(MHVItemKey *) key;

-(BOOL) isVersion:(NSString *) version;
-(BOOL) isLocal;

-(BOOL) isEqualToKey:(MHVItemKey *) key;

+(MHVItemKey *) local;
+(MHVItemKey *) newLocal;

@end

@interface MHVItemKeyCollection : MHVCollection <XSerializable>

-(id) initWithKey:(MHVItemKey *) key;

-(void) addItem:(MHVItemKey *) key;

-(MHVItemKey *) firstKey;
-(MHVItemKey *) itemAtIndex:(NSUInteger) index;

-(MHVClientResult *) validate;

@end
