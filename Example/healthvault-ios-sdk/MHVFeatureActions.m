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

#import "MHVFeatureActions.h"
#import "MHVValidator.h"
#import "MHVUIAlert.h"

@interface MHVFeatureActions ()<UIActionSheetDelegate>

@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation MHVFeatureActions

- (instancetype)init
{
    return [self initWithTitle:nil];
}

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self)
    {
        if (!title)
        {
            title = @"Try Features";
        }
        _alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    }
    return self;
}

- (BOOL)addFeature:(NSString *)title andAction:(MHVAction)action
{
    MHVASSERT_PARAMETER(action);
    
    [self.alertController addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull alertAction)
    {
        action();
    }]];
    
    return YES;
}

- (void)showWithViewController:(UIViewController *)viewController
{
    // Make sure it has a final Cancel action
    if (![[self.alertController.actions lastObject].title isEqualToString:@"Cancel"])
    {
        [self.alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    }
    
    [viewController presentViewController:self.alertController animated:YES completion:nil];
}

@end
