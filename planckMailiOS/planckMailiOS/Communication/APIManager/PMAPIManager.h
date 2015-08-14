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
#import "PMAccountProtocol.h"

typedef void (^BasicBlockHandler)(id error, BOOL success);
typedef void (^ExtendedBlockHandler)(id data, id error, BOOL success);

@interface PMAPIManager : NSObject

+ (PMAPIManager *)shared;

- (void)saveNamespaceIdFromToken:(NSString *)token completion:(BasicBlockHandler)handler;

- (void)getInboxMailWithAccount:(id<PMAccountProtocol>)account
                              limit:(NSUInteger)limit
                             offset:(NSUInteger)offset
                         completion:(ExtendedBlockHandler)handler;

//- (void)getDetailWithMessageId:(NSString *)messageId
//                  account:(id<PMAccountProtocol>)account
//                    completion:(ExtendedBlockHandler)handle;

- (void)searchMailWithKeyword:(NSString *)keyword
                      account:(id<PMAccountProtocol>)account
                   completion:(ExtendedBlockHandler)handler;

- (void)deleteMailWithThreadId:(NSString *)threadId
                       account:(id<PMAccountProtocol>)account
                    completion:(ExtendedBlockHandler)handler;

- (void)archiveMailWithThreadId:(NSString *)threadId
                        account:(id<PMAccountProtocol>)account
                     completion:(ExtendedBlockHandler)handler;

- (void)getDetailWithMessageId:(NSString *)messageId
                       account:(id<PMAccountProtocol>)account
                        unread:(BOOL)unread
                    completion:(ExtendedBlockHandler)handler;

- (void)replyMessage:(NSDictionary *)message
          completion:(ExtendedBlockHandler)handler;

- (void)createDrafts:(NSDictionary *)draftParams
          completion:(ExtendedBlockHandler)handler;

- (void)setActiveNamespace:(DBNamespace *)item;

@property (nonatomic, readonly) DBNamespace *namespaceId;
@property (nonatomic, readonly) NSString *emailAddress;

@end
