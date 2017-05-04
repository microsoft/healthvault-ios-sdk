//
//  MHVHttpTransport.h
//  MHVLib
//

#import <Foundation/Foundation.h>

@protocol MHVHttpTransport <NSObject>

-(NSURLConnection *)sendRequestForURL: (NSString *)url
                             withData: (NSString *)data
                              context: (NSObject *)context
                               target: (NSObject *)target
                             callBack: (SEL)callBack;

@end

@interface MHVHttpTransport : NSObject <MHVHttpTransport>

@end
