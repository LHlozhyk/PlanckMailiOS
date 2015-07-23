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

- (void)getDetailWithMessageId:(NSString *)messageId
                  namespacesId:(NSString *)namespacesId
                    completion:(ExtendedBlockHandler)handle;

- (void)searchMailWithKeyword:(NSString *)keyword
                 namespacesId:(NSString *)namespacesId
                   completion:(ExtendedBlockHandler)handler;

- (void)deleteMailWithThreadId:(NSString *)threadId
                  namespacesId:(NSString *)namespacesId
                    completion:(ExtendedBlockHandler)handler;

- (void)archiveMailWithThreadId:(NSString *)threadId
                   namespacesId:(NSString *)namespacesId
                     completion:(ExtendedBlockHandler)handler;

- (void)getDetailWithMessageId:(NSString *)messageId
                  namespacesId:(NSString *)namespacesId
                        unread:(BOOL)unread
                    completion:(ExtendedBlockHandler)handler;

- (void)replyMessage:(NSDictionary *)message
          completion:(ExtendedBlockHandler)handler;

- (void)createDrafts:(NSDictionary *)draftParams
          completion:(ExtendedBlockHandler)handler;

- (void)setActiveNamespace:(DBNamespace *)item;

@property (nonatomic, readonly) NSString *namespaceId;
@property (nonatomic, readonly) NSString *emailAddress;

@end
