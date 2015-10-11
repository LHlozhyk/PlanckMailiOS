//
//  PMEventDetailsVC.m
//  planckMailiOS
//
//  Created by admin on 9/20/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMEventDetailsVC.h"
#import "UIViewController+PMStoryboard.h"

@interface PMEventDetailsVC () <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *_tableView;
    
    NSArray *_itemsArray;
    PMEventModel *_currentEvent;
}
@end

@implementation PMEventDetailsVC

- (instancetype)initWithEvent:(PMEventModel *)eventModel {
    self = [self initWithStoryboard];
    if (self) {
        _currentEvent = eventModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Event Details"];
    
    _itemsArray = @[@"titleInfo", @"acceptTitle", @"locationCell", @"timeCell", @"organizerCell", @"inviteesCell"];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *lCell = [tableView dequeueReusableCellWithIdentifier:_itemsArray[indexPath.row]];
    
    return lCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_itemsArray[indexPath.row] isEqualToString:@"titleInfo"]) {
        return 150;
    }
    return 50;
}

@end
