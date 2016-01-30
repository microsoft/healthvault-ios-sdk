//
//  HVFile.h
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
#import "HVTypes.h"
#import "HVItemBlobUploadTask.h"

@interface HVFile : HVItemDataTyped
{
@private
    HVString255* m_name;
    NSInteger m_size;
    HVCodableValue* m_contentType;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required)
//
@property (readwrite, nonatomic, retain) NSString* name;
//
// (Required)
//
@property (readwrite, nonatomic) NSInteger size;
// 
// (Optional)
//
@property (readwrite, nonatomic, retain) HVCodableValue* contentType;

//-------------------------
//
// Initializers
//
//-------------------------

+(HVItem *) newItem;
+(HVItem *) newItemWithName:(NSString *) name andContentType:(NSString *) contentType;

//-------------------------
//
// Text
//
//-------------------------
-(NSString *) toString;
//
// size units
// Automatically convers to the right uint - bytes, KB or MB
//
-(NSString *) sizeAsString;
+(NSString *) sizeAsString:(long) size;

//-------------------------
//
// Type Info
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;

@end
