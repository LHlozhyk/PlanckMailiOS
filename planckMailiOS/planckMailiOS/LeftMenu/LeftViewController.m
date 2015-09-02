//
//  LeftViewController.m
//  LGSideMenuControllerDemo
//
//  Created by Grigory Lutkov on 18.02.15.
//  Copyright (c) 2015 Grigory Lutkov. All rights reserved.
//

#import "LeftViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "LeftViewCell.h"
#import "UIView+PMViewCreator.h"
#import "PMMenuHeaderView.h"
#import "DBManager.h"

@interface LeftViewController () <PMMenuHeaderViewDelegate> {
    NSInteger _selectedIndex;
    NSArray *_sectionArray;
}

@property (strong, nonatomic) NSArray *titlesArray;
@end

@implementation LeftViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _titlesArray = @[@"Inbox",
                     @"Sent",
                     @"Drafts",
                     @"Outbox",
                     @"Archive",
                     @"Junk",
                     @"Deleted"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _sectionArray = [[DBManager instance] getNamespaces];
    [self.tableView reloadData];
}

#pragma mark -

- (void)openLeftView {
    [kMainViewController showLeftViewAnimated:YES completionHandler:nil];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == _selectedIndex) ? _titlesArray.count : 0;
}

#pragma mark - UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeftViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.textLabel.text = _titlesArray[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_menu_icon", _titlesArray[indexPath.row]]];
    cell.tintColor = [UIColor whiteColor];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PMMenuHeaderView *lView = [PMMenuHeaderView createView];
    [lView setDelegate:self];
    lView.tag = section;
    DBNamespace *Item = _sectionArray[section];
    [lView setTitleName:Item.email_address];
    [lView setSelected:(section == _selectedIndex)];
    lView.frame = CGRectMake(0, 0, tableView.frame.size.width, 52);
    return lView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 52;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (indexPath.row == 0)
//    {
//        ViewController *viewController = [kNavigationController viewControllers].firstObject;
//        
//        UIViewController *viewController2 = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
//        viewController2.title = @"Test";
//        
//        [kNavigationController setViewControllers:@[viewController, viewController2]];
//        
//        [kMainViewController hideLeftViewAnimated:YES completionHandler:nil];
//    }
//    else if (indexPath.row == 1)
//    {
//        if (![kMainViewController isLeftViewAlwaysVisible])
//        {
//            [kMainViewController hideLeftViewAnimated:YES completionHandler:^(void)
//             {
//                 [kMainViewController showRightViewAnimated:YES completionHandler:nil];
//             }];
//        }
//        else [kMainViewController showRightViewAnimated:YES completionHandler:nil];
//    }
//    else
//    {
//        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
//        viewController.title = _titlesArray[indexPath.row];
//        [kNavigationController pushViewController:viewController animated:YES];
//        
//        [kMainViewController hideLeftViewAnimated:YES completionHandler:nil];
//    }
}

#pragma mark - PMMenuHeaderView delegate

- (void)PMMenuHeaderView:(PMMenuHeaderView *)menuHeaderView selectedState:(BOOL)selected {
    _selectedIndex = menuHeaderView.tag;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MenuNotification" object:_sectionArray[_selectedIndex]];
    [_tableView reloadData];
}

@end
