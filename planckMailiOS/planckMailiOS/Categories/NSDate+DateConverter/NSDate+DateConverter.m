//
//  NSDate+DateConverter.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/16/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#define SecondsPerDay 86400
#define DaysPerYear 365

#import "NSDate+DateConverter.h"

@implementation NSDate (DateConverter)

#pragma mark - Public methods

- (NSString *)convertedStringValue {
  NSString *convertedValue = @"";
  
  NSString *dateFormaterString = @"";
  NSLocale *locale = [NSLocale currentLocale];
  NSInteger days = [self daysBetween:[NSDate date]];
  if(days == 0) {
    dateFormaterString = [NSDateFormatter dateFormatFromTemplate:@"hh:mm a" options:0 locale:locale];
  } else if (days < DaysPerYear) {
    dateFormaterString = [NSDateFormatter dateFormatFromTemplate:@"MMM dd" options:0 locale:locale];
  } else {
    dateFormaterString = [NSDateFormatter dateFormatFromTemplate:@"MMM dd, yyy" options:0 locale:locale];
  }
  
  NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
  [dateFormater setDateFormat:dateFormaterString];
  convertedValue = [dateFormater stringFromDate:self];
  
  return convertedValue;
}

- (NSString *)timeStringValue {
    NSString *convertedValue = [self stringDateForDateFormat:@"hh:mm a"];
    return convertedValue;
}

- (NSString *)dateStringValue {
    NSString *convertedValue = [self stringDateForDateFormat:@"YYYY-MM-dd"];
    return convertedValue;
}

+ (NSDate *)eventDateFromString:(NSString *)string {
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"YYYY-MM-dd"];
    
    NSDate *date = [dateFormater dateFromString:string];
    return date;
}

#pragma mark - Private methods

- (NSUInteger)daysBetween:(NSDate *)date {
  NSDate *dt1 = [self dateWithoutTimeComponents];
  NSDate *dt2 = [date dateWithoutTimeComponents];
  return ABS([dt1 timeIntervalSinceDate:dt2] / SecondsPerDay);
}

- (NSComparisonResult)timelessCompare:(NSDate *)date {
  NSDate *dt1 = [self dateWithoutTimeComponents];
  NSDate *dt2 = [date dateWithoutTimeComponents];
  return [dt1 compare:dt2];
}

- (NSDate *)dateWithoutTimeComponents {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *components = [calendar components:NSCalendarUnitYear  |
                                  NSCalendarUnitMonth |
                                  NSCalendarUnitDay
                                             fromDate:self];
  return [calendar dateFromComponents:components];
}

- (NSString *)stringDateForDateFormat:(NSString *)dateFormat {
    NSString *convertedValue = @"";
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:dateFormat];
    convertedValue = [dateFormater stringFromDate:self];
    
    return convertedValue;
}

@end
