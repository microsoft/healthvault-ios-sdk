//
//  MHVQuestionAnswer.m
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
#import "MHVQuestionAnswer.h"

static NSString* const c_typeid = @"55d33791-58de-4cae-8c78-819e12ba5059";
static NSString* const c_typename = @"question-answer";

static NSString* const c_element_when = @"when";
static NSString* const c_element_question = @"question";
static NSString* const c_element_choice = @"answer-choice";
static NSString* const c_element_answer = @"answer";

@implementation MHVQuestionAnswer

@synthesize when = m_when;
@synthesize question = m_question;

-(MHVCodableValueCollection *)answerChoices
{
    MHVENSURE(m_answerChoices, MHVCodableValueCollection);
    return m_answerChoices;
}

-(void)setAnswerChoices:(MHVCodableValueCollection *)answerChoices
{
    m_answerChoices = answerChoices;
}

-(MHVCodableValueCollection *)answers
{
    MHVENSURE(m_answers, MHVCodableValueCollection);
    return m_answers;
}

-(void)setAnswers:(MHVCodableValueCollection *)answers
{
    m_answers = answers;
}

-(MHVCodableValue *)firstAnswer
{
    return (self.hasAnswers) ? [m_answers itemAtIndex:0] : nil;
}

-(BOOL)hasAnswerChoices
{
    return ![MHVCollection isNilOrEmpty:m_answerChoices];
}

-(BOOL)hasAnswers
{
    return ![MHVCollection isNilOrEmpty:m_answers];
}


-(id)initWithQuestion:(NSString *)question andDate:(NSDate *)date
{
    return [self initWithQuestion:question answer:nil andDate:date];
}

-(id)initWithQuestion:(NSString *)question answer:(NSString *)answer andDate:(NSDate *)date
{
    MHVCHECK_NOTNULL(question);
    MHVCHECK_NOTNULL(date);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_when = [[MHVDateTime alloc] initWithDate:date];
    MHVCHECK_NOTNULL(m_when);
    
    m_question = [[MHVCodableValue alloc] initWithText:question];
    MHVCHECK_NOTNULL(m_question);
    
    if (answer)
    {
        MHVCodableValue* answerValue = [[MHVCodableValue alloc] initWithText:answer];
        MHVCHECK_NOTNULL(answerValue);
        
        [self.answers addObject:answerValue];
        MHVCHECK_NOTNULL(m_answers);
    }
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return [NSString stringWithFormat:@"%@ %@", 
            m_question ? [m_question toString] : c_emptyString,
            self.firstAnswer ? [self.firstAnswer toString] : c_emptyString
            ];
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE(m_when, MHVClientError_InvalidQuestionAnswer);
    MHVVALIDATE(m_question, MHVClientError_InvalidQuestionAnswer);
    MHVVALIDATE_ARRAYOPTIONAL(m_answerChoices, MHVClientError_InvalidQuestionAnswer);
    MHVVALIDATE_ARRAYOPTIONAL(m_answers, MHVClientError_InvalidQuestionAnswer);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_when content:m_when];
    [writer writeElement:c_element_question content:m_question];
    [writer writeElementArray:c_element_choice elements:m_answerChoices.toArray];
    [writer writeElementArray:c_element_answer elements:m_answers.toArray];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [reader readElement:c_element_when asClass:[MHVDateTime class]];
    m_question = [reader readElement:c_element_question asClass:[MHVCodableValue class]];
    m_answerChoices = (MHVCodableValueCollection *)[reader readElementArray:c_element_choice asClass:[MHVCodableValue class] andArrayClass:[MHVCodableValueCollection class]];
    m_answers = (MHVCodableValueCollection *)[reader readElementArray:c_element_answer asClass:[MHVCodableValue class] andArrayClass:[MHVCodableValueCollection class]];
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(MHVItem *) newItem
{
    return [[MHVItem alloc] initWithType:[MHVQuestionAnswer typeID]];
}

@end
