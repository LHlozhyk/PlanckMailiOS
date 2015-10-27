//
//  PMMessagesTableView.h
//  planckMailiOS
//
//  Created by admin on 9/1/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMInboxMailModel.h"
#import "PMTableViewTabBar.h"

@class PMMessagesTableView;
@protocol PMMessagesTableViewDelegate <NSObject>
@required
- (NSArray *)PMMessagesTableViewDelegateGetData:(PMMessagesTableView*)messagesTableView;
- (void)PMMessagesTableViewDelegateupdateData:(PMMessagesTableView*)messagesTableVie;
- (void)PMMessagesTableViewDelegate:(PMMessagesTableView*)messagesTableView selectedMessage:(PMInboxMailModel*)messageModel;
- (void)PMMessagesTableViewDelegateShowAlert:(PMMessagesTableView *)messagesTableView inboxMailModel:(PMInboxMailModel*)mailModel;


- (selectedMessages)getMessagesType;

@end

@interface PMMessagesTableView : UIView 
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, weak) id<PMMessagesTableViewDelegate> delegate;
@property(nonatomic, strong) PMInboxMailModel *inboxMailModel;

- (void)reloadMessagesTableView;
@end
