//
//  HVUITypeViewDataSource.h
//  HVUISampleLib
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
#import "HVLib.h"

@interface HVUITypeViewDataSource : NSObject<UITableViewDataSource, HVTypeViewDelegate>
{
    UITableView* m_table;
    HVTypeView* m_typeView;
    NSString* m_headerText;
}

@property (readwrite, nonatomic, weak) UITableView* table;
@property (readonly, nonatomic) HVTypeView* typeView;

-(id) initWithRecord:(HVRecordReference *) record andTypeID:(NSString *) typeID;
-(id) initWithTypeView:(HVTypeView *) typeView;

//-----------
//
// Override these methods
//
//------------
-(UITableViewCell *) tableView:(UITableView *) table cellForRow:(NSUInteger) row withItem:(HVItem *) item;
-(UITableViewCell *) tableView:(UITableView *)table cellForPendingRow:(NSUInteger)row;

@end
