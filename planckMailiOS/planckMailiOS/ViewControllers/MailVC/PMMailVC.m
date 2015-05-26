//
//  PMMailVC.m
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMailVC.h"
#import "PMMailMenuView.h"
#import "SWTableViewCell.h"
#import "DBManager.h"
#import "PMAPIManager.h"
#import "MBProgressHUD.h"
#import "PMMailTVCell.h"
#import "PMInboxMailModel.h"
#import "PMLoadMoreTVCell.h"

#define CELL_IDENTIFIER @"mailCell"

@interface PMMailVC () <UIGestureRecognizerDelegate, SWTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate, PMMailMenuViewDelegate> {
    CGFloat _centerX;
    
    __weak IBOutlet UITableView *_tableView;
    
    NSString *_currentNamespaeId;
    
    NSUInteger _offesetMails;
    
    NSMutableArray *_itemMailArray;
}

- (IBAction)menuBtnPressed:(id)sender;

@property(nonatomic, strong) PMMailMenuView *mailMenu;
@end

@implementation PMMailVC

#pragma mark - PMMailVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self addGesture];
    _itemMailArray = [NSMutableArray new];
    NSArray *lItemsArray = [[DBManager instance] getNamespaces];
    _currentNamespaeId = ((DBNamespace*)[lItemsArray firstObject]).namespace_id;
    [[PMAPIManager shared] setActiveNamespace:(DBNamespace*)[lItemsArray firstObject]];
    
    if (![_currentNamespaeId isEqualToString:@""]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _offesetMails = 0;
        [self updateMails];
    }
    //delete empty separate lines for tableView
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSArray *lItemsArray = [[DBManager instance] getNamespaces];
    BOOL lResult = NO;
    for (DBNamespace *item in lItemsArray) {
        if ([_currentNamespaeId isEqualToString:item.namespace_id]) {
            lResult = YES;
        }
    }
    
    if (!lResult) {
        [_itemMailArray removeAllObjects];
        [_tableView reloadData];
        _currentNamespaeId = ((DBNamespace*)[lItemsArray firstObject]).namespace_id;
        [[PMAPIManager shared] setActiveNamespace:(DBNamespace*)[lItemsArray firstObject]];
        
        if (![_currentNamespaeId isEqualToString:@""]) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _offesetMails = 0;
            [self updateMails];
        }
    }
    
}

- (void)updateMails {
    [[PMAPIManager shared] getInboxMailWithNamespaceId:_currentNamespaeId limit:30 offset:_offesetMails completion:^(id data, id error, BOOL success) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [_itemMailArray addObjectsFromArray:data];
        [_tableView reloadData];
    }];
}

#pragma mark - IBAction selectors

- (void)menuBtnPressed:(id)sender {
    [self.mailMenu showInView:self.view];
}

#pragma mark - Additional methods

- (void)addGesture {
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftEdgeGesture:)];
    leftEdgeGesture.edges = UIRectEdgeLeft;
    leftEdgeGesture.delegate = self;
    [self.view addGestureRecognizer:leftEdgeGesture];
    
    // Store the center, so we can animate back to it after a slide
    _centerX = self.view.bounds.size.width / 2;
}

- (void)handleLeftEdgeGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    // Get the current view we are touching
    UIView *view = [self.view hitTest:[gesture locationInView:gesture.view] withEvent:nil];
    
    NSLog(@"Ceeee");
    if(UIGestureRecognizerStateBegan == gesture.state ||
       UIGestureRecognizerStateChanged == gesture.state) {
        CGPoint translation = [gesture translationInView:gesture.view];
        // Move the view's center using the gesture
        view.center = CGPointMake(_centerX + translation.x, view.center.y);
    } else {// cancel, fail, or ended
        // Animate back to center x
        [UIView animateWithDuration:.3 animations:^{
            view.center = CGPointMake(_centerX, view.center.y);
        }];
    }
}

#pragma mark - Additional methods

- (PMMailMenuView *)mailMenu {
    if (_mailMenu == nil) {
        _mailMenu = [PMMailMenuView createView];
        [_mailMenu setDelegate:self];
    }
    return _mailMenu;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)configureCell:(UITableViewCell *)cell {
    // Remove seperator inset
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//    // Prevent the cell from inheriting the Table View's margin settings
//    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
//        [cell setPreservesSuperviewLayoutMargins:NO];
//    }
//    // Explictly set your cell's layout margins
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell ;
    
     if ([tableView numberOfRowsInSection:indexPath.section]  - 1 == indexPath.row) {
         
          cell = (PMLoadMoreTVCell *)[tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
         [(PMLoadMoreTVCell*)cell show];
     } else {
         cell = (PMMailTVCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
         
         if (cell == nil) {
             cell = [[PMMailTVCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL_IDENTIFIER];
             //        cell.leftUtilityButtons = [self leftButtons];
             //        cell.rightUtilityButtons = [self rightButtons];
             //        cell.delegate = self;
         }
         PMInboxMailModel *lItem = [_itemMailArray objectAtIndex:indexPath.row];
         [(PMMailTVCell *)cell updateWithModel:lItem];
     }
   
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemMailArray.count > 0 ? _itemMailArray.count + 1 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat lHeight = 90;
    if (_itemMailArray.count == indexPath.row) {
        lHeight = 40;
    }
    return  lHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:cell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([tableView numberOfRowsInSection:indexPath.section]  - 1 == indexPath.row) {
        PMMailTVCell *cell = (PMMailTVCell *)[tableView cellForRowAtIndexPath:indexPath];
        [(PMLoadMoreTVCell*)cell hide];
        _offesetMails = indexPath.row - 1;
        [self updateMails];
    } else {
        
    }
}

#pragma mark - SWTableView delegates

- (NSArray *)rightButtons {
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor greenColor]
                                                title:@"Archive"];
    
    return rightUtilityButtons;
}

- (NSArray *)leftButtons {
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor orangeColor]
                                                title:@"Schedule"];
    
    return leftUtilityButtons;
}

#pragma mark - PMMailMenuView delegates

- (void)PMMailMenuViewSelectNamespace:(DBNamespace *)item {
    if (![item.namespace_id isEqualToString:_currentNamespaeId]) {
        _offesetMails = 0;
        _currentNamespaeId = item.namespace_id;
        [[PMAPIManager shared] setActiveNamespace:item];
        [_itemMailArray removeAllObjects];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self updateMails];
    }
}

@end
