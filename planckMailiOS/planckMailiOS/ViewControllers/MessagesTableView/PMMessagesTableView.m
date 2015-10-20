//
//  PMMessagesTableView.m
//  planckMailiOS
//
//  Created by admin on 9/1/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMessagesTableView.h"
#import "PMMailTVCell.h"
#import "PMLoadMoreTVCell.h"
#import "MGSwipeButton.h"
#import "MGSwipeTableCell.h"
#import "PMAPIManager.h"
@interface PMMessagesTableView () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    NSArray *_itemMailArray;
}
@end

@implementation PMMessagesTableView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _itemMailArray = [NSArray array];

    //delete empty separate lines for tableView
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PMLoadMoreTVCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"loadMoreCell"];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PMMailTVCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"mailCell"];

}

#pragma mark - UITableView delegate
#pragma mark - UITableView data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MGSwipeTableCell *cell ;
    
    if ([tableView numberOfRowsInSection:indexPath.section]  - 1 == indexPath.row) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
        [(PMLoadMoreTVCell*)cell show];
    } else {
        cell = (PMMailTVCell *)[tableView dequeueReusableCellWithIdentifier:@"mailCell"];
      
        cell.leftButtons = @[[MGSwipeButton buttonWithTitle:@"Snooze" backgroundColor:[UIColor orangeColor] callback:^BOOL(MGSwipeTableCell *sender) {
            
            
            
            if (_delegate && [_delegate respondsToSelector:@selector(PMMessagesTableViewDelegateShowAlert:)]) {
                [_delegate PMMessagesTableViewDelegateShowAlert:self];
            }
            
            return YES;
       }]];
        
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Archive" backgroundColor:[UIColor greenColor] callback:^BOOL(MGSwipeTableCell *sender) {
           
            [self showAlertWithCellIndexPath:[self.tableView indexPathForCell:cell]];
            
            return NO;
        }]];
        
        cell.rightExpansion.buttonIndex = 0;
        cell.leftExpansion.buttonIndex = 0;
        cell.rightExpansion.fillOnTrigger = YES;
        cell.leftExpansion.fillOnTrigger = YES;
        
        PMInboxMailModel *lItem = [_itemMailArray objectAtIndex:indexPath.row];
        [(PMMailTVCell *)cell updateWithModel:lItem];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemMailArray.count > 0 ? _itemMailArray.count + 1 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat lHeight = 90;
    if (_itemMailArray.count == indexPath.row) {
        lHeight = 40;
    }
    return  lHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([tableView numberOfRowsInSection:indexPath.section]  - 1 == indexPath.row) {
        PMMailTVCell *cell = (PMMailTVCell *)[tableView cellForRowAtIndexPath:indexPath];
        [(PMLoadMoreTVCell*)cell hide];
        [self updateMails];
    } else {
        PMInboxMailModel *lSelectedMessageModel = _itemMailArray[indexPath.row];
        [self selectedMessage:lSelectedMessageModel];
    }
}

#pragma mark - Public methods 

- (void)reloadMessagesTableView {
    if (_delegate && [_delegate respondsToSelector:@selector(PMMessagesTableViewDelegateGetData:)]) {
        NSArray *lItemArray = [_delegate PMMessagesTableViewDelegateGetData:self];
        if (lItemArray != nil) {
            _itemMailArray = lItemArray;
        } else {
            _itemMailArray = [NSArray array];
        }
        [_tableView reloadData];
    }
}

#pragma mark - Private methods

- (void)updateMails {
    if (_delegate && [_delegate respondsToSelector:@selector(PMMessagesTableViewDelegateupdateData:)]) {
        [_delegate PMMessagesTableViewDelegateupdateData:self];
    }
}

- (void)selectedMessage:(PMInboxMailModel *)msgModel {
    if (_delegate && [_delegate respondsToSelector:@selector(PMMessagesTableViewDelegate:selectedMessage:)]) {
        [_delegate PMMessagesTableViewDelegate:self selectedMessage:msgModel];
    }
}

#pragma mark - Alert Stuff 

-(void)showAlertWithCellIndexPath:(NSIndexPath*)indexPath {
    
    _inboxMailModel = _itemMailArray[indexPath.row];
    
    UIAlertView *lNewAlert = [[UIAlertView alloc] initWithTitle:@"Archive message" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [lNewAlert show];
    
}

#pragma mark - UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 1) {
    
        
        [[PMAPIManager shared] archiveMailWithThreadId:_inboxMailModel.messageId account:[PMAPIManager shared].namespaceId completion:^(id data, id error, BOOL success) {
            
            DLog(@"archiveMailWithThreadId - %@", data);
            NSMutableArray *tmpArray = (NSMutableArray*)_itemMailArray;
            [tmpArray removeObject:_inboxMailModel];
            _itemMailArray = (NSArray*)tmpArray;
            [self.tableView reloadData];
            
        }];
    }else if (buttonIndex == 0) {
        
        [self.tableView reloadData];
    
    }

}

@end
