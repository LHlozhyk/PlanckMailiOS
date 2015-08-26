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
#import "WKContactsController.h"

@interface InterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceTable *tableView;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *addAccountButton;

@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) NSMutableArray *accountsArray;
@property (assign, nonatomic) NSInteger allUnreadCount;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  [self setTitle:@"PlanckLabs"];
}

- (void)updateUserAccounts {
   [WKInterfaceController openParentApplication:@{WK_REQUEST_TYPE: @(PMWatchRequestAccounts)} reply:^(NSDictionary *replyInfo, NSError *error) {
    
    //get requested accounts
    NSArray *accounts = replyInfo[WK_REQUEST_RESPONSE];
    if([accounts count] > 0) {
      NSMutableArray *tempAccounts = [NSMutableArray new];
      for(NSData *arcObj in accounts) {
        PMTypeContainer *myObject = [NSKeyedUnarchiver unarchiveObjectWithData:arcObj];
        [tempAccounts addObject:myObject];
      }
      
      self.accountsArray = [NSMutableArray arrayWithArray:tempAccounts];
      
      self.dataSource = [NSMutableArray arrayWithArray:@[[PMTypeContainer initWithTitle:@"All Unread" count:-1],
                                                    [PMTypeContainer initWithTitle:@"Calendar" count:-1],
                                                    [PMTypeContainer initWithTitle:@"Contact" count:-1]]];
      [self.dataSource insertObjects:self.accountsArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [self.accountsArray count])]];
      [self reloadTable];
      
      [self updateAccountsUnreadCount];
    }
    [self.tableView setHidden:[accounts count] == 0];
    [self.addAccountButton setHidden:[accounts count] != 0];
  }];
}

- (void)reloadTable {
  [self.tableView setNumberOfRows:[_dataSource count] withRowType:PLAIN_ROW_IDENTIFIER];
  [self updateRows];
}

- (void)updateRows {
  NSInteger i = 0;
  for(PMTypeContainer *type in _dataSource) {
    WKPlainRow *row = [self.tableView rowControllerAtIndex:i++];
    [row setTypeContainer:type];
  }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
  PMTypeContainer *selectedType = _dataSource[rowIndex];
  
  if(selectedType.isNameSpace) {
    [self pushControllerWithName:LIST_CONTROLLER_IDENTIFIER context:@{TITLE: selectedType.email_address, CONTENT: selectedType}];
  } else if (rowIndex == [_dataSource count] - 1) {
    [self pushControllerWithName:CONTACTS_LIST_IDENT context:nil];
  }
}

- (IBAction)addAccountPressed {
  [self updateUserActivity:@"com.planckMailiOS.addAccount" userInfo:@{@"info": @"its ok"} webpageURL:nil];
}

- (void)willActivate {
  [super willActivate];
  
  [self updateUserAccounts];
}

- (void)updateAccountsUnreadCount {
  if([_accountsArray count] > 0 && _dataSource) {
    _allUnreadCount = 0;
    
    NSMutableArray *copyAccounts = [_accountsArray mutableCopy];
    [self updateUnreadCountForAccounts:copyAccounts];
  }
}

- (void)updateUnreadCountForAccounts:(NSMutableArray *)accounts {
  if([accounts count] > 0)  {
    __block PMTypeContainer *account = [accounts firstObject];
    NSString *token = account.token;
    
    __weak InterfaceController *__self = self;
    if(token)
      [WKInterfaceController openParentApplication:@{WK_REQUEST_TYPE: @(PMWatchRequestGetUnreadEmailsCount), WK_REQUEST_INFO: token} reply:^(NSDictionary *replyInfo, NSError *error) {
        if(!error) {
          NSInteger count = [replyInfo[WK_REQUEST_RESPONSE] integerValue];
          account.unreadCount = count;
          __self.allUnreadCount += count;
          
          //update All unread number
          __block PMTypeContainer *allUnreadAccount = [__self.dataSource firstObject];
          allUnreadAccount.unreadCount = __self.allUnreadCount;
          
          [accounts removeObjectAtIndex:0];
          if([accounts count] > 0) {
            [__self updateUnreadCountForAccounts:accounts];
          }
          
          [__self updateRows];
        }
    }];
  }
}

- (void)didDeactivate {
  // This method is called when watch view controller is no longer visible
  [super didDeactivate];
}

@end



