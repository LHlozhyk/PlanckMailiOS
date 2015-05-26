//
//  PMAPIManager.h
//  planckMailiOS
//
//  Created by Admin on 5/10/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMRequest.h"
#import "DBManager.h"

typedef void (^BasicBlockHandler)(id error, BOOL success);
typedef void (^ExtendedBlockHandler)(id data, id error, BOOL success);

@interface PMAPIManager : NSObject
+ (PMAPIManager *)shared;

- (void)saveNamespaceIdFromToken:(NSString *)token completion:(BasicBlockHandler)handler;

- (void)getInboxMailWithNamespaceId:(NSString*)namespaceId
                              limit:(NSUInteger)limit
                             offset:(NSUInteger)offset
                         completion:(ExtendedBlockHandler)handler;

- (void)setActiveNamespace:(DBNamespace*)item;

@end
