//
//  PMPreviewMailVC.m
//  planckMailiOS
//
//  Created by admin on 6/9/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMPreviewMailVC.h"

#import "PMPreviewMailTVCell.h"
#import "PMMailComposeVC.h"
#import "PMMessageModel.h"
#import "PMAPIManager.h"

@interface PMPreviewMailVC () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet NSLayoutConstraint *_titleHeightConstraint;
    
    NSMutableArray *_currentSelectedArray;
    NSInteger _cellHeight;
}

- (IBAction)deleteMailBtnPressed:(id)sender;
- (IBAction)archiveMailBtnPressed:(id)sender;
- (IBAction)replyBtnPressed:(id)sender;
- (IBAction)backBtnPressed:(id)sender;

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) PMPreviewMailTVCell *prototypeCell;

@end

@implementation PMPreviewMailVC

#pragma mark - PMPreviewMailVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentSelectedArray = [NSMutableArray new];
    
    _headerView.frame = ({
        CGFloat lHeight = [self getLabelHeight:_titleLabel];
        CGRect lRect = _headerView.frame;
        lRect.size.height = lHeight + 16;
        lRect;
    });
    
    _titleLabel.text = _inboxMailModel.subject;
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSIndexPath *lIndex = [NSIndexPath indexPathForRow:_messages.count - 1 inSection:0];
    [self tableView:_tableView didSelectRowAtIndexPath:lIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction selectors

- (void)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)replyBtnPressed:(id)sender {
    PMMailComposeVC *lNewMailComposeVC = [[PMMailComposeVC alloc] initWithStoryboard];
    [self.tabBarController.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
}

- (void)deleteMailBtnPressed:(id)sender {
    UIAlertView *lNewAlert = [[UIAlertView alloc] initWithTitle:@"Delete message" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    lNewAlert.tag = 0;
    [lNewAlert show];
}

- (void)archiveMailBtnPressed:(id)sender {
   UIAlertView *lNewAlert = [[UIAlertView alloc] initWithTitle:@"Archive message" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    lNewAlert.tag = 1;
    [lNewAlert show];
}

#pragma mark - Private methods

- (PMPreviewMailTVCell *)prototypeCell {
    if (_prototypeCell == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _prototypeCell = (PMPreviewMailTVCell *)[_tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PMPreviewMailTVCell class])];
        });
    }
    return _prototypeCell;
}

- (CGFloat)getLabelHeight:(UILabel*)label {
    CGSize constraint = CGSizeMake(label.frame.size.width, 20000.0f);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

#pragma mark - UITableView data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMPreviewMailTVCell *lTableViewCell = (PMPreviewMailTVCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PMPreviewMailTVCell class])];
    
    NSDictionary *lItem = _messages[indexPath.row];
    [lTableViewCell updateCellWithInfo:lItem];
    
    return lTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if ([_currentSelectedArray containsObject:indexPath]) {
        return _cellHeight;
    } else return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messages.count;
}

#pragma mark - UITableView delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_currentSelectedArray containsObject:indexPath]) {
        [_currentSelectedArray removeObject:indexPath];
        //NSArray *lIndexPathObjects = [_currentSelectedArray allObjects];
        [tableView reloadRowsAtIndexPaths:_currentSelectedArray withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [_currentSelectedArray addObject:indexPath];
        PMPreviewMailTVCell *myCell = (PMPreviewMailTVCell *)[_tableView cellForRowAtIndexPath:indexPath];

        _cellHeight = [myCell height];
        
        [tableView reloadRowsAtIndexPaths:_currentSelectedArray withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UIAlertView delegate 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        switch (alertView.tag) {
            case 0: {
                [[PMAPIManager shared] deleteMailWithThreadId:_inboxMailModel.messageId namespacesId:_inboxMailModel.namespaceId completion:^(id data, id error, BOOL success) {
                    
                    NSLog(@"deleteMailWithThreadId - %@", data);
                    if (_delegate && [_delegate respondsToSelector:@selector(PMPreviewMailVCDelegateAction:mail:)]) {
                        [_delegate PMPreviewMailVCDelegateAction:PMPreviewMailVCTypeActionDelete mail:_inboxMailModel];
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                break;
            }
            case 1: {
                [[PMAPIManager shared] archiveMailWithThreadId:_inboxMailModel.messageId namespacesId:_inboxMailModel.namespaceId completion:^(id data, id error, BOOL success) {
                    
                    NSLog(@"archiveMailWithThreadId - %@", data);
                    if (_delegate && [_delegate respondsToSelector:@selector(PMPreviewMailVCDelegateAction:mail:)]) {
                        [_delegate PMPreviewMailVCDelegateAction:PMPreviewMailVCTypeActionArchive mail:_inboxMailModel];
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                break;
            }
            default:
                break;
        }
    }
}

@end
