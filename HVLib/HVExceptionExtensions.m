//
//  HVExceptionExtensions.m
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

#import "HVExceptionExtensions.h"
#import "HVCommon.h"

@implementation NSException (HVExceptionExtensions)

+(void) throwException:(NSString *)exceptionName
{
    @throw [NSException exceptionWithName:exceptionName reason:@"" userInfo:nil];
}

+(void) throwException:(NSString *)exceptionName reason:(NSString *)reason
{
    @throw [NSException exceptionWithName:exceptionName reason:reason userInfo:nil];
}

+(void) throwInvalidArg
{
    [NSException throwException:NSInvalidArgumentException];
}

+(void) throwInvalidArgWithReason:(NSString *)reason
{
    [NSException throwException:NSInvalidArgumentException reason:reason];    
}

+(void) throwOutOfMemory
{
    [NSException throwException:NSMallocException];
}

+(void) throwNotImpl
{
    [NSException throwException:@"NotImplementedException"];
}

-(void) printSymbolsTo:(NSMutableString *)buffer
{
    HVASSERT_NOTNULL(buffer);
    
    if (buffer)
    {
        NSArray* symbols = [self callStackSymbols];
        [buffer appendStringsAsLines:symbols];
    }    
}

-(NSString *) detailedDescription
{
    NSMutableString *buffer = [[[NSMutableString alloc] init]autorelease];
    if (buffer)
    {
        [buffer appendLines:1, [self description]];
        [buffer appendNewLine];
        [buffer appendLines:2, [self name], [self reason]];
#ifdef DEBUG
        [buffer appendNewLines:2];
        [self printSymbolsTo:buffer];
        [buffer appendNewLine];
#endif
    }
    
    return buffer;
}

@end
