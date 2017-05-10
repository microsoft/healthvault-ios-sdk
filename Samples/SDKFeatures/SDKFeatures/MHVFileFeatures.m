//
//  MHVItemDataTypedFeatures.h
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

#import "MHVFileFeatures.h"
#import "MHVTypeViewController.h"
#import "MHVUIAlert.h"

@interface MHVFileFeatures (MHVPrivate)

-(NSFileHandle *) openFileForWrite:(NSString *) fileName;

@end

@implementation MHVFileFeatures

-(id)init
{
    self = [super initWithTitle:@"File features"];
    MHVCHECK_SELF;
    
    __weak __typeof__(self) weakSelf = self;

    [self addFeature:@"View file" andAction:^{
        [weakSelf viewFileInBrowser];
    }];
    [self addFeature:@"Upload image" andAction:^{
        [weakSelf pickImageForUpload];
    }];
    [self addFeature:@"Download file" andAction:^{
        [weakSelf downloadFile];
    }];
    return self;
    
LError:
    MHVALLOC_FAIL;
}


//
// Files are stored in HealthVault Blobs (note: Any HealthVault type can have multiple associated NAMED blob streams of arbitrary size).
// File data is stored in the default or 'unnamed' blob stream for an item
//
// Each blob is referenced using a blob Url that is active for a limited duration. So, to get a "live" Url, we must first refresh
// an item's blob information
//
-(void)processSelectedFile:(MHVHandler)action
{
    MHVItem* fileItem = [self.controller getSelectedItem];
    if (!fileItem)
    {
        return;
    }
    
    [self.controller showActivityAndStatus:@"Getting updated File info"];
    
    [fileItem updateBlobDataFromRecord:[MHVClient current].currentRecord andCallback:^(MHVTask *task) {
        
        @try {
            [task checkSuccess];

            MHVBlobPayloadItem* fileBlob = [fileItem.blobs getDefaultBlob];
            action(fileBlob);
        }
        @catch (NSException *exception) {
            [MHVUIAlert showInformationalMessage:[exception descriptionForLog]];
            [self.controller clearStatus];
        }
    }];
    
}

-(void)viewFileInBrowser
{
    [self processSelectedFile:^BOOL(id value) {
        MHVBlobPayloadItem* fileBlob = (MHVBlobPayloadItem *) value;
        
        NSURL* blobUrl = [NSURL URLWithString:fileBlob.blobUrl];
        [[UIApplication sharedApplication] openURL:blobUrl];
        
        [self.controller clearStatus];

        return TRUE;
    }];
}

-(void)downloadFile
{
    MHVItem* fileItem = [self.controller getSelectedItem];
    if (!fileItem)
    {
        return;
    }
    
    [self downloadFileToFile:[self openFileForWrite:fileItem.file.name]];
}

-(void)downloadFileToFile:(NSFileHandle *)file
{
    if (!file)
    {
        return;
    }
    
    MHVItem* fileItem = [self.controller getSelectedItem];
    
    [self processSelectedFile:^BOOL(id value)
    {
        MHVBlobPayloadItem* fileBlob = (MHVBlobPayloadItem *) value;
        
        [self.controller showActivityAndStatus:[NSString stringWithFormat:@"Downloading %@", [fileItem.file sizeAsString]]];
        
        [fileBlob downloadToFile:file andCallback:^(MHVTask *task) {
            @try
            {
                [task checkSuccess];
                [MHVUIAlert showInformationalMessage:@"Downloaded into Documents folder."];
            }
            @catch (id exception) {
                [MHVUIAlert showInformationalMessage:[exception descriptionForLog]];
            }
            
            [self.controller clearStatus];
        }];
        
        return TRUE;
    }];
}

-(void)uploadFileWithName:(NSString *)name data:(NSData *)data andMediaType:(NSString *)mediaType
{
    if (!data || data.length == 0)
    {
        return;
    }
    
    [self.controller showActivityAndStatus:@"Uploading file. Please wait..."];
    //
    // Create a new file item
    //
    MHVItem* fileItem = [MHVFile newItemWithName:name andContentType:mediaType];
    fileItem.file.size = data.length;
    //
    // Set up the data source so we can push the file to HealthVault
    //
    id<MHVBlobSourceProtocol> blobSource = [[MHVBlobMemorySource alloc] initWithData:data];
    //
    // This will first commit the blob and if that is successful, also PUT the associated file item
    //
    [fileItem uploadBlob:blobSource contentType:mediaType record:[MHVClient current].currentRecord andCallback:^(MHVTask *task) {
        @try
        {
            [task checkSuccess];
            
            [MHVUIAlert showInformationalMessage:@"File uploaded!"];
            
            [self.controller getItemsFromHealthVault]; // Refresh
        }
        @catch (id exception) {
            [MHVUIAlert showInformationalMessage:[exception descriptionForLog]];
        }
        [self.controller clearStatus];
    }];    
}

-(void)pickImageForUpload
{
    m_fileMediaType = nil;
    m_fileData = nil;
    
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = (UIImagePickerControllerSourceTypePhotoLibrary | UIImagePickerControllerSourceTypeSavedPhotosAlbum);
    picker.delegate = self;
    
    [self.controller presentViewController:picker animated:TRUE completion:^{
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //
    // Save selected image data
    //
    m_fileMediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage* image = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    m_fileData = UIImageJPEGRepresentation(image, 0.8);
    //
    // Close the picker and upload the file
    //
    [picker dismissViewControllerAnimated:TRUE completion:^{

        NSString* fileName = [NSString stringWithFormat:@"Picture_%@.jpg", [[NSDate date] toStringWithFormat:@"yyyyMMdd_HHmmss"]];
        
        [self uploadFileWithName:fileName data:m_fileData andMediaType:m_fileMediaType];

    }];
}


@end

@implementation MHVFileFeatures (MHVPrivate)

-(NSFileHandle *)openFileForWrite:(NSString *)fileName
{
    NSString* folderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil])
    {
        return [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
    
    return nil;
}

@end
