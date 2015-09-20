//
//  PMAPIManager.m
//  planckMailiOS
//
//  Created by Admin on 5/10/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMAPIManager.h"
#import "OPDataLoader.h"
#import "PMRequest.h"
#import "PMInboxMailModel.h"
#import "PMNetworkManager.h"


#define TOKEN @"namespaces"

@interface PMAPIManager ()
@property(nonatomic, strong) PMNetworkManager *networkManager;
@end

@implementation PMAPIManager

#pragma mark - static methods

+ (PMAPIManager *)shared {
    static PMAPIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [PMAPIManager new];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _networkManager = [PMNetworkManager sharedPMNetworkManager];
    }
    return self;
}

#pragma mark - pablic methods

- (void)saveNamespaceIdFromToken:(NSString *)token completion:(BasicBlockHandler)handler {
    SAVE_VALUE(token, TOKEN);
    
    [_networkManager setCurrentToken:token];
    [_networkManager GET:@"/n" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"saveNamespaceIdFromToken-  stask - %@  / response - %@", task, responseObject);
        
        NSArray *lResponse = responseObject;
        
        if (lResponse.count > 0) {
            NSDictionary *lFirstItem = [lResponse objectAtIndex:0];
            DBNamespace *lNewNamespace = [DBManager createNewNamespace];
            
            lNewNamespace.id = lFirstItem[@"id"];
            lNewNamespace.account_id = lFirstItem[@"account_id"];
            lNewNamespace.email_address = lFirstItem[@"email_address"];
            lNewNamespace.name = lFirstItem[@"name"];
            lNewNamespace.namespace_id = lFirstItem[@"namespace_id"];
            
            NSLog(@"namespace id - %@", lFirstItem[@"namespace_id"]);
            
            lNewNamespace.object = lFirstItem[@"object"];
            lNewNamespace.provider = lFirstItem[@"provider"];
            lNewNamespace.token = token;
            [[DBManager instance] save];
            
            [_networkManager GET:@"/messages" parameters:@{@"unread":@"true", @"view":@"count"} success:^(NSURLSessionDataTask *task, id responseObject) {
                NSLog(@"unread count-  stask - %@  / response - %@", task, responseObject);
                lNewNamespace.unreadCount = responseObject[@"count"];
                
                [self saveToken:token andEmail:lNewNamespace.email_address completion:^(id error, BOOL success) {
                    handler(nil, YES);
                }];
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"unread count - ftask - %@  / error - %@", task, error);
            }];
            
            
            
        } else {
            handler(nil, NO);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"saveNamespaceIdFromToken - ftask - %@  / error - %@", task, error);
    }];
}

- (void)getMailsWithAccount:(id<PMAccountProtocol>)account limit:(NSUInteger)limit offset:(NSUInteger)offset filter:(NSString*)filter completion:(ExtendedBlockHandler)handler {
    
    
    NSDictionary *lParameters = @{@"in" : filter,
                                  @"limit" : @(limit),
                                  @"offset" : @(offset)
                                  };
    
    [_networkManager setCurrentToken:account.token];
    [_networkManager GET:@"/threads" parameters:lParameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"getInboxMailWithAccount-  stask - %@  / response - %@", task, responseObject);
        
        NSMutableArray *lResultItems = [NSMutableArray new];
        NSArray *lResponse = responseObject;
        for (NSDictionary *item in lResponse) {
            
            PMInboxMailModel *lNewItem = [PMInboxMailModel new];
            lNewItem.snippet = item[@"snippet"];
            lNewItem.subject = item[@"subject"];
            lNewItem.namespaceId = item[@"namespace_id"];
            lNewItem.messageId = item[@"id"];
            lNewItem.version = [item[@"version"] unsignedIntegerValue];
            lNewItem.labels = item[@"labels"];
            lNewItem.isUnread = NO;
            lNewItem.token = account.token;
            
            NSArray *participants = item[@"participants"];
            
            for (NSDictionary *user in participants) {
                if (![user[@"email"] isEqualToString:_emailAddress]) {
                    lNewItem.ownerName = user[@"name"];
                    break;
                }
            }
            
            NSTimeInterval lastTimeStamp = [item[@"last_message_timestamp"] doubleValue];
            lNewItem.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastTimeStamp];
            
            NSArray *lTagsArray =  item[@"tags"];
            
            for (NSDictionary *itemTag in lTagsArray) {
                if ([itemTag[@"id"] isEqualToString:@"unread"]) {
                    lNewItem.isUnread = YES;
                }
            }
            
            [lResultItems addObject:lNewItem];
        }
        handler(lResultItems, nil, YES);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getInboxMailWithAccount - ftask - %@  / error - %@", task, error);
    }];
}


- (void)getInboxMailWithAccount:(id<PMAccountProtocol>)account limit:(NSUInteger)limit offset:(NSUInteger)offset completion:(ExtendedBlockHandler)handler {
    
    
    NSDictionary *lParameters = @{@"in" : @"inbox",
                                  @"limit" : @(limit),
                                  @"offset" : @(offset)
                                  };
    
    [_networkManager setCurrentToken:account.token];
    [_networkManager GET:@"/threads" parameters:lParameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"getInboxMailWithAccount-  stask - %@  / response - %@", task, responseObject);
        
        NSMutableArray *lResultItems = [NSMutableArray new];
        NSArray *lResponse = responseObject;
        for (NSDictionary *item in lResponse) {
            
            PMInboxMailModel *lNewItem = [PMInboxMailModel new];
            lNewItem.snippet = item[@"snippet"];
            lNewItem.subject = item[@"subject"];
            lNewItem.namespaceId = item[@"namespace_id"];
            lNewItem.messageId = item[@"id"];
            lNewItem.version = [item[@"version"] unsignedIntegerValue];
            lNewItem.labels = item[@"labels"];
            lNewItem.isUnread = NO;
            lNewItem.token = account.token;
            
            NSArray *participants = item[@"participants"];
            
            for (NSDictionary *user in participants) {
                if (![user[@"email"] isEqualToString:_emailAddress]) {
                    lNewItem.ownerName = user[@"name"];
                    break;
                }
            }
            
            NSTimeInterval lastTimeStamp = [item[@"last_message_timestamp"] doubleValue];
            lNewItem.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastTimeStamp];
            
            NSArray *lTagsArray =  item[@"tags"];
            
            for (NSDictionary *itemTag in lTagsArray) {
                if ([itemTag[@"id"] isEqualToString:@"unread"]) {
                    lNewItem.isUnread = YES;
                }
            }
            
            [lResultItems addObject:lNewItem];
        }
        handler(lResultItems, nil, YES);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getInboxMailWithAccount - ftask - %@  / error - %@", task, error);
    }];
}

- (void)getReadLaterMailWithAccount:(id<PMAccountProtocol>)account
                              limit:(NSUInteger)limit
                             offset:(NSUInteger)offset
                         completion:(ExtendedBlockHandler)handler{
    NSDictionary *lParameters = @{@"in" : @"Read Later",
                                  @"limit" : @(limit),
                                  @"offset" : @(offset)
                                  };
    
    [_networkManager setCurrentToken:account.token];
    [_networkManager GET:@"/threads" parameters:lParameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"getInboxMailWithAccount-  stask - %@  / response - %@", task, responseObject);
        
        NSMutableArray *lResultItems = [NSMutableArray new];
        NSArray *lResponse = responseObject;
        for (NSDictionary *item in lResponse) {
            
            PMInboxMailModel *lNewItem = [PMInboxMailModel new];
            lNewItem.snippet = item[@"snippet"];
            lNewItem.subject = item[@"subject"];
            lNewItem.namespaceId = item[@"namespace_id"];
            lNewItem.messageId = item[@"id"];
            lNewItem.version = [item[@"version"] unsignedIntegerValue];
            lNewItem.labels = item[@"labels"];
            lNewItem.isUnread = NO;
            lNewItem.token = account.token;
            
            NSArray *participants = item[@"participants"];
            
            for (NSDictionary *user in participants) {
                if (![user[@"email"] isEqualToString:_emailAddress]) {
                    lNewItem.ownerName = user[@"name"];
                    break;
                }
            }
            
            NSTimeInterval lastTimeStamp = [item[@"last_message_timestamp"] doubleValue];
            lNewItem.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastTimeStamp];
            
            NSArray *lTagsArray =  item[@"tags"];
            
            for (NSDictionary *itemTag in lTagsArray) {
                if ([itemTag[@"id"] isEqualToString:@"unread"]) {
                    lNewItem.isUnread = YES;
                }
            }
            
            [lResultItems addObject:lNewItem];
        }
        handler(lResultItems, nil, YES);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getInboxMailWithAccount - ftask - %@  / error - %@", task, error);
    }];
}

- (void)getDetailWithMessageId:(NSString *)messageId account:(id<PMAccountProtocol>)account unread:(BOOL)unread completion:(ExtendedBlockHandler)handler {
    
    NSDictionary *lParameters = @{@"thread_id" : messageId};
    
    [_networkManager setCurrentToken:account.token];
    [_networkManager GET:[NSString stringWithFormat:@"/n/%@/messages", account.namespace_id] parameters:lParameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"getDetailWithMessageId-  stask - %@  / response - %@", task, responseObject);
        
        NSArray *lResponse = responseObject;
        
        if (unread) {
            [_networkManager PUT:[PMRequest deleteMailWithThreadId:messageId namespacesId:account.namespace_id] parameters:@{@"remove_tags":@[@"unread"]} success:^(NSURLSessionDataTask *task, id responseObject) {
                NSLog(@"deleteMailWithThreadId-  stask - %@  / response - %@", task, responseObject);
                handler(lResponse,nil,YES);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"deleteMailWithThreadId - ftask - %@  / error - %@", task, error);
            }];
        } else {
            handler(lResponse,nil,YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getDetailWithMessageId - ftask - %@  / error - %@", task, error);
    }];
}

- (void)searchMailWithKeyword:(NSString *)keyword account:(id<PMAccountProtocol>)account completion:(ExtendedBlockHandler)handler {
    
    [_networkManager setCurrentToken:account.token];
    [_networkManager GET:[NSString stringWithFormat:@"/n/%@/threads/search", account.namespace_id] parameters:@{@"q" : keyword} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"getDetailWithMessageId-  stask - %@  / response - %@", task, responseObject);
        
        NSArray *lResponse = responseObject;
        
        NSMutableArray *lResultItems = [NSMutableArray new];
        for (NSDictionary *item in lResponse) {
            
            PMInboxMailModel *lNewItem = [PMInboxMailModel new];
            lNewItem.ownerName = [item[@"participants"] firstObject][@"name"];
            lNewItem.snippet = item[@"snippet"];
            lNewItem.subject = item[@"subject"];
            lNewItem.namespaceId = item[@"namespace_id"];
            lNewItem.messageId = item[@"id"];
            lNewItem.isUnread = NO;
            
            NSArray *lTagsArray =  item[@"tags"];
            
            for (NSDictionary *itemTag in lTagsArray) {
                if ([itemTag[@"id"] isEqualToString:@"unread"]) {
                    lNewItem.isUnread = YES;
                }
            }
            [lResultItems addObject:lNewItem];
        }
        handler(lResultItems, nil, YES);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getDetailWithMessageId - ftask - %@  / error - %@", task, error);
    }];
}

- (void)deleteMailWithThreadId:(NSString *)threadId account:(id<PMAccountProtocol>)account completion:(ExtendedBlockHandler)handler {
    [_networkManager setCurrentToken:account.token];
    [_networkManager PUT:[PMRequest deleteMailWithThreadId:threadId namespacesId:account.namespace_id] parameters:@{@"add_tags":@[@"trash"]} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"deleteMailWithThreadId-  stask - %@  / response - %@", task, responseObject);
        handler(responseObject, nil, YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getDetailWithMessageId - ftask - %@  / error - %@", task, error);
        handler(nil, error, NO);
    }];
}

- (void)archiveMailWithThreadId:(NSString *)threadId account:(id<PMAccountProtocol>)account completion:(ExtendedBlockHandler)handler{
    [_networkManager setCurrentToken:account.token];
    [_networkManager PUT:[PMRequest deleteMailWithThreadId:threadId namespacesId:account.namespace_id] parameters:@{@"add_tags":@[@"archive"]} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"archiveMailWithThreadId-  stask - %@  / response - %@", task, responseObject);
        handler(responseObject, nil, YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"archiveMailWithThreadId - ftask - %@  / error - %@", task, error);
        handler(nil, error, NO);
    }];
}

- (void)replyMessage:(NSDictionary *)message completion:(ExtendedBlockHandler)handler {
    [_networkManager POST:[PMRequest replyMessageWithNamespacesId:self.namespaceId.namespace_id] parameters:message success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"replyMessage-  stask - %@  / response - %@", task, responseObject);
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"replyMessage - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}

- (void)createDrafts:(NSDictionary *)draftParams completion:(ExtendedBlockHandler)handler {
    [_networkManager POST:[PMRequest draftMessageWithNamespacesId:self.namespaceId.namespace_id] parameters:draftParams success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"createDrafts-  stask - %@  / response - %@", task, responseObject);
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"createDrafts - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}

- (void)setActiveNamespace:(DBNamespace *)item {
    SAVE_VALUE(item.token, TOKEN);
    _namespaceId = item;
    _emailAddress = [item.email_address copy];
}

- (void)getUnreadCountForNamespaseToken:(NSString *)token completion:(ExtendedBlockHandler)handler {
    
    [_networkManager setCurrentToken:token];
    [_networkManager GET:[PMRequest unreadMessagesCount] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"getUnreadCountForNamespaseToken -  stask - %@  / response - %@", task, responseObject);
        
        NSNumber *result = nil;
        if(responseObject) {
            result = [NSNumber numberWithInteger:[responseObject[@"count"] integerValue]];
        }
        if(handler) {
            handler(result, nil, YES);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, error, NO);
        }
        NSLog(@"getUnreadCountForNamespaseToken - ftask - %@  / error - %@", task, error);
    }];
}

- (void)getFoldersWithAccount:(id<PMAccountProtocol>)account comlpetion:(ExtendedBlockHandler)handler {
    [_networkManager setCurrentToken:account.token];
    [_networkManager GET:[PMRequest foldersWithNamespaceId:account.namespace_id folderId:nil] parameters:nil success:^ (NSURLSessionDataTask *task, id responseObjet) {
        
    } failure:^ (NSURLSessionDataTask * task, NSError *error) {
        
    }];

}

- (void)createFolderWithName:(NSString *)folderName
                     account:(id<PMAccountProtocol>)account
                  comlpetion:(ExtendedBlockHandler)handler{
    
    NSDictionary *lParams = @{@"display_name":folderName};
    [_networkManager setCurrentToken:account.token];
    [_networkManager POST:[PMRequest foldersWithNamespaceId:account.namespace_id folderId:nil] parameters:lParams success:^ (NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^ (NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
}

- (void)renameFolderWithName:(NSString *)newFolderName
                     account:(id<PMAccountProtocol>)account
                    folderId:(NSString *)folderId
                  comlpetion:(ExtendedBlockHandler)handler {
    
    NSDictionary *lParams = @{@"display_name":newFolderName};
    [_networkManager setCurrentToken:account.token];
    [_networkManager PUT:[PMRequest foldersWithNamespaceId:account.namespace_id folderId:folderId] parameters:lParams success:^ (NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^ (NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)getCalendarsWithAccount:(id<PMAccountProtocol>)account comlpetion:(ExtendedBlockHandler)handler {
    [_networkManager setCurrentToken:account.token];
    [_networkManager GET:@"/calendars" parameters:nil success:^ (NSURLSessionDataTask *task, id responseObjet) {
        NSLog(@"getCalendarsWithAccount - %@", responseObjet);
    } failure:^ (NSURLSessionDataTask * task, NSError *error) {
        
    }];
}

#pragma mark - Private methods

// Sourav API

- (void)saveToken:(NSString *)token andEmail:(NSString*)email completion:(BasicBlockHandler)handler {
    AFHTTPSessionManager *lNewSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://token-store-dev.elasticbeanstalk.com/server/"]];
    lNewSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [lNewSessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    email = [email stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSDictionary *lParams = @{@"email_id" : email,
                              @"token" : token,
                              @"access_token" : @"planck_test"
                              };
    
    [lNewSessionManager POST:@"save_token" parameters:lParams success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"saveToken -  stask - %@  / response - %@", task, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        if(handler) {
            handler(nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, NO);
        }
        NSLog(@"saveToken - ftask - %@  / error - %@", task, error);
    }];
}

- (void)getTokenWithEmail:(NSString *)email completion:(BasicBlockHandler)handler {
    AFHTTPSessionManager *lNewSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://token-store-dev.elasticbeanstalk.com/server/"]];
    lNewSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [lNewSessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    email = [email stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSDictionary *lParams = @{@"email_id" : email,
                              @"access_token" : @"planck_test"
                              };
    
    [lNewSessionManager POST:@"get_token" parameters:lParams success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"getTokenWithEmail -  stask - %@  / response - %@", task, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        if(handler) {
            handler(nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, NO);
        }
        NSLog(@"getTokenWithEmail - ftask - %@  / error - %@", task, error);
    }];
}

- (void)deleteTokenWithEmail:(NSString *)email completion:(BasicBlockHandler)handler {
    AFHTTPSessionManager *lNewSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://token-store-dev.elasticbeanstalk.com/server/"]];
    lNewSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [lNewSessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    email = [email stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSDictionary *lParams = @{@"email_id" : email,
                              @"access_token" : @"planck_test"
                              };
    
    [lNewSessionManager POST:@"delete_token" parameters:lParams success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"deleteTokenWithEmail -  stask - %@  / response - %@", task, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        if(handler) {
            handler(nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, NO);
        }
        NSLog(@"deleteTokenWithEmail - ftask - %@  / error - %@", task, error);
    }];
}


@end
