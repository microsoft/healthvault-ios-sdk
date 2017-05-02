//
//  XWriter.h
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
#import <libxml/xmlwriter.h>
#import <libxml/xmlreader.h>
#import "XNodeType.h"
#import "XString.h"
#import "XConverter.h"

@interface XWriter : NSObject
{
    xmlBufferPtr m_buffer;
    xmlTextWriterPtr m_writer;
    XConverter *m_converter;
}

@property (readonly, nonatomic) xmlTextWriterPtr writer;
@property (readonly, nonatomic) XConverter *converter;
@property (readwrite, nonatomic, retain) id context;

//
// Designated constructor
//
-(id) initWithWriter:(xmlTextWriterPtr) writer buffer:(xmlBufferPtr) buffer andConverter:(XConverter *) converter;
-(id) initWithWriter:(xmlTextWriterPtr) writer buffer:(xmlBufferPtr) buffer;
-(id) initWithBufferSize:(size_t) size;
-(id) initWithBufferSize:(size_t) size andConverter:(XConverter *) converter;
-(id) initFromFile:(NSString *) filePath;
-(id) initFromFile:(NSString *)filePath andConverter:(XConverter *) converter;

-(BOOL) flush;

-(BOOL) writeStartDocument;
-(BOOL) writeEndDocument;

-(BOOL) writeAttribute:(NSString *) name value:(NSString *) value;
-(BOOL) writeAttribute:(NSString *)name prefix:(NSString*) prefix NS:(NSString *) ns value:(NSString *)value;
-(BOOL) writeAttributeXmlName:(const xmlChar *) xmlName value:(NSString *) value;
-(BOOL) writeAttributeXmlName:(const xmlChar *)xmlName prefix:(const xmlChar *) xmlPrefix NS:(const xmlChar *) xmlNs value:(NSString *)value;

-(BOOL) writeStartElement:(NSString *) name;
-(BOOL) writeStartElement:(NSString *) name prefix:(NSString*) prefix NS:(NSString *) ns;
-(BOOL) writeStartElementXmlName:(const xmlChar *) xmlName;
-(BOOL) writeStartElementXmlName:(const xmlChar *) xmlName prefix:(const xmlChar *) xmlPrefix NS:(const xmlChar *) xmlNs;
-(BOOL) writeEndElement;

-(BOOL) writeString:(NSString *) value;
-(BOOL) writeRaw:(NSString*) xml;

-(xmlChar *) getXml;
-(size_t) getLength;

-(NSString *) newXmlString;

@end

// 0 for default size
xmlBufferPtr XAllocBuffer(size_t size);
xmlTextWriterPtr XAllocTextWriter(xmlBufferPtr buffer);
xmlTextWriterPtr XAllocFileWriter(NSString* filePath);
