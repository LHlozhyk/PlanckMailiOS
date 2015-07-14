//
//  WKEmailListController.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/15/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKEmailListController.h"
#import "WKEmailRow.h"
#import "PMEmailContainer.h"
#import "WKEmailController.h"

@interface WKEmailListController () {
  NSArray *dataSource;
}

@property (weak, nonatomic) IBOutlet WKInterfaceTable *tableView;

@end

@implementation WKEmailListController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  if(context[TITLE]) {
    [self setTitle:context[TITLE]];
  }
  
  dataSource = nil;
  if(context[CONTENT]) {
    dataSource = context[CONTENT];
    
    [self reloadTableView];
  }
  // Configure interface objects here.
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
  [self pushControllerWithName:EMAIL_CONTROLLER_IDENTIFIER context:dataSource[rowIndex]];
}

- (void)reloadTableView {
  [self.tableView setNumberOfRows:[dataSource count] withRowType:EMAIL_ROW_IDENTIFIER];
  
  NSInteger i = 0;
  for(PMEmailContainer *container in dataSource) {
    WKEmailRow *row = [self.tableView rowControllerAtIndex:i++];
    
    [row setEmailContainer:container];
  }
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



