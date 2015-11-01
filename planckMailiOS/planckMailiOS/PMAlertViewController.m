//
//  PMAlertViewController.m
//  planckMailiOS
//
//  Created by nazar on 10/19/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMAlertViewController.h"
#import "PMAlertCollectionViewCell.h"
#import "PMAPIManager.h"
#import "PMStorageManager.h"
#import "MBProgressHUD.h"

@interface PMAlertViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *iconsArray;
@property (nonatomic, strong) NSArray *titlesArray;
@property (nonatomic, strong) UITextField *fakeTextField;
@property (nonatomic, strong) UIDatePicker *datePicker;
@end

@implementation PMAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.iconsArray = @[[UIImage imageNamed:@"snooze_1.png"], [UIImage imageNamed:@"snooze_2.png"], [UIImage imageNamed:@"snooze_3.png"], [UIImage imageNamed:@"snooze_4.png"], [UIImage imageNamed:@"snooze_5.png"], [UIImage imageNamed:@"snooze_6.png"], [UIImage imageNamed:@"snooze_7.png"], [UIImage new], [UIImage new]];
    
    self.titlesArray = @[@"Later Today", @"This Evening", @"Tomorrow", @"This Weekend", @"Next Week", @"In a Month", @"Someday", @"", @"Pick a Date"];
    
    [self confrigurCollectionView];
    [self configureFakeTextField];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configuring UI Elements

-(void)configureDatePicker {

    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 20, 200)];
    self.datePicker.backgroundColor = [UIColor whiteColor];
}

-(void)configureFakeTextField {

    self.fakeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    
    [self configureDatePicker];
    self.fakeTextField.inputView = self.datePicker;
    [self.collectionView addSubview:self.fakeTextField];


}

-(UIView*)configureActionsView {

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];

    UIButton *snoozesButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    snoozesButton.titleLabel.text = @"SNOOZES";
    
    UIButton *setDateButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 0, 10, 10)];
    setDateButton.titleLabel.text = @"SET DATE";
    
    
    [view addSubview:snoozesButton];
    [view addSubview:setDateButton];
    
    
    
    return view;
}

-(void)confrigurCollectionView {

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    UINib *nib = [UINib nibWithNibName:@"PMAlertCollectionViewCell" bundle:nil];
    [self.collectionView registerClass:[PMAlertCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"Cell"];

}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.titlesArray count];
}


-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    PMAlertCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

      cell.imageView.image = self.iconsArray[indexPath.row];
    cell.titleLabel.text = self.titlesArray[indexPath.row];

    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 8) {
        [self.fakeTextField becomeFirstResponder];
    } else {
        NSString *scheduledFolderId = [PMStorageManager getScheduledFolderIdForAccount:[PMAPIManager shared].namespaceId.namespace_id];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        if ([scheduledFolderId length] > 0) {
            
            [self moveMeilToFollowUp];
            
        } else {
            __weak typeof(self)__self = self;
            [[PMAPIManager shared] createFolderWithName:SCHEDULED account:[PMAPIManager shared].namespaceId comlpetion:^(id data, id error, BOOL success) {
                
                if (!error) {
                    NSDictionary *dict = (NSDictionary*)data;
                    DLog(@"dict = %@", dict);
                    NSString *scheduledID = dict[@"id"];
                    [PMStorageManager setScheduledFolderId:scheduledID forAccount:[PMAPIManager shared].namespaceId.namespace_id];
                    [__self moveMeilToFollowUp];
                } else {
                    DLog(@"error = %@", error);
                    [MBProgressHUD hideAllHUDsForView:__self.view animated:YES];
                }
            }];
        }
    }
}

#pragma mark - Actions

- (IBAction)dismissOnTapAction:(id)sender {
    [self dismissVc];
}

-(void)dismissVc {
    if ([self.delegate respondsToSelector:@selector(PMAlertViewControllerDissmis:)]) {
        [self.delegate PMAlertViewControllerDissmis:self];
    }
   
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) moveMeilToFollowUp {
    NSString *scheduledFolderId = [PMStorageManager getScheduledFolderIdForAccount:[PMAPIManager shared].namespaceId.namespace_id];
    
    __weak typeof(self)__self = self;
    DLog(@" messageId %@\n scheduledFolderId = %@",_inboxMailModel.messageId, scheduledFolderId);
    if (_inboxMailModel.messageId) {
        [[PMAPIManager shared] moveMailWithThreadId:_inboxMailModel account:[PMAPIManager shared].namespaceId toFolder:scheduledFolderId completion:^(id data, id error, BOOL success) {
            if(!error) {
                if ([__self.delegate respondsToSelector:@selector(didShoozedMeil:)]) {
                    [__self.delegate didShoozedMeil:__self.inboxMailModel];
                }
            }
            
            [__self dismissVc];
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
