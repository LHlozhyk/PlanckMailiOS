//
//  InterfaceController.m
//  planckMailiOS WatchKit Extension
//
//  Created by Dmytro Nosulich on 7/14/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "InterfaceController.h"
#import "WKPlainRow.h"
#import "PMTypeContainer.h"
#import "PMEmailContainer.h"
#import "WKEmailListController.h"


@interface InterfaceController() {
  NSArray *dataSource;
}

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  [self setTitle:@"PlanckLabs"];

  dataSource = @[[PMTypeContainer initWithTitle:@"All Unread" count:12],
                          [PMTypeContainer initWithTitle:@"Gmail" count:5],
                          [PMTypeContainer initWithTitle:@"Microsoft" count:7],
                          [PMTypeContainer initWithTitle:@"Calendar" count:-1],
                          [PMTypeContainer initWithTitle:@"Contact" count:-1]];
  
  [self.tableView setNumberOfRows:[dataSource count] withRowType:PLAIN_ROW_IDENTIFIER];
  NSInteger i = 0;
  for(PMTypeContainer *type in dataSource) {
    WKPlainRow *row = [self.tableView rowControllerAtIndex:i++];
    [row setTypeContainer:type];
  }

  // Configure interface objects here.
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
  if(rowIndex > 2) return;
  
  PMTypeContainer *container = dataSource[rowIndex];
  NSMutableDictionary *context = [NSMutableDictionary new];
  [context setObject:container.title forKeyedSubscript:TITLE];
  
  NSArray *emails = @[[PMEmailContainer initWithTitle:@"Apple"
                                              subject:@"ololo"
                                                 text:@"Whoever gave the linguistic definition of text, is wrong, he has mistaken text for language. Your differenciation between (french) like deSaussure did."
                                                 date:nil
                                             isUnread:NO],
                      [PMEmailContainer initWithTitle:@"Dima"
                                              subject:@"sd vsd v"
                                                 text:@"Whoever gave the linguistic definition of text, is wrong, he has mistaken text for language. Your differenciation between a system as the ability of the speakers to communicate using verbal and gestural signstext being understood as the product of this ability is more fitting for the language-definition as separated into  like deSaussure did."
                                                 date:nil
                                             isUnread:YES],
                      [PMEmailContainer initWithTitle:@"Lybomyr"
                                              subject:@"s dv dfv "
                                                 text:@"e. Your differenciation between a system as the ability of the speakers to communicate using verbal and gestural signs and text being understood as the product of this ability is more fitting f"
                                                 date:nil
                                             isUnread:NO],
                      [PMEmailContainer initWithTitle:@"Raj"
                                              subject:@"sdfvsdf sdf vsd"
                                                 text:@"Whoever gave the linguistic definition of text, is wrong, he has mistaken text for language. Your differenciation between a system as the ability of the speakers to communicate using verbal and gestural signs and text being understood as the product of this ability is more fitting for the language-definition as separated into langue and parole (french) like deSaussure did."
                                                 date:nil
                                             isUnread:YES]];
  [context setObject:emails forKey:CONTENT];
  
  [self pushControllerWithName:LIST_CONTROLLER_IDENTIFIER context:context];
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



