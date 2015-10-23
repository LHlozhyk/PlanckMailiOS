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
#import "PMEventModel.h"
#import "PMStorageManager.h"

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
        DLog(@"saveNamespaceIdFromToken-  stask - %@  / response - %@", task, responseObject);
        
        NSArray *lResponse = responseObject;
        
        if (lResponse.count > 0) {
            NSDictionary *lFirstItem = [lResponse objectAtIndex:0];
            DBNamespace *lNewNamespace = [DBManager createNewNamespace];
            
            lNewNamespace.id = lFirstItem[@"id"];
            lNewNamespace.account_id = lFirstItem[@"account_id"];
            lNewNamespace.email_address = lFirstItem[@"email_address"];
            lNewNamespace.name = lFirstItem[@"name"];
            lNewNamespace.namespace_id = lFirstItem[@"namespace_id"];
            
            DLog(@"namespace id - %@", lFirstItem[@"namespace_id"]);
            
            lNewNamespace.object = lFirstItem[@"object"];
            lNewNamespace.provider = lFirstItem[@"provider"];
            lNewNamespace.token = token;
            [[DBManager instance] save];
            
            [_networkManager GET:@"/messages" parameters:@{@"unread":@"true", @"view":@"count"} success:^(NSURLSessionDataTask *task, id responseObject) {
                DLog(@"unread count-  stask - %@  / response - %@", task, responseObject);
                lNewNamespace.unreadCount = responseObject[@"count"];
                
                [self saveToken:token andEmail:lNewNamespace.email_address completion:^(id error, BOOL success) {
                    handler(nil, YES);
                }];
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                DLog(@"unread count - ftask - %@  / error - %@", task, error);
            }];
            
            
            
        } else {
            handler(nil, NO);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"saveNamespaceIdFromToken - ftask - %@  / error - %@", task, error);
    }];
}

- (void)getMailsWithAccount:(id<PMAccountProtocol>)account limit:(NSUInteger)limit offset:(NSUInteger)offset filter:(NSString*)filter completion:(ExtendedBlockHandler)handler {
    NSDictionary *lParameters = @{@"in" : filter,
                                  @"limit" : @(limit),
                                  @"offset" : @(offset)
                                  };
    [self getMailsWithAccount:account parameters:lParameters path:@"/threads" completion:handler];
}


- (void)getInboxMailWithAccount:(id<PMAccountProtocol>)account limit:(NSUInteger)limit offset:(NSUInteger)offset completion:(ExtendedBlockHandler)handler {
    
    
    NSDictionary *lParameters = @{@"in" : @"inbox",
                                  @"limit" : @(limit),
                                  @"offset" : @(offset)
                                  };
    [self getMailsWithAccount:account parameters:lParameters path:@"/threads" completion:handler];
}

- (void)getReadLaterMailWithAccount:(id<PMAccountProtocol>)account
                              limit:(NSUInteger)limit
                             offset:(NSUInteger)offset
                         completion:(ExtendedBlockHandler)handler{
    NSDictionary *lParameters = @{@"in" : @"READ_LATER",
                                  @"limit" : @(limit),
                                  @"offset" : @(offset)
                                  };
    [self getMailsWithAccount:account parameters:lParameters path:@"/threads" completion:handler];
}

-(void)getFollowUpsMailWithAccount:(id<PMAccountProtocol>)account
                             limit:(NSUInteger)limit
                            offset:(NSUInteger)offset
                        completion:(ExtendedBlockHandler)handler{


    NSDictionary *lParameters = @{@"in" : SCHEDULED,
                                  @"limit" : @(limit),
                                  @"offset" : @(offset)
                                  };
    [self getMailsWithAccount:account parameters:lParameters path:@"/threads" completion:handler];

}

- (void)searchMailWithKeyword:(NSString *)keyword account:(id<PMAccountProtocol>)account completion:(ExtendedBlockHandler)handler {
    
    [self getMailsWithAccount:account parameters:@{@"q" : keyword}
                         path:[NSString stringWithFormat:@"/n/%@/threads/search", account.namespace_id]
                   completion:handler];
}

- (void)getDetailWithMessageId:(NSString *)messageId account:(id<PMAccountProtocol>)account unread:(BOOL)unread completion:(ExtendedBlockHandler)handler {
    
    NSDictionary *lParameters = @{@"thread_id" : messageId};
    
    [_networkManager setCurrentToken:account.token];
    [_networkManager GET:[NSString stringWithFormat:@"/n/%@/messages", account.namespace_id] parameters:lParameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getDetailWithMessageId-  stask - %@  / response - %@", task, responseObject);
        
        NSArray *lResponse = responseObject;
        
        if (unread) {
            [_networkManager PUT:[PMRequest deleteMailWithThreadId:messageId namespacesId:account.namespace_id] parameters:@{@"remove_tags":@[@"unread"]} success:^(NSURLSessionDataTask *task, id responseObject) {
                DLog(@"deleteMailWithThreadId-  stask - %@  / response - %@", task, responseObject);
                handler(lResponse,nil,YES);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                DLog(@"deleteMailWithThreadId - ftask - %@  / error - %@", task, error);
            }];
        } else {
            handler(lResponse,nil,YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getDetailWithMessageId - ftask - %@  / error - %@", task, error);
    }];
}

- (void)deleteMailWithThreadId:(NSString *)threadId account:(id<PMAccountProtocol>)account completion:(ExtendedBlockHandler)handler {
    [_networkManager setCurrentToken:account.token];
    [_networkManager PUT:[PMRequest deleteMailWithThreadId:threadId namespacesId:account.namespace_id] parameters:@{@"add_tags":@[@"trash"]} success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"deleteMailWithThreadId-  stask - %@  / response - %@", task, responseObject);
        handler(responseObject, nil, YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getDetailWithMessageId - ftask - %@  / error - %@", task, error);
        handler(nil, error, NO);
    }];
}

- (void)archiveMailWithThreadId:(NSString *)threadId account:(id<PMAccountProtocol>)account completion:(ExtendedBlockHandler)handler{
    [_networkManager setCurrentToken:account.token];
    [_networkManager PUT:[PMRequest deleteMailWithThreadId:threadId namespacesId:account.namespace_id]
              parameters:@{@"add_tags":@[@"archive"]}
                 success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"archiveMailWithThreadId-  stask - %@  / response - %@", task, responseObject);
        handler(responseObject, nil, YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"archiveMailWithThreadId - ftask - %@  / error - %@", task, error);
        handler(nil, error, NO);
    }];
}

- (void)replyMessage:(NSDictionary *)message completion:(ExtendedBlockHandler)handler {
    [_networkManager POST:[PMRequest replyMessageWithNamespacesId:self.namespaceId.namespace_id] parameters:message success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"replyMessage-  stask - %@  / response - %@", task, responseObject);
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"replyMessage - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}

- (void)createDrafts:(NSDictionary *)draftParams completion:(ExtendedBlockHandler)handler {
    [_networkManager POST:[PMRequest draftMessageWithNamespacesId:self.namespaceId.namespace_id] parameters:draftParams success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"createDrafts-  stask - %@  / response - %@", task, responseObject);
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"createDrafts - ftask - %@  / error - %@", task, error);
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
        DLog(@"getUnreadCountForNamespaseToken -  stask - %@  / response - %@", task, responseObject);
        
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
        DLog(@"getUnreadCountForNamespaseToken - ftask - %@  / error - %@", task, error);
    }];
}

#pragma mark - Folders

- (void)getFoldersWithAccount:(id<PMAccountProtocol>)account comlpetion:(ExtendedBlockHandler)handler {
    [_networkManager setCurrentToken:account.token];
    [_networkManager GET:[PMRequest foldersWithNamespaceId:account.namespace_id folderId:nil] parameters:nil success:^ (NSURLSessionDataTask *task, id responseObject) {
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^ (NSURLSessionDataTask * task, NSError *error) {
        handler(nil, error, NO);
    }];

}

- (void)getFoldersWithAccount:(id<PMAccountProtocol>)account folderId:(NSString*)folderId comlpetion:(ExtendedBlockHandler)handler {
    [_networkManager setCurrentToken:account.token];
    [_networkManager GET:[PMRequest foldersWithNamespaceId:account.namespace_id folderId:folderId] parameters:nil success:^ (NSURLSessionDataTask *task, id responseObject) {
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^ (NSURLSessionDataTask * task, NSError *error) {
        handler(nil, error, NO);
    }];
    
}

- (void)createFolderWithName:(NSString *)folderName
                     account:(id<PMAccountProtocol>)account
                  comlpetion:(ExtendedBlockHandler)handler{
    
    NSDictionary *lParams = @{@"display_name":folderName};
    [_networkManager setCurrentToken:account.token];
    [_networkManager POST:[PMRequest foldersWithNamespaceId:account.namespace_id folderId:nil] parameters:lParams success:^ (NSURLSessionDataTask *task, id responseObject) {
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^ (NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, error, NO); 
        }
    }];
    
}

- (void)renameFolderWithName:(NSString *)newFolderName
                     account:(id<PMAccountProtocol>)account
                    folderId:(NSString *)folderId
                  comlpetion:(ExtendedBlockHandler)handler {
    
    NSDictionary *lParams = @{@"display_name":newFolderName};
    [_networkManager setCurrentToken:account.token];
    [_networkManager PUT:[PMRequest foldersWithNamespaceId:account.namespace_id folderId:folderId] parameters:lParams success:^ (NSURLSessionDataTask *task, id responseObject) {
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^ (NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}

-(void)deleteFolderWithId:(NSString*)folderId
                  account:(id<PMAccountProtocol>)account
               completion:(ExtendedBlockHandler)handler {

//    NSLog(@"iddd %@",[PMRequest foldersWithNamespaceId:account.namespace_id folderId:folderId]);
//    NSLog(@"getScheduledFolderIdForAccount");
    
    [_networkManager setCurrentToken:account.token];
    [_networkManager DELETE:[PMRequest foldersWithNamespaceId:account.namespace_id folderId:folderId] parameters:nil
                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                        if (handler) {
                            handler(responseObject, nil, YES);
                        }
                    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                        if (handler) {
                            handler(nil, error, NO);
                        }
                    }];

}

-(void)moveMailWithThreadId:(NSString*)threadId account:(id<PMAccountProtocol>)account toFolder:(NSString*)folderId {

    NSDictionary *lParameters = @{@"folder_id" : folderId};
    
    [_networkManager setCurrentToken:account.token];
    
    [_networkManager PUT:[PMRequest messageId:threadId namespacesId:account.namespace_id] parameters:lParameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"success");
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"failure");
        NSLog(@"error = %@",[error localizedDescription]);

    }];

}

#pragma mark - Calendars

- (void)getCalendarsWithAccount:(id<PMAccountProtocol>)account comlpetion:(ExtendedBlockHandler)handler {
    [_networkManager setCurrentToken:account.token];
    [_networkManager GET:@"/calendars" parameters:nil success:^ (NSURLSessionDataTask *task, id responseObjet) {
        DLog(@"getCalendarsWithAccount - %@", responseObjet);
        if(handler) {
            handler(responseObjet, nil, YES);
        }
    } failure:^ (NSURLSessionDataTask * task, NSError *error) {
        DLog(@"error: %@", error);
        if(handler) {
            handler(nil, error, YES);
        }
    }];
}

- (void)getEventsWithAccount:(id<PMAccountProtocol>)account
                 eventParams:(NSDictionary *)eventParams
                  comlpetion:(ExtendedBlockHandler)handler {
    [_networkManager setCurrentToken:account.token];
    [_networkManager GET:@"/events" parameters:eventParams success:^(NSURLSessionDataTask *task, id responseObjet) {
        DLog(@"getEventsWithAccount - %@", responseObjet);
        
        NSMutableArray *events = [NSMutableArray new];
        if([responseObjet isKindOfClass:[NSArray class]]) {
            for(NSDictionary *eventDict in responseObjet) {
                PMEventModel *eventModel = [[PMEventModel alloc] initWithDictionary:eventDict];
                [events addObject:eventModel];
            }
        }
        
        if(handler) {
            handler(events, nil, YES);
        }
    } failure:^ (NSURLSessionDataTask * task, NSError *error) {
        DLog(@"error: %@", error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}

- (void)createCalendarEventWithAccount:(id<PMAccountProtocol>)account
                             eventParams:(NSDictionary *)eventParams
                            comlpetion:(ExtendedBlockHandler)handler {
    
    [_networkManager setCurrentToken:account.token];
    [_networkManager POST:@"/events" parameters:eventParams success:^ (NSURLSessionDataTask *task, id responseObject) {
        DLog(@"createCalendarEventWithAccount - %@", responseObject);
    } failure:^ (NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)updateCalendarEventWithAccount:(id<PMAccountProtocol>)account
                           eventParams:(NSDictionary *)eventParams
                            comlpetion:(ExtendedBlockHandler)handler {
    
    [_networkManager setCurrentToken:account.token];
    [_networkManager PUT:@"/events" parameters:eventParams success:^ (NSURLSessionDataTask *task, id responseObject) {
        DLog(@"createCalendarEventWithAccount - %@", responseObject);
    } failure:^ (NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)deleteCalendarEventWithAccount:(id<PMAccountProtocol>)account
                           eventParams:(NSDictionary *)eventParams
                            comlpetion:(ExtendedBlockHandler)handler {
    
    [_networkManager setCurrentToken:account.token];
    [_networkManager DELETE:@"/events" parameters:eventParams success:^ (NSURLSessionDataTask *task, id responseObject) {
        DLog(@"createCalendarEventWithAccount - %@", responseObject);
    } failure:^ (NSURLSessionDataTask *task, NSError *error) {
        
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
        DLog(@"saveToken -  stask - %@  / response - %@", task, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        if(handler) {
            handler(nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, NO);
        }
        DLog(@"saveToken - ftask - %@  / error - %@", task, error);
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
        DLog(@"getTokenWithEmail -  stask - %@  / response - %@", task, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        if(handler) {
            handler(nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, NO);
        }
        DLog(@"getTokenWithEmail - ftask - %@  / error - %@", task, error);
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
        DLog(@"deleteTokenWithEmail -  stask - %@  / response - %@", task, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        if(handler) {
            handler(nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, NO);
        }
        DLog(@"deleteTokenWithEmail - ftask - %@  / error - %@", task, error);
    }];
}

- (void)getMailsWithAccount:(id<PMAccountProtocol>)account parameters:(NSDictionary *)parameters path:(NSString *)path completion:(ExtendedBlockHandler)handler {
    NSString *namespace_id = [account namespace_id];
    [_networkManager setCurrentToken:account.token];
    
    [_networkManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getInboxMailWithAccount-  stask - %@  / response - %@", task, responseObject);
        
        NSMutableArray *lResultItems = [NSMutableArray new];
        NSArray *lResponse = responseObject;
        for (NSDictionary *item in lResponse) {
            PMInboxMailModel *lNewItem = [PMInboxMailModel initWithDicationary:item];
            lNewItem.namespace_id = lNewItem.namespace_id?:namespace_id;
            lNewItem.token = account.token;
            
            NSArray *participants = item[@"participants"];
            
            for (NSDictionary *user in participants) {
                if (![user[@"email"] isEqualToString:_emailAddress]) {
                    lNewItem.ownerName = user[@"name"];
                    break;
                }
            }
            
            [lResultItems addObject:lNewItem];
        }
        if(handler) {
            handler(lResultItems, nil, YES);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getInboxMailWithAccount - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}

@end
