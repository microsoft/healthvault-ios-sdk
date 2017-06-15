//
//  MHVUIAlert.m
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

#import "MHVUIAlert.h"

@implementation MHVUIAlert

+ (void)showInformationalMessage:(NSString *)message
{
    NSParameterAssert(message);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[[NSBundle bundleWithIdentifier:@"BundleIdentifier"] objectForInfoDictionaryKey:(id)kCFBundleExecutableKey]
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button")
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];

    [self showAlert:alertController];
}

+ (void)showYesNoPromptWithMessage:(NSString *)message completion:(void (^)(BOOL selectedYes))completion
{
    NSParameterAssert(message);
    NSParameterAssert(completion);

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[[NSBundle bundleWithIdentifier:@"BundleIdentifier"] objectForInfoDictionaryKey:(id)kCFBundleExecutableKey]
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", @"No button")
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action)
                                {
                                    completion(NO);
                                }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", @"Yes button")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action)
                                {
                                    completion(YES);
                                }]];

    [self showAlert:alertController];
}

+ (void)showAlert:(UIAlertController *)alertController
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
    {
        // Make window to show the alert
        UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        alertWindow.rootViewController = [[UIViewController alloc] init];
        
        // Show over any other windows or alerts
        UIWindow *topWindow = [UIApplication sharedApplication].windows.lastObject;
        alertWindow.windowLevel = topWindow.windowLevel + 1;
        
        [alertWindow makeKeyAndVisible];
        
        [alertWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    }];
}

@end
