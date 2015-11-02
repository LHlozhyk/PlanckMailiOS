//
//  DBInboxMailModel+CoreDataProperties.m
//  planckMailiOS
//
//  Created by nazar on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBInboxMailModel+CoreDataProperties.h"

@implementation DBInboxMailModel (CoreDataProperties)

@dynamic lastMessageTimestamp;
@dynamic messageId;
@dynamic subject;
@dynamic owner_name;
@dynamic snippet;
@dynamic follow_up;
@dynamic lastMessageDate;
@dynamic version;
@dynamic isUnread;
@dynamic isLoadMore;
@dynamic token;
@dynamic namespaceId;
@dynamic accountId;
@dynamic labels;

@end
