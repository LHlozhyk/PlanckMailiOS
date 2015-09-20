//
//  WKContactInfoController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 8/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKContactInfoController.h"
#import "WKContactPhonesController.h"
#import "WatchKitDefines.h"
#import "CLPerson.h"

@interface WKContactInfoController () {
  CLPerson *person;
}

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *personName;
@property (nonatomic, weak) IBOutlet WKInterfaceImage *personImage;

@property (nonatomic, weak) IBOutlet WKInterfaceButton *callButton;
@property (nonatomic, weak) IBOutlet WKInterfaceButton *messageButton;

@end

@implementation WKContactInfoController

- (instancetype)initWithContactNames:(NSDictionary *)names {
    self = [super init];
    if(self) {
        
    }
    return self;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self showActivityIndicator:YES];
    NSDictionary *contactNames = context[CONTENT];
    if(contactNames) {
        [WKInterfaceController openParentApplication:@{WK_REQUEST_TYPE:@(PMWatchRequestGetContactInfo),
                                                       WK_REQUEST_INFO: contactNames}
                                               reply:^(id replyInfo, NSError *error) {
            NSData *responceObj = replyInfo[WK_REQUEST_RESPONSE];
            if(responceObj) {
                person = [NSKeyedUnarchiver unarchiveObjectWithData:responceObj];
                [_callButton setEnabled:[person.phoneNumbers count] > 0];
                [_messageButton setEnabled:[person.phoneNumbers count] > 0];
                
                [self updateUserInfo];
           }
                                                   
           [self showActivityIndicator:NO];
        }];
    }
}

- (void)willActivate {
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)updateUserInfo {
  [_personName setText:[NSString stringWithFormat:@"%@%@", person.firstName?[person.firstName stringByAppendingString:@" "]:@"", person.lastName]];
  
  if(person.personImage) {
    [_personImage setImage:person.personImage];
  }
}

#pragma mark - User actions

- (IBAction)callDidPressed:(id)sender {
  NSArray *numbers = person.phoneNumbers;
  if(!numbers) {
    numbers = @[];
  }
  [self presentControllerWithName:CONTACTS_PHONE_IDENT
                          context:@{CONTENT: numbers, ADDITIONAL_INFO: @(PMRequestCall)}];
}

- (IBAction)messageDidPressed:(id)sender {
  NSArray *numbers = person.phoneNumbers;
  if(!numbers) {
    numbers = @[];
  }
  [self presentControllerWithName:CONTACTS_PHONE_IDENT
                          context:@{CONTENT: numbers, ADDITIONAL_INFO: @(PMRequestMessage)}];
}

@end



