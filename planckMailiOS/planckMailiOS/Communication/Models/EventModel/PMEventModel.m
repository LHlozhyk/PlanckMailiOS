//
//  PMEventModel.m
//  planckMailiOS
//
//  Created by admin on 9/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMEventModel.h"
#import "PMParticipantModel.h"
#import "NSDate+DateConverter.h"

@interface PMEventModel ()
- (id)whenEventTakePlaceParams;
- (id)partisipantsParams;
- (EventDateType)eventTypeForObject:(NSString *)object;
@end

@implementation PMEventModel

- (instancetype)initWithDictionary:(NSDictionary *)eventDictionary {
    self = [super init];
    if(self) {
        
        //event info
        self.title = stringValue(eventDictionary[@"title"]);
        self.location = stringValue(eventDictionary[@"location"]);
        self.calendarId = eventDictionary[@"calendar_id"];
        self.eventDescription = stringValue(eventDictionary[@"description"]);
        self.owner = stringValue(eventDictionary[@"owner"]);
        
        _readonly = [eventDictionary[@"read_only"] boolValue];
        
        //init event participants
        NSMutableArray *participantsModels = [NSMutableArray new];
        NSArray *participants = eventDictionary[@"participants"];
        if ([participants count] > 0) {
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

- (instancetype)init {
    self = [super init];
    if (self) {
        [self defaultInit];
    }
    return self;
}

- (void)defaultInit {
    self.title = @"";
    self.location = @"";
    self.calendarId = @"";
    self.eventDescription = @"";
    self.owner = @"";
    self.participants = @[];
    self.eventDateType = EventDateTimespanType;
    self.alertTime = nil;
    _readonly = NO;
}

#pragma mark - Public methods

- (NSDictionary *)getEventParams {
    return @{
             @"title" :_title,
             @"description" : _eventDescription,
             @"when" : [self whenEventTakePlaceParams],
             @"location" : _location,
             @"calendar_id" : _calendarId,
             @"participants" : [self partisipantsParams],
             @"owner" : _owner
             };
}

#pragma mark - Private methods

- (EventDateType)eventTypeForObject:(NSString *)object {
    EventDateType eventDateType = EventDateDateType;
    
    if ([object isEqualToString:@"time"]) {
        eventDateType = EventDateTimeType;
    } else if ([object isEqualToString:@"timespan"]) {
        eventDateType = EventDateTimespanType;
    } else if ([object isEqualToString:@"datespan"]) {
        eventDateType = EventDateDatespanType;
    }
    
    return eventDateType;
}

- (id)whenEventTakePlaceParams {
    return @{
             @"start_time" : [NSString stringWithFormat:@"%f", [[NSDate eventDateFromString:_startTime dateFormat:@"dd MMM. yyyy HH:mm"] timeIntervalSince1970]],
             @"end_time" : [NSString stringWithFormat:@"%f", [[NSDate eventDateFromString:_endTime dateFormat:@"dd MMM. yyyy HH:mm"] timeIntervalSince1970]]
             };
}

- (id)partisipantsParams {
    return @[
             @{
                 @"email": @"lyubomyr.hlozhyk@gmail.com",
                 @"name": @"Lyubomyr Hlozhyk",
                 @"status" : @"yes"
                 }
             ];
}

@end
