//
//  MHVViewController.h
//  TableViewWithSynchronizedType
//
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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
//

#import <UIKit/UIKit.h>
#import "MHVLib.h"

@interface MHVWeightTypeDataSource : HVSynchronizedTypeDataSource

@end

@interface MHVViewController : HVUITaskAwareViewController
{
    MHVSynchronizedType* m_type;
    HVSynchronizedTypeDataSource* m_dataSource;
    MHVItemCommitScheduler* m_commitScheduler;
}

@property (weak, nonatomic) IBOutlet UITableView *itemTable;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

-(void) showStatus:(NSString *) text;

- (IBAction)addNew:(id)sender;
- (IBAction)synchronize:(id)sender;
- (IBAction)deleteItem:(id)sender;
- (IBAction)updateItem:(id)sender;

- (IBAction)deleteLocalItems:(id)sender;

@end
