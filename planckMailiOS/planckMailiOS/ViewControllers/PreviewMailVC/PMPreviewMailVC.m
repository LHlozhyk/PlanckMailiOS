//
//  PMPreviewMailVC.m
//  planckMailiOS
//
//  Created by admin on 6/9/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMPreviewMailVC.h"

@interface PMPreviewMailVC () <UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet NSLayoutConstraint *_titleHeightConstraint;
    
    NSMutableArray *_currentSelectedArray;
}

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
    UITableViewCell *lTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (lTableViewCell == nil) {
        lTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    return lTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_currentSelectedArray containsObject:indexPath]) {
        return  300;
    } else return 90;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

#pragma mark - UITableView delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_currentSelectedArray containsObject:indexPath]) {
        [_currentSelectedArray removeObject:indexPath];
        [tableView reloadRowsAtIndexPaths:_currentSelectedArray withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {;
        [_currentSelectedArray addObject:indexPath];
        [tableView reloadRowsAtIndexPaths:_currentSelectedArray withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
