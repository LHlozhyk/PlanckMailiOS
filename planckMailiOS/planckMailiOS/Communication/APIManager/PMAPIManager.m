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

#define TOKEN @"namespaces"

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

#pragma mark - pablic methods

- (void)saveNamespaceIdFromToken:(NSString *)token completion:(BasicBlockHandler)handler {
    SAVE_VALUE(token, TOKEN);
    
    OPDataLoader *lDataLoader = [OPDataLoader new];
    [lDataLoader loadUrlWithGETMethod:[PMRequest namespaces] handler:^(NSData *loadData, NSError *error, BOOL success) {
        NSString *response = [[NSString alloc] initWithData:loadData encoding:NSUTF8StringEncoding];
        NSLog(@"User ID is   %@ in - %s", response, __PRETTY_FUNCTION__);
        
        NSError *errorJson = nil;
        NSData *objectData = [response dataUsingEncoding:NSASCIIStringEncoding];
        NSArray *lResponse = [NSJSONSerialization JSONObjectWithData:objectData options:0 error:&errorJson];
        
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
            
            handler(nil, YES);
        } else {
            handler(nil, NO);
        }
    }];
}

- (void)getInboxMailWithNamespaceId:(NSString*)namespaceId limit:(NSUInteger)limit offset:(NSUInteger)offset completion:(ExtendedBlockHandler)handler {
    
    OPDataLoader *lDataLoader = [OPDataLoader new];
    [lDataLoader loadUrlWithGETMethod:[PMRequest inboxMailWithNamespaceId:namespaceId limit:limit offset:offset] handler:^(NSData *loadData, NSError *error, BOOL success) {
        NSString *response = [[NSString alloc] initWithData:loadData encoding:NSUTF8StringEncoding];
        NSLog(@"User ID is   %@ in - %s", response, __PRETTY_FUNCTION__);
        
        NSError *errorJson = nil;
        NSData *objectData = [response dataUsingEncoding:NSASCIIStringEncoding];
        NSArray *lResponse = [NSJSONSerialization JSONObjectWithData:objectData options:0 error:&errorJson];
        
        NSMutableArray *lResultItems = [NSMutableArray new];
        for (NSDictionary *item in lResponse) {
            
            PMInboxMailModel *lNewItem = [PMInboxMailModel new];
            lNewItem.snippet = item[@"snippet"];
            lNewItem.subject = item[@"subject"];
            lNewItem.namespaceId = item[@"namespace_id"];
            lNewItem.messageId = item[@"id"];
            lNewItem.version = [item[@"version"] unsignedIntegerValue];
            lNewItem.isUnread = NO;
          
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
    }];
}

- (void)getDetailWithMessageId:(NSString *)messageId namespacesId:(NSString *)namespacesId unread:(BOOL)unread completion:(ExtendedBlockHandler)handler {
    
        OPDataLoader *lDataLoader = [OPDataLoader new];
        [lDataLoader loadUrlWithGETMethod:[PMRequest messageId:messageId namespacesId:namespacesId]  handler:^(NSData *loadData, NSError *error, BOOL success) {
            
            NSString *response = [[NSString alloc] initWithData:loadData encoding:NSUTF8StringEncoding];
            NSError *errorJson = nil;
            NSData *objectData = [response dataUsingEncoding:NSASCIIStringEncoding];
            NSDictionary *lResponse = [NSJSONSerialization JSONObjectWithData:objectData options:0 error:&errorJson];

            if (success && unread) {
                OPDataLoader *lLoadUnred = [OPDataLoader new];
                [lLoadUnred loadUrlWithPUTMethod:[PMRequest deleteMailWithThreadId:messageId namespacesId:namespacesId] JSONParameters:@{@"remove_tags":@[@"unread"]} handler:^(NSData *loadData, NSError *error, BOOL success) {
                    handler(lResponse, error, success);
                }];
            } else {
                handler(lResponse, error, success);
            }
        }];
}

- (void)searchMailWithKeyword:(NSString *)keyword namespacesId:(NSString *)namespacesId completion:(ExtendedBlockHandler)handler {
    OPDataLoader *lDataLoader = [OPDataLoader new];
    [lDataLoader loadUrlWithGETMethod:[PMRequest searchMailWithKeyword:keyword namespacesId:namespacesId]  handler:^(NSData *loadData, NSError *error, BOOL success) {
        NSString *response = [[NSString alloc] initWithData:loadData encoding:NSUTF8StringEncoding];
        NSLog(@"User ID is   %@ in - %s", response, __PRETTY_FUNCTION__);
        
        NSError *errorJson = nil;
        NSData *objectData = [response dataUsingEncoding:NSASCIIStringEncoding];
        NSArray *lResponse = [NSJSONSerialization JSONObjectWithData:objectData options:0 error:&errorJson];
        
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
    }];
}

- (void)deleteMailWithThreadId:(NSString *)threadId namespacesId:(NSString *)namespacesId completion:(ExtendedBlockHandler)handler {
    OPDataLoader *lDataLoader = [OPDataLoader new];
    [lDataLoader loadUrlWithPUTMethod:[PMRequest deleteMailWithThreadId:threadId namespacesId:namespacesId] JSONParameters:@{@"add_tags":@[@"trash"]} handler:^(NSData *loadData, NSError *error, BOOL success) {
        NSString *response = [[NSString alloc] initWithData:loadData encoding:NSUTF8StringEncoding];
        NSError *errorJson = nil;
        NSData *objectData = [response dataUsingEncoding:NSASCIIStringEncoding];
        NSDictionary *lResponse = [NSJSONSerialization JSONObjectWithData:objectData options:0 error:&errorJson];
        handler(lResponse, error, success);
    }];
}

- (void)archiveMailWithThreadId:(NSString *)threadId namespacesId:(NSString *)namespacesId completion:(ExtendedBlockHandler)handler {
    OPDataLoader *lDataLoader = [OPDataLoader new];
    [lDataLoader loadUrlWithPUTMethod:[PMRequest deleteMailWithThreadId:threadId namespacesId:namespacesId] JSONParameters:@{@"add_tags":@[@"archive"]} handler:^(NSData *loadData, NSError *error, BOOL success) {
        NSString *response = [[NSString alloc] initWithData:loadData encoding:NSUTF8StringEncoding];
        NSError *errorJson = nil;
        NSData *objectData = [response dataUsingEncoding:NSASCIIStringEncoding];
        NSDictionary *lResponse = [NSJSONSerialization JSONObjectWithData:objectData options:0 error:&errorJson];
        handler(lResponse, error, success);
    }];
}

- (void)replyMessage:(NSDictionary *)message completion:(ExtendedBlockHandler)handler {
    OPDataLoader *lDataLoader = [OPDataLoader new];
    [lDataLoader loadUrlWithPOSTMethod:[PMRequest replyMessageWithNamespacesId:self.namespaceId] JSONParameters:message handler:^(NSData *loadData, NSError *error, BOOL success) {
      if(handler) {
        handler(nil, error, success);
      }
    }];
}

- (void)setActiveNamespace:(DBNamespace *)item {
    SAVE_VALUE(item.token, TOKEN);
    _namespaceId = item.namespace_id;
    _emailAddress = [item.email_address copy];
}

#pragma mark - Private methods

@end
