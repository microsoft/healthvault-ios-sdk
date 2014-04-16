//
//  HVMessage.h
//  HVLib
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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
#import "HVTypes.h"

@interface HVMessage : HVItemDataTyped
{
@private
    HVDateTime* m_when;
    HVMessageHeaderItemCollection* m_headers;
    HVPositiveInt* m_size;
    NSString* m_summary;
    NSString* m_htmlBlobName;
    NSString* m_textBlobName;
    HVMessageAttachmentCollection* m_attachments;
}

@property (readwrite, nonatomic, retain) HVDateTime* when;
@property (readwrite, nonatomic, retain) HVMessageHeaderItemCollection* headers;
@property (readwrite, nonatomic, retain) HVPositiveInt* size;
@property (readwrite, nonatomic, retain) NSString* summary;
@property (readwrite, nonatomic, retain) NSString* htmlBlobName;
@property (readwrite, nonatomic, retain) NSString* textBlobName;
@property (readwrite, nonatomic, retain) HVMessageAttachmentCollection* attachments;

@property (readonly, nonatomic) BOOL hasHeaders;
@property (readonly, nonatomic) BOOL hasAttachments;
@property (readonly, nonatomic) BOOL hasHtmlBody;
@property (readonly, nonatomic) BOOL hasTextBody;

-(NSString *) getFrom;
-(NSString *) getTo;
-(NSString *) getCC;
-(NSString *) getSubject;
-(NSString *) getMessageDate;
-(NSString *) getValueForHeader:(NSString *) name;

//-------------------------
//
// Type Information
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;

@end
