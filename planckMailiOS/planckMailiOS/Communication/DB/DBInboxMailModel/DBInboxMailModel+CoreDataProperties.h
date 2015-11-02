//
//  DBInboxMailModel+CoreDataProperties.h
//  planckMailiOS
//
//  Created by nazar on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBInboxMailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBInboxMailModel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *lastMessageTimestamp;
@property (nullable, nonatomic, retain) NSString *messageId;
@property (nullable, nonatomic, retain) NSString *subject;
@property (nullable, nonatomic, retain) NSString *owner_name;
@property (nullable, nonatomic, retain) NSString *snippet;
@property (nullable, nonatomic, retain) NSNumber *follow_up;
@property (nullable, nonatomic, retain) NSDate *lastMessageDate;
@property (nullable, nonatomic, retain) NSNumber *version;
@property (nullable, nonatomic, retain) NSNumber *isUnread;
@property (nullable, nonatomic, retain) NSNumber *isLoadMore;
@property (nullable, nonatomic, retain) NSString *token;
@property (nullable, nonatomic, retain) NSString *namespaceId;
@property (nullable, nonatomic, retain) DBNamespace *accountId;
@property (nullable, nonatomic, retain) NSSet<DBInboxMailModel *> *labels;

@end

@interface DBInboxMailModel (CoreDataGeneratedAccessors)

- (void)addLabelsObject:(DBInboxMailModel *)value;
- (void)removeLabelsObject:(DBInboxMailModel *)value;
- (void)addLabels:(NSSet<DBInboxMailModel *> *)values;
- (void)removeLabels:(NSSet<DBInboxMailModel *> *)values;

@end

NS_ASSUME_NONNULL_END
