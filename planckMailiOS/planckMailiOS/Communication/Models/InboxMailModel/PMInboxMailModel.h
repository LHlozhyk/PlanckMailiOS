//
//  PMInboxMailModel.h
//  planckMailiOS
//
//  Created by admin on 5/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMInboxMailModel : NSObject <NSSecureCoding>
@property(nonatomic, copy) NSString *ownerName;
@property(nonatomic, copy) NSString *snippet;
@property(nonatomic, copy) NSString *subject;
@property(nonatomic, copy) NSString *messageId;
@property(nonatomic, copy) NSString *namespaceId;
@property(nonatomic, copy) NSString *lastMessageTimestamp;
@property(nonatomic, copy) NSDate *lastMessageDate;
@property(nonatomic, assign) NSUInteger version;
@property(nonatomic) BOOL isUnread;
@property(nonatomic) BOOL isLoadMore;
@end
