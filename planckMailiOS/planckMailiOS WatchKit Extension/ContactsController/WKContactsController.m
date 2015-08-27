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
@property (weak, nonatomic) IBOutlet WKInterfaceImage *activityView;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *noContactsLabel;

@property (nonatomic, assign) BOOL isLoadingContacts;

@end

@implementation WKContactsController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  self.dataSource = [NSMutableArray new];
  
  __weak WKContactsController *__self = self;
  
  _isLoadingContacts = YES;
  [self showActivityIndicator:YES];
  [WKInterfaceController openParentApplication:@{WK_REQUEST_TYPE:@(PMWatchRequestGetContacts)}
                                         reply:^(id replyInfo, NSError *error) {
                        
       if(replyInfo) {
         NSArray *responceObj = replyInfo[WK_REQUEST_RESPONSE];
         if([responceObj isKindOfClass:[NSArray class]] && [responceObj count] > 0) {
           for(NSData *person in responceObj) {
             [__self.dataSource addObject:[NSKeyedUnarchiver unarchiveObjectWithData:person]];
           }
           [__self showNoContacts:NO withInfo:nil];
         } else {
           [__self showNoContacts:YES withInfo:@"You haven't any contact"];
         }
       } else {
         [__self showNoContacts:YES withInfo:@"Can't get contacts"];
       }
       
       __self.isLoadingContacts = NO;
       [__self showActivityIndicator:NO];
       
       [__self updateTableView];
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

  [self showActivityIndicator:_isLoadingContacts];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - Table view methods

- (void)updateTableView {
  [self.tableView setNumberOfRows:[_dataSource count] withRowType:CONTACT_ROW_IDENT];
  
  NSInteger i = 0;
  for(CLPerson *person in _dataSource) {
    WKContactRow *row = [self.tableView rowControllerAtIndex:i++];
    [row setContactFirstName:person.firstName lastName:person.lastName];
  }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
  [self pushControllerWithName:CONTACTS_INFO_IDENT context:@{CONTENT: _dataSource[rowIndex]}];
}

#pragma mark - Help methods

-(void)showActivityIndicator:(BOOL)yesOrNo {
  if (yesOrNo) {
    [self.tableView setHidden:YES];
    
    //unhide
    [self.activityView setHidden:NO];
    
    // Uses images in WatchKit app bundle.
    [self.activityView setImageNamed:@"frame-"];
    [self.activityView startAnimating];
  } else {
    [self.tableView setHidden:NO];
    
    [self.activityView stopAnimating];
    
    //hide
    [self.activityView setHidden:YES];
  }
}

@end



