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
#import "WatchKitDefines.h"

@interface InterfaceController() {
  NSMutableArray *dataSource;
  NSMutableArray *accountsArray;
}

@property (weak, nonatomic) IBOutlet WKInterfaceTable *tableView;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *addAccountButton;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  [self setTitle:@"PlanckLabs"];
}

- (void)updateUserAccounts {
  BOOL isOk = [WKInterfaceController openParentApplication:@{WK_REQUEST_TYPE: @(PMWatchRequestAccounts)} reply:^(NSDictionary *replyInfo, NSError *error) {
    
    //get requested accounts
    NSArray *accounts = replyInfo[WK_REQUEST_RESPONSE];
    if([accounts count] > 0) {
      NSMutableArray *tempAccounts = [NSMutableArray new];
      for(NSData *arcObj in accounts) {
        PMTypeContainer *myObject = [NSKeyedUnarchiver unarchiveObjectWithData:arcObj];
        [tempAccounts addObject:myObject];
      }
      
      accountsArray = [NSMutableArray arrayWithArray:tempAccounts];
      
      dataSource = [NSMutableArray arrayWithArray:@[[PMTypeContainer initWithTitle:@"All Unread" count:-1],
                                                    [PMTypeContainer initWithTitle:@"Calendar" count:-1],
                                                    [PMTypeContainer initWithTitle:@"Contact" count:-1]]];
      [dataSource insertObjects:accountsArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [accountsArray count])]];
//      if(reloadTable) {
        [self reloadTable];
//      } else {
//        [self updateRows];
//      }
    }
    [_tableView setHidden:[accounts count] == 0];
    [_addAccountButton setHidden:[accounts count] != 0];
  }];
}

- (void)reloadTable {
  [self.tableView setNumberOfRows:[dataSource count] withRowType:PLAIN_ROW_IDENTIFIER];
  [self updateRows];
}

- (void)updateRows {
  NSInteger i = 0;
  for(PMTypeContainer *type in dataSource) {
    WKPlainRow *row = [self.tableView rowControllerAtIndex:i++];
    [row setTypeContainer:type];
  }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
  PMTypeContainer *selectedType = dataSource[rowIndex];
  
  if(selectedType.isNameSpace) {
    [self pushControllerWithName:LIST_CONTROLLER_IDENTIFIER context:@{TITLE: selectedType.email_address, CONTENT: selectedType}];
  }
}

- (IBAction)addAccountPressed {
  [self updateUserActivity:@"com.planckMailiOS.addAccount" userInfo:@{@"info": @"its ok"} webpageURL:nil];
}

- (void)willActivate {
  [super willActivate];
  
  [self updateUserAccounts];
}

- (void)didDeactivate {
  // This method is called when watch view controller is no longer visible
  [super didDeactivate];
}

@end



