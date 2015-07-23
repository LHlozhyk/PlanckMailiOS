//
//  WKEmailRow.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/14/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKEmailRow.h"
#import "NSDate+DateConverter.h"
#import "PMInboxMailModel.h"

@interface WKEmailRow ()

@property (weak, nonatomic) IBOutlet WKInterfaceImage *unreadIndicator;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *subjectLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *dateLabel;

@end

@implementation WKEmailRow

- (void)setEmailContainer:(PMInboxMailModel *)emailContainer {
  [self.titleLabel setText:emailContainer.ownerName];
  [self.subjectLabel setText:emailContainer.subject];
  [self.dateLabel setText:[emailContainer.lastMessageDate convertedStringValue]];
  
  [self.unreadIndicator setHidden:!emailContainer.isUnread];
}

@end
