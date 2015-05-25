//
//  PMSettigsVC.m
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMSettigsTVC.h"
#import "PMLoginVC.h"

#import "UIViewController+PMStoryboard.h"

#define DYNAMIC_SECTION 0
#define CELL_IDENTIFIER @"journalTVCell"

@interface PMSettigsTVC ()
- (IBAction)addAccountBtnPressed:(id)sender;
@end

@implementation PMSettigsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)addAccountBtnPressed:(id)sender {
    PMLoginVC *lNewLoginVC = [[PMLoginVC alloc] initWithStoryboard];
    
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
    return 3;
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
        
         lTableViewCell.textLabel.text = @"";
    }
    
    return lTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"ACCOUNT SETTINGS";
}

@end
