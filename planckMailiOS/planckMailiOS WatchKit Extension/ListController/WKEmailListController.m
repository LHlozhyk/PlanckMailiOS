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

#define LOAD_MORE_ROW_TYPE @"loadMoreType"

@interface WKEmailListController () {
  NSInteger emailsOffset;
}

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *emailsDictionaries;

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
    [self showActivityIndicator:YES];
    
    if([context[CONTENT] isKindOfClass:[PMInboxMailModel class]]) {
        __weak typeof(self) __self = self;
        
      PMInboxMailModel *inboxModel = (PMInboxMailModel *)context[CONTENT];
      NSData *emailData = [NSKeyedArchiver archivedDataWithRootObject:inboxModel];
      [WKInterfaceController openParentApplication:@{WK_REQUEST_TYPE:@(PMWatchRequestGetEmailDetails), WK_REQUEST_INFO:emailData}
                                             reply:^(id replyInfo, NSError *error) {
        @autoreleasepool {
            inboxModel.isUnread = NO;
            
            if([replyInfo isKindOfClass:[NSArray class]]) {
                __self.dataSource = [NSMutableArray new];
                __self.emailsDictionaries = [NSMutableArray new];
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
                    
                    [__self.dataSource addObject:lNewItem];
                    [__self.emailsDictionaries addObject:item];
                    
                    [__self reloadTableView];
                    [__self showActivityIndicator:NO];
                }
            }
        }
      }];
    } else {
      _selectedAccount = context[CONTENT];
      _dataSource = [NSMutableArray new];
      [self loadEmails];
    }
  }
}

#pragma mark - Table view methods

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    PMInboxMailModel *email = _dataSource[rowIndex];
    if(email.isLoadMore) {
        WKEmailRow *row = [self.tableView rowControllerAtIndex:rowIndex];
        [row showActivityIndicator:YES];
        
        emailsOffset += 10;
        
        [self loadEmails];
    } else {
        if(email.version > 1) {
            [self pushControllerWithName:LIST_CONTROLLER_IDENTIFIER context:@{TITLE: email.subject, CONTENT: email}];
        } else {
            NSDictionary *context = nil;
            if([_emailsDictionaries count] > rowIndex) {
                context = @{CONTENT: email, ADDITIONAL_INFO: _emailsDictionaries[rowIndex]};
            } else {
                context = @{CONTENT: email};
            }
            [self pushControllerWithName:EMAIL_CONTROLLER_IDENTIFIER context:context];
        }
    }
}

- (void)reloadTableView {
  [self.tableView setNumberOfRows:[_dataSource count] withRowType:EMAIL_ROW_IDENTIFIER];
  
  [self updateRows];
}

- (void)updateRows {
  NSInteger i = 0;
  for(PMInboxMailModel *container in _dataSource) {
    WKEmailRow *row = [self.tableView rowControllerAtIndex:i++];
    [row setEmailContainer:container];
  }
}

#pragma mark - Load emails

- (void)loadEmails {
    __weak typeof(self) __self = self;
    
    NSData *account = [NSKeyedArchiver archivedDataWithRootObject:_selectedAccount];
    [WKInterfaceController openParentApplication:@{WK_REQUEST_TYPE: @(PMWatchRequestGetEmails), WK_REQUEST_INFO: account, WK_REQUEST_EMAILS_LIMIT: @(emailsOffset)}
                                           reply:^(NSDictionary *replyInfo, NSError *error) {
       if(replyInfo[WK_REQUEST_RESPONSE]) {
           NSArray *archivedMessages = replyInfo[WK_REQUEST_RESPONSE];
           
           PMInboxMailModel *loadMoreModel = [__self.dataSource lastObject];
           if(loadMoreModel.isLoadMore) {
               [__self.dataSource removeLastObject];
           }
           for(NSData *message in archivedMessages) {
               [__self.dataSource addObject:[NSKeyedUnarchiver unarchiveObjectWithData:message]];
           }
           if([archivedMessages count] == EMAILS_LIMIT_COUNT) {
               if(!loadMoreModel) {
                   loadMoreModel = [PMInboxMailModel new];
                   loadMoreModel.ownerName = @"Load More";
                   loadMoreModel.isLoadMore = YES;
               }
               [__self.dataSource addObject:loadMoreModel];
           }
           
           [__self reloadTableView];
           
           [__self showActivityIndicator:NO];
       }
    }];
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



