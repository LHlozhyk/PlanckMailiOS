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
#import "PMPreviewTableView.h"

@interface PMPreviewMailVC () <UIAlertViewDelegate> {
    __weak IBOutlet UIScrollView *emailsScrollView;
    
    NSMutableArray *_currentSelectedArray;
    NSInteger _cellHeight;
}

- (IBAction)deleteMailBtnPressed:(id)sender;
- (IBAction)archiveMailBtnPressed:(id)sender;
- (IBAction)replyBtnPressed:(id)sender;
- (IBAction)replyAllBtnPressed:(id)sender;
- (IBAction)forwardBtnPressed:(id)sender;
- (IBAction)backBtnPressed:(id)sender;

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) PMPreviewMailTVCell *prototypeCell;

@end

@implementation PMPreviewMailVC

#pragma mark - PMPreviewMailVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentSelectedArray = [NSMutableArray new];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    PMPreviewTableView *previewTable = [PMPreviewTableView newPreviewView];
    previewTable.messages = _messages;
    previewTable.inboxMailModel = _inboxMailModel;
    
    CGRect previewFrame = previewTable.frame;
    previewFrame.size.width = emailsScrollView.frame.size.width;
    previewFrame.size.height = emailsScrollView.frame.size.height;
    [emailsScrollView addSubview:previewTable];
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
    
    NSDictionary *lItem = [_messages lastObject];
    lNewMailComposeVC.messageId = lItem[@"id"];
    
    PMDraftModel *lDraft = [PMDraftModel new];
    lDraft.to = [_messages lastObject][@"from"];
    
    if ([_inboxMailModel.subject hasPrefix:@"Re:"]) {
        lDraft.subject = _inboxMailModel.subject;
    } else {
        lDraft.subject = [NSString stringWithFormat:@"Re: %@", _inboxMailModel.subject];
    }
    lNewMailComposeVC.draft = lDraft;
    
    [self.tabBarController.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
}

- (void)replyAllBtnPressed:(id)sender {
    PMMailComposeVC *lNewMailComposeVC = [[PMMailComposeVC alloc] initWithStoryboard];
    
    NSDictionary *lItem = [_messages lastObject];
    lNewMailComposeVC.messageId = lItem[@"id"];
    
    PMDraftModel *lDraft = [PMDraftModel new];
    
    NSMutableArray *lEmailsArray = [NSMutableArray arrayWithArray:[_messages lastObject][@"from"]];
    [lEmailsArray addObjectsFromArray:[_messages lastObject][@"to"]];
    lDraft.to = lEmailsArray;
    lDraft.cc = [_messages lastObject][@"cc"];
    lDraft.bcc = [_messages lastObject][@"bcc"];
    
    if ([_inboxMailModel.subject hasPrefix:@"Re:"]) {
        lDraft.subject = _inboxMailModel.subject;
    } else {
        lDraft.subject = [NSString stringWithFormat:@"Re: %@", _inboxMailModel.subject];
    }
    lNewMailComposeVC.draft = lDraft;
    
    [self.tabBarController.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
}

- (void)forwardBtnPressed:(id)sender {
    PMMailComposeVC *lNewMailComposeVC = [[PMMailComposeVC alloc] initWithStoryboard];
    
    lNewMailComposeVC.messageId = @"";
    
    PMDraftModel *lDraft = [PMDraftModel new];
    
    if ([_inboxMailModel.subject hasPrefix:@"Fwd:"]) {
        lDraft.subject = _inboxMailModel.subject;
    } else {
        lDraft.subject = [NSString stringWithFormat:@"Fwd: %@", _inboxMailModel.subject];
    }
    lNewMailComposeVC.draft = lDraft;
    
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

#pragma mark - UIAlertView delegate 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        switch (alertView.tag) {
            case 0: {
                [[PMAPIManager shared] deleteMailWithThreadId:_inboxMailModel.messageId account:[PMAPIManager shared].namespaceId completion:^(id data, id error, BOOL success) {
                    
                    NSLog(@"deleteMailWithThreadId - %@", data);
                    if (_delegate && [_delegate respondsToSelector:@selector(PMPreviewMailVCDelegateAction:mail:)]) {
                        [_delegate PMPreviewMailVCDelegateAction:PMPreviewMailVCTypeActionDelete mail:_inboxMailModel];
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                break;
            }
            case 1: {
                [[PMAPIManager shared] archiveMailWithThreadId:_inboxMailModel.messageId account:[PMAPIManager shared].namespaceId completion:^(id data, id error, BOOL success) {
                    
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
