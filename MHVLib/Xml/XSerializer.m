//
//  XSerializer.m
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
#import "XSerializer.h"

NSString* const XExceptionNotSerializable = @"X_NotSerializable";

@implementation XSerializer

+(NSString *) serializeToString:(id)obj withRoot:(NSString *)root
{
    XWriter *writer = [[XWriter alloc] init];
    MHVCHECK_NOTNULL(writer);
    
    @try 
    {
        if ([XSerializer serialize:obj withRoot:root toWriter:writer])
        {
            return [writer newXmlString];
        }
    }
    @finally 
    {
        writer = nil;
    }

LError:
    return nil;
}

+(BOOL) serialize:(id)obj withRoot:(NSString *)root toWriter:(XWriter *)writer
{
    MHVCHECK_NOTNULL(obj);
    MHVCHECK_STRING(root);
    MHVCHECK_NOTNULL(writer);
    MHVCHECK_SUCCESS([obj conformsToProtocol:@protocol(XSerializable)]);
    
    //
    // Alloc pool manually. If we use @autoreleasepool, and the serializer throws an exception, which
    // could happen, then the pool won't be released
    // So we release the pool ourselves in the finally block
    // DO NOT replace with @autoreleasepool
    //
    @autoreleasepool
    {
        id savedEx = nil;
        
        @try
        {
            [writer writeElementRequired:root content:(id<XSerializable>) obj];
            return TRUE;
        }
        @catch (id ex)
        {
            savedEx = ex;
            [ex log];
            
            @throw;
        }
    }
    
LError:
    return FALSE;
}

+(BOOL)serialize:(id)obj withRoot:(NSString *)root toFilePath:(NSString *)filePath
{
    MHVCHECK_STRING(filePath);
    
    XWriter* writer = [[XWriter alloc] initFromFile:filePath];
    MHVCHECK_NOTNULL(writer);
    
    @try 
    {
        return [XSerializer serialize:obj withRoot:root toWriter:writer];
    }
    @finally 
    {
        writer = nil;
    }
    
LError:
    return FALSE;
}

+(BOOL)secureSerialize:(id)obj withRoot:(NSString *)root toFilePath:(NSString *)filePath
{
    return [XSerializer secureSerialize:obj withRoot:root toFilePath:filePath withConverter:nil];
}

+(BOOL)secureSerialize:(id)obj withRoot:(NSString *)root toFilePath:(NSString *)filePath withConverter:(XConverter *)converter
{
    XWriter* writer = [[XWriter alloc] initWithBufferSize:2048 andConverter:converter];
    MHVCHECK_NOTNULL(writer);
    
    NSData* rawData = nil;
    @try
    {
        MHVCHECK_SUCCESS([XSerializer serialize:obj withRoot:root toWriter:writer]);
        
        rawData = [[NSData alloc] initWithBytesNoCopy:[writer getXml] length:[writer getLength] freeWhenDone:FALSE];
        MHVCHECK_NOTNULL(rawData);
        
        return [rawData writeToFile:filePath
                            options:NSDataWritingAtomic | NSDataWritingFileProtectionComplete
                              error:nil];
    }
    @catch (id exception)
    {
        [exception log];
    }
    @finally
    {
        rawData = nil;
        writer = nil;
    }
    
LError:
    return FALSE;
}

+(BOOL) deserialize:(XReader *)reader withRoot:(NSString *)root into:(id)obj
{
    MHVCHECK_NOTNULL(reader);
    MHVCHECK_STRING(root);
    MHVCHECK_NOTNULL(obj);
    
    @autoreleasepool
    {
        id savedEx = nil;
        
        @try
        {
            [reader readElementRequired:root intoObject:obj];
            return TRUE;
        }
        @catch (id ex)
        {
            savedEx = ex;
            [ex log];
            
            @throw;
        }
    }

LError:
    return FALSE;
}

@end

@implementation NSObject (XSerializer)

-(NSString *)toXmlStringWithRoot:(NSString *)root
{
    MHVCHECK_STRING(root);
    
    return [XSerializer serializeToString:self withRoot:root];
    
LError:
    return nil;
}

+(id) newFromString:(NSString *)xml withRoot:(NSString *)root asClass:(Class)classObj
{
    MHVCHECK_STRING(xml);
    
    XReader *reader = [[XReader alloc] initFromString:xml];
    MHVCHECK_NOTNULL(reader);
    @try 
    {
        return [NSObject newFromReader:reader withRoot:root asClass:classObj];
    }
    @finally    
    {
        reader = nil;
    }
    
LError: 
    return nil;
}

+(id) newFromReader:(XReader *)reader withRoot:(NSString *)root asClass:(Class)classObj
{
    id obj = nil;
    
    MHVASSERT_NOTNULL(reader);
    MHVCHECK_STRING(root);
    MHVCHECK_NOTNULL(classObj);
    
    obj = [[classObj alloc] init]; // Ownership is passed to caller
    MHVCHECK_NOTNULL(obj);
    
    @try 
    {
        if ([XSerializer deserialize:reader withRoot:root into:obj])
        {
            return obj;
        }
    }
    @finally 
    {
        obj = nil;
    }
    
LError:
    ;
    return nil;
}

+(id) newFromFilePath:(NSString *)filePath withRoot:(NSString *)root asClass:(Class)classObj
{
    MHVCHECK_STRING(filePath);
    
#ifdef LOGXML
    NSString *rawXml = [[NSString alloc] initWithContentsOfFile:filePath usedEncoding:nil error:nil];
    NSLog(@"%@\r\n%@", filePath, rawXml);
    [rawXml release];
#endif
    
    XReader* reader = [[XReader alloc] initFromFile:filePath];
    MHVCHECK_NOTNULL(reader);
    @try 
    {
        return [NSObject newFromReader:reader withRoot:root asClass:classObj];
    }
    @catch (id ex) 
    {
        // Eat deserialization exceptions for now. 
        [ex log];
    }
    @finally    
    {
        reader = nil;
    }
    
LError:
    return nil;    
}

+(id)newFromSecureFilePath:(NSString *)filePath withRoot:(NSString *)root asClass:(Class)classObj
{
    return [NSObject newFromSecureFilePath:filePath withRoot:root asClass:classObj withConverter:nil];
}

+(id)newFromSecureFilePath:(NSString *)filePath withRoot:(NSString *)root asClass:(Class)classObj withConverter:(XConverter *)converter
{
    MHVCHECK_STRING(filePath);
    
    XReader* reader = nil;
    NSData* fileData = nil;
    @try
    {
        fileData = [[NSData alloc] initWithContentsOfFile:filePath];
        if (!fileData)
        {
            return nil;
        }
        
        reader = [[XReader alloc] initFromMemory:fileData withConverter:converter];
        MHVCHECK_NOTNULL(reader);
        
        return [NSObject newFromReader:reader withRoot:root asClass:classObj];
    }
    @catch (id ex)
    {
        [ex log];
    }
    @finally
    {
        fileData = nil;
        reader = nil;
    }
    
LError:
    return nil;    
}

+(id) newFromFileUrl:(NSURL *)url withRoot:(NSString *)root asClass:(Class)classObj
{
    MHVCHECK_NOTNULL(url);
    
    return [NSObject newFromFilePath:url.path withRoot:root asClass:classObj];
    
LError:
    return nil;
}


+(id) newFromResource:(NSString *)name withRoot:(NSString *)root asClass:(Class)classObj
{
    NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:@"xml"];
    if ([NSString isNilOrEmpty:path])
    {
        return nil;
    }
    
    return [NSObject newFromFilePath:path withRoot:root asClass:classObj];
    
LError:
    return nil;    
}

@end

@implementation XReader (XSerializer)

-(NSString *) readValue
{
    if (!self.isTextualNode)
    {
        return nil;
    }
    
    NSString *value = self.value;
    [self read];
    return value;
}

-(NSString *) readValueEnsure
{
    if (!self.isTextualNode)
    {
        [XException throwException:XExceptionNotText fromReader:m_reader];
    }
    
    NSString *value = self.value;
    if (!value)
    {
        [XException throwException:XExceptionNotText fromReader:m_reader];
    }
    [self read];
    return value;
}

-(NSUUID *) readUuid
{
    return [self.converter stringToUuid:[self readValueEnsure]];
}

-(int) readInt
{
    return [self.converter stringToInt:[self readValueEnsure]];
}

-(float) readFloat
{
    return [self.converter stringToFloat:[self readValueEnsure]];
}

-(double) readDouble
{
    return [self.converter stringToDouble:[self readValueEnsure]];
}

-(BOOL) readBool
{
    return [self.converter stringToBool:[self readValueEnsure]];
}

-(NSDate *)readDate
{
    return [self.converter stringToDate:[self readValueEnsure]];
}

-(NSString *)readNextElement
{
    NSString *value = nil;
    
    if ([self readStartElement])
    {
        value = [self readValue];
        
        if (value != nil || self.nodeType == XEndElement)
        {
            [self readEndElement];
        }
    }
    
    return (value != nil) ? value : c_emptyString;
}

-(NSString *) readStringElementRequired:(NSString *)name
{
    NSString *value = nil;
    
    if ([self readStartElementWithName:name])
    {
        value = [self readValue];
        
        if (value != nil || self.nodeType == XEndElement)
        {
            [self readEndElement];
        }
    }
    
    return (value != nil) ? value : c_emptyString;
}

-(NSString *) readStringElement:(NSString *)name
{
    if ([self isStartElementWithName:name])
    {
        return [self readNextElement];
    }
    
    return nil;
}

-(NSDate *)readNextDate
{
    NSString* string = [self readNextElement];
    if ([NSString isNilOrEmpty:string])
    {
        return nil;
    }
    
    return [self.converter stringToDate:string];    
}

-(NSDate*) readDateElement:(NSString *)name
{
    NSString* string = [self readStringElement:name];
    if ([NSString isNilOrEmpty:string])
    {
        return nil;
    }
    
    return [self.converter stringToDate:string];
}

-(int)readNextInt
{
    NSString* string = [self readNextElement];
    if ([NSString isNilOrEmpty:string])
    {
        return 0;
    }
    
    return [self.converter stringToInt:string];    
}

-(int) readIntElement:(NSString *)name
{
    NSString* string = [self readStringElement:name];
    if ([NSString isNilOrEmpty:string])
    {
        return 0;
    }
    
    return [self.converter stringToInt:string];
}

-(BOOL) readIntElement:(NSString *)name into:(NSInteger *)value
{
    if ([self isStartElementWithName:name])
    {
        *value = [self readIntElement:name];
        return TRUE;
    }
    
    return FALSE;
}

-(double)readNextDouble
{
    NSString* string = [self readNextElement];
    if ([NSString isNilOrEmpty:string])
    {
        return 0.0;
    }
    
    return [self.converter stringToDouble:string];    
}

-(double) readDoubleElement:(NSString *)name
{
    NSString* string = [self readStringElement:name];
    if ([NSString isNilOrEmpty:string])
    {
        return 0.0;
    }
    
    return [self.converter stringToDouble:string];
}

-(BOOL)readDoubleElement:(NSString *)name into:(double *)value
{
    if ([self isStartElementWithName:name])
    {
        *value = [self readDoubleElement:name];
        return TRUE;
    }
    
    return FALSE;
}

-(BOOL)readNextBool
{
    NSString* string = [self readNextElement];
    if ([NSString isNilOrEmpty:string])
    {
        return 0;
    }
    
    return [self.converter stringToBool:string];    
}

-(BOOL)readBoolElement:(NSString *)name
{
    NSString* string = [self readStringElement:name];
    if ([NSString isNilOrEmpty:string])
    {
        return 0;
    }
    
    return [self.converter stringToBool:string];    
}

-(BOOL) readBoolElement:(NSString *)name into:(BOOL *)value
{
    if ([self isStartElementWithName:name])
    {
        *value = [self readBoolElement:name];
        return TRUE;
    }
    
    return FALSE;
}

-(void)readElementContentIntoObject:(id<XSerializable>)content
{
    if (content == nil)
    {
        [NSException throwInvalidArg];
    }
    //
    // Deserialize any attributes
    //
    [content deserializeAttributes:self];
    //
    // Now read the element contents, if any
    //
    int currentDepth = self.depth;
    if ([self readStartElement])
    {
        //
        // Has content and a distrinct end tag
        //
        [content deserialize:self];
        //
        // We may not have consumed all items...
        // So skip any that were not
        //
        while (self.depth > currentDepth && [self read]);
        //
        // Read last element
        //
        [self readEndElement];
    }    
}

-(id) readElementRequired:(NSString *)name asClass:(Class)classObj
{
    id obj = [[classObj alloc] init];
    MHVCHECK_OOM(obj);
    
    [self readElementRequired:name intoObject:obj];
    return obj;
}

-(void) readElementRequired:(NSString *)name intoObject:(id<XSerializable>)content
{
    if (![self isStartElementWithName:name])
    {
        [XException throwException:XExceptionElementMismatch reason:name fromReader:m_reader];
    }
    return [self readElementContentIntoObject:content];
}

-(id) readElement:(NSString *)name asClass:(Class)classObj
{
    if ([self isStartElementWithName:name])
    {
        id obj = [[classObj alloc] init];
        MHVCHECK_OOM(obj);
        
        [self readElementContentIntoObject:obj];
        
        return obj;
    }
    
    return nil;
}

-(NSString *)readElementRaw:(NSString *)name
{
    if ([self isStartElementWithName:name])
    {
        NSString* xml = [self readOuterXml];
        
        [self skipSingleElement:name];
        
        return xml;
    }
    
    return nil;    
}

-(NSMutableArray *) readElementArray:(NSString *)name asClass:(Class) classObj;
{
    return [self readElementArray:name asClass:classObj andArrayClass:[NSMutableArray class]];
}

-(NSMutableArray *) readElementArray:(NSString *)name asClass:(Class)classObj andArrayClass:(Class)arrayClassObj
{
    const xmlChar* xName = [name toXmlString];
    MHVCHECK_OOM(xName);
    
    return [self readElementArrayWithXmlName:xName asClass:classObj andArrayClass:arrayClassObj];
}

-(NSMutableArray *) readElementArray:(NSString *)name itemName:(NSString *)itemName asClass:(Class)classObj andArrayClass:(Class)arrayClassObj
{
    NSMutableArray* array = nil;
    if ([self readStartElementWithName:name])
    {
        array = [self readElementArray:itemName asClass:classObj andArrayClass:arrayClassObj];
        [self readEndElement];
    }
    return array;
}

-(MHVStringCollection *) readStringElementArray:(NSString *)name
{
    MHVStringCollection *elements = nil;
    while ([self isStartElementWithName:name])
    {
        if (elements == nil)
        {
            elements = [[MHVStringCollection alloc] init];
            MHVCHECK_OOM(elements);
        }

        [elements addObject:[self readStringElementRequired:name]];
    }
 
    return elements;
}

-(NSMutableArray *)readRawElementArray:(NSString *)name
{
    NSMutableArray* elements = nil;
    NSString* xml = nil;
 
    if ([self isStartElementWithName:name])
    {
        while ((xml = [self readElementRaw:name]))
        {
            if (!elements)
            {
                elements = [[NSMutableArray alloc] init];
            }
            [elements addObject:xml];
        }
    }
    
    return elements;
}

-(NSString *) readAttribute:(NSString *)name
{
    if (![self moveToAttribute:name])
    {
        return nil;
    }
    
    NSString* value = self.value;
    
    [self moveToElement];
    
    return value;
}

-(BOOL) readIntAttribute:(NSString *)name intValue:(int *) value
{
    if (!self.hasAttributes || ![self moveToAttribute:name])
    {
        return FALSE;
    }
    
    NSString* string = self.value;
    *value = [self.converter stringToInt:string];
    
    [self moveToElement];
    
    return TRUE;
}

-(BOOL)readBoolAttribute:(NSString *)name boolValue:(BOOL *)value
{
    if (!self.hasAttributes || ![self moveToAttribute:name])
    {
        return FALSE;
    }
    
    NSString* string = self.value;
    *value = [self.converter stringToBool:string];
    
    [self moveToElement];
    
    return TRUE;    
}

-(BOOL)readDoubleAttribute:(NSString *)name doubleValue:(double *)value
{
    if (!self.hasAttributes || ![self moveToAttribute:name])
    {
        return FALSE;
    }
    
    NSString* string = self.value;
    *value = [self.converter stringToDouble:string];
    
    [self moveToElement];
    
    return TRUE;    
}

-(BOOL)readFloatAttribute:(NSString *)name floatValue:(float *)value
{
    if (!self.hasAttributes || ![self moveToAttribute:name])
    {
        return FALSE;
    }
    
    NSString* string = self.value;
    *value = [self.converter stringToFloat:string];
    
    [self moveToElement];
    
    return TRUE;    
}

-(BOOL) readUntilNodeType:(enum XNodeType)type
{
    while ([self read])
    {
        if (self.nodeType == type)
        {
            return TRUE;
        }
    }
    
    return FALSE;
}

-(BOOL) skipElement:(NSString *)name
{    
    while ([self isStartElementWithName:name])
    {
        [self skipSingleElement];
    }
    
    return TRUE;
}

-(BOOL)skipSingleElement
{
    int currentDepth = [self depth];
    if ([self readStartElement])
    {
        // A non-empty element
        while (self.depth > currentDepth)
        {
            if (![self read])
            {
                return FALSE;
            }
        }
        [self readEndElement];
    }
    
    return TRUE;
}

-(BOOL)skipSingleElement:(NSString *)name
{
    if ([self isStartElementWithName:name])
    {
        return [self skipSingleElement];
    }
    
    return TRUE;    
}

-(BOOL)skipToElement:(NSString *)name
{
    while ([self isStartElement])
    {
        if ([name isEqualToString:self.localName])
        {
            return TRUE;
        }
        
        if (![self skipElement:self.localName])
        {
            break;
        }
    }
    
    return FALSE;
}

-(id)readElementRequiredWithXmlName:(const xmlChar *)xName asClass:(Class)classObj
{
    id obj = [[classObj alloc] init];
    MHVCHECK_OOM(obj);
    
    [self readElementRequiredWithXmlName:xName intoObject:obj];
    return obj;
}

-(void)readElementRequiredWithXmlName:(const xmlChar *)xName intoObject:(id<XSerializable>)content
{
    if (![self isStartElementWithXmlName:xName])
    {
        [XException throwException:XExceptionElementMismatch xmlReason:xName fromReader:m_reader];
    }
    
    return [self readElementContentIntoObject:content];
    
}

-(id)readElementWithXmlName:(const xmlChar *)xmlName asClass:(Class)classObj
{
    if ([self isStartElementWithXmlName:xmlName])
    {
        id obj = [[classObj alloc] init];
        MHVCHECK_OOM(obj);
        
        [self readElementContentIntoObject:obj];
        
        return obj;
    }
    
    return nil;
}

-(NSString *)readStringElementWithXmlName:(const xmlChar *)xmlName
{
    if ([self isStartElementWithXmlName:xmlName])
    {
        return [self readNextElement];
    }
    
    return nil;    
}

-(NSDate *)readDateElementXmlName:(const xmlChar *)xmlName
{
    NSString* string = [self readStringElementWithXmlName:xmlName];
    if ([NSString isNilOrEmpty:string])
    {
        return nil;
    }
    
    return [self.converter stringToDate:string];
}

-(int) readIntElementXmlName:(const xmlChar *)xmlName
{
    NSString* string = [self readStringElementWithXmlName:xmlName];
    if ([NSString isNilOrEmpty:string])
    {
        return 0;
    }
    
    return [self.converter stringToInt:string];
}

-(BOOL) readIntElementXmlName:(const xmlChar *)xmlName into:(int *)value
{
    if ([self isStartElementWithXmlName:xmlName])
    {
        *value = [self readIntElementXmlName:xmlName];
        return TRUE;
    }
    
    return FALSE;
}

-(double) readDoubleElementXmlName:(const xmlChar *)xmlName
{
    NSString* string = [self readStringElementWithXmlName:xmlName];
    if ([NSString isNilOrEmpty:string])
    {
        return 0.0;
    }
    
    return [self.converter stringToDouble:string];
}

-(BOOL)readDoubleElementXmlName:(const xmlChar *)xmlName into:(double *)value
{
    if ([self isStartElementWithXmlName:xmlName])
    {
        *value = [self readDoubleElementXmlName:xmlName];
        return TRUE;
    }
    
    return FALSE;
}

-(BOOL)readBoolElementXmlName:(const xmlChar *)xmlName
{
    NSString* string = [self readStringElementWithXmlName:xmlName];
    if ([NSString isNilOrEmpty:string])
    {
        return 0;
    }
    
    return [self.converter stringToBool:string];
}

-(BOOL) readBoolElementXmlName:(const xmlChar *)xmlName into:(BOOL *)value
{
    if ([self isStartElementWithXmlName:xmlName])
    {
        *value = [self readBoolElementXmlName:xmlName];
        return TRUE;
    }
    
    return FALSE;
}

-(NSString *)readAttributeWithXmlName:(const xmlChar *)xmlName
{
    if (![self moveToAttributeWithXmlName:xmlName])
    {
        return nil;
    }
    
    NSString* value = self.value;
    
    [self moveToElement];
    
    return value;
}

-(NSString *)readElementRawWithXmlName:(const xmlChar *)xmlName
{
    if ([self isStartElementWithXmlName:xmlName])
    {
        NSString* xml = [self readOuterXml];
        
        [self skipSingleElementWithXmlName:xmlName];
        
        return xml;
    }
    
    return nil;
}

-(NSMutableArray *)readElementArrayWithXmlName:(const xmlChar *)xName asClass:(Class)classObj
{
    return [self readElementArrayWithXmlName:xName asClass:classObj andArrayClass:[NSMutableArray class]];
}

-(NSMutableArray *)readElementArrayWithXmlName:(const xmlChar *)xName asClass:(Class)classObj andArrayClass:(Class)arrayClassObj
{
    NSMutableArray *elements = nil;
    while ([self isStartElementWithXmlName:xName])
    {
        if (elements == nil)
        {
            elements = [[arrayClassObj alloc] init];
            MHVCHECK_OOM(elements);
        }
        
        [elements addObject:[self readElementRequiredWithXmlName:xName asClass:classObj]];
    }
    
    return elements;
}

-(NSMutableArray *)readElementArrayWithXmlName:(const xmlChar *)xName itemName:(const xmlChar *)itemName asClass:(Class)classObj andArrayClass:(Class)arrayClassObj
{
    NSMutableArray* array = nil;
    if ([self readStartElementWithXmlName:xName])
    {
        array = [self readElementArrayWithXmlName:itemName asClass:classObj andArrayClass:arrayClassObj];
        [self readEndElement];
    }
    return array;
    
}

-(BOOL)skipElementWithXmlName:(const xmlChar *)xmlName
{
    while ([self isStartElementWithXmlName:xmlName])
    {
        [self skipSingleElement];
    }
    
    return TRUE;
}

-(BOOL)skipSingleElementWithXmlName:(const xmlChar *)xmlName
{
    if ([self isStartElementWithXmlName:xmlName])
    {
        return [self skipSingleElement];
    }
    
    return TRUE;    
}

@end


void throwWriterError(void)
{
    [XException throwException:XExceptionWriterError reason:c_emptyString]; 
}

@implementation XWriter (XSerializer)

-(void) writeUuid:(NSUUID *) uuid;
{
    [self writeText:[self.converter uuidToString:uuid]];
}

-(void) writeInt:(int)value
{
    [self writeText:[self.converter intToString:value]];
}

-(void) writeFloat:(float)value
{
    [self writeText:[self.converter floatToString:value]]; 
}

-(void) writeDouble:(double)value
{
    [self writeText:[self.converter doubleToString:value]];
}

-(void) writeBool:(BOOL)value
{
    [self writeText:[self.converter boolToString:value]];
}

-(void) writeDate:(NSDate *)value
{
    [self writeText:[self.converter dateToString:value]];
}

-(void) writeEmptyElement:(NSString *)name
{
    MHVCHECK_XWRITE([self writeStartElement:name]);
    MHVCHECK_XWRITE([self writeEndElement]);
}

-(void) writeElementRequired:(NSString *)name content:(id<XSerializable>)content
{
    if (content == nil)
    {
        [XException throwException:XExceptionRequiredDataMissing reason:name];
    }
    
    MHVCHECK_XWRITE([self writeStartElement:name]);
    {
        [content serializeAttributes:self];
        [content serialize:self];
    }
    MHVCHECK_XWRITE([self writeEndElement]);
}

-(void) writeElementRequired:(NSString *)name value:(NSString *)value
{
    if (!value)
    {
        [NSException throwInvalidArg];
    }
    
    MHVCHECK_XWRITE([self writeStartElement:name]);
    {
        [self writeText:value];
    }
    MHVCHECK_XWRITE([self writeEndElement]);
}

-(void) writeElementArrayRequired:(NSString *)name elements:(NSArray *)array
{
    if ([NSArray isNilOrEmpty:array])
    {
        [XException throwException:XExceptionRequiredDataMissing reason:name];
    }
    
    for (id obj in array)
    {
        [self writeElement:name object:obj];
    }
}

-(void) writeElement:(NSString *)name content:(id<XSerializable>)content
{
    if (content == nil)
    {
        return;
    }
    
    [self writeElementRequired:name content:content];
}

-(void) writeElement:(NSString *)name value:(NSString *)value
{
    if (!value)
    {
        return;
    }
    
    [self writeElementRequired:name value:value];
}

-(void) writeElementArray:(NSString *)name elements:(NSArray *)array
{
    if ([NSArray isNilOrEmpty:array])
    {
        return;
    }
    
    [self writeElementArrayRequired:name elements:array];
}

-(void) writeElementArray:(NSString *)name itemName:(NSString *)itemName elements :(NSArray *)array
{
    if ([NSArray isNilOrEmpty:array])
    {
        return;
    }
    
    MHVCHECK_XWRITE([self writeStartElement:name]);
    {
        [self writeElementArray:itemName elements:array];
    }
    MHVCHECK_XWRITE([self writeEndElement]);
}

-(void)writeRawElementArray:(NSString *)name elements:(NSArray *)array
{
    if ([NSArray isNilOrEmpty:array])
    {
        return;
    }
    
    for (NSString* xml in array) 
    {
        MHVCHECK_XWRITE([self writeRaw:xml]);
    }
}

-(void) writeElement:(NSString *)name intValue:(int)value
{
    MHVCHECK_XWRITE([self writeStartElement:name]);
    {
        [self writeInt:value];
    }
    MHVCHECK_XWRITE([self writeEndElement]);
}

-(void)writeElement:(NSString *)name doubleValue:(double)value
{
    MHVCHECK_XWRITE([self writeStartElement:name]);
    {
        [self writeDouble:value];
    }
    MHVCHECK_XWRITE([self writeEndElement]);
}

-(void) writeElement:(id)name dateValue:(NSDate *)value
{
    if (value == nil)
    {
        return;
    }

    MHVCHECK_XWRITE([self writeStartElement:name]);
    {
        [self writeDate:value];
    }
    MHVCHECK_XWRITE([self writeEndElement]);
}

-(void)writeElement:(NSString *)name boolValue:(BOOL)value
{
    MHVCHECK_XWRITE([self writeStartElement:name]);
    {
        [self writeBool:value];
    }
    MHVCHECK_XWRITE([self writeEndElement]);    
}

-(void)writeElement:(NSString *)name object:(id)value
{
    if ([value conformsToProtocol:@protocol(XSerializable)])
    {
        [self writeElement:name content:(id<XSerializable>)value];
    }
    else if ([value isKindOfClass:[NSString class]])
    {
        [self writeElement:name value:(NSString *) value];
    }
    else
    {
        NSString* description = [value description];
        [self writeElement:name value:description];
    }
}

-(void) writeAttribute:(NSString *)name intValue:(int)value
{
    [self writeAttribute:name value:[self.converter intToString:value]];
}

-(void) writeText:(NSString *)value
{
    if ([NSString isNilOrEmpty:value])
    {
        return;
    }
    
    MHVCHECK_XWRITE([self writeString:value]);
}

-(void)writeElementXmlName:(const xmlChar *)xmlName content:(id<XSerializable>)content
{
    if (content == nil)
    {
        return;
    }
    
    MHVCHECK_XWRITE([self writeStartElementXmlName:xmlName]);
    {
        [content serializeAttributes:self];
        [content serialize:self];
    }
    MHVCHECK_XWRITE([self writeEndElement]);
    
}

-(void) writeElementXmlName:(const xmlChar *)xmlName value:(NSString *)value
{
    if (!value)
    {
        return;
    }
    
    MHVCHECK_XWRITE([self writeStartElementXmlName:xmlName]);
    {
        [self writeText:value];
    }
    MHVCHECK_XWRITE([self writeEndElement]);
}

-(void)writeElementXmlName:(const xmlChar *)xmlName doubleValue:(double)value
{
    MHVCHECK_XWRITE([self writeStartElementXmlName:xmlName]);
    {
        [self writeDouble:value];
    }
    MHVCHECK_XWRITE([self writeEndElement]);    
}

-(void)writeElementXmlName:(const xmlChar *)xmlName dateValue:(NSDate *)value
{
    if (!value)
    {
        return;
    }
    
    MHVCHECK_XWRITE([self writeStartElementXmlName:xmlName]);
    {
        [self writeDate:value];
    }
    MHVCHECK_XWRITE([self writeEndElement]);    
}

-(void)writeElementXmlName:(const xmlChar *)xmlName intValue:(int)value
{
    MHVCHECK_XWRITE([self writeStartElementXmlName:xmlName]);
    {
        [self writeInt:value];
    }
    MHVCHECK_XWRITE([self writeEndElement]);    
}

-(void)writeElementXmlName:(const xmlChar *)xmlName boolValue:(BOOL)value
{
    MHVCHECK_XWRITE([self writeStartElementXmlName:xmlName]);
    {
        [self writeBool:value];
    }
    MHVCHECK_XWRITE([self writeEndElement]);    
}

@end
