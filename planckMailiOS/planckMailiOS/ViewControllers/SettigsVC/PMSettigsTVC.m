//
//  PMSettigsVC.m
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMSettigsTVC.h"
#import "PMLoginVC.h"
#import "DBManager.h"
#import "UIViewController+PMStoryboard.h"

#define DYNAMIC_SECTION 0
#define CELL_IDENTIFIER @"journalTVCell"

@interface PMSettigsTVC () <UIActionSheetDelegate> {
    NSArray *_itemsArray;
    NSIndexPath *_selectedIndex;
}
- (IBAction)addAccountBtnPressed:(id)sender;
@end

@implementation PMSettigsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _itemsArray = [[DBManager instance] getNamespaces];
    [self.tableView reloadData];
}

- (void)addAccountBtnPressed:(id)sender {
    PMLoginVC *lNewLoginVC = [[PMLoginVC alloc] initWithStoryboard];
    [lNewLoginVC setAdditionalAccoutn:YES];
    UINavigationController *lNav = [[UINavigationController alloc] initWithRootViewController:lNewLoginVC];
    
    UIBarButtonItem *customBtn=[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:lNewLoginVC action:@selector(backBtnPressed:)];
    
    [lNewLoginVC.navigationItem setRightBarButtonItem:customBtn];
    
    [self presentViewController:lNav animated:YES completion:nil];
}

- (void)configureCell:(UITableViewCell *)cell {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_itemsArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *lTableViewCell;
    
    
    if ([tableView numberOfRowsInSection:indexPath.section]  - 1 == indexPath.row) {
        
        lTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"AddAccount"];
//        lTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddAccount"];
    } else {
        
        lTableViewCell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
        if (lTableViewCell == nil) {
            lTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
        }
        DBNamespace *lItemModel = [_itemsArray objectAtIndex:indexPath.row];
        lTableViewCell.textLabel.text = lItemModel.email_address;
    }
    
    return lTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedIndex = indexPath;
    UIActionSheet *lNewActionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete Account " delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
    [lNewActionSheet showInView:self.view];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"ACCOUNT SETTINGS";
}

#pragma mark - UIActionSheet delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        DBNamespace *lSelectedNamespace = [_itemsArray objectAtIndex:_selectedIndex.row];
        [DBManager deleteNamespace:lSelectedNamespace];
        _itemsArray = [[DBManager instance] getNamespaces];
        
        if (_itemsArray.count > 0) {
            [self.tableView reloadData];
        } else {
            [self.tabBarController.navigationController popToRootViewControllerAnimated:YES];
            [self.tabBarController.navigationController setNavigationBarHidden:NO];
        }
    }
}

@end
