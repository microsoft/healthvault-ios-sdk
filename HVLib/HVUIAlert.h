//
//  HVUIAlert.h
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
#import <UIKit/UIKit.h>
#import "HVBlock.h"

enum HVUIAlertResult 
{
    HVUIAlertCancel = 0,
    HVUIAlertOK = 1
};

@interface HVUIAlert : NSObject <UIAlertViewDelegate>
{
    enum HVUIAlertResult m_result;
    UIAlertView *m_view;
    HVNotify m_callback;
    NSString* m_text;
}

//-------------------------
//
// Properties
//
//-------------------------
@property (readonly, nonatomic) UIAlertView* view;
@property (readonly, nonatomic) enum HVUIAlertResult result;
@property (readonly, nonatomic) NSString* inputText;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithMessage:(NSString *) message callback:(HVNotify) callback;
-(id) initWithTitle:(NSString *) title message:(NSString *) message callback:(HVNotify) callback;
-(id) initWithTitle:(NSString *) title message:(NSString *) message cancelButtonText:(NSString *) cancelText okButtonText:(NSString *) okText callback:(HVNotify) callback;
-(id) initWithInformationalMessage:(NSString *) message;
-(id) initWithTitle:(NSString *) title forInformationalMessage:(NSString *) message;

//-------------------------
//
// Methods
//
//-------------------------
-(void) show;

+(HVUIAlert *) showWithMessage:(NSString *) message callback:(HVNotify) callback;
+(HVUIAlert *) showYesNoWithMessage:(NSString *) message callback:(HVNotify) callback;
+(HVUIAlert *) showWithTitle:(NSString *) title message:(NSString *) message callback:(HVNotify) callback;
+(HVUIAlert *) showInformationalMessage:(NSString *) message;
+(HVUIAlert *) showPromptWithMessage:(NSString *) message callback:(HVNotify) callback;
+(HVUIAlert *) showPromptWithMessage:(NSString *) message defaultText:(NSString *) defaultText andCallback:(HVNotify) callback;

@end
