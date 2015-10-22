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
- (void)getReadLaterMailWithAccount:(id<PMAccountProtocol>)account
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

- (void)getUnreadCountForNamespaseToken:(NSString *)token completion:(ExtendedBlockHandler)handler;
- (void)getUnreadMessagesForNamespaseToken:(NSString *)token completion:(ExtendedBlockHandler)handler;

//folders
- (void)getFoldersWithAccount:(id<PMAccountProtocol>)account
                   comlpetion:(ExtendedBlockHandler)handler;

- (void)createFolderWithName:(NSString *)folderName
                     account:(id<PMAccountProtocol>)account
                  comlpetion:(ExtendedBlockHandler)handler;

- (void)renameFolderWithName:(NSString *)newFolderName
                     account:(id<PMAccountProtocol>)account
                    folderId:(NSString *)folderId
                  comlpetion:(ExtendedBlockHandler)handler;
//----

- (void)deleteTokenWithEmail:(NSString *)email
                  completion:(BasicBlockHandler)handler;

- (void)getMailsWithAccount:(id<PMAccountProtocol>)account
                      limit:(NSUInteger)limit
                     offset:(NSUInteger)offset
                     filter:(NSString*)filter
                 completion:(ExtendedBlockHandler)handler;

// Calendar methods

- (void)getCalendarsWithAccount:(id<PMAccountProtocol>)account
                     comlpetion:(ExtendedBlockHandler)handler;

- (void)getEventsWithAccount:(id<PMAccountProtocol>)account
                 eventParams:(NSDictionary *)eventParams
                  comlpetion:(ExtendedBlockHandler)handler;

- (void)createCalendarEventWithAccount:(id<PMAccountProtocol>)account
                           eventParams:(NSDictionary *)eventParams
                            comlpetion:(ExtendedBlockHandler)handler;

- (void)deleteCalendarEventWithAccount:(id<PMAccountProtocol>)account
                           eventParams:(NSDictionary *)eventParams
                            comlpetion:(ExtendedBlockHandler)handler;

- (void)updateCalendarEventWithAccount:(id<PMAccountProtocol>)account
                           eventParams:(NSDictionary *)eventParams
                            comlpetion:(ExtendedBlockHandler)handler;

@property (nonatomic, readonly) DBNamespace *namespaceId;
@property (nonatomic, readonly) NSString *emailAddress;

@end
