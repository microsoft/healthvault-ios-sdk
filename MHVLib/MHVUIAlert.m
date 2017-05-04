//
//  MHVUIAlert.m
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
#import "MHVUIAlert.h"
#import "MHVClient.h"

@implementation MHVUIAlert

@synthesize view = m_view;
@synthesize result = m_result;
@synthesize inputText = m_text;

-(id) init
{
    return [self initWithInformationalMessage:@"Your message here"];
}

-(id)initWithMessage:(NSString *)message callback:(MHVNotify)callback
{
    NSString* title = [MHVClient current].settings.appName;
    return [self initWithTitle:title message:message callback:callback];
}

-(id)initWithTitle:(NSString *)title message:(NSString *)message callback:(MHVNotify)callback
{
    return [self initWithTitle:title message:message 
                  cancelButtonText:NSLocalizedString(@"Cancel", @"Cancel button text")
                  okButtonText:NSLocalizedString(@"OK", @"OK button text") 
                  callback:callback];
}

-(id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonText:(NSString *)cancelText okButtonText:(NSString *)okText callback:(MHVNotify)callback
{
    MHVCHECK_STRING(title);
    MHVCHECK_STRING(cancelText);
    MHVCHECK_STRING(message);

    self = [super init];
    MHVCHECK_SELF;
    
    m_result = MHVUIAlertCancel;
    
    if (okText)
    {
        m_view = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelText otherButtonTitles:okText, nil];        
    }
    else
    {
        m_view = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelText otherButtonTitles:nil];       
    }
    MHVCHECK_NOTNULL(m_view);
    
    if (callback)
    {
        m_callback = [callback copy];
        MHVCHECK_NOTNULL(m_callback);
    }
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(id)initWithInformationalMessage:(NSString *)message
{
    return [self initWithTitle:[MHVClient current].settings.appName forInformationalMessage:message];
}

-(id)initWithTitle:(NSString *)title forInformationalMessage:(NSString *)message
{
    return [self initWithTitle:title forInformationalMessage:message withCallback:nil];
}

-(id)initWithTitle:(NSString *)title forInformationalMessage:(NSString *)message withCallback:(MHVNotify)callback
{
    return [self initWithTitle:title 
                    message:message 
                    cancelButtonText:NSLocalizedString(@"OK", @"OK button text")
                    okButtonText:nil 
                    callback:callback];
}


-(void) show
{
    [m_view show];
}

+(MHVUIAlert *) showWithMessage:(NSString *) message callback:(MHVNotify) callback
{
    MHVUIAlert* alert = [[MHVUIAlert alloc] initWithMessage:message callback:callback];
    MHVCHECK_NOTNULL(alert);
    
    [alert show];
    //
    // DO NOT RELEASE. Releases itself when dialog delegate completes
    //
    return alert;
    
LError:
    return nil;
}

+(MHVUIAlert *)showYesNoWithMessage:(NSString *)message callback:(MHVNotify)callback
{
    NSString* title = [MHVClient current].settings.appName;
    NSString* noText = NSLocalizedString(@"No", @"No button");
    NSString* yesText = NSLocalizedString(@"Yes", @"Yes button");
    
    MHVUIAlert* alert = [[MHVUIAlert alloc]   initWithTitle:title 
                                            message:message 
                                            cancelButtonText:noText 
                                             okButtonText:yesText 
                                            callback:callback];
    [alert show];

    //
    // DO NOT RELEASE. Releases itself when dialog delegate completes
    //
    return alert;
    
LError:
    return nil;
    
}

+(MHVUIAlert *) showWithTitle:(NSString *) title message:(NSString *) message callback:(MHVNotify) callback
{
    MHVUIAlert* alert = [[MHVUIAlert alloc] initWithTitle:title message:message callback:callback];
    MHVCHECK_NOTNULL(alert);
    
    [alert show];
    //
    // DO NOT RELEASE. Releases itself when dialog delegate completes
    //
    return alert;
    
LError:
    return nil;
 
}

+(MHVUIAlert *)showInformationalMessage:(NSString *)message
{
    MHVUIAlert* alert = [[MHVUIAlert alloc] initWithInformationalMessage:message];
    MHVCHECK_NOTNULL(alert);
    
    [alert show];
    return alert;
    
LError:
    return nil;
}

+(MHVUIAlert *)showInformationalMessage:(NSString *)message withCallback:(MHVNotify) callback
{
    MHVUIAlert* alert = [[MHVUIAlert alloc] 
                        initWithTitle:[MHVClient current].settings.appName 
                        forInformationalMessage:message 
                        withCallback:callback];
    
    MHVCHECK_NOTNULL(alert);
    
    [alert show];
    return alert;
    
LError:
    return nil;
}

+(MHVUIAlert *)showPromptWithMessage:(NSString *)message callback:(MHVNotify)callback
{
    return [MHVUIAlert showPromptWithMessage:message defaultText:nil andCallback:callback];
}

+(MHVUIAlert *)showPromptWithMessage:(NSString *)message defaultText:(NSString *)defaultText andCallback:(MHVNotify)callback
{
    MHVUIAlert* alert = [[MHVUIAlert alloc] initWithMessage:message callback:callback];
    MHVCHECK_NOTNULL(alert);
    
    alert.view.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* textField = [alert.view textFieldAtIndex:0];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    if (defaultText)
    {
        textField.text = defaultText;
    }
    
    [alert show];
    return alert;    

LError:
    return nil;
}

//------------------------------------
//
// UIAlertViewDelegate
//
//------------------------------------
static const NSInteger c_okButtonIndex = 1;

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex   
{
    if (m_callback)
    {
        if (alertView.alertViewStyle != UIAlertViewStyleDefault)
        {
            m_text = [[alertView textFieldAtIndex:0] text];
        }
        
        switch (buttonIndex) {
     
            case c_okButtonIndex:
                m_result = MHVUIAlertOK;
                break;
            
            default:
                m_result = MHVUIAlertCancel;
                break;
        }
        safeInvokeNotify(m_callback, self);
    }
    
}


@end
