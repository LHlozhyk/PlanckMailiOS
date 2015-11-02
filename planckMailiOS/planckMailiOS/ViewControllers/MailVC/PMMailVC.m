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
#import "PMPreviewMailVC.h"
#import "AppDelegate.h"
#import "MainViewController.h"

#import "PMMailComposeVC.h"
#import "PMSearchMailVC.h"
#import "PMTableViewTabBar.h"
#import "UIView+PMViewCreator.h"
#import "PMMessagesTableView.h"
#import "LeftViewController.h"
#import "PMAlertViewController.h"

#import "PMStorageManager.h"

#define CELL_IDENTIFIER @"mailCell"
#define COUNT_MESSAGES 50

typedef NS_ENUM(NSInteger, EEMessagesType) {
    Inbox,
    Sent,
    Drafts,
    Outbox,
    Archive,
    Junk,
    Deleted
};

IB_DESIGNABLE
@interface PMMailVC () <PMMailMenuViewDelegate, PMPreviewMailVCDelegate, PMTableViewTabBarDelegate, PMMessagesTableViewDelegate, PMAlertViewControllerDelegate> {
    CGFloat _centerX;
    __weak IBOutlet PMTableViewTabBar *_tableViewTabBar;
    NSString *_currentNamespaeId;
    
    NSUInteger _offesetMails;
    NSUInteger _offsetReadLater;
    NSUInteger _offsetFollowUps;
    NSMutableArray *_itemMailArray;
    NSMutableArray *_itemReadLaterArray;
    NSMutableArray *_itemFollowUpsArray;
    NSIndexPath *_selectedIndex;
    
    PMMessagesTableView *_view1;
    PMMessagesTableView *_view2;
    PMMessagesTableView *_view3;
    
    CGRect readLaterRect;
    CGRect readLaterHiddenRect;
    CGRect importantRect;
    CGRect importantHiddenRect;
    CGRect followUpsRect;
    CGRect followUpsHiddenRect;
    
    selectedMessages _selectedTableType;
    
    EEMessagesType _messageType;
}

- (IBAction)searchBtnPressed:(id)sender;
- (IBAction)menuBtnPressed:(id)sender;
- (IBAction)createMailBtnPressed:(id)sender;

@property(nonatomic, strong) PMMailMenuView *mailMenu;

@property(nonatomic) IBInspectable UIColor *color;
@end

@implementation PMMailVC

#pragma mark - PMMailVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"INBOX";
    
    _selectedTableType = ImportantMessagesSelected;
    
    _itemMailArray = [NSMutableArray array];
    _itemReadLaterArray = [NSMutableArray array];
    _itemFollowUpsArray = [NSMutableArray array];
    
    
    NSArray *lItemsArray = [[DBManager instance] getNamespaces];
    _currentNamespaeId = ((DBNamespace*)[lItemsArray firstObject]).namespace_id;
    
    [[PMAPIManager shared] setActiveNamespace:(DBNamespace*)[lItemsArray firstObject]];
    
    CGFloat x = 0;
    CGFloat y = 64 + _tableViewTabBar.frame.size.height;
    CGFloat height = self.view.frame.size.height - _tableViewTabBar.frame.size.height - self.navigationController.navigationBar.frame.size.height - 64;
    CGFloat width = self.view.frame.size.width;
    
    
    importantRect = CGRectMake(x, y, width, height);
    importantHiddenRect = CGRectMake(-width, y, width, height);
   
    readLaterRect = CGRectMake(x, y, width, height);
    readLaterHiddenRect = CGRectMake(width, y, width, height);
    
    followUpsRect = CGRectMake(x, y, width, height);
    followUpsHiddenRect = CGRectMake(width*2, y, width, height);
    
    _view1 = [PMMessagesTableView createView];
    _view1.frame = importantRect;
    _view1.delegate = self;
    [self.view addSubview:_view1];
    
    _view2 = [PMMessagesTableView createView];
    _view2.delegate = self;
    _view2.frame = readLaterHiddenRect;
    [self.view addSubview:_view2];
    
    _view3 = [PMMessagesTableView createView];
    _view3.frame = followUpsHiddenRect;
    _view3.delegate = self;
    [self.view addSubview:_view3];
    
    
    [_tableViewTabBar selectMessages:_selectedTableType];
    
    
    if (![_currentNamespaeId isEqualToString:@""]) {
        [MBProgressHUD showHUDAddedTo:[self currentTableView] animated:YES];
        _offesetMails = 0;
        _offsetReadLater = 0;
        _offsetFollowUps = 0;
        [self updateImportant];
        [self updateReadLater];
        [self updateFollowsUp];
        [self updateFolders];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGetMyNotification:)
                                                 name:@"MenuNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setType:)
                                                 name:@"setType"
                                               object:nil];
    _tableViewTabBar.delegate = self;

}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MenuNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"setType" object:nil];
}

- (void)didGetMyNotification:(NSNotification*)notification {
    
    DBNamespace *lItem = [notification object];
    if (![lItem.namespace_id isEqualToString:_currentNamespaeId]) {
        _offesetMails = 0;
        _offsetReadLater = 0;
        _offsetFollowUps = 0;
        _currentNamespaeId = lItem.namespace_id;
        [[PMAPIManager shared] setActiveNamespace:lItem];
        [_itemMailArray removeAllObjects];
        [_itemReadLaterArray removeAllObjects];
        [_itemFollowUpsArray removeAllObjects];
        
        [MBProgressHUD showHUDAddedTo:[self currentTableView] animated:YES];
        [self updateMails];
    }
}

- (void)setType:(NSNotification *)notification {
    EEMessagesType lMessageTpe = [(NSNumber *)[notification.userInfo objectForKey:@"type_value"] integerValue];
    
    if (_messageType != lMessageTpe) {
        
        if (lMessageTpe == Inbox) {
            [self showTableViewTabBar];
        } else {
            [self hideTableViewTabBar];
        }
        _offesetMails = 0;
        [_itemMailArray removeAllObjects];
        //[self messagesDidSelect:ImportantMessagesSelected];
        [_tableViewTabBar selectMessages:ImportantMessagesSelected];
        [MBProgressHUD showHUDAddedTo:[self currentTableView] animated:YES];
        switch (lMessageTpe) {
            case Inbox:{
                [self updateImportant];
                [self setTitle:@"INBOX"];
            }
                break;
            case Sent:{
                [self updateMailsWithFilter:@"sent"];
                [self setTitle:@"SENT"];
            }
                break;
            case Drafts:{
                [self updateMailsWithFilter:@"drafts"];
                [self setTitle:@"DRAFTS"];
            }
                break;
            case Outbox:{
                [self updateMailsWithFilter:@"outbox"];
                [self setTitle:@"OUTBOX"];
            }
                break;
            case Archive:{
                [self updateMailsWithFilter:@"archive"];
                [self setTitle:@"ARCHIVE"];
            }
                break;
            case Junk:{
                [self updateMailsWithFilter:@"junk"];
                [self setTitle:@"JUNK"];
            }
                break;
            case Deleted:{
                
                [self updateMailsWithFilter:@"trash"];
                [self setTitle:@"DELETED"];
            }
                break;
        }
    }
    _messageType  = lMessageTpe;
}

- (void)setColor:(UIColor *)color {
    self.view.backgroundColor = color;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    

    
    self.navigationController.navigationBarHidden = NO;
    
    NSArray *lItemsArray = [[DBManager instance] getNamespaces];
    
    BOOL lResult = NO;
    for (DBNamespace *item in lItemsArray) {
        if ([_currentNamespaeId isEqualToString:item.namespace_id]) {
            lResult = YES;
        }
    }
    
    if (!lResult) {
        [_itemMailArray removeAllObjects];
        [[self currentTableView] reloadMessagesTableView];
        _currentNamespaeId = ((DBNamespace*)[lItemsArray firstObject]).namespace_id;
        [[PMAPIManager shared] setActiveNamespace:(DBNamespace*)[lItemsArray firstObject]];
        
        if (![_currentNamespaeId isEqualToString:@""]) {
            [MBProgressHUD showHUDAddedTo:[self currentTableView] animated:YES];
            _offesetMails = 0;
            [self updateMails];
        }
    }
    [[self currentTableView] reloadMessagesTableView];
}

- (void)updateMails {
    if (_selectedTableType == ImportantMessagesSelected) {
        switch (_messageType) {
            case Inbox:{
                [self updateImportant];
            }
                break;
            case Sent:{
                [self updateMailsWithFilter:@"sent"];
            }
                break;
            case Drafts:{
                [self updateMailsWithFilter:@"drafts"];
            }
                break;
            case Outbox:{
                [self updateMailsWithFilter:@"outbox"];
            }
                break;
            case Archive:{
                [self updateMailsWithFilter:@"archive"];
            }
                break;
            case Junk:{
                [self updateMailsWithFilter:@"junk"];
            }
                break;
            case Deleted:{
                [self updateMailsWithFilter:@"trash"];
            }
                break;
        }
    } else if (_selectedTableType == ReadLaterMessagesSelected){
        [self updateReadLater];
    }else if (_selectedTableType == FollowUpsMessagesSelected){
        [self updateFollowsUp];
    }
}

- (void)updateMailsWithFilter:(NSString*)filter {
    [[PMAPIManager shared] getMailsWithAccount:[PMAPIManager shared].namespaceId limit:COUNT_MESSAGES offset:_offesetMails filter:filter completion:^(id data, id error, BOOL success) {
        [MBProgressHUD hideHUDForView:_view1 animated:YES];
        [_itemMailArray addObjectsFromArray:[self deleteReadLaterMessagesFromArray:data]];
        [[self currentTableView] reloadMessagesTableView];
        _offesetMails += COUNT_MESSAGES;
    }];
}

- (void)updateImportant {
    [[PMAPIManager shared] getInboxMailWithAccount:[PMAPIManager shared].namespaceId limit:COUNT_MESSAGES offset:_offesetMails completion:^(id data, id error, BOOL success) {
        
        [MBProgressHUD hideHUDForView:_view1 animated:YES];
        [_itemMailArray addObjectsFromArray:[self deleteReadLaterMessagesFromArray:data]];
        [[self currentTableView] reloadMessagesTableView];
        _offesetMails += COUNT_MESSAGES;
    }];
}

- (void)updateReadLater {
    [[PMAPIManager shared] getReadLaterMailWithAccount:[PMAPIManager shared].namespaceId limit:COUNT_MESSAGES offset:_offsetReadLater completion:^(id data, id error, BOOL success) {
        
        [MBProgressHUD hideAllHUDsForView:_view2 animated:YES];
        [_itemReadLaterArray addObjectsFromArray:data];
        [[self currentTableView] reloadMessagesTableView];
        _offsetReadLater += COUNT_MESSAGES;
    }];
}

-(void)updateFollowsUp {
    NSString *folderID = [PMStorageManager getScheduledFolderIdForAccount:[PMAPIManager shared].namespaceId.namespace_id];
    if(folderID) {
        [[PMAPIManager shared] getMailsWithAccount:[PMAPIManager shared].namespaceId limit:COUNT_MESSAGES offset:_offsetFollowUps filter:folderID completion:^(id data, id error, BOOL success) {
            [MBProgressHUD hideAllHUDsForView:_view3 animated:YES];
            [_itemFollowUpsArray addObjectsFromArray:data];
            [[self currentTableView] reloadMessagesTableView];
            _offsetFollowUps += COUNT_MESSAGES;
        }];
    }
}

- (void)updateFolders {
    __weak typeof(id<PMAccountProtocol>)account = [PMAPIManager shared].namespaceId;
    [[PMAPIManager shared] getFoldersWithAccount:[PMAPIManager shared].namespaceId comlpetion:^(id data, id error, BOOL success) {
        if(data) {
            [PMStorageManager setFolders:data forAccount:account.namespace_id];
        }
    }];
}

#pragma mark - IBAction selectors

- (void)searchBtnPressed:(id)sender {
    PMSearchMailVC *lNewSearchMailVC = [[PMSearchMailVC alloc] initWithStoryboard];
    
    UINavigationController *lNavControler = [[UINavigationController alloc] initWithRootViewController:lNewSearchMailVC];
    
    [self.tabBarController presentViewController:lNavControler animated:YES completion:nil];
}

- (void)menuBtnPressed:(id)sender {
    [kMainViewController showLeftViewAnimated:YES completionHandler:nil];
}

- (void)createMailBtnPressed:(id)sender {
    PMMailComposeVC *lNewMailComposeVC = [[PMMailComposeVC alloc] initWithStoryboard];
    PMDraftModel *lDraft = [PMDraftModel new];
    lNewMailComposeVC.draft = lDraft;
    [self.tabBarController.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
}
#pragma mark - Additional methods

- (PMMessagesTableView *)currentTableView {
    
    id lTableView;
    if (_selectedTableType == ImportantMessagesSelected) {
        lTableView = _view1;
    } else if (_selectedTableType == ReadLaterMessagesSelected) {
        lTableView = _view2;
    }else if (_selectedTableType == FollowUpsMessagesSelected) {
        lTableView = _view3;
    }
    return lTableView;
}

- (PMMailMenuView *)mailMenu {
    if (_mailMenu == nil) {
        _mailMenu = [PMMailMenuView createView];
        [_mailMenu setDelegate:self];
    }
    return _mailMenu;
}

#pragma mark - PMMessageTableView delegate

- (void)PMMessagesTableViewDelegateupdateData:(PMMessagesTableView *)messagesTableVie {
    [self updateMails];
}

- (void)PMMessagesTableViewDelegate:(PMMessagesTableView *)messagesTableView selectedMessage:(PMInboxMailModel *)messageModel {
    
    PMPreviewMailVC *lNewMailPreviewVC = [[PMPreviewMailVC alloc] initWithStoryboard];
    lNewMailPreviewVC.delegate = self;
    lNewMailPreviewVC.inboxMailModel = messageModel;
    
    lNewMailPreviewVC.inboxMailArray = [self selectedDataSource];
    lNewMailPreviewVC.selectedMailIndex = [[self selectedDataSource] indexOfObject:messageModel];
    
    [MBProgressHUD showHUDAddedTo:[self currentTableView] animated:YES];
    
    [[PMAPIManager shared] getDetailWithMessageId:messageModel.messageId account:[PMAPIManager shared].namespaceId unread:messageModel.isUnread completion:^(id data, id error, BOOL success) {
        if (success) {
            messageModel.isUnread = NO;
        }
        [MBProgressHUD hideAllHUDsForView:[self currentTableView] animated:YES];
        DLog(@"data - %@", data);
        lNewMailPreviewVC.messages = data;
        [self.navigationController pushViewController:lNewMailPreviewVC animated:YES];
    }];
}

- (NSArray *)PMMessagesTableViewDelegateGetData:(PMMessagesTableView *)messagesTableView {
    return [self selectedDataSource];
}

-(void)PMMessagesTableViewDelegateShowAlert:(PMMessagesTableView *)messagesTableView inboxMailModel:(PMInboxMailModel*)mailModel {

    
    PMAlertViewController *alert = [[PMAlertViewController alloc] init];
    alert.view.backgroundColor = [UIColor clearColor];
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    alert.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    alert.inboxMailModel = mailModel;
    alert.delegate = self;
    [self presentViewController:alert animated:YES completion:nil];

    [UIView animateWithDuration:0.4 animations:^{

        UIViewController *controller = kMainViewController;
        
        controller.view.backgroundColor = [UIColor whiteColor];
        MainViewController *vc;
        vc.rightViewSwipeGestureEnabled = NO;
        [self animateAlpha:0.2];
        self.tabBarController.tabBar.userInteractionEnabled = NO;
  
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disableSwipe" object:nil];
    
}

- (selectedMessages)getMessagesType {
    
    return _selectedTableType;
}

#pragma mark - PMAlertViewControllerDelegate

-(void)PMAlertViewControllerDissmis:(PMAlertViewController *)viewContorller {
    [UIView animateWithDuration:0.4 animations:^{
        [UIApplication sharedApplication].keyWindow.window.backgroundColor = [UIColor clearColor];
        UIViewController *controller = kMainViewController;
        controller.view.backgroundColor = [UIColor whiteColor];
        [self animateAlpha:1];
        self.tabBarController.tabBar.userInteractionEnabled = YES;
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"enableSwipe" object:nil];
}

- (void)didShoozedMeil:(PMInboxMailModel *)meil {
    [_itemFollowUpsArray addObject:meil];
    [[self selectedDataSource] removeObject:meil];
    
    [[self currentTableView] reloadMessagesTableView];

}

#pragma mark - PMPreviewMailVC delegate

- (void)PMPreviewMailVCDelegateAction:(PMPreviewMailVCTypeAction)typeAction mail:(PMInboxMailModel *)model {
    [_itemMailArray removeObject:model];
    [[self currentTableView] reloadMessagesTableView];
    
}

#pragma mark - PMMailMenuView delegates

- (void)PMMailMenuViewSelectNamespace:(DBNamespace *)item {
    if (![item.namespace_id isEqualToString:_currentNamespaeId]) {
        _offesetMails = 0;
        _currentNamespaeId = item.namespace_id;
        [[PMAPIManager shared] setActiveNamespace:item];
        [_itemMailArray removeAllObjects];
        [MBProgressHUD showHUDAddedTo:[self currentTableView] animated:YES];
        [self updateMails];
        [self updateFolders];
    }
}

- (void)messagesDidSelect:(selectedMessages)messages {
    
    _selectedTableType = messages;
    
    switch (messages) {
        case ReadLaterMessagesSelected:
        {
            [UIView animateWithDuration:0.3 animations:^{
                _view1.frame = importantHiddenRect;
                _view2.frame = readLaterRect;
                _view3.frame = followUpsHiddenRect;
            } completion:^(BOOL finished) {
                
                [[self currentTableView] reloadMessagesTableView];
            }];
        }
            break;
            
        case ImportantMessagesSelected:
        {
            [UIView animateWithDuration:0.3 animations:^{
                _view2.frame = readLaterHiddenRect;
                _view1.frame = importantRect;
                _view3.frame = followUpsHiddenRect;
            } completion:^(BOOL finished) {
                
                [[self currentTableView] reloadMessagesTableView];
            }];
        }
            break;
            
            case FollowUpsMessagesSelected:
        {
            [UIView animateWithDuration:0.3 animations:^{
                _view1.frame = importantHiddenRect;
                _view2.frame = readLaterHiddenRect;
                _view3.frame = followUpsRect;
            } completion:^(BOOL finished) {
                [[self currentTableView] reloadMessagesTableView];
            }];
        
        }
            break;
    }
}

#pragma mark - Private methods

- (void)showTableViewTabBar {
    [_tableViewTabBar.importantMessagesBtn setHidden:NO];
    [_tableViewTabBar.readLaterMessageBtn setHidden:NO];
}

- (void)hideTableViewTabBar{
    [_tableViewTabBar.importantMessagesBtn setHidden:YES];
    [_tableViewTabBar.readLaterMessageBtn setHidden:YES];
}

- (NSMutableArray *)deleteReadLaterMessagesFromArray:(NSMutableArray *)array {
    NSMutableArray *lNewArray = [NSMutableArray array];
    
    for (int i = 0; i < array.count; i++){
        if (![[array objectAtIndex:i] isReadLater]) {
            [lNewArray addObject:[array objectAtIndex:i]];
        }
    }
    
    return lNewArray;
}

- (NSMutableArray *)selectedDataSource {
    if (_selectedTableType == ImportantMessagesSelected) {
        return _itemMailArray;
    }else if (_selectedTableType == ReadLaterMessagesSelected) {
        return _itemReadLaterArray;
    }else if (_selectedTableType == FollowUpsMessagesSelected) {
        return _itemFollowUpsArray;
    }
    
    return nil;
}

#pragma mark - Animation Stuff 

-(void)animateAlpha:(CGFloat)alpha {
    
    self.view.alpha = alpha;
    self.navigationController.view.alpha = alpha;
    self.tabBarController.tabBar.alpha = alpha;

}


@end
