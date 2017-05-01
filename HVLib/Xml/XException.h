//
//  XException.h
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
#import <libxml/xmlreader.h>

NSString* const XExceptionInvalidNodeType;
NSString* const XExceptionNotElement;
NSString* const XExceptionElementMismatch;
NSString* const XExceptionTypeConversion;
NSString* const XExceptionNotText;
NSString* const XExceptionReaderError;
NSString* const XExceptionWriterError;
NSString* const XExceptionRequiredDataMissing;

@interface XException : NSException

+(void) throwException:(NSString*) exceptionName reason:(NSString *) reason;
+(void) throwException:(NSString*) exceptionName reason:(NSString *) reason fromReader:(xmlTextReader *) reader;
+(void) throwException:(NSString*) exceptionName xmlReason:(const xmlChar *) reason fromReader:(xmlTextReader *) reader;
+(void) throwException:(NSString*) exceptionName fromReader:(xmlTextReader *) reader;
+(void) throwException:(NSString*) exceptionName lineNumber:(int) line columnNumber:(int) col;

@end
