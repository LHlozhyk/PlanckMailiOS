//
//  PMWatchRequestHandler.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMWatchRequestHandler.h"
#import "WatchKitDefines.h"
#import "DBManager.h"
#import "PMTypeContainer.h"
#import "PMAPIManager.h"
#import "PMInboxMailModel.h"

@implementation PMWatchRequestHandler

+ (instancetype)sharedHandler {
    static PMWatchRequestHandler *sharedHandler = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedHandler = [PMWatchRequestHandler new];
    });
    return sharedHandler;
}

- (void)handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {
    NSInteger requestType = [userInfo[WK_REQUEST_TYPE] integerValue];
    
    switch (requestType) {
        case PMWatchRequestAccounts: {
            NSArray *lNamespacesArray = [[DBManager instance] getNamespaces];
            
            NSMutableArray *typesArray = [NSMutableArray new];
            for(DBNamespace *nameSpace in lNamespacesArray) {
                [typesArray addObject:[NSKeyedArchiver archivedDataWithRootObject: [PMTypeContainer initWithNameSpase:nameSpace]]];
            }
            
            if(reply) {
                reply(@{WK_REQUEST_RESPONSE: typesArray});
            }
        }
            
            break;
            
        case PMWatchRequestGetEmails: {
            if(userInfo[WK_REQUEST_INFO]) {
                PMTypeContainer *account = [NSKeyedUnarchiver unarchiveObjectWithData:userInfo[WK_REQUEST_INFO]];
                [[PMAPIManager shared] getInboxMailWithAccount:account
                                                         limit:LIMIT_COUNT
                                                        offset:[userInfo[WK_REQUEST_EMAILS_LIMIT] unsignedIntegerValue]
                                                    completion:^(NSArray *data, id error, BOOL success) {
                                                        if(reply) {
                                                            NSMutableArray *archivedEmails = [NSMutableArray new];
                                                            for(PMInboxMailModel *email in data) {
                                                                [archivedEmails addObject:[NSKeyedArchiver archivedDataWithRootObject:email]];
                                                            }
                                                            reply(@{WK_REQUEST_RESPONSE: archivedEmails});
                                                        }
                                                    }];
            }
        }
            
            break;
            
        case PMWatchRequestReply: {
            NSMutableDictionary *replyDict = [NSMutableDictionary dictionaryWithDictionary:userInfo[WK_REQUEST_INFO]];
            [[PMAPIManager shared] replyMessage:replyDict completion:^(id data, id error, BOOL success) {
                if(reply) {
                    reply(@{WK_REQUEST_RESPONSE: [NSNumber numberWithBool:success]});
                }
            }];
        }
            
            break;
            
        case PMWatchRequestGetEmailDetails: {
            PMInboxMailModel *mailModel = [NSKeyedUnarchiver unarchiveObjectWithData:userInfo[WK_REQUEST_INFO]];
          [[PMAPIManager shared] getDetailWithMessageId:mailModel.messageId
                                                account:mailModel
                                                 unread:mailModel.isUnread
                                             completion:^(id data, id error, BOOL success) {
              if(reply) {
                id result = data;
      //          if([data isKindOfClass:[NSArray class]]) {
      //            result = [data firstObject];
      //          }
                
                reply(result);
              }
            }];
        }
            
            break;
            
        default:
            break;
    }
}

@end
