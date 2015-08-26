//
//  PMNetworkManager.m
//  planckMailiOS
//
//  Created by admin on 8/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMNetworkManager.h"

#define TIME_OUT 15.0f

@implementation PMNetworkManager

- (void)GET:(NSString *)urlString success:(SuccessHandler)success failure:(FailureHandler)failure{
    
    NSURLRequest *lRequest = [self requestWithURL:[NSURL URLWithString:urlString]
                                       HTTPMethod:@"GET"
                                       HTTPHeader:nil
                                         HTTPBody:nil];
    [self startLoadWithRequest:lRequest success:^(AFHTTPRequestOperation *operation, id responseData) {
        success(operation,responseData);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation,error);
    }];
}

- (void)PUT:(NSString *)urlString JSONParameters:(NSDictionary *)jsonDictionary success:(SuccessHandler)success failure:(FailureHandler)failure{

    NSError *error;
    NSData *lPostData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:&error];
    
    NSString *lRequestData = [[NSString alloc] initWithData:lPostData encoding:NSUTF8StringEncoding];
    NSString *lPostLength = [NSString stringWithFormat:@"%lu",(unsigned long)[lRequestData length]];
    
    NSURLRequest *lRequest = [self requestWithURL:[NSURL URLWithString:urlString]
                                       HTTPMethod:@"PUT"
                                       HTTPHeader:@{@"Content-Type":@"application/json",
                                                    @"Content-Length":lPostLength}
                                         HTTPBody:[lRequestData dataUsingEncoding:NSUTF8StringEncoding]];
    [self startLoadWithRequest:lRequest success:^(AFHTTPRequestOperation *operation, id responseData) {
        success(operation,responseData);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation,error);
    }];
}


#pragma mark - Private methods

- (NSMutableURLRequest *)requestWithURL:(NSURL *)url
                             HTTPMethod:(NSString *)httpMethod
                             HTTPHeader:(NSDictionary *)header
                               HTTPBody:(NSData *)body {
    NSMutableURLRequest *lNewRequest = [[NSMutableURLRequest alloc]
                                        initWithURL:url
                                        cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                        timeoutInterval:TIME_OUT];
    [lNewRequest setHTTPMethod:httpMethod];
    
    if (header) {
        for (NSString *key in header) {
            id value = [header objectForKey:key];
            [lNewRequest setValue:value forHTTPHeaderField:key];
        }
    }
    
    if (body) {
        [lNewRequest setHTTPBody:body];
    }
    
    return lNewRequest;
}

- (void)startLoadWithRequest:(NSURLRequest *)request success:(SuccessHandler)success failure:(FailureHandler)failure{

    AFHTTPRequestOperation *lOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    lOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [lOperation setWillSendRequestForAuthenticationChallengeBlock:^(NSURLConnection * connection, NSURLAuthenticationChallenge * challenge) {
        
        if ([challenge previousFailureCount] == 0) {
            NSURLCredential *lCredential = [NSURLCredential credentialWithUser:_token ? : @""
                                                                      password:@""
                                                                   persistence:NSURLCredentialPersistenceNone];
            [[challenge sender] useCredential:lCredential forAuthenticationChallenge:challenge];
        }
    }];
    
    [lOperation setCompletionBlockWithSuccess:^ (AFHTTPRequestOperation *operation, id response) {
        success(operation,response);
    } failure:^ (AFHTTPRequestOperation * operation, NSError * error) {
        failure(operation,error);
    }];
    [lOperation start];

}



@end
