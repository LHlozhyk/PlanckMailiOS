//
//  PMTypeContainer.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/14/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMTypeContainer.h"

@implementation PMTypeContainer

+ (instancetype)initWithTitle:(NSString *)title count:(NSInteger)count {
  PMTypeContainer *newType = [[PMTypeContainer alloc] init];
  newType.title = title;
  newType.unreadCount = count;
  return newType;
}

@end
