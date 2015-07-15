//
//  WKEmailController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/15/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKEmailController.h"
#import "PMEmailContainer.h"

#define SEGUE_GO_TO_REPLAY @"goToReplyIdentifier"

@interface WKEmailController () {
  PMEmailContainer *emailContainer;
}


@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *subjectLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *dateLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *textLabel;

@end

@implementation WKEmailController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  if(context) {
    emailContainer = (PMEmailContainer *)context;
    
    [self.titleLabel setText:emailContainer.title];
    [self.subjectLabel setText:emailContainer.subject];
    [self.dateLabel setText:[NSString stringWithFormat:@"%@", emailContainer.date]];
    [self.textLabel setText:emailContainer.text];
  }
  
  // Configure interface objects here.
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier {
  if([segueIdentifier isEqualToString:SEGUE_GO_TO_REPLAY]) {
    return emailContainer;
  }
  return nil;
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



