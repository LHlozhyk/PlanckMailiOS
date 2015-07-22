//
//  PMInboxMailModel.m
//  planckMailiOS
//
//  Created by admin on 5/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMInboxMailModel.h"

@implementation PMInboxMailModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _ownerName = @"";
        _snippet = @"";
        _subject = @"";
        _namespaceId = @"";
        _messageId = @"";
        _lastMessageTimestamp = @"";
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
  return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:_ownerName forKey:@"ownerName"];
  [aCoder encodeObject:_snippet forKey:@"snippet"];
  [aCoder encodeObject:_subject forKey:@"subject"];
  [aCoder encodeObject:_messageId forKey:@"messageId"];
  [aCoder encodeObject:_namespaceId forKey:@"namespaceId"];
  [aCoder encodeBool:_isUnread forKey:@"isUnread"];
  [aCoder encodeObject:_firstMessageDate forKey:@"firstMessageDate"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  PMInboxMailModel *newMail = [PMInboxMailModel new];
  
  newMail.ownerName = [aDecoder decodeObjectForKey:@"ownerName"];
  newMail.snippet = [aDecoder decodeObjectForKey:@"snippet"];
  newMail.subject = [aDecoder decodeObjectForKey:@"subject"];
  newMail.messageId = [aDecoder decodeObjectForKey:@"messageId"];
  newMail.namespaceId = [aDecoder decodeObjectForKey:@"namespaceId"];
  newMail.isUnread = [aDecoder decodeBoolForKey:@"isUnread"];
  newMail.firstMessageDate = [aDecoder decodeObjectForKey:@"firstMessageDate"];
  
  return newMail;
}

@end
