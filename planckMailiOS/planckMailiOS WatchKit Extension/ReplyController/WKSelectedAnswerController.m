//
//  WKSelectedAnswerController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/16/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKSelectedAnswerController.h"

@interface WKSelectedAnswerController ()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *answerLabel;

@end

@implementation WKSelectedAnswerController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];

  [_answerLabel setText:(NSString *)context];
  // Configure interface objects here.
}

- (IBAction)sendDidPressed {
  
  [WKInterfaceController openParentApplication:nil reply:^(NSDictionary *replyInfo, NSError *error) {
    
  }];
}

- (IBAction)retakeDidPressed {
  [[NSNotificationCenter defaultCenter] postNotificationName:SELECTED_ANSWER_RETAKE object:nil];
  [self popController];
}

- (IBAction)cancelDidPressed {
  [self popController];
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



