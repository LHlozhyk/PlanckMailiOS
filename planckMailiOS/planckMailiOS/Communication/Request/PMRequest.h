//
//  PMRequest.h
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMRequest : NSObject
+ (NSString*)loginWithAppId:(NSString*)appId
                       mail:(NSString *)mail
                redirectUri:(NSString *)uri;

+ (NSString*)namespaces;

+ (NSString *)inboxMailWithNamespaceId:(NSString*)namespaceId
                                 limit:(NSUInteger)limit
                                offset:(NSUInteger)offset;

+ (NSString *)messageId:(NSString *)messageId
           namespacesId:(NSString *)namespacesId;

@end
