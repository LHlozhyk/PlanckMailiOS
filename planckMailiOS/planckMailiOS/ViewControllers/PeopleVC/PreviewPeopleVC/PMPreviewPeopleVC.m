//
//  PMPreviewPeopleVC.m
//  planckMailiOS
//
//  Created by admin on 6/15/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMPreviewPeopleVC.h"

@interface PMPreviewPeopleVC () <UITableViewDataSource, UITableViewDelegate> {
    __weak IBOutlet UITableView *_tableView;
    
    NSMutableArray *_itemsArray;
}
@end

@implementation PMPreviewPeopleVC

#pragma mark - PreviewPeopleVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:_currentPerson.fullName];
    
    _itemsArray = [NSMutableArray new];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.scrollEnabled = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView data source 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *lTableViewCell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (lTableViewCell == nil) {
        lTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    lTableViewCell.textLabel.text = @"Mobile";
    lTableViewCell.detailTextLabel.text = _currentPerson.phoneNumber;
    return lTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

@end
