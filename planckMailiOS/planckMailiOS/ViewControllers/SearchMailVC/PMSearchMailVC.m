//
//  PMSearchMailVC.m
//  planckMailiOS
//
//  Created by admin on 6/30/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMSearchMailVC.h"

#import "PMAPIManager.h"
#import "PMMailTVCell.h"
#import "PMPreviewMailVC.h"
#import "MBProgressHUD.h"

#define CELL_IDENTIFIER @"mailCell"

@interface PMSearchMailVC () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    UISearchBar *_searchBar;
    NSMutableArray *_itemsArray;
    __weak IBOutlet UITableView *_tableView;
    IBOutlet NSLayoutConstraint *_tableViewConstraintBottom;
}

- (void)keyboardWillShow:(NSNotification *)notification;

@end

@implementation PMSearchMailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _itemsArray = [NSMutableArray new];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
    [_searchBar setDelegate:self];
    [_searchBar setPlaceholder:@"Search"];
    [_searchBar setTintColor:[UIColor blackColor]];
    [_searchBar becomeFirstResponder];
    [_searchBar setShowsCancelButton:YES];
    
    self.navigationItem.titleView = _searchBar;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private methods

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *lUserInfo = notification.userInfo;
    CGRect lKeyboardFrame = [lUserInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _tableViewConstraintBottom.constant = lKeyboardFrame.size.height;
    [self.view layoutIfNeeded];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _tableViewConstraintBottom.constant = 0;
    [self.view layoutIfNeeded];
}

- (void)startSearchWithEmail:(NSString *)email {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[PMAPIManager shared] searchMailWithKeyword:email namespacesId:[[PMAPIManager shared] namespaceId] completion:^(id data, id error, BOOL success) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        _itemsArray = data;
        [_tableView reloadData];
    }];
}

#pragma mark - SearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self startSearchWithEmail:searchBar.text];
}

#pragma mark - UITableView data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   PMMailTVCell* cell = (PMMailTVCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    
    if (cell == nil) {
        cell = [[PMMailTVCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL_IDENTIFIER];
    }
    PMInboxMailModel *lItem = [_itemsArray objectAtIndex:indexPath.row];
    [(PMMailTVCell *)cell updateWithModel:lItem];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat lHeight = 90;
    if (_itemsArray.count == indexPath.row) {
        lHeight = 40;
    }
    return  lHeight;
}

#pragma mark - UITableView delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PMPreviewMailVC *lNewMailPreviewVC = [[PMPreviewMailVC alloc] initWithStoryboard];

    PMInboxMailModel *lSelectedModel = _itemsArray[indexPath.row];
    lNewMailPreviewVC.inboxMailModel = lSelectedModel;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[PMAPIManager shared] getDetailWithMessageId:lSelectedModel.messageId namespacesId:lSelectedModel.namespaceId completion:^(id data, id error, BOOL success) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"data - %@", data);
        lNewMailPreviewVC.messages = data;
        [self.navigationController pushViewController:lNewMailPreviewVC animated:YES];
    }];
}

@end
