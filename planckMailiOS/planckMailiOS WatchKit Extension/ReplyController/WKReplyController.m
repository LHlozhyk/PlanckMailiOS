//
//  WKReplyController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/15/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKReplyController.h"
#import "PMEmailContainer.h"
#import "WKPlainRow.h"

@interface WKReplyController () {
  PMEmailContainer *emailContainer;
  NSArray *preDeterminedMessages;
}

@property (weak, nonatomic) IBOutlet WKInterfaceTable *tableView;

@end

@implementation WKReplyController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  emailContainer = (PMEmailContainer *)context;
  
  preDeterminedMessages = @[@"OK", @"Thanks", @"Got it", @"Running late", @"On my way", @"I will get back to you soon", @"Sounds good", @"I am on it", @"Yes", @"No", @"+1"];
  
  [self.tableView setNumberOfRows:[preDeterminedMessages count] withRowType:PLAIN_ROW_IDENTIFIER];
  NSInteger i = 0;
  for(NSString *title in preDeterminedMessages) {
    WKPlainRow *row = [self.tableView rowControllerAtIndex:i++];
    [row setTitle:title];
  }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



