//
//  XmlReader.m
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

#import "HVCommon.h"
#import "XReader.h"

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
-(void) throwInvalidNode:(enum XNodeType) type expectedType:(enum XNodeType) expected;
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
    HVCHECK_NOTNULL(reader);
    
    self = [super init];
    HVCHECK_SELF;
    
    if (converter)
    {
        HVRETAIN(m_converter, converter);
    }
    else
    {
        m_converter = [[XConverter alloc] init];
        HVCHECK_NOTNULL(m_converter);        
    }
    
    m_reader = reader;  // C pointer. Weak ref
    
    return self;
    
LError:
    HVALLOC_FAIL;
    
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
    
    [super dealloc];
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
    HVCHECK_STRING(name);
     
    xmlChar *xmlName = [name toXmlString]; // The string is auto-released. Delegate null checking to reader
    HVCHECK_NOTNULL(xmlName);
    
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
    HVCHECK_STRING(name);
    HVCHECK_STRING(ns);
    
    // These strings are auto released. 
    xmlChar *xmlName = [name toXmlString]; 
    xmlChar *xmlNs = [ns toXmlString];  
    
    HVCHECK_NOTNULL(xmlName);
    HVCHECK_NOTNULL(xmlNs);
    
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
    HVCHECK_STRING(name);
    
    [self clear];
    
    xmlChar *xmlName = [name toXmlString];
    HVCHECK_NOTNULL(xmlName);
    
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
    HVCHECK_STRING(name);
    HVCHECK_STRING(ns);
    
    [self clear];
    
    // These strings are auto released. 
    xmlChar *xmlName = [name toXmlString]; 
    xmlChar *xmlNs = [ns toXmlString];  

    HVCHECK_NOTNULL(xmlName);
    HVCHECK_NOTNULL(xmlNs);

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
    HVCHECK_STRING(name);
     
    return ([self isStartElement] && [name isEqualToString:self.localName]);

LError:
    return FALSE;
}

-(BOOL) isStartElementWithName:(NSString *)name NS:(NSString *) ns
{
    HVCHECK_STRING(name);
    HVCHECK_STRING(ns);
    
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
    HVCHECK_NOTNULL(name);
    
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
    
LNext:
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
                goto LNext;
            }
            break;
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
    HVCHECK_STRING(name);
    
    [self ensureStartElement];
     
    if (!self.localName || ![name isEqualToString:self.localName])
    {
        goto LError;
    }
    
    BOOL hasEndTag = ![self isEmptyElement];
    
    [self read];
    
    return hasEndTag;

LError:
    [XException throwException:XExceptionElementMismatch reason:name fromReader:m_reader];
    return FALSE;
}

-(BOOL) readStartElementWithName:(NSString *)name NS:(NSString *)ns
{
    HVCHECK_STRING(name);
    HVCHECK_STRING(ns);
    
    [self ensureStartElement];
 
    if (!self.localName || ![name isEqualToString:self.localName])
    {
        goto LError;
    }

    if (!self.namespaceUri || ![ns isEqualToString:self.namespaceUri])
    {
        goto LError;
    }
    
    BOOL hasEndTag = ![self isEmptyElement];
    
    [self read];
    
    return hasEndTag;
    
LError:
    [XException throwException:XExceptionElementMismatch 
                        reason:[NSString stringWithFormat:@"%@ %@", name, ns] 
                    fromReader:m_reader];
    return FALSE;
}

-(BOOL)readStartElementWithXmlName:(const xmlChar *)xName
{
    HVCHECK_NOTNULL(xName);
    
    [self ensureStartElement];
 
    const xmlChar* rawName = self.localNameRaw;
    if (!rawName || !xmlStrEqual(rawName, xName))
    {
        goto LError;
    }
    
    BOOL hasEndTag = ![self isEmptyElement];
    
    [self read];
    
    return hasEndTag;
    
LError:
    [XException throwException:XExceptionElementMismatch xmlReason:xName fromReader:m_reader];
    return FALSE;    
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
        [XException throwException:XExceptionNotText fromReader:m_reader];
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
    HVCHECK_SELF;
    
    return self;
    
LError:
    if (reader)
    {
        xmlFreeTextReader(reader);
    }
    HVALLOC_FAIL;    
}

-(void) ensureStartElement
{
    if (![self moveToStartElement])
    {
        [XException throwException:XExceptionNotElement fromReader:m_reader];
    }
}

-(void) moveToContentType:(enum XNodeType)type
{
    enum XNodeType nodeType = [self moveToContent];
    if (nodeType != type)
    {
        [self throwInvalidNode:nodeType expectedType:type];
    }
}

-(void) verifyNodeType:(enum XNodeType)type
{
    if (self.nodeType != type)
    {
        [self throwInvalidNode:self.nodeType expectedType:type];
    }
}

-(void) throwInvalidNode:(enum XNodeType)type expectedType:(enum XNodeType)expected
{
    NSString *message = [NSString stringWithFormat:@"%@ [Expected: %@]", XNodeTypeToString(type), XNodeTypeToString(expected)];
    
    [XException throwException:XExceptionInvalidNodeType reason:message fromReader:m_reader];    
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
    [m_converter release];
    [m_context release];
}

-(BOOL) isSuccess:(int) result
{
    if (result == READER_FAIL)
    {
        [XException throwException:XExceptionReaderError fromReader:m_reader];
    }
    
    return (result == READER_TRUE);
}

@end

