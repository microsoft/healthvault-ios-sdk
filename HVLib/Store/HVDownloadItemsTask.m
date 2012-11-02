//
//  HVDownloadItemsTask.m
//  HVLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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

#import "HVCommon.h"
#import "HVDownloadItemsTask.h"

@implementation HVDownloadItemsTask

-(BOOL)didKeysDownload
{
    return ![NSArray isNilOrEmpty:m_downloadedKeys];
}

-(NSMutableArray *)downloadedKeys
{
    if (!m_downloadedKeys)
    {
        m_downloadedKeys = [[NSMutableArray alloc] init];
    }
    
    return m_downloadedKeys;
}

-(void)dealloc
{
    [m_downloadedKeys release];
    [super dealloc];
}

-(id)initWithCallback:(HVTaskCompletion)callback
{
    self = [super initWithCallback:callback];
    HVCHECK_SELF;
    
    m_downloadedKeys = [[NSMutableArray alloc] init];
    HVCHECK_NOTNULL(m_downloadedKeys);
        
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)recordItemsAsDownloaded:(HVItemCollection *)items
{
    NSMutableArray* keys = self.downloadedKeys;
    self.result = keys;
    
    for (NSUInteger i = 0, count = items.count; i < count; ++i)
    {
        [keys addObject:[items itemAtIndex:i].key];
    }
}

@end
