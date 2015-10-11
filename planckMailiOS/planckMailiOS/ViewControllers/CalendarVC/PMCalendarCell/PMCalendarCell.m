//
//  PMCalendarCell.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 9/22/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMCalendarCell.h"
#import "PMEventModel.h"
#import "NSDate+DateConverter.h"

@interface PMCalendarCell ()

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;

@end

@implementation PMCalendarCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEvent:(PMEventModel *)event {
    _titleLabel.text = event.title;
    _locationLabel.text = event.location;
    
    NSString *timeText = @"";
    
    switch (event.eventDateType) {
        case EventDateTimeType: {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[event.startTime doubleValue]];
            timeText = [date timeStringValue];
        }
            break;
            
        case EventDateTimespanType: {
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[event.startTime doubleValue]];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[event.endTime doubleValue]];
            timeText = [NSString stringWithFormat:@"%@\n%@", [startDate timeStringValue], [endDate timeStringValue]];
        }
            
            break;
            
        case EventDateDateType: {
            NSDate *date = [NSDate eventDateFromString:event.startTime];
            timeText = [date dateStringValue];
        }
            break;
            
        case EventDateDatespanType: {
            NSDate *startDate = [NSDate eventDateFromString:event.startTime];
            NSDate *endDate = [NSDate eventDateFromString:event.endTime];
            timeText = [NSString stringWithFormat:@"%@\n%@", [startDate dateStringValue], [endDate dateStringValue]];
        }

            break;
            
        default:
            break;
    }
    NSLog(@"time text - %@", timeText);
    _timeLabel.text = timeText;
}

@end
