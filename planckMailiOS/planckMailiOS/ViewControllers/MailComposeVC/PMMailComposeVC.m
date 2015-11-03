//
//  PMMailComposeVC.m
//  planckMailiOS
//
//  Created by admin on 6/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMailComposeVC.h"

#import "PMSelectionEmailView.h"
#import "PMMailComposeTVCell.h"
#import "PMMailComposeBodyTVCell.h"
#import "PMAPIManager.h"
#import "MBProgressHUD.h"
#import "PMFileItem.h"
#import "PMFileManager.h"
#import "PMMailComposeAttachCell.h"
#import <AFNetworking/UIProgressView+AFNetworking.h>
#import "PMFilesNC.h"

@interface PMMailComposeVC () <PMSelectionEmailViewDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, PMMailComposeTVCellDelegate, PMMailComposeBodyTVCellDelegate, PMMailComposeAttachCellDelegate> {
    __weak IBOutlet UIBarButtonItem *_sentBarBtn;
    __weak IBOutlet UIBarButtonItem *attachBarBtn;
    __weak IBOutlet UIButton *_emailBtn;
    __weak IBOutlet UITableView *_tableView;
    
    __weak IBOutlet UITextField *_toTextField;
    __weak IBOutlet UITextField *_cCTextField;
    __weak IBOutlet UITextField *_subjectTextField;
    __weak IBOutlet UITextView *_bodyTextView;
    
    NSMutableDictionary *_dataInfo;
    
    
    NSMutableDictionary *uploadedFlags;
    NSMutableDictionary *fileIds;
}
- (IBAction)closeBtnPressed:(id)sender;
- (IBAction)sentBtnPressed:(id)sender;
- (IBAction)selectMailBtnPressed:(id)sender;
- (IBAction)attachBtnPressed:(id)sender;
@end

static int nUploadingCount = 0;

@implementation PMMailComposeVC

#pragma mark - PMMailComposeVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataInfo = [NSMutableDictionary dictionary];
    
    NSArray *_itemsArray = [[DBManager instance] getNamespaces];
    
    DBNamespace *lItemModel = [_itemsArray objectAtIndex:0];
    _emails = lItemModel.email_address;
    [_emailBtn setTitle:lItemModel.email_address forState:UIControlStateNormal];
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    

    
    uploadedFlags = [[NSMutableDictionary alloc] init];
    
    [self performSelector:@selector(uploadFiles) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) uploadFiles
{
    for(int i=0; i<_files.count; i++)
    {
        NSString *filepath = _files[i];
        
        NSNumber *uploadedFlag = [uploadedFlags objectForKey:filepath];
        if(uploadedFlag==nil || [uploadedFlag boolValue]==NO)
        {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4+i inSection:0];
            PMMailComposeAttachCell *attachcell = [_tableView cellForRowAtIndexPath:indexPath];
            
            
            NSURLSessionUploadTask *uploadTask = [[PMAPIManager shared] uploadFileWithAccount:[PMAPIManager shared].namespaceId filepath:filepath completion:^(NSURLResponse *response, id responseObject, NSError *error) {
                
                NSDictionary *jsonResult = (NSDictionary*)responseObject[0];
                
                NSLog(@"File upload response: %@", jsonResult);
                NSString *fileId = [jsonResult objectForKey:@"id"];
                
                
                if(fileIds==nil) fileIds = [[NSMutableDictionary alloc] init];
                [fileIds setObject:fileId forKey:filepath];
                
                nUploadingCount--;
                if(nUploadingCount == 0) _sentBarBtn.enabled = YES;
                
                attachcell.progressView.hidden = YES;
            }];
            _sentBarBtn.enabled = NO; nUploadingCount++;
            [uploadTask resume];
            
            [attachcell.progressView setProgressWithUploadProgressOfTask:uploadTask animated:YES];
            
            
            
            [uploadedFlags setObject:[NSNumber numberWithBool:YES] forKey:filepath];
            
        }
    }
}

-(void)didClickAttachDeleteButton:(NSString *)filepath
{
    [_files removeObject:filepath];
    [fileIds removeObjectForKey:filepath];
    [_tableView reloadData];
}
#pragma mark - Private methods

//- (BOOL)validateEmailWithString:(NSString*)checkString {
//    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
//    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
//    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
//    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
//    return [emailTest evaluateWithObject:checkString];
//}

- (NSMutableArray*)validateEmailWithString:(NSString*)emails {
    NSMutableArray *validEmails = [[NSMutableArray alloc] init];
    NSArray *emailArray = [emails componentsSeparatedByString:@" "];
    for (NSString *email in emailArray)
    {
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if ([emailTest evaluateWithObject:email])
            [validEmails addObject:email];
    }
    return validEmails;
}

#pragma mark - IBAction selectors

- (void)closeBtnPressed:(id)sender {
    UIActionSheet *lNewActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Draft" otherButtonTitles:@"Save Draft", nil];
    [lNewActionSheet showInView:self.view];
}

- (NSString *)getToString {
    NSMutableString *lToStr = [NSMutableString string];
    for (NSDictionary *item in _draft.to) {
        [lToStr appendString:[NSString stringWithFormat:@" %@", item[@"email"]]];
    }
    return lToStr;
}

- (NSString *)getCcString {
    NSMutableString *lCcStr = [NSMutableString string];
    for (NSDictionary *item in _draft.cc) {
        [lCcStr appendString:[NSString stringWithFormat:@" %@", item[@"email"]]];
    }
    return lCcStr;
}

- (NSString *)getBccString {
    NSMutableString *lBccStr = [NSMutableString string];
    for (NSDictionary *item in _draft.to) {
        [lBccStr appendString:[NSString stringWithFormat:@" %@", item[@"email"]]];
    }
    return lBccStr;
}

- (NSDictionary *)getSendMessageParams {
    NSString *lEmailsTo = _dataInfo[@"toCell"] ? : [self getToString];
    NSArray *emailToArray = [self validateEmailWithString:lEmailsTo];
    
    NSString *lEmailsCc = _dataInfo[@"CcCell"] ? : [self getCcString];
    NSArray *emailCcArray = [self validateEmailWithString:lEmailsCc];
    
    NSString *lEmailsBcc = _dataInfo[@"bccCell"] ? : [self getBccString];
    NSArray *emailBccArray = [self validateEmailWithString:lEmailsBcc];
    NSDictionary *lRequsetParmeters = nil;
    
    if ([emailToArray count] > 0) {
        
        NSMutableArray *lTo = [NSMutableArray array];
        
        for (NSString *item in emailToArray) {
            if (![item isEqualToString:@""]) {
                [lTo addObject:@{
                                 @"name": @"",
                                 @"email": item
                                 }];
            }
        }
        NSMutableArray *lCc = [NSMutableArray array];
        for (NSString *item in emailCcArray) {
            if (![item isEqualToString:@""]) {
                [lCc addObject:@{
                                 @"name": @"",
                                 @"email": item
                                 }];
            }
        }
        NSMutableArray *lBcc = [NSMutableArray array];
        for (NSString *item in emailBccArray) {
            if (![item isEqualToString:@""]) {
                [lBcc addObject:@{
                                  @"name": @"",
                                  @"email": item
                                  }];
            }
        }
        
        NSString *lSubject = _dataInfo[@"SubjectCell"] ? : _draft.subject;
        
        
        NSString *lBody = _dataInfo[@"TextViewCell"] ? : @"Sent from PlanckMailiOS";
        
        NSArray *fileIdArray = [fileIds allValues];
        
        
        if ([_messageId isEqualToString:@""] || _messageId == nil) {
            
            lRequsetParmeters = @{
                                  @"body" : lBody,
                                  @"subject" : lSubject,
                                  @"to" : lTo,
                                  @"bcc" : lBcc,
                                  @"cc" : lCc,
                                  @"from":@[
                                          @{
                                              @"name": @"",
                                              @"email": _emails
                                              }
                                          ],
                                  @"file_ids": fileIdArray,
                                  @"version" : [NSNumber numberWithInt:1]
                                  };
        } else {
            lRequsetParmeters = @{
                                  @"reply_to_message_id": _messageId,
                                  @"body" : lBody,
                                  @"subject" : lSubject,
                                  @"to" : lTo,
                                  @"bcc" : lBcc,
                                  @"cc" : lCc,
                                  @"from":@[
                                          @{
                                              @"name": @"",
                                              @"email": _emails
                                              }
                                          ],
                                  @"file_ids": fileIdArray,
                                  @"version" : [NSNumber numberWithInt:1]
                                  };
        }
    }
    return lRequsetParmeters;
}

- (void)sentBtnPressed:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary * lSendParams = [self getSendMessageParams];
    if (lSendParams != nil) {
        
        [[PMAPIManager shared] replyMessage:lSendParams completion:^(id data, id error, BOOL success) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    } else {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Invalid Recipients" message:@"One or more of the recipients you provided doesn't have a valid email address. If you continue, your message will not be sent to these recipients." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil] show];
    }
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

- (IBAction)attachBtnPressed:(id)sender {
    PMFilesNC *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMFilesNC"];
    
    controller.isSelecting = YES;
    [self presentViewController:controller animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneSelectFile:) name:@"DoneSelectFile" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canceledSelectFile:) name:@"CanceledSelectFile" object:nil];
}
-(void) doneSelectFile:(NSNotification*) notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSString *filepath = [userInfo objectForKey:@"filepath"];
    
    if(_files == nil) _files = [[NSMutableArray alloc] init];
    
    if(![_files containsObject:filepath])
    {
        [_files addObject:filepath];
        [_tableView reloadData];
        
        [self performSelector:@selector(uploadFiles) withObject:nil afterDelay:.1];
        
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) canceledSelectFile:(NSNotification*) notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        [(PMMailComposeTVCell*)lCell setDelegate:self];
        
        if ([_dataInfo count] == 0) {
            NSMutableString *lToStr = [NSMutableString string];
            for (NSDictionary *item in _draft.to) {
                [lToStr appendString:[NSString stringWithFormat:@" %@", item[@"email"]]];
            }
            [(PMMailComposeTVCell*)lCell setContentText:lToStr];
        }
    } else if (indexPath.row == 1) {
        lCell = [tableView dequeueReusableCellWithIdentifier:@"CcCell"];
        if ([_dataInfo count] == 0) {
            [(PMMailComposeTVCell*)lCell setDelegate:self];
            NSMutableString *lToStr = [NSMutableString string];
            for (NSDictionary *item in _draft.cc) {
                [lToStr appendString:[NSString stringWithFormat:@" %@", item[@"email"]]];
            }
            [(PMMailComposeTVCell*)lCell setContentText:lToStr];
        }
    } else if (indexPath.row == 2) {
        lCell = [tableView dequeueReusableCellWithIdentifier:@"BccCell"];
        [(PMMailComposeTVCell*)lCell setDelegate:self];
        if ([_dataInfo count] == 0) {
            NSMutableString *lToStr = [NSMutableString string];
            for (NSDictionary *item in _draft.bcc) {
                [lToStr appendString:[NSString stringWithFormat:@" %@", item[@"email"]]];
            }
            [(PMMailComposeTVCell*)lCell setContentText:lToStr];
        }
    } else if (indexPath.row == 3) {
        lCell = [tableView dequeueReusableCellWithIdentifier:@"SubjectCell"];
        [(PMMailComposeTVCell*)lCell setDelegate:self];
        if ([_dataInfo count] == 0) {
            [(PMMailComposeTVCell*)lCell setContentText:_draft.subject];
        }
    } else if (indexPath.row == (4+_files.count)) {
        lCell = [tableView dequeueReusableCellWithIdentifier:@"TextViewCell"];
        [(PMMailComposeBodyTVCell*)lCell setDelegate:self];
    }
    
    if(_files.count > 0)
    {
        if(indexPath.row >= 4 && indexPath.row < 4 + _files.count)
        {
            
            lCell = [tableView dequeueReusableCellWithIdentifier:@"AttachCell"];
            
            NSString *filepath = _files[indexPath.row - 4];
            
            [((PMMailComposeAttachCell*)lCell) bindModel:filepath];
            ((PMMailComposeAttachCell*)lCell).delegate = self;
        }
    }

    return lCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5 + _files.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == (4+_files.count)) {
        return 1000;
    } else return 44;
}

#pragma mark - UITableView delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case 1: {
            DLog(@"save draft");
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSDictionary * lSendParams = [self getSendMessageParams];
            if (lSendParams != nil) {
                
                [[PMAPIManager shared] createDrafts:lSendParams completion:^(id data, id error, BOOL success) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
            } else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [[[UIAlertView alloc] initWithTitle:@"Invalid Recipients" message:@"One or more of the recipients you provided doesn't have a valid email address. If you continue, your message will not be sent to these recipients." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil] show];
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - PMMailComposeTVCell delegates 

- (void)PMMailComposeTVCellDelegate:(PMMailComposeTVCell *)cell contentTextDidChange:(NSString *)contentText {
    if ([cell.reuseIdentifier isEqualToString:@"toCell"]) {
        [_dataInfo setObject:contentText forKey:@"toCell"];
        
    } else if ([cell.reuseIdentifier isEqualToString:@"CcCell"]) {
        [_dataInfo setObject:contentText forKey:@"CcCell"];
        
    } else if ([cell.reuseIdentifier isEqualToString:@"SubjectCell"]) {
        [_dataInfo setObject:contentText forKey:@"SubjectCell"];
        
    } else if ([cell.reuseIdentifier isEqualToString:@"BccCell"]) {
        [_dataInfo setObject:contentText forKey:@"BccCell"];
    }
}

#pragma mark - PMMailComposeBodyTVCell delegates

- (void)PMMailComposeBodyTVCellDelegate:(PMMailComposeBodyTVCell *)cell contentTextDidChange:(NSString *)contentText {
    if ([cell.reuseIdentifier isEqualToString:@"TextViewCell"]) {
        [_dataInfo setObject:contentText forKey:@"TextViewCell"];
        
    }
}

@end
