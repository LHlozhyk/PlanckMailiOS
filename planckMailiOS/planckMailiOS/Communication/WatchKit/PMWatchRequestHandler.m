//
//  PMWatchRequestHandler.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMWatchRequestHandler.h"
#import "AppDelegate.h"
#import "WatchKitDefines.h"
#import "DBManager.h"
#import "PMTypeContainer.h"
#import "PMAPIManager.h"
#import "PMInboxMailModel.h"
#import "CLContactLibrary.h"
#import <MessageUI/MessageUI.h>

@interface PMWatchRequestHandler () <APContactLibraryDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, copy) void (^replyBlock)(NSDictionary *);

@end

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
                reply(result);
              }
            }];
        }
            
            break;
        
        case PMWatchRequestGetContacts: {
          self.replyBlock = reply;
          
          [[CLContactLibrary sharedInstance] getContactArrayForDelegate:self];
        }
          
          break;
        
      case PMWatchRequestCall: {
        if([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
          reply(nil);
          return;
        }
        
        NSString *lPhoneString = [NSString stringWithFormat:@"%@%@", @"tel://", userInfo[WK_REQUEST_INFO][WK_REQUEST_PHONE]];
        NSString *urlString = [lPhoneString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *lUrl = [[NSURL alloc] initWithString:urlString];
        [[UIApplication sharedApplication] openURL:lUrl];
      }
        
        break;
        
      case PMWatchRequestSendSMS: {
        if([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
          reply(nil);
          return;
        }
        
        self.replyBlock = reply;
        NSDictionary *info = userInfo[WK_REQUEST_INFO];
        
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
          controller.body = info[WK_REQUEST_MESSAGE];
          controller.recipients = [NSArray arrayWithObjects:info[WK_REQUEST_PHONE], nil];
          controller.messageComposeDelegate = self;
          [((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController presentViewController:controller animated:YES completion:^{
            
          }];
        }
      }
        
      case PMWatchRequestGetUnreadEmailsCount: {
        NSString *token = userInfo[WK_REQUEST_INFO];
        if(token) {
          [[PMAPIManager shared] getUnreadCountForNamespaseToken:token completion:^(id data, id error, BOOL success) {
            NSDictionary *result = nil;
            if(!error && data) {
              result = @{WK_REQUEST_RESPONSE: data};
            }
            if(reply) {
              reply(result);
            }
          }];
        }
      }
        break;
        
      case PMWatchRequestGetUnreadEmails: {
        
      }
        break;
        
        break;
        
        default:
            break;
    }
}

#pragma mark - APContactLibraryDelegate

- (void)apGetContactArray:(NSArray *)contactArray {
    NSMutableArray *personsArray = nil;
    NSDictionary *response = nil;
    
    if(contactArray) {
        personsArray = [NSMutableArray new];
        for(CLPerson *person in contactArray) {
            [personsArray addObject:[NSKeyedArchiver archivedDataWithRootObject:person]];
        }
        
        response = @{WK_REQUEST_RESPONSE: personsArray};
    }
    
    _replyBlock(response);
}

- (BOOL)shouldScaleImage {
    return YES;
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
  [controller dismissViewControllerAnimated:YES completion:nil];
  
  BOOL status = (result == MessageComposeResultSent);
  _replyBlock(@{WK_REQUEST_RESPONSE: [NSNumber numberWithBool:status]});
}

@end
