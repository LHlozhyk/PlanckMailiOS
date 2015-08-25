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
    NSArray *_defaultItemsArray;
    NSIndexPath *_selectedIndex;
}
- (IBAction)addAccountBtnPressed:(id)sender;
@end

@implementation PMSettigsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _defaultItemsArray = @[@"Mail", @"Calendar", @"Signature", @"Swipe Options", @"Broswer", @"Week Start", @"Foused inbox"];
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
    return (section == 0) ? [_itemsArray count] + 1 : [_defaultItemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *lTableViewCell;
    
    if (indexPath.section == 0) {
        if ([tableView numberOfRowsInSection:indexPath.section]  - 1 == indexPath.row) {
            lTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"AddAccount"];
        } else {
            
            lTableViewCell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
            if (lTableViewCell == nil) {
                lTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
            }
            DBNamespace *lItemModel = [_itemsArray objectAtIndex:indexPath.row];
            lTableViewCell.textLabel.text = lItemModel.email_address;
            lTableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (indexPath.section == 1) {
        lTableViewCell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
        if (lTableViewCell == nil) {
            lTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
        }
        lTableViewCell.textLabel.text = _defaultItemsArray[indexPath.row];
        lTableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return lTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        _selectedIndex = indexPath;
        UIActionSheet *lNewActionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete Account " delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
        [lNewActionSheet showInView:self.view];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel * sectionHeader = [[UILabel alloc] initWithFrame:CGRectZero];
    sectionHeader.backgroundColor = [UIColor clearColor];
    sectionHeader.textAlignment = NSTextAlignmentCenter;
    sectionHeader.font = [UIFont systemFontOfSize:15];
    sectionHeader.textColor = [UIColor darkGrayColor];
    
    switch(section) {
        case 0:sectionHeader.text = @"ACCOUNT SETTIGS"; break;
        case 1:sectionHeader.text = @"DEFAULTS SETTINGS"; break;
        default:sectionHeader.text = @"TITLE OTHER"; break;
    }
    return sectionHeader;
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
