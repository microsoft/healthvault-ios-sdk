//
// MHVThingDataTypedFeatures.h
// SDKFeatures
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

#import "MHVFileFeatures.h"
#import "MHVTypeViewController.h"
#import "MHVUIAlert.h"
#import "MHVSodaConnectionProtocol.h"
#import "MHVConnectionFactory.h"
#import "MHVFeaturesConfiguration.h"
#import "MHVConnectionFactoryProtocol.h"
#import "MHVTypeListViewController.h"
#import "MHVThingClientProtocol.h"
#import "SDKFeatures-Swift.h"

@interface MHVFileFeatures ()

@property (nonatomic, strong) id<MHVSodaConnectionProtocol> connection;
@property (nonatomic, assign) BOOL isPickingPersonalImage;

@end

@implementation MHVFileFeatures

- (instancetype)init
{
    self = [super initWithTitle:@"File features"];
    if (self)
    {
        __weak __typeof__(self)weakSelf = self;

        [self addFeature:@"View file URL in Safari" andAction:^
        {
            [weakSelf viewFileInBrowser];
        }];
        [self addFeature:@"Upload image" andAction:^
        {
            [weakSelf pickImageForUpload];
        }];
        [self addFeature:@"Download and view file" andAction:^
        {
            [weakSelf downloadFile];
        }];
        [self addFeature:@"Update personal image" andAction:^
         {
             [weakSelf pickImageFoPersonalImage];
         }];
        
        _connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    }

    return self;
}

//
// Files are stored in HealthVault Blobs (note: Any HealthVault type can have multiple associated NAMED blob streams of arbitrary size).
// File data is stored in the default or 'unnamed' blob stream for an thing
//
// Each blob is referenced using a blob Url that is active for a limited duration. So, to get a "live" Url, we must first refresh
// an thing's blob information
//
- (void)processSelectedFile:(void(^)(MHVBlobPayloadThing *value))action
{
    MHVThing *fileThing = [self.controller getSelectedThing];

    if (!fileThing)
    {
        return;
    }

    [self.controller showActivityAndStatus:@"Getting updated File info"];

    [self updateBlobsForThing:fileThing action:action];
}

- (void)updateBlobsForThing:(MHVThing *)thing action:(void(^)(MHVBlobPayloadThing *value))action
{
    [self.connection.thingClient refreshBlobUrlsForThing:thing
                                                recordId:self.connection.personInfo.selectedRecordID
                                              completion:^(MHVThing * _Nullable thing, NSError * _Nullable error)
     {
         MHVBlobPayloadThing *fileBlob = [thing.blobs getDefaultBlob];
         action(fileBlob);
     }];
}

- (void)viewFileInBrowser
{
    [self processSelectedFile:^(MHVBlobPayloadThing *value)
    {
        MHVBlobPayloadThing *fileBlob = (MHVBlobPayloadThing *)value;

        NSURL *blobUrl = [NSURL URLWithString:fileBlob.blobUrl];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
        {
            [self.controller clearStatus];
            
            [[UIApplication sharedApplication] openURL:blobUrl options:@{} completionHandler:nil];
        }];
    }];
}

#pragma mark - Download

- (void)downloadFile
{
    MHVThing *fileThing = [self.controller getSelectedThing];

    if (!fileThing)
    {
        return;
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths firstObject] stringByAppendingPathComponent:fileThing.file.name];
    
    [self downloadFileToFilePath:filePath];
}

- (void)downloadFileToFilePath:(NSString *)filePath
{
    if (!filePath)
    {
        return;
    }
    
    MHVThing *fileThing = [self.controller getSelectedThing];

    [self.controller showActivityAndStatus:[NSString stringWithFormat:@"Downloading %@", [fileThing.file sizeAsString]]];

    [self processSelectedFile:^(MHVBlobPayloadThing *fileBlob)
    {
        NSLog(@"Download to path: %@", filePath);

        [self downloadBlobPayload:fileBlob toFilePath:filePath];
    }];
}

- (void)downloadBlobPayload:(MHVBlobPayloadThing *)fileBlob toFilePath:(NSString *)filePath
{
    [self.connection.thingClient downloadBlob:fileBlob
                                   toFilePath:filePath
                                   completion:^(NSError * _Nullable error)
     {
         [self downloadCompleteWithError:error filePath:filePath];
     }];
}

- (void)downloadCompleteWithError:(NSError *)error filePath:(NSString *)filePath
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         if (error)
         {
             [MHVUIAlert showInformationalMessage:error.localizedDescription];
         }
         else
         {
             UIImage *image = [UIImage imageWithContentsOfFile:filePath];
             if (image)
             {
                 MHVImageViewController *imageVC = [[MHVImageViewController alloc] initWithNibName:@"MHVImageViewController" bundle:nil image:image];
                 
                 [self.controller.navigationController pushViewController:imageVC animated:TRUE];
             }
             else
             {
                 [MHVUIAlert showInformationalMessage:@"Downloaded into Documents folder."];
             }
         }
         
         [self.controller clearStatus];
     }];
}

#pragma mark - Upload

- (void)uploadFileWithName:(NSString *)name data:(NSData *)data andMediaType:(NSString *)mediaType
{
    if (!data || data.length == 0)
    {
        return;
    }

    [self.controller showActivityAndStatus:@"Uploading file. Please wait..."];
    //
    // Create a new file thing
    //
    MHVThing *fileThing = [MHVFile newThingWithName:name andContentType:mediaType];
    fileThing.file.size = data.length;
    //
    // Set up the data source so we can push the file to HealthVault
    //
    id<MHVBlobSourceProtocol> blobSource = [[MHVBlobMemorySource alloc] initWithData:data];
    //
    // This will first commit the blob and if that is successful, also PUT the associated file thing
    //
    
    //NOTE: Uses nil for name so this blob is the DefaultBlob for the MHVFile which does have the name
    [self.connection.thingClient addBlobSource:blobSource
                                       toThing:fileThing
                                          name:nil
                                   contentType:mediaType
                                      recordId:self.connection.personInfo.selectedRecordID
                                    completion:^(MHVThing *_Nullable thing, NSError * _Nullable error)
     {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (error)
             {
                 [MHVUIAlert showInformationalMessage:error.localizedDescription];
             }
             else
             {
                 [MHVUIAlert showInformationalMessage:@"File uploaded!"];
                 
                 [self.controller getThingsFromHealthVault]; // Refresh
             }
         }];
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
    }];
}

- (void)pickImageForUpload
{
    self.isPickingPersonalImage = NO;

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = (UIImagePickerControllerSourceTypePhotoLibrary | UIImagePickerControllerSourceTypeSavedPhotosAlbum);
    picker.delegate = self;

    [self.controller presentViewController:picker animated:TRUE completion:nil];
}

- (void)pickImageFoPersonalImage
{
    self.isPickingPersonalImage = YES;
    
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
    
    if (self.isPickingPersonalImage)
    {
        // Size image to be 200 pixels wide & preserve aspect ratio
        CGSize newSize = CGSizeMake(200, (image.size.height / image.size.width) * 200);
        
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    NSData *fileData = UIImageJPEGRepresentation(image, 0.8);
    NSString *fileMediaType = @"image/jpeg";

    //
    // Close the picker and upload the file
    //
    [picker dismissViewControllerAnimated:TRUE completion:^
    {
        if (self.isPickingPersonalImage)
        {
            [self updatePersonalImage:fileData contentType:fileMediaType];
        }
        else
        {
            NSString *fileName = [NSString stringWithFormat:@"Picture_%@.jpg", [[NSDate date] toStringWithFormat:@"yyyyMMdd_HHmmss"]];
            
            [self uploadFileWithName:fileName data:fileData andMediaType:fileMediaType];
        }
    }];
}

@end

