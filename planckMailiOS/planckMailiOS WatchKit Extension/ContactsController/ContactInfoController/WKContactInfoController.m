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

@end

@implementation WKContactInfoController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  person = context[CONTENT];
  
  [self updateUserInfo];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
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



