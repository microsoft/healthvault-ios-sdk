//
//  XSerializable.h
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
#import <CoreFoundation/CoreFoundation.h>
#import "HVCollection.h"
#import "XReader.h"
#import "XWriter.h"


NSString* const XExceptionNotSerializable;

@protocol XSerializable <NSObject>

-(void) deserialize:(XReader *) reader;
-(void) deserializeAttributes:(XReader *) reader;

-(void) serialize:(XWriter *) writer;
-(void) serializeAttributes:(XWriter *) writer;

@end

@interface XSerializer : NSObject

+(NSString *) serializeToString:(id) obj withRoot:(NSString *) root;
+(BOOL) serialize:(id) obj withRoot:(NSString *) root toWriter:(XWriter *) writer;
+(BOOL) serialize:(id)obj withRoot:(NSString *)root toFilePath:(NSString *) filePath;
+(BOOL) secureSerialize:(id)obj withRoot:(NSString *)root toFilePath:(NSString *) filePath;
+(BOOL) secureSerialize:(id)obj withRoot:(NSString *)root toFilePath:(NSString *) filePath withConverter:(XConverter *) converter;

+(BOOL) deserialize:(XReader *) reader withRoot:(NSString *) root into:(id) obj;

@end

@interface NSObject (XSerializer)

-(NSString *) toXmlStringWithRoot:(NSString *) root;

+(id) newFromString:(NSString *)xml withRoot:(NSString *) root asClass:(Class) classObj;
+(id) newFromReader:(XReader *) reader withRoot:(NSString *) root asClass:(Class) classObj;
+(id) newFromFilePath:(NSString*) filePath withRoot:(NSString *) root asClass:(Class) classObj;
+(id) newFromSecureFilePath:(NSString*) filePath withRoot:(NSString *) root asClass:(Class) classObj;
+(id) newFromSecureFilePath:(NSString*) filePath withRoot:(NSString *) root asClass:(Class) classObj withConverter:(XConverter *) converter;

+(id) newFromFileUrl:(NSURL*) url withRoot:(NSString *) root asClass:(Class) classObj;
+(id) newFromResource:(NSString*) name withRoot:(NSString *) root asClass:(Class) classObj;


@end

//
// Deserialization methods for XmlReader
//
@interface XReader (XSerializer)

-(NSString *) readValue;
-(NSString *) readValueEnsure;

-(CFUUIDRef) readGuid;
-(int) readInt;
-(double) readDouble;
-(float) readFloat;
-(BOOL) readBool;

-(NSString *) readNextElement;
-(NSString *) readStringElementRequired:(NSString *) name;
-(NSString *) readStringElement:(NSString *)name;

-(NSDate *) readNextDate;
-(NSDate *) readDateElement:(NSString *) name;

-(int) readNextInt;
-(int) readIntElement:(NSString *) name;
-(BOOL) readIntElement:(NSString *) name into:(int *) value;

-(double) readNextDouble;
-(double) readDoubleElement:(NSString *) name;
-(BOOL) readDoubleElement:(NSString *) name into:(double *) value;

-(BOOL) readNextBool;
-(BOOL) readBoolElement:(NSString*) name;
-(BOOL) readBoolElement:(NSString *) name into:(BOOL *) value;

-(void) readElementContentIntoObject:(id<XSerializable>) content;

-(id) readElementRequired:(NSString *) name asClass:(Class) classObj;
-(void) readElementRequired:(NSString *) name intoObject:(id<XSerializable>) content;

-(id) readElement:(NSString *) name asClass:(Class) classObj;

-(NSString *) readElementRaw:(NSString *) name;

-(NSMutableArray *) readElementArray:(NSString *) name asClass:(Class) classObj;
-(NSMutableArray *) readElementArray:(NSString *) name asClass:(Class) classObj andArrayClass:(Class) arrayClassObj;
-(NSMutableArray *) readElementArray:(NSString *) name itemName:(NSString*) itemName asClass:(Class) classObj andArrayClass:(Class) arrayClassObj;

-(HVStringCollection *) readStringElementArray:(NSString *) name;

-(NSMutableArray *) readRawElementArray:(NSString *) name;

-(NSString *) readAttribute:(NSString *) name;
-(BOOL) readIntAttribute:(NSString *) name intValue:(int *) value;
-(BOOL) readBoolAttribute:(NSString *) name boolValue:(BOOL *) value;
-(BOOL) readDoubleAttribute:(NSString *) name doubleValue:(double *) value;
-(BOOL) readFloatAttribute:(NSString *) name floatValue:(float *) value;

-(BOOL) readUntilNodeType:(enum XNodeType) type;
-(BOOL) skipElement:(NSString *) name;
-(BOOL) skipSingleElement:(NSString *) name;
-(BOOL) skipToElement:(NSString *) name;

-(id) readElementRequiredWithXmlName:(const xmlChar *) xName asClass:(Class) classObj;
-(void) readElementRequiredWithXmlName:(const xmlChar *) xName intoObject:(id<XSerializable>) content;
-(id) readElementWithXmlName:(const xmlChar *) xmlName asClass:(Class) classObj;
-(NSString *) readStringElementWithXmlName:(const xmlChar *)xmlName;

-(NSDate *) readDateElementXmlName:(const xmlChar *) xmlName;
-(double) readDoubleElementXmlName:(const xmlChar *) xmlName;
-(BOOL) readDoubleElementXmlName:(const xmlChar *) xmlName into:(double *) value;
-(int) readIntElementXmlName:(const xmlChar *) xmlName;
-(BOOL) readIntElementXmlName:(const xmlChar *) xmlName into:(int *) value;
-(BOOL) readBoolElementXmlName:(const xmlChar*) xmlName;
-(BOOL) readBoolElementXmlName:(const xmlChar *) xmlName into:(BOOL *) value;

-(NSMutableArray *) readElementArrayWithXmlName:(const xmlChar *) xName asClass:(Class) classObj;
-(NSMutableArray *) readElementArrayWithXmlName:(const xmlChar *) xName asClass:(Class) classObj andArrayClass:(Class) arrayClassObj;
-(NSMutableArray *) readElementArrayWithXmlName:(const xmlChar *) xName itemName:(const xmlChar *) itemName asClass:(Class) classObj andArrayClass:(Class) arrayClassObj;


-(NSString *) readAttributeWithXmlName:(const xmlChar *) xmlName;

@end

//
// Serialization methods for XWriter
// 
@interface XWriter (XSerializer) 

-(void) writeGuid:(CFUUIDRef) guid;
-(void) writeInt:(int) value;
-(void) writeDouble:(double) value;
-(void) writeFloat:(float) value;
-(void) writeBool:(BOOL) value;
-(void) writeDate:(NSDate*) value;

-(void) writeEmptyElement:(NSString *) name;
-(void) writeElementRequired:(NSString *) name content:(id<XSerializable>) content; 
-(void) writeElementArrayRequired:(NSString *)name elements:(NSArray *) array;
-(void) writeElementRequired:(NSString *)name value:(NSString *) value;

-(void) writeElement:(NSString *)name value:(NSString *) value;
-(void) writeElement:(NSString *) name content:(id<XSerializable>) content; 
-(void) writeElement:(NSString *) name intValue:(int) value;
-(void) writeElement:(NSString *) name doubleValue:(double) value;
-(void) writeElement:(NSString *) name dateValue:(NSDate*) value;
-(void) writeElement:(NSString *) name boolValue:(BOOL) value;
//
// If value conforms to XSerializable, calls writeElementRequired:content
// If NSString, writes out raw string as element content
// Else calls value.description and writes that
//
-(void) writeElement:(NSString *) name object:(id) value;

-(void) writeElementArray:(NSString *)name elements:(NSArray *) array;
-(void) writeElementArray:(NSString *)name itemName:(NSString*) itemName elements:(NSArray *)array;
-(void) writeRawElementArray:(NSString *) name elements:(NSArray *) array;

-(void) writeAttribute:(NSString *) name intValue:(int) value;
-(void) writeText:(NSString *) value;

-(void) writeElementXmlName:(const xmlChar *) xmlName content:(id<XSerializable>) content;
-(void) writeElementXmlName:(const xmlChar *)xmlName value:(NSString *) value;
-(void) writeElementXmlName:(const xmlChar *) xmlName intValue:(int) value;
-(void) writeElementXmlName:(const xmlChar *) xmlName doubleValue:(double) value;
-(void) writeElementXmlName:(const xmlChar *) xmlName dateValue:(NSDate*) value;
-(void) writeElementXmlName:(const xmlChar *) xmlName boolValue:(BOOL) value;

@end

void throwWriterError(void);

#define HVCHECK_XWRITE(condition) \
    if (!(condition)) \
    { \
        throwWriterError(); \
    }

//---------------------------------------
//
// Xml Deserialization Macros
//
//---------------------------------------

#define HVDESERIALIZE(var, name, className) HVSETIF(var, [reader readElement:name asClass:[className class]])

#define HVDESERIALIZE_STRING(var, name) HVSETIF(var, [reader readStringElement:name])

#define HVDESERIALIZE_DATE(var, name) HVSETIF(var, [reader readDateElement:name])

#define HVDESERIALIZE_INT(var, name) [reader readIntElement:name into:&var]

#define HVDESERIALIZE_DOUBLE(var, name) [reader readDoubleElement:name into:&var]

#define HVDESERIALIZE_BOOL(var, name) [reader readBoolElement:name into:&var]

#define HVDESERIALIZE_ARRAY(var, name, className) HVSETIF(var, [reader readElementArray:name asClass:[className class]])

#define HVDESERIALIZE_TYPEDARRAY(var, name, className, arrayClass) HVSETIF(var, [reader readElementArray:name asClass:[className class] andArrayClass:[arrayClass class]])

#define HVDESERIALIZE_TYPEDARRAYNESTED(var, name, item, className, arrayClass) HVSETIF(var, [reader readElementArray:name itemName:item asClass:[className class] andArrayClass:[arrayClass class]])

#define HVDESERIALIZE_STRINGCOLLECTION(var, name) HVSETIF(var, [reader readStringElementArray:name])

#define HVDESERIALIZE_TEXT(var) HVSETIF(var, [reader readValue])

#define HVDESERIALIZE_ENUM(var, name, converter) {NSString* var_sz = [reader readStringElement:name]; if (var_sz) { var = converter(var_sz);}}

#define HVDESERIALIZE_URL(var, name) {NSString* var_sz = [reader readStringElement:name]; if (var_sz) {var = [[NSURL alloc]initWithString:var_sz];} }

#define HVDESERIALIZE_IGNORE(name) [reader skipElement:name]

#define HVDESERIALIZE_RAW(var, name) HVSETIF(var, [reader readElementRaw:name])
#define HVDESERIALIZE_RAWARRAY(var, name) HVSETIF(var, [reader readRawElementArray:name])

#define HVDESERIALIZE_ATTRIBUTE(var, name) HVSETIF(var, [reader readAttribute:name])
#define HVDESERIALIZE_INTATTRIBUTE(var, name) [reader readIntAttribute:name intValue:&var]
#define HVDESERIALIZE_BOOLATTRIBUTE(var, name) [reader readBoolAttribute:name boolValue:&var]
#define HVDESERIALIZE_DOUBLEATTRIBUTE(var, name) [reader readDoubleAttribute:name doubleValue:&var]
#define HVDESERIALIZE_FLOATATTRIBUTE(var, name) [reader readFloatAttribute:name floatValue:&var]

#define HVDESERIALIZE_X(var, xname, className) HVSETIF(var, [reader readElementWithXmlName:xname asClass:[className class]])
#define HVDESERIALIZE_STRING_X(var, xname) HVSETIF(var, [reader readStringElementWithXmlName:xname])
#define HVDESERIALIZE_DATE_X(var, name) HVSETIF(var, [reader readDateElementXmlName:name])
#define HVDESERIALIZE_INT_X(var, name) [reader readIntElementXmlName:name into:&var]
#define HVDESERIALIZE_DOUBLE_X(var, name) [reader readDoubleElementXmlName:name into:&var]
#define HVDESERIALIZE_BOOL_X(var, name) [reader readBoolElementXmlName:name into:&var]
#define HVDESERIALIZE_ATTRIBUTE_X(var, xname) HVSETIF(var, [reader readAttributeWithXmlName:xname])

#define HVDESERIALIZE_TYPEDARRAY_X(var, name, className, arrayClass) HVSETIF(var, [reader readElementArrayWithXmlName:name asClass:[className class] andArrayClass:[arrayClass class]])

//---------------------------------------
//
// Xml Serialization Macros
//
//---------------------------------------

#define HVSERIALIZE(var, name) [writer writeElement:name content:var]

#define HVSERIALIZE_STRING(var, name) [writer writeElement:name value:var]

#define HVSERIALIZE_INT(var, name) [writer writeElement:name intValue:var]

#define HVSERIALIZE_DOUBLE(var, name) [writer writeElement:name doubleValue:var]

#define HVSERIALIZE_DATE(var, name) [writer writeElement:name dateValue:var]

#define HVSERIALIZE_BOOL(var, name) [writer writeElement:name boolValue:var]

#define HVSERIALIZE_ARRAY(var, name) [writer writeElementArray:name elements:var]

#define HVSERIALIZE_ARRAYNESTED(var, name, item) [writer writeElementArray:name itemName:item elements:var]

#define HVSERIALIZE_STRINGCOLLECTION(var, name) HVSERIALIZE_ARRAY(var, name)

#define HVSERIALIZE_ENUM(var, name, converter) {NSString* var_sz = converter(var); if (var_sz) {HVSERIALIZE_STRING(var_sz, name);}}

#define HVSERIALIZE_URL(var, name) if (var) { HVSERIALIZE_STRING(var.absoluteString, name);}

#define HVSERIALIZE_ATTRIBUTE(var, name) if (var) { [writer writeAttribute:name value:var];}

#define HVSERIALIZE_TEXT(var) [writer writeText:var]

#define HVSERIALIZE_RAW(var) if (var) {[writer writeRaw:var];}
#define HVSERIALIZE_RAWARRAY(var, name) if (var) {[writer writeRawElementArray:name elements:var];}

#define HVSERIALIZE_X(var, xmlName) [writer writeElementXmlName:xmlName content:var]
#define HVSERIALIZE_STRING_X(var, name) [writer writeElementXmlName:name value:var]
#define HVSERIALIZE_INT_X(var, name) [writer writeElementXmlName:name intValue:var]
#define HVSERIALIZE_DOUBLE_X(var, name) [writer writeElementXmlName:name doubleValue:var]
#define HVSERIALIZE_DATE_X(var, name) [writer writeElementXmlName:name dateValue:var]
#define HVSERIALIZE_BOOL_X(var, name) [writer writeElementXmlName:name boolValue:var]
#define HVSERIALIZE_ATTRIBUTE_X(var, xmlName) if (var) { [writer writeAttributeXmlName:xmlName value:var];}

