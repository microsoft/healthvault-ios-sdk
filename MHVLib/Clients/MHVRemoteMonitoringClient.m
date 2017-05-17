//
// MHVRemoteMonitoringClient.m
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
//

#import <Foundation/Foundation.h>
#import "MHVRemoteMonitoringClient.h"
#import "MHVClient.h"
#import "MHVJsonSerializer.h"

@implementation MHVRemoteMonitoringClient

+ (NSURLSessionTask*) requestWithPath:(NSString* _Nonnull)path
                               method:(NSString* _Nonnull)method
                           pathParams:(NSDictionary * _Nullable)pathParams
                          queryParams:(NSDictionary* _Nullable)queryParams
                           formParams:(NSDictionary * _Nullable)formParams
                                 body:(id _Nullable)body
                              toClass:(Class)toClass
                      completionBlock:(void (^ _Nonnull)(id _Nullable output, NSError * _Nullable error))completionBlock
{
    if (pathParams != nil) {
        NSMutableString * queryPath = [NSMutableString stringWithString:path];
        [pathParams enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [queryPath replaceCharactersInRange:[queryPath rangeOfString:[NSString stringWithFormat:@"{%@}", key]] withString:obj];
        }];
        
        path = [queryPath toString];
    }
    
    NSString *endpoint = [NSString stringWithFormat:@"https://hvc-prerel-khvwus01.westus2.cloudapp.azure.com%@", path];
    
    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    headers[@"Authorization"] = @"TOKEN";
     
    [[MHVClient current].service.httpService sendRequestForURL:url body:nil headers:headers completion:^(MHVHttpServiceResponse * _Nullable response, NSError * _Nullable error)
    {
        if (!error) {
            if (!response.hasError) {
                NSString *body = response.responseAsString;
                id result = [MHVJsonSerializer deserialize:body toClass:[toClass class] shouldCache:NO];
                completionBlock(result, error);
            } else {
                completionBlock(nil, error);
            }
        } else {
            completionBlock(nil, error);
        }
     }];
    
    return nil;
}

@end;
