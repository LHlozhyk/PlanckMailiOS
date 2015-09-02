//
//  PMInboxMailModel.m
//  planckMailiOS
//
//  Created by admin on 5/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMInboxMailModel.h"

@implementation PMInboxMailModel

@synthesize token;
@synthesize namespace_id;
@synthesize id;
@synthesize account_id;

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
    [aCoder encodeObject:token forKey:@"token"];
    [aCoder encodeBool:_isUnread forKey:@"isUnread"];
    [aCoder encodeObject:_lastMessageDate forKey:@"lastMessageDate"];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:_version] forKey:@"version"];
    [aCoder encodeObject:_labels forKey:@"labels"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  PMInboxMailModel *newMail = [PMInboxMailModel new];
  
    newMail.ownerName = [aDecoder decodeObjectForKey:@"ownerName"];
    newMail.snippet = [aDecoder decodeObjectForKey:@"snippet"];
    newMail.subject = [aDecoder decodeObjectForKey:@"subject"];
    newMail.messageId = [aDecoder decodeObjectForKey:@"messageId"];
    newMail.namespaceId = [aDecoder decodeObjectForKey:@"namespaceId"];
    newMail.token = [aDecoder decodeObjectForKey:@"token"];
    newMail.isUnread = [aDecoder decodeBoolForKey:@"isUnread"];
    newMail.lastMessageDate = [aDecoder decodeObjectForKey:@"lastMessageDate"];
    newMail.labels = [aDecoder decodeObjectForKey:@"labels"];
    newMail.version = [[aDecoder decodeObjectForKey:@"version"] unsignedIntegerValue];
  
  return newMail;
}

- (NSString *)namespace_id {
  return _namespaceId;
}

- (NSString *)token {
  return token;
}

- (BOOL)isReadLater{
    BOOL readLater = NO;
    for(NSDictionary *item in _labels) {
        NSString *lDisplayName = item[@"display_name"];
        if ([lDisplayName isEqualToString:@"Read Later"])  {
            readLater = YES;
        }
    }
        return readLater;
}

@end
