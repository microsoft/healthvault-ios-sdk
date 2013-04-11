//
//  HVFeatureActions.m
//  SDKFeatures
//
//  Created by Umesh Madan on 4/10/13.
//  Copyright (c) 2013 Microsoft. All rights reserved.
//

#import "HVCommon.h"
#import "HVFeatureActions.h"

@implementation HVFeatureActions

-(id)init
{
    self = [super init];
    HVCHECK_SELF;
    
    m_actionSheet = [[UIActionSheet alloc] initWithTitle:@"Try MORE Features"
                                        delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                        otherButtonTitles:nil];
    HVCHECK_NOTNULL(m_actionSheet);
    m_actionSheet.delegate = self;
    
    m_actions = [[NSMutableArray alloc] init];
    HVCHECK_NOTNULL(m_actions);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    m_actionSheet.delegate = nil;
    [m_actionSheet release];
    [m_actions release];
    
    [super dealloc];
}

-(BOOL) addFeature:(NSString *)title andAction:(HVAction)action
{
    HVCHECK_NOTNULL(action);
    
    [m_actionSheet addButtonWithTitle:title];
    [m_actions addObject:[action copy]]; // Action is a block, so we need to copy it
    
    return TRUE;
    
LError:
    return FALSE;
}

-(void)showFrom:(UIBarButtonItem *)button
{
    [m_actionSheet showFromBarButtonItem:button animated:true];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        return;  // Cancel
    }
    @try
    {
        HVAction action = (HVAction) [m_actions objectAtIndex:buttonIndex - 1];
        action();
    }
    @catch (NSException *exception)
    {
        [HVUIAlert showInformationalMessage:exception.description];
    }
}

@end
