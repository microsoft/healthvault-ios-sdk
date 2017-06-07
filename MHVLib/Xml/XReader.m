//
//  XmlReader.m
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

#import "MHVCommon.h"
#import "XReader.h"
#import "Logger.h"

#define READER_TRUE 1
#define READER_FALSE 0
#define READER_FAIL -1


xmlTextReader* XAllocBufferReader(NSData *buffer)
{
    if (!buffer)
    {
        return nil;
    }
    return xmlReaderForMemory([buffer bytes], (int)[buffer length], nil, nil, 0);
}

xmlTextReader* XAllocStringReader(NSString *string)
{
    if (!string)
    {
        return nil;
    }
    
    return xmlReaderForDoc([string toXmlStringConst], nil, nil, 0);
}

xmlTextReader* XAllocFileReader(NSString *fileName)
{
    if ([NSString isNilOrEmpty:fileName])
    {
        return nil;
    }
    
    return xmlNewTextReaderFilename([fileName UTF8String]); // further error checking delegated
}

//
// PRIVATE METHOD DECLARATIONS
//
@interface XReader (XPrivate)

-(id) initWithCreatedReader:(xmlTextReader *) reader;
-(id) initWithCreatedReader:(xmlTextReader *) reader withConverter:(XConverter *) converter;
-(void) ensureStartElement;
-(void) moveToContentType:(enum XNodeType) type;
-(void) verifyNodeType:(enum XNodeType) type;
-(void) logInvalidNode:(enum XNodeType) type expectedType:(enum XNodeType) expected;
-(void) close;

-(BOOL) isSuccess:(int) result;

@end

//------------
//
// XReader
//
//------------

@implementation XReader

@synthesize context = m_context;

//
// PROPERTIES
//

-(xmlTextReader *) reader
{
    return m_reader;
}

-(XConverter *) converter
{
    return m_converter;
}

-(int) depth
{
    return xmlTextReaderDepth(m_reader);
}

-(enum XNodeType)nodeType 
{
    if (m_nodeType == XUnknown)
    {
        int type = xmlTextReaderNodeType(m_reader);
        if (type < 0)
        {
            [NSException throwException:NSInternalInconsistencyException];
        }
        
        m_nodeType = (enum XNodeType) type;
    }
    
    return m_nodeType;
}

-(NSString*) nodeTypeString
{
    return XNodeTypeToString(self.nodeType);    
}

-(BOOL) isEmptyElement
{
    return xmlTextReaderIsEmptyElement(m_reader);
}

-(BOOL) hasEndTag
{
    return (![self isEmptyElement]);
}

-(BOOL) isTextualNode
{
    return XIsTextualNodeType(self.nodeType);
}

-(const xmlChar*) name
{
    return xmlTextReaderConstName(m_reader);
}

-(NSString*) localName
{
    if (m_localName == nil)
    {
        m_localName = [NSString fromConstXmlString: xmlTextReaderConstLocalName(m_reader)];
    }
    
    return m_localName;
}

-(const xmlChar*) localNameRaw
{
    return xmlTextReaderConstLocalName(m_reader);
}

-(const xmlChar*) prefix
{
    return xmlTextReaderConstPrefix(m_reader);
}

-(NSString *) namespaceUri
{
    if (m_ns == nil)
    {
        m_ns = [NSString fromConstXmlString: xmlTextReaderConstNamespaceUri(m_reader)];
    }
    
    return m_ns;
}

-(const xmlChar *) namespaceUriRaw
{
    return xmlTextReaderConstNamespaceUri(m_reader);
}

-(BOOL) hasValue
{
    return [self isSuccess:xmlTextReaderHasValue(m_reader)];
}

-(NSString *) value
{
    if (m_value == nil)
    {
        m_value = [NSString fromConstXmlString:xmlTextReaderConstValue(m_reader)];
    }
    
    return m_value;
}

-(const xmlChar *) valueRaw
{
    return xmlTextReaderConstValue(m_reader);
}

-(BOOL) hasAttributes
{
    return xmlTextReaderHasAttributes(m_reader);
}

-(int) attributeCount
{
    return xmlTextReaderAttributeCount(m_reader);
}

-(id) initWithReader:(xmlTextReader *)reader
{
    return [self initWithReader:reader andConverter:nil];
}

-(id)initWithReader:(xmlTextReader *)reader andConverter:(XConverter *)converter
{
    MHVCHECK_NOTNULL(reader);
    
    self = [super init];
    MHVCHECK_SELF;
    
    if (converter)
    {
        m_converter = converter;
    }
    else
    {
        m_converter = [[XConverter alloc] init];
        MHVCHECK_NOTNULL(m_converter);        
    }
    
    m_reader = reader;  // C pointer. Weak ref
    
    return self;
    
LError:
    MHVALLOC_FAIL;
    
}

-(id) initFromMemory:(NSData *)buffer
{
    return [self initFromMemory:buffer withConverter:nil];
}

-(id)initFromMemory:(NSData *)buffer withConverter:(XConverter *)converter
{
    return [self initWithCreatedReader:XAllocBufferReader(buffer) withConverter:converter];
}

-(id) initFromString:(NSString *)string
{
    return [self initFromString:string withConverter:nil];
}

-(id)initFromString:(NSString *)string withConverter:(XConverter *)converter
{
    return [self initWithCreatedReader:XAllocStringReader(string) withConverter:converter];
}

-(id) initFromFile:(NSString *)fileName
{
    return [self initFromFile:fileName withConverter:nil];
}

-(id)initFromFile:(NSString *)fileName withConverter:(XConverter *)converter
{
    return [self initWithCreatedReader:XAllocFileReader(fileName) withConverter:converter];
}

-(id) init
{
    // This will force an error, since you shouldn't call init directly
    return [self initWithReader:nil];
}

-(void) dealloc
{
    [self close];
    
}

-(void) clear
{
    m_nodeType = XUnknown;
    //
    // Ownership of these variables is with the outer autorelease pool
    // We only hold on to them for caching. NOT RETAINED
    //
    m_localName = nil;
    m_ns = nil;
    m_value = nil;
}

-(NSString *) getAttribute:(NSString *)name
{
    MHVCHECK_STRING(name);
     
    xmlChar *xmlName = [name toXmlString]; // The string is auto-released. Delegate null checking to reader
    MHVCHECK_NOTNULL(xmlName);
    
    return [NSString fromXmlStringAndFreeXml: xmlTextReaderGetAttribute(m_reader, xmlName)];

LError:
    return nil;
}

-(NSString *) getAttributeAt:(int)index
{
    return [NSString fromXmlStringAndFreeXml: xmlTextReaderGetAttributeNo(m_reader, index)];
}

-(NSString *) getAttribute:(NSString *)name NS:(NSString *)ns
{
    MHVCHECK_STRING(name);
    MHVCHECK_STRING(ns);
    
    // These strings are auto released. 
    xmlChar *xmlName = [name toXmlString]; 
    xmlChar *xmlNs = [ns toXmlString];  
    
    MHVCHECK_NOTNULL(xmlName);
    MHVCHECK_NOTNULL(xmlNs);
    
    return [NSString fromXmlStringAndFreeXml: xmlTextReaderGetAttributeNs(m_reader, xmlName, xmlNs)];

LError:
    return nil;
}

-(BOOL) moveToAttributeAt:(int)index
{
    [self clear];
    return [self isSuccess:xmlTextReaderMoveToAttributeNo(m_reader, index)];
}

-(BOOL) moveToAttribute:(NSString *)name
{
    MHVCHECK_STRING(name);
    
    [self clear];
    
    xmlChar *xmlName = [name toXmlString];
    MHVCHECK_NOTNULL(xmlName);
    
    return [self isSuccess:xmlTextReaderMoveToAttribute(m_reader, xmlName)];

LError:
    return FALSE;
}

-(BOOL)moveToAttributeWithXmlName:(const xmlChar *)xmlName
{
    [self clear];
    return [self isSuccess:xmlTextReaderMoveToAttribute(m_reader, xmlName)];
}

-(BOOL) moveToAttribute:(NSString *)name NS:(NSString *)ns
{
    MHVCHECK_STRING(name);
    MHVCHECK_STRING(ns);
    
    [self clear];
    
    // These strings are auto released. 
    xmlChar *xmlName = [name toXmlString]; 
    xmlChar *xmlNs = [ns toXmlString];  

    MHVCHECK_NOTNULL(xmlName);
    MHVCHECK_NOTNULL(xmlNs);

    return [self isSuccess:xmlTextReaderMoveToAttributeNs(m_reader, xmlName, xmlNs)];

LError:
    return FALSE;
}

-(BOOL)moveToAttributeWithXmlName:(const xmlChar *)xmlName andXmlNs:(const xmlChar *)xmlNs
{
    [self clear];
    return [self isSuccess:xmlTextReaderMoveToAttributeNs(m_reader, xmlName, xmlNs)];
}

-(BOOL) moveToFirstAttribute
{
    [self clear];
    return [self isSuccess:xmlTextReaderMoveToFirstAttribute(m_reader)]; 
}

-(BOOL) moveToNextAttribute
{
    [self clear];
    return [self isSuccess:xmlTextReaderMoveToNextAttribute(m_reader)];
}

-(BOOL) isStartElement
{
    return ([self moveToContent] == XElement);
}

-(BOOL) isStartElementWithName:(NSString *)name
{
    MHVCHECK_STRING(name);
     
    return ([self isStartElement] && [name isEqualToString:self.localName]);
}

-(BOOL) isStartElementWithName:(NSString *)name NS:(NSString *) ns
{
    MHVCHECK_STRING(name);
    MHVCHECK_STRING(ns);
    
    if (![self isStartElement])
    {
        return FALSE;
    }
    
    if (!self.localName || !self.namespaceUri)
    {
        return FALSE;
    }
    
    return (([name isEqualToString:self.localName]) && [ns isEqualToString:self.namespaceUri]);

LError:
    return FALSE;
}

-(BOOL)isStartElementWithXmlName:(const xmlChar *)name
{
    MHVCHECK_NOTNULL(name);
    
    if (![self isStartElement])
    {
        return FALSE;
    }

    const xmlChar* rawName = self.localNameRaw;
    
    return (rawName && xmlStrEqual(rawName, name));

LError:
    return FALSE;
}

-(enum XNodeType) moveToContent
{
    enum XNodeType type;
    
    BOOL loop = YES;
    while (loop)
    {
        loop = NO;
        type = self.nodeType;
        switch(type)
        {
            case XElement:
            case XText:
            case XCDATA:
            case XEntityRef:
            case XEntityDeclaration:
            case XEndElement:
            case XEndEntity:
                break;
                
            case XAttribute:
                [self moveToElement];
                break;
                
            default:
                if ([self read])
                {
                    loop = YES;
                }
                break;
        }
    }
    
    return type;
}

-(BOOL) moveToElement
{
    [self clear];
    return [self isSuccess:xmlTextReaderMoveToElement(m_reader)];
}

-(BOOL) moveToStartElement
{
    return ([self moveToContent] == XElement);
}

-(BOOL) readStartElement
{
    [self ensureStartElement];
    
    BOOL hasEndTag = ![self isEmptyElement];
    
    [self read];
    
    return hasEndTag;
}

-(BOOL) readStartElementWithName:(NSString *)name
{
    if ([NSString isNilOrEmpty:name])
    {
        MHVLOG(@"Cannot read the start element because the element name parameter is nil or empty.");
        return FALSE;
    }
    
    [self ensureStartElement];
     
    if (!self.localName || ![name isEqualToString:self.localName])
    {
        MHVLOG(@"Cannot read the start element because there is a mismatch between the local name (%@) and the name parameter (%@).", self.localName, name);
        return FALSE;
    }
    
    BOOL hasEndTag = ![self isEmptyElement];
    
    [self read];
    
    return hasEndTag;
}

-(BOOL) readStartElementWithName:(NSString *)name NS:(NSString *)ns
{
    if ([NSString isNilOrEmpty:name] ||
        [NSString isNilOrEmpty:ns])
    {
        MHVLOG(@"The name (%@) or namespace (%@) paramter is nil.", name, ns);
        return FALSE;
    }
    
    [self ensureStartElement];
 
    if (!self.localName || ![name isEqualToString:self.localName])
    {
        MHVLOG(@"Cannot read the start element because there is a mismatch between the local name (%@) and the name parameter (%@).", self.localName, name);
        return FALSE;
    }

    if (!self.namespaceUri || ![ns isEqualToString:self.namespaceUri])
    {
        MHVLOG(@"Cannot read the start element because there is a mismatch between the namespaceUri (%@) and the namespace parameter (%@).", self.namespaceUri, ns);
        return FALSE;
    }
    
    BOOL hasEndTag = ![self isEmptyElement];
    
    [self read];
    
    return hasEndTag;
}

-(BOOL)readStartElementWithXmlName:(const xmlChar *)xName
{
    if (!xName)
    {
        MHVLOG(@"Cannot read the start element because the element name parameter is nil.");
        return NO;
    }
    
    [self ensureStartElement];
 
    const xmlChar* rawName = self.localNameRaw;
    if (!rawName || !xmlStrEqual(rawName, xName))
    {
        MHVLOG(@"Cannot read the start element because there is a mismatch between the local name (%@) and the name parameter (%@).", [NSString newFromXmlString:(xmlChar *)rawName], [NSString newFromXmlString:(xmlChar *)xName]);
        return NO;
    }
    
    BOOL hasEndTag = ![self isEmptyElement];
    
    [self read];
    
    return hasEndTag;
}

-(void) readEndElement
{
    [self moveToContentType:XEndElement];
    [self read];
}

-(BOOL) read
{
    [self clear];
    return [self isSuccess:xmlTextReaderRead(m_reader)];
}

-(NSString *) readString
{
    [self moveToElement];
    if (![self isTextualNode])
    {
        MHVLOG(@"Cannot read the element into a string because the node is not text.");
        return nil;
    }
    NSString * string = [NSString fromXmlStringAndFreeXml:xmlTextReaderReadString(m_reader)];  
    [self read];
    return string;
}

-(NSString *) readElementString
{
    [self ensureStartElement];
    
    if ([self isEmptyElement])
    {
        [self read];
        return c_emptyString;
    }
    
    [self read];
    NSString *str = [self readString];
    [self verifyNodeType:XEndElement];
    [self read];
    
    return str;
}

-(NSString *) readInnerXml
{
    return [NSString fromXmlStringAndFreeXml:xmlTextReaderReadInnerXml(m_reader)];
}

-(NSString *)readOuterXml
{
    return [NSString fromXmlStringAndFreeXml:xmlTextReaderReadOuterXml(m_reader)];
}

-(BOOL) skip
{
    [self clear];
    return [self isSuccess:xmlTextReaderNext(m_reader)];
}

@end

//
// PRIVATE METHODS
//
@implementation XReader (XPrivate)

-(id) initWithCreatedReader:(xmlTextReader *)reader
{
    return [self initWithCreatedReader:reader withConverter:nil];
}

-(id)initWithCreatedReader:(xmlTextReader *)reader withConverter:(XConverter *)converter
{
    self = [self initWithReader:reader andConverter:converter];
    if (!self)
    {
        if (reader)
        {
            xmlFreeTextReader(reader);
        }
        return nil;
    }
    
    return self;
}

-(void) ensureStartElement
{
    if (![self moveToStartElement])
    {
        MHVLOG(@"Could not find start element.");
    }
}

-(void) moveToContentType:(enum XNodeType)type
{
    enum XNodeType nodeType = [self moveToContent];
    if (nodeType != type)
    {
        [self logInvalidNode:nodeType expectedType:type];
    }
}

-(void) verifyNodeType:(enum XNodeType)type
{
    if (self.nodeType != type)
    {
        [self logInvalidNode:self.nodeType expectedType:type];
    }
}

-(void) logInvalidNode:(enum XNodeType)type expectedType:(enum XNodeType)expected
{
    MHVLOG(@"%@ [Expected: %@]", XNodeTypeToString(type), XNodeTypeToString(expected));
}

-(void) close
{
    [self clear];
    if (m_reader)
    {
        xmlTextReaderClose(m_reader);
        xmlFreeTextReader(m_reader);
        m_reader = nil;
    }
}

-(BOOL) isSuccess:(int) result
{
    return (result == READER_TRUE);
}

@end

