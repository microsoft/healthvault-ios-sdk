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

@interface MHVFileFeatures ()

@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, strong) NSString *fileMediaType;

@property (nonatomic, strong) id<MHVSodaConnectionProtocol> connection;

@end

@implementation MHVFileFeatures

- (instancetype)init
{
    self = [super initWithTitle:@"File features"];
    if (self)
    {
        __weak __typeof__(self)weakSelf = self;

        [self addFeature:@"View file" andAction:^
        {
            [weakSelf viewFileInBrowser];
        }];
        [self addFeature:@"Upload image" andAction:^
        {
            [weakSelf pickImageForUpload];
        }];
        [self addFeature:@"Download file" andAction:^
        {
            [weakSelf downloadFile];
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

#if SHOULD_USE_LEGACY
    [self updateBlobsForThingLegacy:fileThing action:action];
#else
    [self updateBlobsForThingNew:fileThing action:action];
#endif
}

- (void)updateBlobsForThingLegacy:(MHVThing *)thing action:(void(^)(MHVBlobPayloadThing *value))action
{
    [thing updateBlobDataFromRecord:[MHVClient current].currentRecord andCallback:^(MHVTask *task)
     {
         @try
         {
             [task checkSuccess];
             
             MHVBlobPayloadThing *fileBlob = [thing.blobs getDefaultBlob];
             action(fileBlob);
         }
         @catch (NSException *exception)
         {
             [MHVUIAlert showInformationalMessage:[exception descriptionForLog]];
             [self.controller clearStatus];
         }
     }];
}

- (void)updateBlobsForThingNew:(MHVThing *)thing action:(void(^)(MHVBlobPayloadThing *value))action
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
            [[UIApplication sharedApplication] openURL:blobUrl options:@{} completionHandler:nil];
            
            [self.controller clearStatus];
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

#if SHOULD_USE_LEGACY
        [self downloadBlobPayloadLegacy:fileBlob toFilePath:filePath];
#else
        [self downloadBlobPayloadNew:fileBlob toFilePath:filePath];
#endif
    }];
}

- (void)downloadBlobPayloadLegacy:(MHVBlobPayloadThing *)fileBlob toFilePath:(NSString *)filePath
{
    [fileBlob downloadBlobToFilePath:filePath completion:^(NSError *error)
     {
         [self downloadCompleteWithError:error];
     }];
}

- (void)downloadBlobPayloadNew:(MHVBlobPayloadThing *)fileBlob toFilePath:(NSString *)filePath
{
    [self.connection.thingClient downloadBlob:fileBlob
                                   toFilePath:filePath
                                     recordId:self.connection.personInfo.selectedRecordID
                                   completion:^(NSError * _Nullable error)
     {
         [self downloadCompleteWithError:error];
     }];
}

- (void)downloadCompleteWithError:(NSError *)error
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         if (!error)
         {
             [MHVUIAlert showInformationalMessage:@"Downloaded into Documents folder."];
         }
         else
         {
             [MHVUIAlert showInformationalMessage:error.localizedDescription];
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
    [fileThing uploadBlob:blobSource contentType:mediaType record:[MHVClient current].currentRecord andCallback:^(MHVTask *task)
    {
        @try
        {
            [task checkSuccess];

            [MHVUIAlert showInformationalMessage:@"File uploaded!"];

            [self.controller getThingsFromHealthVault]; // Refresh
        }
        @catch (id exception)
        {
            [MHVUIAlert showInformationalMessage:[exception descriptionForLog]];
        }
        [self.controller clearStatus];
    }];
}

- (void)pickImageForUpload
{
    self.fileMediaType = nil;
    self.fileData = nil;

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = (UIImagePickerControllerSourceTypePhotoLibrary | UIImagePickerControllerSourceTypeSavedPhotosAlbum);
    picker.delegate = self;

    [self.controller presentViewController:picker animated:TRUE completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //
    // Save selected image data
    //
    UIImage *image = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    self.fileData = UIImageJPEGRepresentation(image, 0.8);
    self.fileMediaType = @"image/jpeg";

    //
    // Close the picker and upload the file
    //
    [picker dismissViewControllerAnimated:TRUE completion:^
    {
        NSString *fileName = [NSString stringWithFormat:@"Picture_%@.jpg", [[NSDate date] toStringWithFormat:@"yyyyMMdd_HHmmss"]];

        [self uploadFileWithName:fileName data:self.fileData andMediaType:self.fileMediaType];
    }];
}

@end

