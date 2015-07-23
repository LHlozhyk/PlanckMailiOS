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
  NSMutableArray *emailsDictionaries;
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
    if([context[CONTENT] isKindOfClass:[PMInboxMailModel class]]) {
      PMInboxMailModel *inboxModel = (PMInboxMailModel *)context[CONTENT];
      NSData *emailData = [NSKeyedArchiver archivedDataWithRootObject:inboxModel];
      [WKInterfaceController openParentApplication:@{WK_REQUEST_TYPE:@(PMWatchRequestGetEmailDetails), WK_REQUEST_INFO:emailData}
                                             reply:^(id replyInfo, NSError *error) {
       //remove htmp tags
       @autoreleasepool {
         inboxModel.isUnread = NO;
         
         if([replyInfo isKindOfClass:[NSArray class]]) {
           dataSource = [NSMutableArray new];
           emailsDictionaries = [NSMutableArray new];
           for(NSDictionary *item in replyInfo) {
             PMInboxMailModel *lNewItem = [PMInboxMailModel new];
             lNewItem.snippet = item[@"snippet"];
             lNewItem.subject = item[@"subject"];
             lNewItem.namespaceId = item[@"namespace_id"];
             lNewItem.messageId = item[@"id"];
             lNewItem.version = 1;
             lNewItem.ownerName = [item[@"from"] firstObject][@"name"];
             lNewItem.isUnread = NO;
             NSTimeInterval lastTimeStamp = [item[@"date"] doubleValue];
             lNewItem.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastTimeStamp];
             
             [dataSource addObject:lNewItem];
             [emailsDictionaries addObject:item];
             
             [self reloadTableView];
           }
         }
       }
      }];
    } else {
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
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
  PMInboxMailModel *email = dataSource[rowIndex];
  if(email.version > 1) {
    [self pushControllerWithName:LIST_CONTROLLER_IDENTIFIER context:@{TITLE: email.subject, CONTENT: email}];
  } else {
    NSDictionary *context = nil;
    if([emailsDictionaries count] > rowIndex) {
      context = @{CONTENT: email, ADDITIONAL_INFO: emailsDictionaries[rowIndex]};
    } else {
      context = @{CONTENT: email};
    }
    [self pushControllerWithName:EMAIL_CONTROLLER_IDENTIFIER context:context];
  }
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



