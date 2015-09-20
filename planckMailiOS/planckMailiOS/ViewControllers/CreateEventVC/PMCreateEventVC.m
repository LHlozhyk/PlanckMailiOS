//
//  PMCreateEventTVC.m
//  planckMailiOS
//
//  Created by admin on 9/20/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMCreateEventVC.h"

@interface PMCreateEventVC () <UITableViewDelegate, UITableViewDataSource> {
    NSArray *_itemArray;
    
    IBOutlet UITableView *_tableiew;
    IBOutlet NSLayoutConstraint *_tableViewTop;
    
    IBOutlet UISwitch *_allDaySwitch;
    IBOutlet UITextField *_titleTF;
    IBOutlet UITextField *_locationTF;
}
- (IBAction)cancelBtnPressed:(id)sender;
- (IBAction)doneBtnPressed:(id)sender;
@end

@implementation PMCreateEventVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _itemArray = @[
                   @"eventTitleCell",
                   @[@"eventAllDayCell", @"eventStartsCell", @"eventEndsCell"],
                   @"eventAlertCell",
                   @"eventCalendarCell",
                   @"eventLocationCell",
                   @"eventInviteesCell",
                   @"eventNotesCell"
                   ];
    [_tableiew setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)keyboardWillShow:(NSNotification*)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    _tableViewTop.constant = -keyboardSize.height + 45;
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.view setNeedsLayout];
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    _tableViewTop.constant = 0;
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.view setNeedsLayout];
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - IBAction selectors

- (void)cancelBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger lCountRows = 1;
    id lItem = _itemArray[section];
    if ([lItem isKindOfClass:[NSArray class]]) {
        lCountRows = ((NSArray*)lItem).count;
    }
    return lCountRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _itemArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat lEstimateHeight = 40;
    
    if (_itemArray.count - 1 == indexPath.section) {
        lEstimateHeight = 90;
    }
    return lEstimateHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *lCellIdentifier = nil;
    id lItem = _itemArray[indexPath.section];
    if ([lItem isKindOfClass:[NSArray class]]) {
        lCellIdentifier = ((NSArray*)lItem)[indexPath.row];
    } else {
        lCellIdentifier = lItem;
    }
    
    UITableViewCell *lCell = [tableView dequeueReusableCellWithIdentifier:lCellIdentifier];
    
    return lCell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
