//
//  HVQuestionAnswer.h
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
#import "HVTypes.h"

@interface HVQuestionAnswer : HVItemDataTyped
{
    HVDateTime* m_when;
    HVCodableValue* m_question;
    HVCodableValueCollection* m_answerChoices;
    HVCodableValueCollection* m_answers;
}

@property (readwrite, nonatomic, retain) HVDateTime* when;
@property (readwrite, nonatomic, retain) HVCodableValue* question;
@property (readwrite, nonatomic, retain) HVCodableValueCollection* answerChoices;
@property (readwrite, nonatomic, retain) HVCodableValueCollection* answers;
@property (readonly, nonatomic) HVCodableValue* firstAnswer;

@property (readonly, nonatomic) BOOL hasAnswerChoices;
@property (readonly, nonatomic) BOOL hasAnswers;

-(id) initWithQuestion:(HVCodableValue *) question andDate:(NSDate *) date;
-(id) initWithQuestion:(HVCodableValue *) question answer:(HVCodableValue *) answer andDate:(NSDate *) date;

-(NSString *) toString;

+(NSString *) typeID;
+(NSString *) XRootElement;

+(HVItem *) newItem;

@end
