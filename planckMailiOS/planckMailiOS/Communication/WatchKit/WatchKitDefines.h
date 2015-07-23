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
#define WK_REQUEST_RESPONSE @"wk_request_response"

typedef NS_ENUM(NSInteger, PMWatchRequestType) {
  PMWatchRequestAccounts,
  PMWatchRequestGetEmails,
  PMWatchRequestGetEmailDetails,
  PMWatchRequestReply
};

#endif
