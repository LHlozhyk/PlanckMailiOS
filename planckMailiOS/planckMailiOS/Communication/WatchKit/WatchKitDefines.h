//
//  WatchKitDefines.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/17/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#ifndef planckMailiOS_WatchKitDefines_h
#define planckMailiOS_WatchKitDefines_h

#import <Foundation/Foundation.h>

#define WK_REQUEST_TYPE @"wk_request_type"
#define WK_REQUEST_INFO @"wk_request_info"
#define WK_REQUEST_EMAILS_LIMIT @"wk_request_emails_limit"
#define WK_REQUEST_RESPONSE @"wk_request_response"

#define LIST_CONTROLLER_IDENTIFIER @"emailListController"
#define TITLE @"title"
#define CONTENT @"content"
#define ADDITIONAL_INFO @"additional_info"

#define LIMIT_COUNT 10

typedef NS_ENUM(NSInteger, PMWatchRequestType) {
  PMWatchRequestAccounts,
  PMWatchRequestGetEmails,
  PMWatchRequestGetEmailDetails,
  PMWatchRequestReply,
  PMWatchRequestGetContacts
};

#endif
