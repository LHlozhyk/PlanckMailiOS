//
//  WKEmailController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/15/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKEmailController.h"
#import "PMInboxMailModel.h"
#import "WKSelectedAnswerController.h"
#import "NSDate+DateConverter.h"
#import "WatchKitDefines.h"

#define SEGUE_GO_TO_REPLAY @"goToReplyIdentifier"

@interface WKEmailController () {
  PMInboxMailModel *emailContainer;
  BOOL retakePressed;
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
    emailContainer = (PMInboxMailModel *)context;
    
    [self.titleLabel setText:emailContainer.ownerName];
    [self.subjectLabel setText:emailContainer.subject];
    
    NSData *emailData = [NSKeyedArchiver archivedDataWithRootObject:emailContainer];
    [WKInterfaceController openParentApplication:@{WK_REQUEST_TYPE: @(PMWatchRequestGetEmailDetails), WK_REQUEST_INFO: emailData}
                                           reply:^(NSDictionary *replyInfo, NSError *error) {
      //remove htmp tags
     @autoreleasepool {
       NSString *htmlBody = replyInfo[@"body"];
       NSAttributedString *textBody = [[NSAttributedString alloc] initWithData:[htmlBody dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
       [self.textLabel setText:textBody.string];
     }
     
     NSTimeInterval date = [replyInfo[@"date"] doubleValue];
     NSDate *dateStamp = [NSDate dateWithTimeIntervalSince1970:date];
     [self.dateLabel setText:[dateStamp convertedStringValue]];
   }];
  }
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier {
  if([segueIdentifier isEqualToString:SEGUE_GO_TO_REPLAY]) {
    return emailContainer;
  }
  return nil;
}

- (IBAction)replyDidPressed {
  NSArray *preDeterminedMessages = @[@"OK", @"Thanks", @"Got it", @"Running late", @"On my way", @"I will get back to you soon", @"Sounds good", @"I am on it", @"Yes", @"No", @"+1"];
  [self presentTextInputControllerWithSuggestions:preDeterminedMessages
                                 allowedInputMode:WKTextInputModeAllowEmoji
                                       completion:^(NSArray *results) {
    if([results count]) {
      
      [self pushControllerWithName:SELECTED_ANSWER_IDENTIFIER
                           context:@{REPLY_TEXT: [results firstObject], REPLY_MESSAGE_ID: emailContainer.messageId}];
      
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retakePressedNotification:) name:SELECTED_ANSWER_RETAKE object:nil];
    }
  }];
}

- (void)retakePressedNotification:(NSNotification *)notification {
  retakePressed = YES;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
  
  if(retakePressed) {
    [self replyDidPressed];
  }
  retakePressed = NO;
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



