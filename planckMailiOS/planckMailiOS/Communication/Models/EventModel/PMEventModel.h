//
//  PMEventModel.h
//  planckMailiOS
//
//  Created by admin on 9/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EventDateType) {
    EventDateDateType,
    EventDateTimeType,
    EventDateTimespanType,
    EventDateDatespanType
};

@interface PMEventModel : NSObject
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *location;
@property(nonatomic, copy) NSString *calendarId;
@property(nonatomic, copy) NSString *startTime;
@property(nonatomic, copy) NSString *endTime;
@property(nonatomic, copy) NSString *eventDescription;
@property(nonatomic, strong) NSArray *participants;
@property(nonatomic, copy) NSString *owner;


@property(nonatomic, assign) EventDateType eventDateType;

@property(nonatomic) BOOL notifyParticipants;
@property(nonatomic, readonly) BOOL readonly;

- (instancetype)initWithDictionary:(NSDictionary *)eventDictionary;

- (NSDictionary*)getEventParams;

@end
