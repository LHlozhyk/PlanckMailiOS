//
//  WKContactsController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 8/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKContactsController.h"
#import "WKContactInfoController.h"
#import "WKContactRow.h"
#import "WatchKitDefines.h"
#import "CLPerson.h"

#define CONTACT_ROW_IDENT @"contactRow"

@interface WKContactsController ()

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (weak, nonatomic) IBOutlet WKInterfaceTable *tableView;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *noContactsLabel;

@property (nonatomic, assign) BOOL isLoadingContacts;
@property (nonatomic, assign) NSInteger contactsOffset;

@end

@implementation WKContactsController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    self.dataSource = [NSMutableArray new];

    _isLoadingContacts = YES;
    [self showActivityIndicatorAndTable:YES];
    
    _contactsOffset = 0;
    [self loadNextContacts];
}

- (void)loadNextContacts {
    __weak WKContactsController *__self = self;
    
    [WKInterfaceController openParentApplication:@{WK_REQUEST_TYPE:@(PMWatchRequestGetContacts), WK_REQUEST_INFO: @{CONTACTS_OFFSET: @(__self.contactsOffset), CONTACTS_LIMIT: @(CONTACTS_LIMIT_COUNT)}}
                                           reply:^(id replyInfo, NSError *error) {
        @autoreleasepool {
            NSArray *responceArray = replyInfo[WK_REQUEST_RESPONSE];
            if(responceArray) {
               if([responceArray isKindOfClass:[NSArray class]] && [responceArray count] > 0) {
                   __self.contactsOffset += [responceArray count];
                   for(NSData *person in responceArray) {
                       [__self.dataSource addObject:[NSKeyedUnarchiver unarchiveObjectWithData:person]];
                   }
                   [__self showNoContacts:NO withInfo:nil];
               } else if([__self.dataSource count] == 0) {
                   [__self showNoContacts:YES withInfo:@"You haven't any contact"];
               }
            } else if([__self.dataSource count] == 0) {
               [__self showNoContacts:YES withInfo:@"Can't get contacts"];
            }

            [__self updateTableView];
            if([responceArray count] >= CONTACTS_LIMIT_COUNT) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [__self loadNextContacts];
                });
                [__self showActivityIndicatorAndTable:YES];
            } else {
                __self.isLoadingContacts = NO;
                [__self showActivityIndicatorAndTable:NO];
            }
        }
    }];
}

- (void)showNoContacts:(BOOL)noContacts withInfo:(NSString *)info {
  [self.tableView setHidden:noContacts];
  [self.noContactsLabel setHidden:!noContacts];
  if(info) {
    [self.noContactsLabel setText:info];
  }
}

- (void)willActivate {
  [super willActivate];

  [self showActivityIndicatorAndTable:_isLoadingContacts];
}

- (void)didDeactivate {
    [super didDeactivate];
}

#pragma mark - Table view methods

- (void)updateTableView {
  [self.tableView setNumberOfRows:[_dataSource count] withRowType:CONTACT_ROW_IDENT];
  
  NSInteger i = 0;
  for(NSDictionary *person in _dataSource) {
    WKContactRow *row = [self.tableView rowControllerAtIndex:i++];
    [row setContactFirstName:person[PERSON_NAME] lastName:person[PERSON_SECOND_NAME]];
  }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
  [self pushControllerWithName:CONTACTS_INFO_IDENT context:@{CONTENT: _dataSource[rowIndex]}];
}

#pragma mark - Help methods

- (void)showActivityIndicatorAndTable:(BOOL)yesOrNo {
    [super showActivityIndicator:yesOrNo];
//    [self.tableView setHidden:yesOrNo];
}

@end



