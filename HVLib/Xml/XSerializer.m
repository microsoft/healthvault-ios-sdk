//
//  XSerializer.m
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
#import "XSerializer.h"

NSString* const XExceptionNotSerializable = @"X_NotSerializable";

@implementation XSerializer

+(NSString *) serializeToString:(id)obj withRoot:(NSString *)root
{
    XWriter *writer = [[XWriter alloc] init];
    HVCHECK_NOTNULL(writer);
    
    @try 
    {
        if ([XSerializer serialize:obj withRoot:root toWriter:writer])
        {
            return [[writer newXmlString] autorelease];
        }
    }
    @finally 
    {
        [writer release];
    }

LError:
    return nil;
}

+(BOOL) serialize:(id)obj withRoot:(NSString *)root toWriter:(XWriter *)writer
{
    HVCHECK_NOTNULL(obj);
    HVCHECK_STRING(root);
    HVCHECK_NOTNULL(writer);
    HVCHECK_SUCCESS([obj conformsToProtocol:@protocol(XSerializable)]);
    
    //
    // Alloc pool manually. If we use @autoreleasepool, and the serializer throws an exception, which
    // could happen, then the pool won't be released
    // So we release the pool ourselves in the finally block
    // DO NOT replace with @autoreleasepool
    //
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    HVCHECK_NOTNULL(pool);
    id savedEx = nil;
    
    @try 
    {
        [writer writeElementRequired:root content:(id<XSerializable>) obj];
        return TRUE;
    }
    @catch (id ex) 
    {
        savedEx = [ex retain];
        [ex log];

        @throw;
    }
    @finally 
    {
        [pool release];
        [savedEx autorelease]; // Transfer the exception to the next autorelease pool
    }
        
LError:
    return FALSE;
}

+(BOOL)serialize:(id)obj withRoot:(NSString *)root toFilePath:(NSString *)filePath
{
    HVCHECK_STRING(filePath);
    
    XWriter* writer = [[XWriter alloc] initFromFile:filePath];
    HVCHECK_NOTNULL(writer);
    
    @try 
    {
        return [XSerializer serialize:obj withRoot:root toWriter:writer];
    }
    @finally 
    {
        [writer release];
    }
    
LError:
    return FALSE;
}

+(BOOL)secureSerialize:(id)obj withRoot:(NSString *)root toFilePath:(NSString *)filePath
{
    XWriter* writer = [[XWriter alloc] initWithBufferSize:2048];   
    HVCHECK_NOTNULL(writer);
    
    NSData* rawData = nil;
    @try 
    {
        HVCHECK_SUCCESS([XSerializer serialize:obj withRoot:root toWriter:writer]);
        
        rawData = [[NSData alloc] initWithBytesNoCopy:[writer getXml] length:[writer getLength] freeWhenDone:FALSE];
        HVCHECK_NOTNULL(rawData);
        
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
        [rawData release];
        [writer release];
    }

LError:
    return FALSE;
}

+(BOOL) deserialize:(XReader *)reader withRoot:(NSString *)root into:(id)obj
{
    HVCHECK_NOTNULL(reader);
    HVCHECK_STRING(root);
    HVCHECK_NOTNULL(obj);
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    HVCHECK_NOTNULL(pool);
    id savedEx = nil;
    
    @try 
    {
        [reader readElementRequired:root intoObject:obj];
        return TRUE;
    }
    @catch (id ex) 
    {
        savedEx = [ex retain];
        [ex log];
        
        @throw;
    }
    @finally 
    {
        [pool release];
        [savedEx autorelease];
    }

LError:
    return FALSE;
}

@end

@implementation NSObject (XSerializer)

-(NSString *)toXmlStringWithRoot:(NSString *)root
{
    HVCHECK_STRING(root);
    
    return [XSerializer serializeToString:self withRoot:root];
    
LError:
    return nil;
}

+(id) newFromString:(NSString *)xml withRoot:(NSString *)root asClass:(Class)classObj
{
    HVCHECK_STRING(xml);
    
    XReader *reader = [[XReader alloc] initFromString:xml];
    HVCHECK_NOTNULL(reader);
    @try 
    {
        return [NSObject newFromReader:reader withRoot:root asClass:classObj];
    }
    @finally    
    {
        [reader release];
    }
    
LError: 
    return nil;
}

+(id) newFromReader:(XReader *)reader withRoot:(NSString *)root asClass:(Class)classObj
{
    id obj = nil;
    
    HVASSERT_NOTNULL(reader);
    HVCHECK_STRING(root);
    HVCHECK_NOTNULL(classObj);
    
    obj = [[classObj alloc] init]; // Ownership is passed to caller
    HVCHECK_NOTNULL(obj);
    
    @try 
    {
        if ([XSerializer deserialize:reader withRoot:root into:obj])
        {
            return [obj retain];
        }
    }
    @finally 
    {
        [obj release];
    }
    
LError:
    [obj release];
    return nil;
}

+(id) newFromFilePath:(NSString *)filePath withRoot:(NSString *)root asClass:(Class)classObj
{
    HVCHECK_STRING(filePath);
    
#ifdef LOGXML
    NSString *rawXml = [[NSString alloc] initWithContentsOfFile:filePath usedEncoding:nil error:nil];
    NSLog(@"%@\r\n%@", filePath, rawXml);
    [rawXml release];
#endif
    
    XReader* reader = [[XReader alloc] initFromFile:filePath];
    HVCHECK_NOTNULL(reader);
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
        [reader release];
    }
    
LError:
    return nil;    
}

+(id)newFromSecureFilePath:(NSString *)filePath withRoot:(NSString *)root asClass:(Class)classObj
{
    HVCHECK_STRING(filePath);
    
    XReader* reader = nil;
    NSData* fileData = nil;
    @try 
    {
        fileData = [[NSData alloc] initWithContentsOfFile:filePath];
        if (!fileData)
        {
            return nil;
        }
        
        reader = [[XReader alloc] initFromMemory:fileData];
        HVCHECK_NOTNULL(reader);
        
        return [NSObject newFromReader:reader withRoot:root asClass:classObj];
    }
    @catch (id ex) 
    {
        [ex log];
    }
    @finally 
    {
        [fileData release];
        [reader release];
    }
    
LError:
    return nil;
}

+(id) newFromFileUrl:(NSURL *)url withRoot:(NSString *)root asClass:(Class)classObj
{
    HVCHECK_NOTNULL(url);
    
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

-(CFUUIDRef) readGuid
{
    return [self.converter stringToGuid:[self readValueEnsure]];
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
        return [self readStringElementRequired:name];
    }
    
    return nil;
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

-(int) readIntElement:(NSString *)name
{
    NSString* string = [self readStringElement:name];
    if ([NSString isNilOrEmpty:string])
    {
        return 0;
    }
    
    return [self.converter stringToInt:string];
}

-(BOOL) readIntElement:(NSString *)name into:(int *)value
{
    if ([self isStartElementWithName:name])
    {
        *value = [self readIntElement:name];
        return TRUE;
    }
    
    return FALSE;
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

-(id) readElementRequired:(NSString *)name asClass:(Class)classObj
{
    id obj = [[[classObj alloc] init] autorelease];
    HVCHECK_OOM(obj);
    
    [self readElementRequired:name intoObject:obj];
    return obj;
}

-(id) readElement:(NSString *)name asClass:(Class)classObj
{
    if ([self isStartElementWithName:name])
    {
        return [self readElementRequired:name asClass:classObj];
    }
    
    return nil;
}

-(void) readElementRequired:(NSString *)name intoObject:(id<XSerializable>)content
{
    if (content == nil)
    {
        [NSException throwInvalidArg];
    }
    
    if (![self isStartElementWithName:name])
    {
        [XException throwException:XExceptionElementMismatch reason:name fromReader:m_reader];
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
    NSMutableArray *elements = nil;
    while ([self isStartElementWithName:name])
    {
        if (elements == nil)
        {
            elements = [[[arrayClassObj alloc] init] autorelease];
            HVCHECK_OOM(elements);
        }

        [elements addObject:[self readElementRequired:name asClass:classObj]];
    }
    
    return elements;
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

-(HVStringCollection *) readStringElementArray:(NSString *)name
{
    HVStringCollection *elements = nil;
    while ([self isStartElementWithName:name])
    {
        if (elements == nil)
        {
            elements = [[[HVStringCollection alloc] init] autorelease];
            HVCHECK_OOM(elements);
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
                elements = [[[NSMutableArray alloc] init] autorelease];
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
      }
    
    return TRUE;
}

-(BOOL)skipSingleElement:(NSString *)name
{
    if ([self isStartElementWithName:name])
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

@end


void throwWriterError(void)
{
    [XException throwException:XExceptionWriterError reason:c_emptyString]; 
}

@implementation XWriter (XSerializer)

-(void) writeGuid:(CFUUIDRef)guid
{
    [self writeText:[self.converter guidToString:guid]];
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
    HVCHECK_XWRITE([self writeStartElement:name]);
    HVCHECK_XWRITE([self writeEndElement]);
}

-(void) writeElementRequired:(NSString *)name content:(id<XSerializable>)content
{
    if (content == nil)
    {
        [XException throwException:XExceptionRequiredDataMissing reason:name];
    }
    
    HVCHECK_XWRITE([self writeStartElement:name]);
    {
        [content serializeAttributes:self];
        [content serialize:self];
    }
    HVCHECK_XWRITE([self writeEndElement]);
}

-(void) writeElementRequired:(NSString *)name value:(NSString *)value
{
    if (!value)
    {
        [NSException throwInvalidArg];
    }
    
    HVCHECK_XWRITE([self writeStartElement:name]);
    {
        [self writeText:value];
    }
    HVCHECK_XWRITE([self writeEndElement]);
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
    
    HVCHECK_XWRITE([self writeStartElement:name]);
    {
        [self writeElementArray:itemName elements:array];
    }
    HVCHECK_XWRITE([self writeEndElement]);
}

-(void)writeRawElementArray:(NSString *)name elements:(NSArray *)array
{
    if ([NSArray isNilOrEmpty:array])
    {
        return;
    }
    
    for (NSString* xml in array) 
    {
        HVCHECK_XWRITE([self writeRaw:xml]);
    }
}

-(void) writeElement:(NSString *)name intValue:(int)value
{
    HVCHECK_XWRITE([self writeStartElement:name]);
    {
        [self writeInt:value];
    }
    HVCHECK_XWRITE([self writeEndElement]);
}

-(void)writeElement:(NSString *)name doubleValue:(double)value
{
    HVCHECK_XWRITE([self writeStartElement:name]);
    {
        [self writeDouble:value];
    }
    HVCHECK_XWRITE([self writeEndElement]);
}

-(void) writeElement:(id)name dateValue:(NSDate *)value
{
    if (value == nil)
    {
        return;
    }

    HVCHECK_XWRITE([self writeStartElement:name]);
    {
        [self writeDate:value];
    }
    HVCHECK_XWRITE([self writeEndElement]);
}

-(void)writeElement:(NSString *)name boolValue:(BOOL)value
{
    HVCHECK_XWRITE([self writeStartElement:name]);
    {
        [self writeBool:value];
    }
    HVCHECK_XWRITE([self writeEndElement]);    
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
    
    HVCHECK_XWRITE([self writeString:value]);
}

@end
