//
//  WKContactPhonesController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 8/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKContactPhonesController.h"
#import "WatchKitDefines.h"
#import "WKContactPhoneRow.h"
#import "CLPerson.h"

#define CONTACT_PHONE_ROW_IDENT @"contactPhoneRow"

@interface WKContactPhonesController () {
  PMRequestType requestType;
  NSArray *phonesNumbers;
}

@property (nonatomic, weak) IBOutlet WKInterfaceTable *tableView;

@end

@implementation WKContactPhonesController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
  
  requestType = [context[ADDITIONAL_INFO] integerValue];
  phonesNumbers = context[CONTENT];
  
  [self updateTableView];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - Table view methods

- (void)updateTableView {
  [self.tableView setNumberOfRows:[phonesNumbers count] withRowType:CONTACT_PHONE_ROW_IDENT];
  
  NSInteger i = 0;
  for(NSDictionary *person in phonesNumbers) {
    WKContactPhoneRow *row = [self.tableView rowControllerAtIndex:i++];
    [row setPhone:person[PHONE_NUMBER] label:person[PHONE_TITLE]];
  }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
  NSString *phone = phonesNumbers[rowIndex][PHONE_NUMBER]?phonesNumbers[rowIndex][PHONE_NUMBER]:@"";
  if(requestType == PMRequestMessage) {
    NSArray *preDeterminedMessages = @[@"What's Up?", @"On my way", @"OK", @"Sorry, I can't talk right now"];
    [self presentTextInputControllerWithSuggestions:preDeterminedMessages
                                   allowedInputMode:WKTextInputModeAllowEmoji
                                         completion:^(NSArray *results) {
       if([results count]) {
         [WKInterfaceController openParentApplication:@{WK_REQUEST_TYPE:@(PMWatchRequestSendSMS), WK_REQUEST_INFO: @{WK_REQUEST_PHONE: phone, WK_REQUEST_MESSAGE: results[0]}}
                                                reply:^(id replyInfo, NSError *error) {
              {
                
              }
          }];
       }
     }];
  } else if (requestType == PMRequestCall) {
    [WKInterfaceController openParentApplication:@{WK_REQUEST_TYPE:@(PMWatchRequestCall), WK_REQUEST_INFO: @{WK_REQUEST_PHONE:phone}}
                                           reply:^(id replyInfo, NSError *error) {
//                                             {
//       NSArray *responceObj = replyInfo[WK_REQUEST_RESPONSE];
//       if([responceObj isKindOfClass:[NSArray class]]) {
//         for(NSData *person in responceObj) {
//           [__self.dataSource addObject:[NSKeyedUnarchiver unarchiveObjectWithData:person]];
//         }
//       }
//       
//       __self.isLoadingContacts = NO;
//       [__self showActivityIndicator:NO];
//       
//       [__self updateTableView];
//     }
   }];
  }
}

@end



