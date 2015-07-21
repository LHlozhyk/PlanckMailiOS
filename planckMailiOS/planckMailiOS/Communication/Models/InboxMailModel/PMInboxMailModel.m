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

@end
