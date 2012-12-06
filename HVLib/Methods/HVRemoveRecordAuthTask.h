//
//  HVRemoveRecordAuthTask.h
//  HVLib
//
//  Created by Umesh Madan on 12/4/12.
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HVMethodCallTask.h"
#import "HVRecordReference.h"

@interface HVRemoveRecordAuthTask : HVMethodCallTask

-(id) initWithRecord:(HVRecordReference *) record andCallback:(HVTaskCompletion) callback;

@end
