//
//  PMMailComposeVC.m
//  planckMailiOS
//
//  Created by admin on 6/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMailComposeVC.h"

#import "PMSelectionEmailView.h"
#import "PMAPIManager.h"

@interface PMMailComposeVC () <PMSelectionEmailViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UIBarButtonItem *_sentBarBtn;
    __weak IBOutlet UIButton *_emailBtn;
    __weak IBOutlet UITableView *_tableView;
}
- (IBAction)closeBtnPressed:(id)sender;
- (IBAction)sentBtnPressed:(id)sender;
- (IBAction)selectMailBtnPressed:(id)sender;
@end

@implementation PMMailComposeVC

#pragma mark - PMMailComposeVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *_itemsArray = [[DBManager instance] getNamespaces];
    DBNamespace *lItemModel = [_itemsArray objectAtIndex:0];
    _emails = lItemModel.email_address;
    [_emailBtn setTitle:lItemModel.email_address forState:UIControlStateNormal];
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction selectors

- (void)closeBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sentBtnPressed:(id)sender {
    
}

- (void)selectMailBtnPressed:(id)sender {
    PMSelectionEmailView *lNewSelectEmailView = [PMSelectionEmailView createView];
    
    NSArray *_itemsArray = [[DBManager instance] getNamespaces];
    NSMutableArray *_array = [NSMutableArray new];
    
    for (DBNamespace *item in _itemsArray) {
        [_array addObject:item.email_address];
    }
    
    [lNewSelectEmailView setEmails:_array];
    [lNewSelectEmailView setDelegate:self];
    [lNewSelectEmailView showInView:self.view];
}

#pragma mark - PMSelectionEmailView delegates

- (void)PMSelectionEmailViewDelegate:(PMSelectionEmailView *)view didSelectEmail:(NSString *)emeil {
    _emails = emeil;
    [_emailBtn setTitle:emeil forState:UIControlStateNormal];
}

#pragma mark - UITableView data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *lCell;
    if (indexPath.row == 0) {
        lCell = [tableView dequeueReusableCellWithIdentifier:@"toCell"];
    } else if (indexPath.row == 1) {
        lCell = [tableView dequeueReusableCellWithIdentifier:@"CcCell"];
    } else if (indexPath.row == 2) {
        lCell = [tableView dequeueReusableCellWithIdentifier:@"SubjectCell"];
    } else if (indexPath.row == 3) {
        lCell = [tableView dequeueReusableCellWithIdentifier:@"TextViewCell"];
    }

    return lCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        return 1000;
    } else return 44;
}

#pragma mark - UITableView delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
