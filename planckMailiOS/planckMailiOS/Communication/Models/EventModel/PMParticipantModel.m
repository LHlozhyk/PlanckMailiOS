//
//  PMParticipantModel.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 9/22/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMParticipantModel.h"

@implementation PMParticipantModel

- (instancetype)initWithDictionary:(NSDictionary *)object {
    if(self = [super init]) {
        self.comment = stringValue(object[@"comment"]);
        self.email = stringValue(object[@"email"]);
        self.name = stringValue(object[@"name"]);
        self.status = stringValue(object[@"status"]);
        self.statusType = [self statusTypeForStatus:_status];
    }
    return self;
}

- (ParticipantStatuType)statusTypeForStatus:(NSString *)status {
    ParticipantStatuType statusType = ParticipantNoreplyStatus;
    
    if([status isEqualToString:@"no"]) {
        statusType = ParticipantNoStatus;
    } else if([status isEqualToString:@"maybe"]) {
        statusType = ParticipantMaybeStatus;
    } else if([status isEqualToString:@"yes"]) {
        statusType = ParticipantYesStatus;
    }
    return statusType;
}

@end
