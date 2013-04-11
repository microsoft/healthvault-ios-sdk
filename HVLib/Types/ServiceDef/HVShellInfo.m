//
//  HVShellInfo.m
//  HVLib
//
//  Created by Umesh Madan on 4/10/13.
//  Copyright (c) 2013 Microsoft Corporation. All rights reserved.
//

#import "HVCommon.h"
#import "HVShellInfo.h"


static const xmlChar* x_element_url = XMLSTRINGCONST("url");
static const xmlChar* x_element_redirect = XMLSTRINGCONST("redirect-url");

@implementation HVShellInfo

@synthesize url = m_url;
@synthesize redirectUrl = m_redirectUrl;

-(void)dealloc
{
    [m_url release];
    [m_redirectUrl release];
    [super dealloc];
}

-(void)deserialize:(XReader *)reader
{
    HVDESERIALIZE_STRING_X(m_url, x_element_url);
    HVDESERIALIZE_STRING_X(m_redirectUrl, x_element_redirect);
}

-(void)serialize:(XWriter *)writer
{
    HVSERIALIZE_STRING_X(m_url, x_element_url);
    HVSERIALIZE_STRING_X(m_redirectUrl, x_element_redirect);
}

@end
