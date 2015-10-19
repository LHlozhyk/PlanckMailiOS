//
//  PMEventModel.m
//  planckMailiOS
//
//  Created by admin on 9/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMEventModel.h"
#import "PMParticipantModel.h"

@implementation PMEventModel


- (instancetype)initWithDictionary:(NSDictionary *)eventDictionary {
    self = [super init];
    if(self) {
        
        //event info
        self.title = stringValue(eventDictionary[@"title"]);
        self.location = stringValue(eventDictionary[@"location"]);
        self.calendarId = eventDictionary[@"calendar_id"];
        self.eventDescription = stringValue(eventDictionary[@"description"]);
        self.owner = eventDictionary[@"owner"];
        
        _readonly = [eventDictionary[@"read_only"] boolValue];
        
        //init event participants
        NSMutableArray *participantsModels = [NSMutableArray new];
        NSArray *participants = eventDictionary[@"participants"];
        if([participants count] > 0) {
            for(NSDictionary *participant in participants) {
                PMParticipantModel *participantModel = [[PMParticipantModel alloc] initWithDictionary:participant];
                [participantsModels addObject:participantModel];
            }
        }
        self.participants = participantsModels;
        
        //event date or time
        NSDictionary *whenDict = eventDictionary[@"when"];
        self.eventDateType = [self eventTypeForObject:whenDict[@"object"]];
        
        switch (_eventDateType) {
            case EventDateTimeType:
                self.startTime = [whenDict[@"time"] stringValue];
                self.endTime = [whenDict[@"time"] stringValue];
                
                break;
                
            case EventDateTimespanType:
                self.startTime = [whenDict[@"start_time"] stringValue];
                self.endTime = [whenDict[@"end_time"] stringValue];
                
                break;
                
            case EventDateDateType:
                self.startTime = whenDict[@"date"];
                self.endTime = whenDict[@"date"];
                
                break;
                
            case EventDateDatespanType:
                self.startTime = whenDict[@"start_date"];
                self.endTime = whenDict[@"end_date"];
                
                break;
                
            default:
                break;
        }
    }
    return self;
}

- (EventDateType)eventTypeForObject:(NSString *)object {
    EventDateType eventDateType = EventDateDateType;
    
    if([object isEqualToString:@"time"]) {
        eventDateType = EventDateTimeType;
    } else if([object isEqualToString:@"timespan"]) {
        eventDateType = EventDateTimespanType;
    } else if([object isEqualToString:@"datespan"]) {
        eventDateType = EventDateDatespanType;
    }
    
    return eventDateType;
}

- (NSDictionary*)getEventParams {
    return @{};
}

@end
