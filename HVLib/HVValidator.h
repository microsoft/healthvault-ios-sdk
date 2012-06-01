//
//  HVValidator.h
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
#import "HVExceptionExtensions.h"
#import "HVClientResult.h"


#define HVLOG(message)

#ifdef DEBUG

#define HVASSERT_MESSAGE(message) NSLog(@"%@ file:%@ line:%d", message, [NSString stringWithUTF8String:__FILE__], __LINE__);

#define HVASSERT(condition) if (!(condition)) { HVASSERT_MESSAGE(@#condition)}
#define HVASSERT_C(condition) assert(condition);
                
#else

#define HVASSERT(condition) 
#define HVASSERT_MESSAGE(message) 
#define HVASSERT_C(condition)

#endif

#define HVASSERT_NOTNULL(obj) HVASSERT(obj != nil)
#define HVASSERT_STRING(string) HVASSERT(!([NSString isNilOrEmpty:string]))

#define HVCHECK_TRUE(condition) HVASSERT(condition); \
                                if (!(condition)) \
                                { \
                                    goto LError; \
                                }
#define HVCHECK_FALSE(condition) HVCHECK_TRUE(!(condition))

#define HVCHECK_NOTNULL(obj) HVCHECK_TRUE(obj != nil)
#define HVCHECK_SELF HVCHECK_TRUE(self != nil) 
#define HVCHECK_STRING(string) HVCHECK_FALSE([NSString isNilOrEmpty:string])

#define HVCHECK_OOM(obj) if (obj == nil) \
                         { \
                            [NSException throwOutOfMemory]; \
                         }

#define HVCHECK_SUCCESS(methodCall) if (!methodCall) { \
                                HVASSERT_MESSAGE(@#methodCall); \
                                goto LError; \
                            }

#define HVCHECK_PTR(ptr) HVASSERT_C(ptr); \
                         if (!ptr) \
                         {         \
                            goto LError; \
                         }

//-----------------------
//
// Type validation
//
//-----------------------
#define HVVALIDATE_BEGIN        HVClientResult *hr = HVERROR_UNKNOWN; 
#define HVVALIDATE_FAIL         return hr;
#define HVVALIDATE_SUCCESS      return HVRESULT_SUCCESS;

#define HVCHECK_RESULT(method)  hr = method; \
                                if (hr.isError) \
                                { \
                                    goto LError; \
                                }

#define HVVALIDATE(obj, error)      if (!obj) \
                                    { \
                                        hr = HVMAKE_ERROR(error); \
                                        goto LError; \
                                    } \
                                    HVCHECK_RESULT([obj validate])

#define HVVALIDATE_OPTIONAL(obj)    if (obj) \
                                    { \
                                        HVCHECK_RESULT([obj validate]);\
                                    }

#define HVVALIDATE_STRING(string, error)   if ([NSString isNilOrEmpty:string]) \
                                            { \
                                                hr = HVMAKE_ERROR(error); \
                                                goto LError; \
                                            }


#define HVVALIDATE_PTR(ptr, error)     if (!ptr) \
                                        { \
                                            hr = HVMAKE_ERROR(error); \
                                            goto LError; \
                                        } \

#define HVVALIDATE_STRINGOPTIONAL(string, error)

#define HVVALIDATE_ARRAY(var, error) HVCHECK_RESULT(HVValidateArray(var, error));
#define HVVALIDATE_ARRAYOPTIONAL(var, error) if (var) { HVVALIDATE_ARRAY(var, error);}

#define HVVALIDATE_TRUE(condition, error)   if (!condition) \
                                            { \
                                                hr = HVMAKE_ERROR(error); \
                                                goto LError; \
                                            } \

HVClientResult* HVValidateArray(NSArray* array, enum HVClientResultCode error);

