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
  NSDictionary *emailInfo;
}


@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *subjectLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *dateLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *textLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *activityView;

@end

@implementation WKEmailController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  if(context) {
    emailContainer = (PMInboxMailModel *)context[CONTENT];
    emailInfo = context[ADDITIONAL_INFO];
    [self.titleLabel setText:emailContainer.ownerName];
    [self.subjectLabel setText:emailContainer.subject];
    
    if(emailInfo) {
      [self updateBodyAndDate];
    } else {
      [self showActivityIndicator:YES];
      NSData *emailData = [NSKeyedArchiver archivedDataWithRootObject:emailContainer];
      [WKInterfaceController openParentApplication:@{WK_REQUEST_TYPE: @(PMWatchRequestGetEmailDetails), WK_REQUEST_INFO: emailData}
                                             reply:^(id replyInfo, NSError *error) {
        //remove htmp tags
       @autoreleasepool {
         emailContainer.isUnread = NO;
         if([replyInfo isKindOfClass:[NSArray class]]) {
           emailInfo = [[replyInfo firstObject] copy];
         } else {
           emailInfo = [replyInfo copy];
         }
         
         [self updateBodyAndDate];
         [self showActivityIndicator:NO];
       }
     }];
    }
  }
}

- (void) updateBodyAndDate {
  NSString *htmlBody = emailInfo[@"body"];
  NSAttributedString *textBody = [[NSAttributedString alloc] initWithData:[htmlBody dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
  [self.textLabel setText:textBody.string];
  
  NSTimeInterval date = [emailInfo[@"date"] doubleValue];
  NSDate *online = [NSDate dateWithTimeIntervalSince1970:date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"MMM dd, YYYY 'at' hh:mm aaa"];
  
  [self.dateLabel setText:[dateFormatter stringFromDate:online]];
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
                           context:@{REPLY_TEXT: [results firstObject], REPLY_MESSAGE_INFO: emailInfo}];
      
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

-(void)showActivityIndicator:(BOOL)yesOrNo {
  if (yesOrNo) {
    //unhide
    [self.activityView setHidden:NO];
    
    // Uses images in WatchKit app bundle.
    [self.activityView setImageNamed:@"frame-"];
    [self.activityView startAnimating];
  } else {
    [self.activityView stopAnimating];
    
    //hide
    [self.activityView setHidden:YES];
  }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



