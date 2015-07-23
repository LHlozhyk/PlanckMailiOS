//
//  PMRequest.m
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMRequest.h"
#import "Config.h"

@implementation PMRequest

+ (NSString *)loginWithAppId:(NSString *)appId
                       mail:(NSString *)mail
                redirectUri:(NSString *)uri {
    
    return [NSString stringWithFormat:@"%@/oauth/authorize?client_id=%@&response_type=token&login_hint=%@&redirect_uri=%@", APP_SERVER_LINK, appId, mail, uri];
}

+ (NSString *)namespaces {
    return [NSString stringWithFormat:@"%@/n", APP_SERVER_LINK];
}

+ (NSString *)inboxMailWithNamespaceId:(NSString*)namespaceId limit:(NSUInteger)limit offset:(NSUInteger)offset {
    return [NSString stringWithFormat:@"%@/n/%@/threads?tag=inbox&limit=%lu&offset=%lu", APP_SERVER_LINK, namespaceId, (unsigned long)limit, (unsigned long)offset];
}

+ (NSString *)messageId:(NSString *)messageId namespacesId:(NSString *)namespacesId {
    return [NSString stringWithFormat:@"%@/n/%@/messages?thread_id=%@", APP_SERVER_LINK, namespacesId, messageId];
}

+ (NSString *)searchMailWithKeyword:(NSString *)keyword namespacesId:(NSString *)namespacesId {
    return [NSString stringWithFormat:@"%@/n/%@/threads?any_email=%@", APP_SERVER_LINK, namespacesId, keyword];
}

+ (NSString *)deleteMailWithThreadId:(NSString *)threadId namespacesId:(NSString *)namespacesId {
    return [NSString stringWithFormat:@"%@/n/%@/threads/%@", APP_SERVER_LINK, namespacesId, threadId];
}

+ (NSString *)replyMessageWithNamespacesId:(NSString *)namespacesId {
    return [NSString stringWithFormat:@"%@/n/%@/send", APP_SERVER_LINK, namespacesId];
}

+ (NSString *)draftMessageWithNamespacesId:(NSString *)namespacesId {
    return [NSString stringWithFormat:@"%@/n/%@/drafts", APP_SERVER_LINK, namespacesId];
}

@end
