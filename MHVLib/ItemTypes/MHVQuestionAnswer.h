//
//  MHVQuestionAnswer.h
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

#import <Foundation/Foundation.h>
#import "MHVTypes.h"

@interface MHVQuestionAnswer : MHVItemDataTyped
{
@private
    MHVDateTime* m_when;
    MHVCodableValue* m_question;
    MHVCodableValueCollection* m_answerChoices;
    MHVCodableValueCollection* m_answers;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required)
//
@property (readwrite, nonatomic, strong) MHVDateTime* when;
//
// (Required)
//
@property (readwrite, nonatomic, strong) MHVCodableValue* question;
//
// (Optional)
// Was this a multiple choice question. If so, useful to capture the original choices
//
@property (readwrite, nonatomic, strong) MHVCodableValueCollection* answerChoices;
//
// (Optional)
// One or more answers
//
@property (readwrite, nonatomic, strong) MHVCodableValueCollection* answers;
//
// Convenience Properties
//
@property (readonly, nonatomic, strong) MHVCodableValue* firstAnswer;
@property (readonly, nonatomic) BOOL hasAnswerChoices;
@property (readonly, nonatomic) BOOL hasAnswers;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithQuestion:(NSString *) question andDate:(NSDate *) date;
-(id) initWithQuestion:(NSString *) question answer:(NSString *) answer andDate:(NSDate *) date;

+(MHVItem *) newItem;

//-------------------------
//
// Text
//
//-------------------------
-(NSString *) toString;

//-------------------------
//
// Type Info
//
//-------------------------
+(NSString *) typeID;
+(NSString *) XRootElement;

@end