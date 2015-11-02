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

@interface PMPreviewMailVC () <UIAlertViewDelegate, UIScrollViewDelegate, PMPreviewTableViewDelegate> {
    __weak IBOutlet UIScrollView *emailsScrollView;
    
    NSMutableArray *_currentSelectedArray;
    NSInteger _cellHeight;
    
    NSMutableDictionary *addedEmailTables;
    NSInteger prevMailIndex;
    NSInteger currentTableIndex;
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
    
    //scrollView content size
    CGSize scrollSize = emailsScrollView.contentSize;
    NSInteger widthMultiplier = ([_inboxMailArray count] > 2 ? 3 : [_inboxMailArray count]);
    if((_selectedMailIndex == 0 || _selectedMailIndex == [_inboxMailArray count] - 1) && widthMultiplier > 2) {
        widthMultiplier = 2;
    }
    scrollSize.width = SCREEN_WIDTH * widthMultiplier;
    emailsScrollView.contentSize = scrollSize;
    
    currentTableIndex = _selectedMailIndex == 0 ? 0 : 1;
    
    //scrollView content offset
    CGPoint scrollOffset = emailsScrollView.contentOffset;
    CGFloat scrollOffsetX = ([_inboxMailArray count] > 2 || _selectedMailIndex == 1) && (_selectedMailIndex != 0) ? SCREEN_WIDTH : 0.f;
    scrollOffset.x = scrollOffsetX;
    emailsScrollView.contentOffset = scrollOffset;
    
    prevMailIndex = _selectedMailIndex;
    [self updatePreviewTables];
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger selectedIndex = 1;
    BOOL shouldUpdate = NO;
    
    if(scrollView.contentOffset.x < scrollView.frame.size.width) {
        selectedIndex = 0;
    } else if (scrollView.contentOffset.x >= scrollView.frame.size.width &&
               scrollView.contentOffset.x < scrollView.frame.size.width * 2) {
        selectedIndex = 1;
    } else if (scrollView.contentOffset.x >= scrollView.frame.size.width * 2) {
        selectedIndex = 2;
    }
    
    NSInteger indexOffset = 0;
    if(selectedIndex != currentTableIndex) {
        shouldUpdate = YES;
        indexOffset = selectedIndex - currentTableIndex;
    }
    
    if(shouldUpdate) {
        prevMailIndex = _selectedMailIndex;
        _selectedMailIndex += indexOffset;
        
        self.messages = nil;
        self.inboxMailModel = _inboxMailArray[_selectedMailIndex];
        
        currentTableIndex = _selectedMailIndex == 0 ? 0 : 1;
        
        [self updatePreviewTables];
    }
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        switch (alertView.tag) {
            case 0: {
                [[PMAPIManager shared] deleteMailWithThreadId:_inboxMailModel.messageId account:[PMAPIManager shared].namespaceId completion:^(id data, id error, BOOL success) {
                    
                    DLog(@"deleteMailWithThreadId - %@", data);
                    if (_delegate && [_delegate respondsToSelector:@selector(PMPreviewMailVCDelegateAction:mail:)]) {
                        [_delegate PMPreviewMailVCDelegateAction:PMPreviewMailVCTypeActionDelete mail:_inboxMailModel];
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                break;
            }
            case 1: {
                [[PMAPIManager shared] archiveMailWithThreadId:_inboxMailModel account:[PMAPIManager shared].namespaceId completion:^(id data, id error, BOOL success) {
                    
                    DLog(@"archiveMailWithThreadId - %@", data);
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

#pragma mark - PMPreviewTableViewDelegate

- (void)PMPreviewTableView:(PMPreviewTableView *)previewTable didUpdateMessages:(NSArray *)messages {
    if([_inboxMailModel isEqual:previewTable.inboxMailModel]) {
        self.messages = [messages copy];
    }
}

#pragma mark - Private methods

- (void)updatePreviewTables {
    if(prevMailIndex != _selectedMailIndex) {
        //find index of table to delete
        NSInteger indexToDelete = 0;
        NSInteger indexToUpdate = -1;
        if(prevMailIndex < _selectedMailIndex) {
            indexToDelete = prevMailIndex - 1;
            if(_selectedMailIndex < [_inboxMailArray count] - 1) {
                indexToUpdate = 2;
            }
        } else {
            indexToDelete = prevMailIndex + 1;
            if(_selectedMailIndex > 0) {
                indexToUpdate = 0;
            }
        }
        PMPreviewTableView *previewTableToDelete = addedEmailTables[@(indexToDelete)];
        if(previewTableToDelete) {
            [previewTableToDelete removeFromSuperview];
            [addedEmailTables removeObjectForKey:@(indexToDelete)];
            previewTableToDelete = nil;
        }
        
        [self shiftTables];
        
        if(indexToUpdate >= 0) {
            [self addPreviewTableForIndex:indexToUpdate];
        }
    } else if (!addedEmailTables) {
        addedEmailTables = [NSMutableDictionary new];
        
        NSInteger indexesCount = [_inboxMailArray count] > 2 ? 3 : [_inboxMailArray count];
        if(_selectedMailIndex == 0 || _selectedMailIndex == [_inboxMailArray count] - 1) {
            indexesCount--;
        }
        for(NSInteger i = 0; i < indexesCount; i++) {
            [self addPreviewTableForIndex:i];
        }
    }
}

- (void)addPreviewTableForIndex:(NSInteger)index {
    PMPreviewTableView *previewTable = [PMPreviewTableView newPreviewView];
    previewTable.delegate = self;
    NSInteger mailIndex = _selectedMailIndex + (index - 1);
    if(_selectedMailIndex == 0 || _selectedMailIndex == [_inboxMailArray count]) {
        mailIndex++;
    }
    previewTable.inboxMailModel = _inboxMailArray[mailIndex];
    
    CGRect previewFrame = previewTable.frame;
    previewFrame.origin.x = SCREEN_WIDTH * index;
    previewFrame.size.width = emailsScrollView.frame.size.width;
    previewFrame.size.height = emailsScrollView.frame.size.height;
    previewTable.frame = previewFrame;
    [emailsScrollView addSubview:previewTable];
    
    [addedEmailTables setObject:previewTable forKey:@(mailIndex)];
}

- (void)shiftTables {
    if([_inboxMailArray count] < 3) {
        return;
    }
    
    //change content offset and shift tables
    BOOL doOffset = NO;
    CGFloat offsetValue = 0;
    if(_selectedMailIndex > prevMailIndex && prevMailIndex != 0) {
        doOffset = YES;
        offsetValue = -SCREEN_WIDTH;
    } else if (_selectedMailIndex < prevMailIndex) {
        if(_selectedMailIndex > 0) {
            doOffset = YES;
            offsetValue = SCREEN_WIDTH;
        }
    }
    if (doOffset) {
        for(UIView *previreTable in [addedEmailTables allValues]) {
            CGRect viewFrame = previreTable.frame;
            viewFrame.origin.x += offsetValue;
            previreTable.frame = viewFrame;
        }
        
        CGPoint scrollOffset = emailsScrollView.contentOffset;
        scrollOffset.x = SCREEN_WIDTH;
        emailsScrollView.contentOffset = scrollOffset;
    }
    
    //change content size
    if(prevMailIndex == 0 || prevMailIndex == [_inboxMailArray count] - 1) {//moved from edge
        CGSize scrollSize = emailsScrollView.contentSize;
        scrollSize.width = SCREEN_WIDTH * ([_inboxMailArray count] > 2 ? 3 : [_inboxMailArray count]);
        emailsScrollView.contentSize = scrollSize;
    } else if (_selectedMailIndex == 0 || _selectedMailIndex == [_inboxMailArray count] - 1) {
        CGSize scrollSize = emailsScrollView.contentSize;
        scrollSize.width = SCREEN_WIDTH * 2;
        emailsScrollView.contentSize = scrollSize;
    }
}



@end
