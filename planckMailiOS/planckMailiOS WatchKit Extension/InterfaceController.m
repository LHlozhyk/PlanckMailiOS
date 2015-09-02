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

@property (weak, nonatomic) IBOutlet WKInterfaceImage *appLogoView;

@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) NSMutableArray *accountsArray;
@property (assign, nonatomic) NSInteger allUnreadCount;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self.addAccountButton setHidden:YES];
    [self.tableView setHidden:YES];
    
    [self setHelpItemsHidden:NO];
    
    [self setTitle:@"PlanckLabs"];
}

- (void)updateUserAccounts {
    [self showActivityIndicator:YES];
    __weak typeof(self) __self = self;
    [WKInterfaceController openParentApplication:@{WK_REQUEST_TYPE: @(PMWatchRequestAccounts)} reply:^(NSDictionary *replyInfo, NSError *error) {
        
        //get requested accounts
        NSArray *accounts = replyInfo[WK_REQUEST_RESPONSE];
        if([accounts count] > 0) {
            NSMutableArray *tempAccounts = [NSMutableArray new];
            for(NSData *arcObj in accounts) {
                PMTypeContainer *myObject = [NSKeyedUnarchiver unarchiveObjectWithData:arcObj];
                [tempAccounts addObject:myObject];
            }
            
            if(![__self.accountsArray isEqualToArray:tempAccounts]) {
                __self.accountsArray = [NSMutableArray arrayWithArray:tempAccounts];
                
                __self.dataSource = [NSMutableArray arrayWithArray:@[[PMTypeContainer initWithTitle:@"All Unread" count:-1],
                                                                     [PMTypeContainer initWithTitle:@"Calendar" count:-1],
                                                                     [PMTypeContainer initWithTitle:@"Contact" count:-1]]];
                [__self.dataSource insertObjects:__self.accountsArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [__self.accountsArray count])]];
                [__self reloadTable];
            }
            
            [__self updateAccountsUnreadCount];
        }
        [__self.tableView setHidden:[accounts count] == 0];
        [__self.addAccountButton setHidden:[accounts count] != 0];
        
        [__self.appLogoView setHidden:YES];
    }];
}

- (void)setHelpItemsHidden:(BOOL)hidden {
    [self showActivityIndicator:!hidden];
    [self.appLogoView setHidden:hidden];
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
        
        [self showActivityIndicator:YES];
        
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
          } else {
              [__self showActivityIndicator:NO];
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



