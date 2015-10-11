//
//  PMPreviewTableView.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 10/10/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMPreviewTableView.h"

#import "PMPreviewMailTVCell.h"
#import "PMInboxMailModel.h"
#import "MBProgressHUD.h"
#import "PMAPIManager.h"

@interface PMPreviewTableView () <UITableViewDataSource, UITableViewDelegate> {
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet UIView *headerView;
    
    NSMutableArray *_currentSelectedArray;
    NSInteger _cellHeight;
}

@end

@implementation PMPreviewTableView

+ (instancetype)newPreviewView {
    NSArray *previewViewes = [[NSBundle mainBundle] loadNibNamed:@"PMPreviewTableView" owner:nil options:nil];
    return [previewViewes firstObject];
}

#pragma mark - Init

- (instancetype)init {
    if(self = [super init]) {
        
    }
    return self;
}

- (void)awakeFromNib {
    
}

#pragma mark - View life circle

- (void)didMoveToSuperview {
    _currentSelectedArray = [NSMutableArray new];
    
    _titleLabel.text = _inboxMailModel.subject;
    
    headerView.frame = ({
        CGFloat lHeight = [self getLabelHeight:_titleLabel];
        CGRect lRect = headerView.frame;
        lRect.size.height = lHeight + 16;
        lRect;
    });
    
    [_tableView reloadData];
    
    _tableView.tableHeaderView = headerView;
    
    [self layoutSubviews];
    
    [self performSelector:@selector(selectLastRow) withObject:nil afterDelay:1];
}

#pragma mark - Properties

- (void)setInboxMailModel:(PMInboxMailModel *)inboxMailModel {
    _inboxMailModel = inboxMailModel;
    
    if(!_messages) {
        [MBProgressHUD showHUDAddedTo:self animated:YES];
        
        __weak typeof(self) __self = self;
        [[PMAPIManager shared] getDetailWithMessageId:_inboxMailModel.messageId account:[PMAPIManager shared].namespaceId unread:_inboxMailModel.isUnread completion:^(id data, id error, BOOL success) {
            if (success) {
                __self.inboxMailModel.isUnread = NO;
            }
            [MBProgressHUD hideAllHUDsForView:__self animated:YES];
            __self.messages = data;
            
            if([__self.delegate respondsToSelector:@selector(PMPreviewTableView:didUpdateMessages:)]) {
                [__self.delegate PMPreviewTableView:__self didUpdateMessages:data];
            }
        }];
    }
}

- (void)setMessages:(NSArray *)messages {
    _messages = messages;
    
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMPreviewMailTVCell *lTableViewCell = (PMPreviewMailTVCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PMPreviewMailTVCell class])];
    if(!lTableViewCell) {
        lTableViewCell = [PMPreviewMailTVCell newCell];
    }
    
    NSDictionary *lItem = _messages[indexPath.row];
    [lTableViewCell updateCellWithInfo:lItem];
    
    return lTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_currentSelectedArray containsObject:indexPath]) {
        return _cellHeight;
    } else return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messages.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_currentSelectedArray containsObject:indexPath]) {
        [_currentSelectedArray removeObject:indexPath];
        //NSArray *lIndexPathObjects = [_currentSelectedArray allObjects];
        [tableView reloadRowsAtIndexPaths:_currentSelectedArray withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [_currentSelectedArray addObject:indexPath];
        PMPreviewMailTVCell *myCell = (PMPreviewMailTVCell *)[_tableView cellForRowAtIndexPath:indexPath];
        
        _cellHeight = [myCell height];
        
        [tableView reloadRowsAtIndexPaths:_currentSelectedArray withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Private methods

- (CGFloat)getLabelHeight:(UILabel*)label {
    CGSize constraint = CGSizeMake(label.frame.size.width, 20000.0f);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

- (void)selectLastRow {
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(selectLastRow) withObject:nil waitUntilDone:NO];
    } else {
        NSIndexPath *lIndex = [NSIndexPath indexPathForRow:_messages.count - 1 inSection:0];
        [self tableView:_tableView didSelectRowAtIndexPath:lIndex];
        [_tableView scrollToRowAtIndexPath:lIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

@end
