//
//  MHVStatusLabel.m
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

#import "MHVStatusLabel.h"

@interface MHVStatusLabel ()

@property (nonatomic, strong) UIActivityIndicatorView *activity;

@end

@implementation MHVStatusLabel

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        CGRect frame = self.frame;
        float side = frame.size.height;  // We'll size the spinner so it is a square as tall as this label
        
        if (self.textAlignment == NSTextAlignmentRight)
        {
            frame.origin.x = 0;
        }
        else
        {
            frame.origin.x = frame.size.width - side;
        }
        frame.origin.y = 0;
        frame.size.width = side;
        frame.size.height = side;

        [self addSubview:_activity];
    }
    
    return self;
}

- (void)showStatus:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    NSLogv(format, args);
    NSString* message = [[NSString alloc] initWithFormat:format arguments:args];
    
    va_end(args);
    
    self.text = message;
    
    [self hideActivity];
}

- (void)clearStatus
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
    {
        self.text = nil;
        [self hideActivity];
    }];
}

- (void)showActivity
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
    {
        [self.activity setHidden:FALSE];
        [self.activity startAnimating];
    }];
    
}

- (void)hideActivity
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
    {
        if (self.activity)
        {
            [self.activity stopAnimating];
            [self.activity setHidden:TRUE];
        }
    }];
}

- (void)showBusy
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
    {
        [self showStatus:@"Working. Please wait..."];
        [self showActivity];
    }];
}

@end
