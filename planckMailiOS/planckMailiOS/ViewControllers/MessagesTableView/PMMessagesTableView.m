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

@interface PMMessagesTableView () <UITableViewDelegate, UITableViewDataSource> {
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
    
    UITableViewCell *cell ;
    
    if ([tableView numberOfRowsInSection:indexPath.section]  - 1 == indexPath.row) {
        
        cell = (PMLoadMoreTVCell *)[tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
        [(PMLoadMoreTVCell*)cell show];
    } else {
        cell = (PMMailTVCell *)[tableView dequeueReusableCellWithIdentifier:@"mailCell"];
        
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
        if (lItemArray != nil && lItemArray.count > 0) {
            
            _itemMailArray = lItemArray;
            [_tableView reloadData];
        }
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


@end
