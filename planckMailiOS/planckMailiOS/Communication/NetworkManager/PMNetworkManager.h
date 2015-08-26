//
//  PMNetworkManager.h
//  planckMailiOS
//
//  Created by admin on 8/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

typedef void (^SuccessHandler)(AFHTTPRequestOperation *operation, id responseData);
typedef void (^FailureHandler)(AFHTTPRequestOperation *operation, NSError *error);

@interface PMNetworkManager : NSObject

@property (nonatomic,copy)NSString *token;

- (void)GET:(NSString *)urlString success:(SuccessHandler)success failure:(FailureHandler)failure;
- (void)PUT:(NSString *)urlString JSONParameters:(NSDictionary *)jsonDictionary success:(SuccessHandler)success failure:(FailureHandler)failure;

- (NSMutableURLRequest *)requestWithURL:(NSURL *)url
                             HTTPMethod:(NSString *)httpMethod
                             HTTPHeader:(NSDictionary *)header
                               HTTPBody:(NSData *)body;
- (void)startLoadWithRequest:(NSURLRequest *)request success:(SuccessHandler)success failure:(FailureHandler)failure;


@end
