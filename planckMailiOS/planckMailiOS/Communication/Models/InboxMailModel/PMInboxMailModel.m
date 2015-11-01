//
//  PMInboxMailModel.m
//  planckMailiOS
//
//  Created by admin on 5/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMInboxMailModel.h"
#import "Config.h"

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

+ (PMInboxMailModel *)initWithDicationary:(NSDictionary *)item {
    PMInboxMailModel *lNewItem = [PMInboxMailModel new];
    lNewItem.snippet = item[@"snippet"];
    lNewItem.subject = item[@"subject"];
    lNewItem.namespaceId = item[@"namespace_id"];
    lNewItem.messageId = item[@"id"];
    lNewItem.version = [item[@"version"] unsignedIntegerValue];
    lNewItem.labels = item[@"labels"];
    lNewItem.folders = item[@"folders"];
    lNewItem.isUnread = NO;
    
    NSTimeInterval lastTimeStamp = [item[@"last_message_timestamp"] doubleValue];
    lNewItem.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastTimeStamp];
    
    NSArray *lTagsArray =  item[@"tags"];
    
    for (NSDictionary *itemTag in lTagsArray) {
        if ([itemTag[@"id"] isEqualToString:@"unread"]) {
            lNewItem.isUnread = YES;
        }
    }
    
    return lNewItem;
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
    [aCoder encodeObject:_folders forKey:@"folders"];
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
    newMail.folders = [aDecoder decodeObjectForKey:@"folders"];
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

- (NSString *)sentLabelID {
    NSString *labelID = nil;
    
    if(self.labels) {
        for(NSDictionary *labelObj in self.labels) {
            if([labelObj[@"name"] isEqualToString:LABEL_SENT]) {
                labelID = labelObj[@"id"];
                break;
            }
        }
    }
    
    return labelID;
}

@end
