//
//  PMPreviewMailVC.m
//  planckMailiOS
//
//  Created by admin on 6/9/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMPreviewMailVC.h"

#import "PMPreviewMailTVCell.h"
#import "PMMailComposeVC.h"

@interface PMPreviewMailVC () <UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet NSLayoutConstraint *_titleHeightConstraint;
    
    NSMutableArray *_currentSelectedArray;
    NSInteger _cellHeight;
}

- (IBAction)replyBtnPressed:(id)sender;

@property (nonatomic, strong) IBOutlet UIView *headerView;
@end

@implementation PMPreviewMailVC

#pragma mark - PMPreviewMailVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentSelectedArray = [NSMutableArray new];
    
    _headerView.frame = ({
        CGFloat lHeight = [self getLabelHeight:_titleLabel];
        CGRect lRect = _headerView.frame;
        lRect.size.height = lHeight + 16;
        lRect;
    });
    
    _titleLabel.text = _detailMail[@"subject"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)replyBtnPressed:(id)sender {
    PMMailComposeVC *lNewMailComposeVC = [[PMMailComposeVC alloc] initWithStoryboard];
    [self.tabBarController.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
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

#pragma mark - UITableView data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMPreviewMailTVCell *lTableViewCell = (PMPreviewMailTVCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PMPreviewMailTVCell class])];
    
//    if (lTableViewCell == nil) {
//        lTableViewCell = [[PMPreviewMailTVCell alloc] crea];
//    }
    //lTableViewCell.textLabel.text = @"dfdf";
    [lTableViewCell updateCellWithInfo:_detailMail];
    return lTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_currentSelectedArray containsObject:indexPath]) {
        
        return _cellHeight;
    } else return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

#pragma mark - UITableView delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_currentSelectedArray containsObject:indexPath]) {
        [_currentSelectedArray removeObject:indexPath];
        [tableView reloadRowsAtIndexPaths:_currentSelectedArray withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        PMPreviewMailTVCell *myCell = (PMPreviewMailTVCell *)[_tableView cellForRowAtIndexPath:indexPath];
        _cellHeight = [myCell height];
        [_currentSelectedArray addObject:indexPath];
        [tableView reloadRowsAtIndexPaths:_currentSelectedArray withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
