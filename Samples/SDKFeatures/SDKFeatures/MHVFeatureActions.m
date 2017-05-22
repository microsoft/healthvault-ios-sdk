//
//  MHVFeatureActions.m
//  SDKFeatures
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
//

#import "MHVCommon.h"
#import "MHVFeatureActions.h"
#import "MHVUIAlert.h"

@interface MHVFeatureActions ()<UIActionSheetDelegate>

@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) NSMutableArray<MHVAction> *actions;

@end

@implementation MHVFeatureActions

- (id)init
{
    return [self initWithTitle:nil];
}

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    
    
    if (!title)
    {
        title = @"Try MORE Features";
    }
    _actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:nil];
    
    _actionSheet.delegate = self;
    
    _actions = [NSMutableArray new];
    
    return self;
}

- (BOOL)addFeature:(NSString *)title andAction:(MHVAction)action
{
    MHVASSERT_PARAMETER(action);
    
    [self.actionSheet addButtonWithTitle:title];
    [self.actions addObject:action];
    
    return YES;
}

- (void)showFrom:(UIBarButtonItem *)button
{
    [self.actionSheet showFromBarButtonItem:button animated:true];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        return;  // Cancel
    }
    @try
    {
        MHVAction action = (MHVAction) [self.actions objectAtIndex:buttonIndex - 1];
        action();
    }
    @catch (NSException *exception)
    {
        [MHVUIAlert showInformationalMessage:exception.description];
    }
}

@end
