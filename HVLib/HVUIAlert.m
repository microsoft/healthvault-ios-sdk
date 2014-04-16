//
//  HVUIAlert.m
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
#import "HVUIAlert.h"
#import "HVClient.h"

@implementation HVUIAlert

@synthesize view = m_view;
@synthesize result = m_result;
@synthesize inputText = m_text;

-(id) init
{
    return [self initWithInformationalMessage:@"Your message here"];
}

-(id)initWithMessage:(NSString *)message callback:(HVNotify)callback
{
    NSString* title = [HVClient current].settings.appName;
    return [self initWithTitle:title message:message callback:callback];
}

-(id)initWithTitle:(NSString *)title message:(NSString *)message callback:(HVNotify)callback
{
    return [self initWithTitle:title message:message 
                  cancelButtonText:NSLocalizedString(@"Cancel", @"Cancel button text")
                  okButtonText:NSLocalizedString(@"OK", @"OK button text") 
                  callback:callback];
}

-(id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonText:(NSString *)cancelText okButtonText:(NSString *)okText callback:(HVNotify)callback
{
    HVCHECK_STRING(title);
    HVCHECK_STRING(cancelText);
    HVCHECK_STRING(message);

    self = [super init];
    HVCHECK_SELF;
    
    m_result = HVUIAlertCancel;
    
    if (okText)
    {
        m_view = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelText otherButtonTitles:okText, nil];        
    }
    else
    {
        m_view = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelText otherButtonTitles:nil];       
    }
    HVCHECK_NOTNULL(m_view);
    
    if (callback)
    {
        m_callback = [callback copy];
        HVCHECK_NOTNULL(m_callback);
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(id)initWithInformationalMessage:(NSString *)message
{
    return [self initWithTitle:[HVClient current].settings.appName forInformationalMessage:message];
}

-(id)initWithTitle:(NSString *)title forInformationalMessage:(NSString *)message
{
    return [self initWithTitle:title forInformationalMessage:message withCallback:nil];
}

-(id)initWithTitle:(NSString *)title forInformationalMessage:(NSString *)message withCallback:(HVNotify)callback
{
    return [self initWithTitle:title 
                    message:message 
                    cancelButtonText:NSLocalizedString(@"OK", @"OK button text")
                    okButtonText:nil 
                    callback:callback];
}

-(void)dealloc
{
    [m_view release];
    [m_callback release];
    [m_text release];
    
    [super dealloc];
}

-(void) show
{
    [m_view show];
}

+(HVUIAlert *) showWithMessage:(NSString *) message callback:(HVNotify) callback
{
    HVUIAlert* alert = [[HVUIAlert alloc] initWithMessage:message callback:callback];
    HVCHECK_NOTNULL(alert);
    
    [alert show];
    //
    // DO NOT RELEASE. Releases itself when dialog delegate completes
    //
    return alert;
    
LError:
    return nil;
}

+(HVUIAlert *)showYesNoWithMessage:(NSString *)message callback:(HVNotify)callback
{
    NSString* title = [HVClient current].settings.appName;
    NSString* noText = NSLocalizedString(@"No", @"No button");
    NSString* yesText = NSLocalizedString(@"Yes", @"Yes button");
    
    HVUIAlert* alert = [[HVUIAlert alloc]   initWithTitle:title 
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

+(HVUIAlert *) showWithTitle:(NSString *) title message:(NSString *) message callback:(HVNotify) callback
{
    HVUIAlert* alert = [[HVUIAlert alloc] initWithTitle:title message:message callback:callback];
    HVCHECK_NOTNULL(alert);
    
    [alert show];
    //
    // DO NOT RELEASE. Releases itself when dialog delegate completes
    //
    return alert;
    
LError:
    return nil;
 
}

+(HVUIAlert *)showInformationalMessage:(NSString *)message
{
    HVUIAlert* alert = [[HVUIAlert alloc] initWithInformationalMessage:message];
    HVCHECK_NOTNULL(alert);
    
    [alert show];
    return alert;
    
LError:
    return nil;
}

+(HVUIAlert *)showInformationalMessage:(NSString *)message withCallback:(HVNotify) callback
{
    HVUIAlert* alert = [[HVUIAlert alloc] 
                        initWithTitle:[HVClient current].settings.appName 
                        forInformationalMessage:message 
                        withCallback:callback];
    
    HVCHECK_NOTNULL(alert);
    
    [alert show];
    return alert;
    
LError:
    return nil;
}

+(HVUIAlert *)showPromptWithMessage:(NSString *)message callback:(HVNotify)callback
{
    return [HVUIAlert showPromptWithMessage:message defaultText:nil andCallback:callback];
}

+(HVUIAlert *)showPromptWithMessage:(NSString *)message defaultText:(NSString *)defaultText andCallback:(HVNotify)callback
{
    HVUIAlert* alert = [[HVUIAlert alloc] initWithMessage:message callback:callback];
    HVCHECK_NOTNULL(alert);
    
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
            m_text = [[[alertView textFieldAtIndex:0] text] retain];
        }
        
        switch (buttonIndex) {
     
            case c_okButtonIndex:
                m_result = HVUIAlertOK;
                break;
            
            default:
                m_result = HVUIAlertCancel;
                break;
        }
        safeInvokeNotify(m_callback, self);
    }
    
    [self release];
}


@end
