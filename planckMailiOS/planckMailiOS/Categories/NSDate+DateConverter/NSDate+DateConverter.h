//
//  NSDate+DateConverter.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/16/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DateConverter)

- (NSString *)convertedStringValue;

- (NSString *)timeStringValue;
- (NSString *)dateStringValue;

+ (NSDate *)eventDateFromString:(NSString *)string;
+ (NSDate *)eventDateFromString:(NSString *)string dateFormat:(NSString*)dateFormat;

@end
