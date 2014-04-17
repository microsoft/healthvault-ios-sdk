//
//  HVHttpTransport.h
//  HVLib
//

#import <Foundation/Foundation.h>

@protocol HVHttpTransport <NSObject>

-(NSURLConnection *)sendRequestForURL: (NSString *)url
                             withData: (NSString *)data
                              context: (NSObject *)context
                               target: (NSObject *)target
                             callBack: (SEL)callBack;

@end

@interface HVHttpTransport : NSObject <HVHttpTransport>

@end
