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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView data source 

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 5;
//}

@end
