//
//  HVItemRaw.m
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

#import "HVCommon.h"
#import "HVItemRaw.h"

@implementation HVItemRaw

@synthesize xml = m_xml;

-(BOOL)hasRawData
{
    return TRUE;
}

-(void) dealloc
{
    [m_root release];
    [m_xml release];
    
    [super dealloc];
}

-(NSString *)rootElement
{
    return m_root;
}

-(void) serialize:(XWriter *)writer
{
    if (m_xml)
    {
        [writer writeRaw:m_xml];
    }
}

-(void) deserialize:(XReader *)reader
{
    m_root = [reader.localName retain];
    m_xml = [[reader readElementRaw:m_root] retain];
}

@end
