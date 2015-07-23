//
//  WKEmailListController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/15/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKEmailListController.h"
#import "WKEmailRow.h"
#import "PMInboxMailModel.h"
#import "WKEmailController.h"
#import "PMTypeContainer.h"
#import "WatchKitDefines.h"

@interface WKEmailListController () {
  NSMutableArray *dataSource;
}

@property (weak, nonatomic) IBOutlet WKInterfaceTable *tableView;
@property (nonatomic, strong) PMTypeContainer *selectedAccount;

@end

@implementation WKEmailListController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  if(context[TITLE]) {
    [self setTitle:context[TITLE]];
  }
  
  if(context[CONTENT]) {
    _selectedAccount = context[CONTENT];
    
    NSData *account = [NSKeyedArchiver archivedDataWithRootObject:_selectedAccount];
    [WKInterfaceController openParentApplication:@{WK_REQUEST_TYPE: @(PMWatchRequestGetEmails), WK_REQUEST_INFO: account}
                                           reply:^(NSDictionary *replyInfo, NSError *error) {
     if(replyInfo[WK_REQUEST_RESPONSE]) {
       dataSource = [NSMutableArray new];
       NSArray *archivedMessages = replyInfo[WK_REQUEST_RESPONSE];
       for(NSData *message in archivedMessages) {
         [dataSource addObject:[NSKeyedUnarchiver unarchiveObjectWithData:message]];
       }
       [self reloadTableView];
     }
    }];
  }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
  [self pushControllerWithName:EMAIL_CONTROLLER_IDENTIFIER context:dataSource[rowIndex]];
}

- (void)reloadTableView {
  [self.tableView setNumberOfRows:[dataSource count] withRowType:EMAIL_ROW_IDENTIFIER];
  
  [self updateRows];
}

- (void)updateRows {
  NSInteger i = 0;
  for(PMInboxMailModel *container in dataSource) {
    WKEmailRow *row = [self.tableView rowControllerAtIndex:i++];
    
    [row setEmailContainer:container];
  }
}

- (void)willActivate {
  [super willActivate];
  
  [self updateRows];
}

- (void)didDeactivate {
  // This method is called when watch view controller is no longer visible
  [super didDeactivate];
}

@end



