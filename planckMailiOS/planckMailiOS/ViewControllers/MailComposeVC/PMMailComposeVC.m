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
#import "PMAPIManager.h"

@interface PMMailComposeVC () <PMSelectionEmailViewDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, PMMailComposeTVCellDelegate> {
    __weak IBOutlet UIBarButtonItem *_sentBarBtn;
    __weak IBOutlet UIButton *_emailBtn;
    __weak IBOutlet UITableView *_tableView;
    
    __weak IBOutlet UITextField *_toTextField;
    __weak IBOutlet UITextField *_cCTextField;
    __weak IBOutlet UITextField *_subjectTextField;
    __weak IBOutlet UITextView *_bodyTextView;
    
    NSMutableDictionary *_dataInfo;
}
- (IBAction)closeBtnPressed:(id)sender;
- (IBAction)sentBtnPressed:(id)sender;
- (IBAction)selectMailBtnPressed:(id)sender;
@end

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

- (void)sentBtnPressed:(id)sender {
    
    NSString *lEmailsTo = _dataInfo[@"toCell"];
    BOOL lIsValidEmailTo = [self validateEmailWithString:lEmailsTo];

    NSString *lEmailsCc = _dataInfo[@"CcCell"];
    BOOL lIsValidEmailCc = [self validateEmailWithString:lEmailsCc];
    
    if (lIsValidEmailTo && lIsValidEmailCc) {
        
        NSString *lSubject = _dataInfo[@"SubjectCell"];
        
       NSDictionary *lRequsetParmeters = @{
            @"reply_to_message_id": _messageId,
            @"body" : @"Sounds great! See you then.",
            
            @"to": @[
                   @{
                       @"name": @"",
                       @"email": lEmailsTo
                   }
                   ]
            };
        [[PMAPIManager shared] replyMessage:lRequsetParmeters completion:^(id data, id error, BOOL success) {
            
        }];
    } else {
       NSLog(@"error");
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

#pragma mark - PMSelectionEmailView delegates

- (void)PMSelectionEmailViewDelegate:(PMSelectionEmailView *)view didSelectEmail:(NSString *)emeil {
    _emails = emeil;
    [_emailBtn setTitle:emeil forState:UIControlStateNormal];
}

#pragma mark - UITableView data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMMailComposeTVCell *lCell;
    if (indexPath.row == 0) {
        lCell = [tableView dequeueReusableCellWithIdentifier:@"toCell"];
        [lCell setDelegate:self];
    } else if (indexPath.row == 1) {
        lCell = [tableView dequeueReusableCellWithIdentifier:@"CcCell"];
        [lCell setDelegate:self];
    } else if (indexPath.row == 2) {
        lCell = [tableView dequeueReusableCellWithIdentifier:@"SubjectCell"];
        [lCell setDelegate:self];
    } else if (indexPath.row == 3) {
        lCell = [tableView dequeueReusableCellWithIdentifier:@"TextViewCell"];
    }

    return lCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
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
    }
}

@end
