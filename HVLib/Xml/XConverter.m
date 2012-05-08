//
//  XConvert.m
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
#import "XConverter.h"

const int c_xDateFormatCount = 6;
static NSString* s_xDateFormats[c_xDateFormatCount] = 
{
    @"yyyy'-'MM'-'dd'T'HHmmss.SSS'Z'",      // Zulu form
    @"yyyy'-'MM'-'dd'T'HHmmss'Z'",          // Zulu form
    @"yyyy'-'MM'-'dd'T'HHmmss.SSSZZZZ",     // Time zone form
    @"yyyy'-'MM'-'dd'T'HHmmssZZZZ",          // Time zone form,
    @"yyyy'-'MM'-'dd",
    @"yy'-'MM'-'dd"
};

static NSString* const c_POSITIVEINF = @"INF";
static NSString* const c_NEGATIVEINF = @"-INF";
static NSString* const c_TRUE = @"true";
static NSString* const c_FALSE = @"false";

@implementation XConverter

-(id) init
{
    self = [super init];
    HVCHECK_SELF;

    m_parser = [NSDateFormatter newUtcFormatter];
    HVCHECK_NOTNULL(m_parser);
    
    m_formatter = [NSDateFormatter newZuluFormatter]; // always emit Zulu form
    HVCHECK_NOTNULL(m_formatter);
    
    m_stringBuffer = [[NSMutableString alloc] init];
    HVCHECK_NOTNULL(m_stringBuffer);
    
    return self;

LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_parser release];
    [m_formatter release];
    [m_stringBuffer release];
    [super dealloc];
}

-(BOOL) tryString:(NSString *)source toInt:(int *)result
{
    HVCHECK_STRING(source);
    HVCHECK_NOTNULL(result);
        
    HVCHECK_SUCCESS([m_stringBuffer setStringAndVerify:source]);
    [m_stringBuffer trim];
    
    return [m_stringBuffer parseInt: result];
    
LError:
    return FALSE;
}

-(int) stringToInt:(NSString *)source
{
    int value = 0;
    if (![self tryString:source toInt:&value])
    {
       [XException throwException:XExceptionTypeConversion reason:@"stringToInt"];       
    }
  
    return value;
}

-(BOOL) tryInt:(int)source toString:(NSString **)result
{
    HVCHECK_NOTNULL(result);
    
    *result = [NSString stringWithFormat:@"%d", source];
    HVCHECK_STRING(*result);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(NSString *) intToString:(int)source
{
    NSString *result;
    if (![self tryInt:source toString:&result])
    {
        [XException throwException:XExceptionTypeConversion reason:@"intToString"];
    }
    
    return result;
}

-(BOOL) tryString:(NSString *) source toFloat:(float *) result
{
    HVCHECK_STRING(source);
    HVCHECK_NOTNULL(result);
    
    HVCHECK_SUCCESS([m_stringBuffer setStringAndVerify:source]);
    [m_stringBuffer trim];
    
    if ([m_stringBuffer isEqualToString:c_NEGATIVEINF])
    {
        *result = -INFINITY;
        return TRUE;
    }
    if ([m_stringBuffer isEqualToString:c_POSITIVEINF])
    {
        *result = INFINITY;
        return TRUE;
    }
    
    return [m_stringBuffer parseFloat: result];
    
LError:
    return FALSE;
}

-(float) stringToFloat:(NSString *) source
{
    float value = 0;
    if (![self tryString:source toFloat:&value])
    {
        [XException throwException:XExceptionTypeConversion reason:@"stringToFloat"];
    }
    
    return value;
    
}

-(BOOL) tryFloat:(float) source toString:(NSString **) result
{
    HVCHECK_NOTNULL(result);
    
    if (source == -INFINITY)
    {
        *result = c_NEGATIVEINF;
        return TRUE;
    }
    if (source == INFINITY)
    {
        *result = c_POSITIVEINF;
        return TRUE;
    }
    
    *result = [NSString stringWithFormat:@"%g", source];
    HVCHECK_STRING(*result);
    
    return TRUE;
    
LError:
    return FALSE;
    
}

-(NSString *) floatToString:(float) source
{
    NSString *string = nil;
    if (![self tryFloat:source toString:&string])
    {
        [XException throwException:XExceptionTypeConversion reason:@"floatToString"];
    }
    
    return string;
    
}

-(BOOL) tryString:(NSString *)source toDouble:(double *)result
{
    HVCHECK_STRING(source);
    HVCHECK_NOTNULL(result);
    
    HVCHECK_SUCCESS([m_stringBuffer setStringAndVerify:source]);
    [m_stringBuffer trim];
    
    if ([m_stringBuffer isEqualToString:c_NEGATIVEINF])
    {
        *result = -INFINITY;
        return TRUE;
    }
    if ([m_stringBuffer isEqualToString:c_POSITIVEINF])
    {
        *result = INFINITY;
        return TRUE;
    }
    
    return [m_stringBuffer parseDouble: result];
   
LError:
    return FALSE;
}

-(double) stringToDouble:(NSString *)source
{
    double value = 0;
    if (![self tryString:source toDouble:&value])
    {
        [XException throwException:XExceptionTypeConversion reason:@"stringToDouble"];
    }
    
    return value;
}

-(BOOL) tryDouble:(double)source toString:(NSString **)result
{
    HVCHECK_NOTNULL(result);
    
    if (source == -INFINITY)
    {
        *result = c_NEGATIVEINF;
        return TRUE;
    }
    if (source == INFINITY)
    {
        *result = c_POSITIVEINF;
        return TRUE;
    }
    
    *result = [NSString stringWithFormat:@"%g", source];
    HVCHECK_STRING(*result);
    
    return TRUE;
   
LError:
    return FALSE;
}

-(NSString *) doubleToString:(double)source
{
    NSString *string = nil;
    if (![self tryDouble:source toString:&string])
    {
        [XException throwException:XExceptionTypeConversion reason:@"doubleToString"];
    }
    
    return string;
}

-(BOOL) tryString:(NSString *) source toBool:(BOOL *) result
{
    HVCHECK_STRING(source);
    HVCHECK_NOTNULL(result);
    
    HVCHECK_SUCCESS([m_stringBuffer setStringAndVerify:source]);
    
    if ([m_stringBuffer isEqualToString:c_TRUE])
    {
        *result = TRUE;
    }
    else if ([m_stringBuffer isEqualToString:c_FALSE])
    {
        *result =  FALSE;
    }
    else if ([m_stringBuffer isEqualToString:@"1"])
    {
        *result =  TRUE;
    }
    else if ([m_stringBuffer isEqualToString:@"0"])
    {
        *result =  FALSE;
    }
    else
    {
        goto LError;
    }
    
    return TRUE;
    
LError:
    return FALSE;    
}

-(BOOL) stringToBool:(NSString *)source
{
    BOOL value = FALSE;
    if (![self tryString:source toBool:&value])
    {
        [XException throwException:XExceptionTypeConversion reason:@"stringToBool"];
    }
    
    return value;
}

-(NSString *) boolToString:(BOOL)source
{
    return source ? c_TRUE : c_FALSE;
}

-(BOOL) tryString:(NSString *)source toDate:(NSDate **)result
{
    HVCHECK_STRING(source);
    HVCHECK_NOTNULL(result);
    
    //
    // Since NSDateFormatter is otherwise incapable of parsing xsd:datetime
    // ISO 8601 expresses UTC/GMT offsets as "2001-10-26T21:32:52+02:00"
    // DateFormatter does not like the : in the +02:00
    // So, we simply whack all : in the string, and change our dateformat strings accordingly
    // 
    // Use a mutable string, so we don't have to keep allocating new strings
    //
    
    HVCHECK_SUCCESS([m_stringBuffer setStringAndVerify:source]);
    [m_stringBuffer replaceOccurrencesOfString:@":" withString:@""];
    
    for (int i = 0; i < c_xDateFormatCount; ++i)
    {
        NSString *format = s_xDateFormats[i];
        [m_parser setDateFormat:format];
        *result = [m_parser dateFromString:m_stringBuffer];
        if (*result)
        {
            return TRUE;
        }
    }

LError:
    return FALSE;
}

-(NSDate *) stringToDate:(NSString *)source
{
    NSDate* date = nil;
    if (![self tryString:source toDate:&date])
    {
       [XException throwException:XExceptionTypeConversion reason:@"stringToDate"]; 
    }
    
    return date;
}

-(BOOL) tryDate:(NSDate *) source toString:(NSString **)result
{
    HVCHECK_NOTNULL(source);
    HVCHECK_NOTNULL(result);
    
    *result = [m_formatter stringFromDate:source];
    HVCHECK_STRING(*result);
    
    return TRUE;

LError:
    return FALSE;
}

-(NSString *) dateToString:(NSDate *)source
{
    NSString *string = nil;
    if (![self tryDate:source toString:&string])
    {
        [XException throwException:XExceptionTypeConversion reason:@"dateToString"]; 
    }
    
    return string;
}

-(BOOL) tryString:(NSString *)source toGuid:(CFUUIDRef *)result
{
    HVCHECK_STRING(source);
    HVCHECK_NOTNULL(result);
    
    *result = CFUUIDCreateFromString(nil, (CFStringRef) source);
    HVCHECK_NOTNULL(*result);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(CFUUIDRef) stringToGuid:(NSString *)source
{
    CFUUIDRef guid;
    if (![self tryString:source toGuid:&guid])
    {
        [XException throwException:XExceptionTypeConversion reason:@"stringToGuid"]; 
    }
    
    return guid;
}

-(BOOL) tryGuid:(CFUUIDRef)guid toString:(NSString **)result
{
    HVCHECK_NOTNULL(guid);
    HVCHECK_NOTNULL(result);
    
    *result = [((NSString *) CFUUIDCreateString(nil, guid)) autorelease];
    HVCHECK_STRING(*result);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(NSString *) guidToString:(CFUUIDRef)guid
{
    NSString *string;
    if (![self tryGuid:guid toString:&string])
    {
        [XException throwException:XExceptionTypeConversion reason:@"guidToString"]; 
    }
    return string;
}

@end
