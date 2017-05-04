//
//  NSString+StringExtensions.m
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

#import "MHVStringExtensions.h"
#import "MHVCommon.h"

NSString* const c_emptyString = @"";

@implementation NSString (NVNSStringExtensions)

+(BOOL) isNilOrEmpty:(NSString *) string
{
    return (string == nil || string.length == 0);
}

-(BOOL) isEmpty
{
    return (self.length == 0);
}

-(NSRange) getRange
{
    return NSMakeRange(0, self.length);
}

-(BOOL) isIndexInRange:(NSUInteger)index
{
    return (index < self.length);
}

-(NSUInteger) indexOfFirstChar:(unichar)ch
{
    for(NSUInteger i = 0, count = self.length; i < count; ++i)
    {
        if (ch == [self characterAtIndex:i])
        {
            return i;
        }
    }
    
    return NSNotFound;
}

-(NSUInteger) indexOfFirstCharInSet:(NSCharacterSet *)charSet
{
    MHVASSERT_NOTNULL(charSet);
    
    for(NSUInteger i = 0, count = self.length; i < count; ++i)
    {
        if ([charSet characterIsMember:[self characterAtIndex:i]])
        {
            return i;
        }
    }
    
    return NSNotFound;
}
 
-(NSUInteger) indexOfFirstCharNotInSet:(NSCharacterSet *)charSet
{
    MHVASSERT_NOTNULL(charSet);
    
    for(NSUInteger i = 0, count = self.length; i < count; ++i)
    {
        if (![charSet characterIsMember:[self characterAtIndex:i]])
        {
            return i;
        }
    }
    
    return NSNotFound;
}

-(NSUInteger) indexOfLastChar:(unichar)ch
{
    NSUInteger i = self.length;
    while (i > 0) 
    {
        --i;
        if (ch == [self characterAtIndex:i])
        {
            return i;
        }
    }
    
    return NSNotFound;
}

-(NSUInteger) indexOfLastCharInSet:(NSCharacterSet *)charSet
{
    NSUInteger i = self.length;
    while (i > 0) 
    {
        --i;
        if ([charSet characterIsMember:[self characterAtIndex:i]])
        {
            return i;
        }
    }
    
    return NSNotFound;
}

-(NSUInteger) indexOfLastCharNotInSet:(NSCharacterSet *)charSet
{
    NSUInteger i = self.length;
    while (i > 0) 
    {
        --i;
        if (![charSet characterIsMember:[self characterAtIndex:i]])
        {
            return i;
        }
    }
    
    return NSNotFound;
}

-(BOOL)contains:(NSString *)other
{
    NSRange range = [self rangeOfString:other];
    return (range.location != NSNotFound);
}

-(BOOL)isEqualToStringCaseInsensitive:(NSString *)aString
{
    return ([self caseInsensitiveCompare:aString] == NSOrderedSame);
}

-(NSString *) trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSScanner *) newScanner
{
    return [[NSScanner alloc] initWithString:self];
}

-(BOOL) parseFloat:(float *)pValue
{
    MHVCHECK_NOTNULL(pValue);
    
    NSScanner *scanner = [self newScanner];
    MHVCHECK_NOTNULL(scanner);
    
    BOOL result = [scanner scanFloat:pValue];
    
    return result;
    
LError:
    return FALSE;    
}

-(BOOL) parseDouble:(double *)pValue
{
    MHVCHECK_NOTNULL(pValue);
    
    NSScanner *scanner = [self newScanner];
    MHVCHECK_NOTNULL(scanner);
 
    BOOL result = [scanner scanDouble:pValue];
    
    return result;

LError:
    return FALSE;
}

-(BOOL) parseInt:(int *)pValue
{
    MHVCHECK_NOTNULL(pValue);
    
    NSScanner *scanner = [self newScanner];
    MHVCHECK_NOTNULL(scanner);
   
    BOOL result = [scanner scanInt:pValue];
    return result;   

LError:
    return FALSE;
}

-(NSString *)stringByAppendingName:(NSString *)name andExtension:(NSString *)ext    
{
    return [[self stringByAppendingPathComponent:name] stringByAppendingPathExtension:ext];
}

-(NSString *)urlEncode
{
    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(NSString *)toString
{
    return self;
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    return [NSString stringWithFormat:format, self];
}

@end

@implementation NSMutableString (MHVNSMutableStringExtensions)

-(void) clear
{
    [self setString:c_emptyString];
}

-(BOOL) setStringAndVerify:(NSString *)aString
{
    [self setString:aString];
    return(self.length == aString.length);
}

-(void) appendNewLine
{
    [self appendString:@"\r\n"];
}

-(void) appendNewLines:(int)count
{
    for (int i = 0; i < count; ++i)
    {
        [self appendNewLine];
    }
}

-(void) appendLines:(int)count, ...
{
    va_list args;
    va_start(args, count);
    
    for (int i = 0; i < count; ++i)
    {
        NSString *string = va_arg(args, NSString *);
        if (![NSString isNilOrEmpty:string])
        {    
            [self appendString:string];
            [self appendNewLine];
        }
    }
    
    va_end(args);
}

-(void) appendStrings:(NSArray *)strings
{
    if ([NSArray isNilOrEmpty:strings])
    {
        return;
    }
    
    for (NSString* string in strings) {
        [self appendString:string];
    }
}

-(void) appendStringAsLine:(NSString *)string
{
    if (!string)
    {
        return;
    }
    
    [self appendString:string];
    [self appendNewLine];
}

-(void) appendStringsAsLines:(NSArray *)strings
{
    if ([NSArray isNilOrEmpty:strings])
    {
        return;
    }
    
    for (NSString* string in strings) {
        if (![NSString isNilOrEmpty:string])
        {
            [self appendString:string];
            [self appendNewLine];
        }
    }
}

-(void)appendOptionalString:(NSString *)string
{
    if (![NSString isNilOrEmpty:string])
    {
        [self appendString:string];
    }
}

-(void)appendOptionalString:(NSString *)string withSeparator:(NSString *)separator
{
    if (![NSString isNilOrEmpty:string])
    {
        if (self.length > 0)
        {
            [self appendString:separator];
        }
        [self appendString:string];
    }
}

-(void)appendOptionalStringAsLine:(NSString *)string
{
    if (![NSString isNilOrEmpty:string])
    {
        [self appendStringAsLine:string];
    }    
}

-(void)appendOptionalStringOnNewLine:(NSString *)string
{
    if (![NSString isNilOrEmpty:string])
    {
        if (self.length > 0)
        {
            [self appendNewLine];
        }
        [self appendString:string];
    }        
}

-(void)appendOptionalWords:(NSString *)string
{
    if (self.length > 0)
    {
        [self appendString:@" "];
    }
    [self appendOptionalString:string];
}

-(NSString *) trim
{
    [self trimLeft];
    [self trimRight];
    return self;
}

-(void) trimLeft
{
    NSUInteger position = [self indexOfFirstCharNotInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (position != NSNotFound && position > 0)
    {
        [self deleteCharactersInRange:NSMakeRange(0, position)];
    }
}

-(void) trimRight
{
    NSUInteger lastPosition = [self indexOfLastCharNotInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (lastPosition == NSNotFound)
    {
        return;
    }
    
    NSUInteger index = lastPosition + 1;
    NSRange range = NSMakeRange(index, self.length - index);
    if (range.length > 0)
    {
        [self deleteCharactersInRange:range];
    }
}

-(NSUInteger) replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement
{
    //NSRange range = NSMakeRange(0, self.length);
    NSRange range = [self getRange];
    return [self replaceOccurrencesOfString:@":" withString:c_emptyString options:0 range:range];
}

-(void)appendXmlElementStart:(NSString *)tag
{
    [self appendString:@"<"];
    [self appendString:tag];
    [self appendString:@">"];
}

-(void)appendXmlElementEnd:(NSString *)tag
{
    [self appendString:@"</"];
    [self appendString:tag];
    [self appendString:@">"];
}

-(void)appendXmlElement:(NSString *)tag text:(NSString *)text
{
    [self appendXmlElementStart:tag];
    [self appendString:text];
    [self appendXmlElementEnd:tag];
}

@end

CFStringRef CreateHVUrlEncode(CFStringRef source)
{
    return CFURLCreateStringByAddingPercentEscapes(NULL, source,
                                                   NULL,
                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                   kCFStringEncodingUTF8);
}
