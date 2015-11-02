//
//  DBInboxMailModel.m
//  planckMailiOS
//
//  Created by nazar on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "DBInboxMailModel.h"
#import "DBNamespace.h"
#import "DBManager.h"

#define DB_MailModel @"DBInboxMailModel"

@implementation DBInboxMailModel



// Insert code here to add functionality to your managed object subclass

+ (DBInboxMailModel*)createNewMailModelFromDictionary:(NSDictionary*)item {
    
    
    DBManager *lDBManager = [DBManager instance];
  DBInboxMailModel *lDBInboxModel = (DBInboxMailModel *)[NSEntityDescription insertNewObjectForEntityForName:DB_MailModel inManagedObjectContext:lDBManager.managedObjectContext];
    
    lDBInboxModel.snippet = item[@"snippet"];
    lDBInboxModel.subject = item[@"subject"];
    lDBInboxModel.namespaceId = item[@"namespace_id"];
    lDBInboxModel.messageId = item[@"id"];
    lDBInboxModel.version = item[@"version"];
    lDBInboxModel.labels = nil;
    lDBInboxModel.isUnread = @(NO);
    lDBInboxModel.follow_up = @(YES);
    
    NSTimeInterval lastTimeStamp = [item[@"last_message_timestamp"] doubleValue];
    lDBInboxModel.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastTimeStamp];
    
    NSArray *lTagsArray = item[@"tags"];
    
    for (NSDictionary *itemTag in lTagsArray) {
        if ([itemTag[@"id"] isEqualToString:@"unread"]) {
            lDBInboxModel.isUnread = @(YES);
        }
    }
    
    
    [[DBManager instance] save];
    
    return lDBInboxModel;
}



@end
