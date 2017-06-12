//
//  MHVMedicalImageStudyTests.m
// MHVLib
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

#import <XCTest/XCTest.h>
#import "Kiwi.h"
#import "MHVMedicalImageStudy.h"

SPEC_BEGIN(MHVMedicalImageStudyTests)

describe(@"MHVMedicalImageStudy", ^
         {
             NSString *objectDefinition = @"<medical-image-study><when><date><y>2009</y><m>1</m><d>8</d></date><time><h>11</h><m>4</m><s>9</s><f>97</f></time></when><patient-name>MUNDAY LETICIA</patient-name><description>Study of head</description><series><acquisition-datetime><date><y>2009</y><m>1</m><d>8</d></date><time><h>11</h><m>4</m><s>9</s><f>97</f></time></acquisition-datetime><description>CT HEAD/NK 5.0 B30s</description><images><image-blob-name>image blob name</image-blob-name></images></series><series><acquisition-datetime><date><y>2009</y><m>1</m><d>8</d></date><time><h>11</h><m>4</m><s>9</s><f>97</f></time></acquisition-datetime><description>FMRI BRAIN BY PHYS/PSYCH</description><images><image-blob-name>ImageBlob</image-blob-name><image-preview-blob-name>ImagePreviewBlob</image-preview-blob-name></images><images><image-blob-name>ImageBlob2</image-blob-name><image-preview-blob-name>ImagePreviewBlob2</image-preview-blob-name></images><institution-name><name>SampleHospital</name></institution-name><modality><text>MR</text></modality><body-part><text>HEAD</text></body-part><series-instance-uid>0.2.3.5.1.3.5.3.2.1</series-instance-uid></series><series><acquisition-datetime><date><y>2009</y><m>1</m><d>8</d></date><time><h>12</h><m>4</m><s>9</s><f>97</f></time></acquisition-datetime><description>FMRI BRAIN BY PHYS/PSYCH</description><images><image-blob-name>ImageBloba</image-blob-name><image-preview-blob-name>ImagePreviewBloba</image-preview-blob-name></images><images><image-blob-name>ImageBloba2</image-blob-name><image-preview-blob-name>ImagePreviewBloba2</image-preview-blob-name></images><institution-name><name>SampleHospital a</name></institution-name><modality><text>MR</text></modality><body-part><text>HEAD</text></body-part><series-instance-uid>0.2.3.5.1.3.5.3.2.1</series-instance-uid></series><reason><text>mass</text><code><value>Value</value><family>Family</family><type>type</type><version>version</version></code></reason><study-instance-uid>0.2.3.5.1.3.5.3.2.1</study-instance-uid><referring-physician><name><full>Benjamin Pierce</full></name></referring-physician><accession-number>some value</accession-number></medical-image-study>";
             
             context(@"Deserialize", ^
                     {
                         it(@"should deserialize correctly", ^
                            {
                                MHVMedicalImageStudy *imageStudy = (MHVMedicalImageStudy*)[XReader newFromString:objectDefinition withRoot:[MHVMedicalImageStudy XRootElement] asClass:[MHVMedicalImageStudy class]];
                                
                                [[imageStudy.when.description should] equal:@"01/08/09 11:04 AM"];
                                [[imageStudy.patientName.description should] equal:@"MUNDAY LETICIA"];
                                [[imageStudy.descriptionText.description should] equal:@"Study of head"];
                                [[theValue(imageStudy.series.count) should] equal:theValue(3)];
                                
                                MHVMedicalImageStudySeries *series = [imageStudy.series objectAtIndex:1];
                                [[series.acquisitionDatetime.description should] equal:@"01/08/09 11:04 AM"];
                                [[series.descriptionText.description should] equal:@"FMRI BRAIN BY PHYS/PSYCH"];
                                [[theValue(series.images.count) should] equal:theValue(2)];
                                [[series.institutionName.description should] equal:@"SampleHospital"];
                                [[series.modality.description should] equal:@"MR"];
                                [[series.bodyPart.description should] equal:@"HEAD"];
                                
                                MHVMedicalImageStudySeriesImage *image = [series.images objectAtIndex:1];
                                [[image.imageBlobName.description should] equal:@"ImageBlob2"];
                                [[image.imagePreviewBlobName.description should] equal:@"ImagePreviewBlob2"];
                                
                                [[imageStudy.reason.description should] equal:@"mass"];
                                [[imageStudy.studyInstanceUid.description should] equal:@"0.2.3.5.1.3.5.3.2.1"];
                                [[imageStudy.referringPhysician.description should] equal:@"Benjamin Pierce"];
                                [[imageStudy.accessionNumber.description should] equal:@"some value"];
                            });
                     });
             
             context(@"Serialize", ^
                     {
                         it(@"should serialize correctly", ^
                            {
                                MHVMedicalImageStudy *imageStudy = (MHVMedicalImageStudy*)[XReader newFromString:objectDefinition withRoot:[MHVMedicalImageStudy XRootElement] asClass:[MHVMedicalImageStudy class]];
                                
                                XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                                [writer writeStartElement:[MHVMedicalImageStudy XRootElement]];
                                [imageStudy serialize:writer];
                                [writer writeEndElement];
                                
                                NSString *result = [writer newXmlString];
                                
                                [[result should] equal:objectDefinition];
                            });
                     });
         });

SPEC_END
