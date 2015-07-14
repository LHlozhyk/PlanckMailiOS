//
//  WKEmailRow.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/14/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKEmailRow.h"
#import "PMEmailContainer.h"

@interface WKEmailRow ()

@property (weak, nonatomic) IBOutlet WKInterfaceImage *unreadIndicator;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *subjectLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *dateLabel;

@end

@implementation WKEmailRow

- (void)setEmailContainer:(PMEmailContainer *)emailContainer {
  [self.titleLabel setText:emailContainer.title];
  [self.subjectLabel setText:emailContainer.subject];
  [self.dateLabel setText:[NSString stringWithFormat:@"%@", emailContainer.date]];
  
  [self.unreadIndicator setHidden:!emailContainer.isUnread];
}

@end
