//
//  WKEmailController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/15/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKEmailController.h"
#import "PMEmailContainer.h"

@interface WKEmailController ()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *subjectLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *dateLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *textLabel;

@end

@implementation WKEmailController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  if(context) {
    PMEmailContainer *container = (PMEmailContainer *)context;
    
    [self.titleLabel setText:container.title];
    [self.subjectLabel setText:container.subject];
    [self.dateLabel setText:[NSString stringWithFormat:@"%@", container.date]];
    [self.textLabel setText:container.text];
  }
  
  // Configure interface objects here.
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



