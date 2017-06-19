//
//  MHVPersonalImageFeatures.m
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


#import "MHVPersonalImageFeatures.h"
#import "MHVTypeViewController.h"
#import "MHVUIAlert.h"
#import "MHVSodaConnectionProtocol.h"
#import "MHVConnectionFactory.h"
#import "MHVFeaturesConfiguration.h"
#import "MHVConnectionFactoryProtocol.h"
#import "MHVTypeListViewController.h"
#import "MHVThingClientProtocol.h"

static NSInteger kPersonalImageSize = 600;

@interface MHVPersonalImageFeatures ()

@property (nonatomic, strong) id<MHVSodaConnectionProtocol> connection;

@end

@implementation MHVPersonalImageFeatures

- (instancetype)init
{
    self = [super initWithTitle:@"Personal Image features"];
    if (self)
    {
        __weak __typeof__(self)weakSelf = self;
        
        [self addFeature:@"Update personal image" andAction:^
         {
             [weakSelf pickImageFoPersonalImage];
         }];
        
        _connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    }
    
    return self;
}

- (void)pickImageFoPersonalImage
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    picker.delegate = self;
    
    [self.controller presentViewController:picker animated:TRUE completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //
    // Save selected image data
    //
    UIImage *image = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Size image to be kPersonalImageSize pixels wide & preserve aspect ratio
    CGSize newSize = CGSizeMake(kPersonalImageSize,
                                (image.size.height / image.size.width) * kPersonalImageSize);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *fileData = UIImageJPEGRepresentation(image, 0.8);
    NSString *fileMediaType = @"image/jpeg";
    
    //
    // Close the picker and upload the file
    //
    [picker dismissViewControllerAnimated:TRUE completion:^
     {
         [self updatePersonalImage:fileData contentType:fileMediaType];
     }];
}

- (void)updatePersonalImage:(NSData *)data contentType:(NSString *)contentType
{
    [self.controller showActivityAndStatus:@"Uploading image. Please wait..."];
    
    [self.connection.thingClient setPersonalImage:data
                                      contentType:contentType
                                         recordId:self.connection.personInfo.selectedRecordID
                                       completion:^(NSError * _Nullable error)
     {
         if (error)
         {
             [MHVUIAlert showInformationalMessage:error.localizedDescription];
         }
         else
         {
             [MHVUIAlert showInformationalMessage:@"Personal image updated!"];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:kPersonalImageUpdateNotification
                                                                 object:self.connection.personInfo.selectedRecordID];
         }
         [self.controller clearStatus];
     }];
}

@end
