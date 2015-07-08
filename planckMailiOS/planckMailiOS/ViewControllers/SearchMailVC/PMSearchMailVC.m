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

@interface PMSearchMailVC () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    UISearchBar *_searchBar;
    NSMutableArray *_itemsArray;
    
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

- (void)startSearchWithEmail:(NSString *)email {
    [[PMAPIManager shared] searchMailWithKeyword:email namespacesId:@"3qcfrz797tl4hj2kvsr2dbfgu" completion:^(id data, id error, BOOL success) {
        
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
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

#pragma mark - UITableView delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
