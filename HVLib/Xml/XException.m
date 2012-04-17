//
//  XException.m
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

#import "XException.h"

NSString* const XExceptionInvalidNodeType = @"X_InvalidNodeType";
NSString* const XExceptionNotElement = @"X_NotElement";
NSString* const XExceptionElementMismatch = @"X_ElementMismatch";
NSString* const XExceptionTypeConversion = @"X_TypeConversion";
NSString* const XExceptionNotText = @"X_NotText";
NSString* const XExceptionReaderError = @"X_ReaderError";
NSString* const XExceptionWriterError = @"X_WriterError";
NSString* const XExceptionRequiredDataMissing = @"X_RequiredDataMissing";

@implementation XException

+(void) throwException:(NSString*) exceptionName reason:(NSString *) reason
{
    @throw [[[XException alloc] initWithName:exceptionName reason:reason userInfo:nil] autorelease];  
}

+(void) throwException:(NSString *)exceptionName lineNumber:(int)line columnNumber:(int)col
{
    NSString *reason = [NSString stringWithFormat:@"line=%d, col=%d", line, col];
    @throw [[[XException alloc] initWithName:exceptionName reason:reason userInfo:nil] autorelease];
}

+(void) throwException:(NSString *)exceptionName reason:(NSString *) reason fromReader:(xmlTextReader *)reader
{
    int line = 0;
    int col = 0;
    if (reader)
    {
        line = xmlTextReaderGetParserLineNumber(reader);
        col = xmlTextReaderGetParserColumnNumber(reader);
    }
    
    NSString *message;
    if (reason == nil)
    {
        message = [NSString stringWithFormat:@"line=%d, col=%d", line, col];
    }
    else
    {
        message = [NSString stringWithFormat:@"%@ line=%d, col=%d", reason, line, col];       
    }
    @throw [[[XException alloc] initWithName:exceptionName reason:message userInfo:nil] autorelease];
}

+(void) throwException:(NSString *)exceptionName fromReader:(xmlTextReader *)reader
{
    [XException throwException:exceptionName reason:nil fromReader:reader];
}

@end
