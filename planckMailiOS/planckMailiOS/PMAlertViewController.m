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

@interface PMAlertViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *iconsArray;
@property (nonatomic, strong) NSArray *titlesArray;
@property (nonatomic, strong) UITextField *fakeTextField;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIAlertView *alertView;
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
    
    
//    [[PMAPIManager shared] deleteFolderWithId:@"36m61hvf5qidcc6l40r8au09u" account:[PMAPIManager shared].namespaceId completion:^(id data, id error, BOOL success) {
//        
//    }];
    
    if (indexPath.row == 8) {
        [self.fakeTextField becomeFirstResponder];
    }else {
    
        
        NSString *scheduledFolderId = [PMStorageManager getScheduledFolderIdForAccount:[PMAPIManager shared].namespaceId.namespace_id];
        DLog(@"scheduledFolderId = %@", scheduledFolderId);

        if (![scheduledFolderId isEqualToString:@""] && ![scheduledFolderId isKindOfClass:[NSNull class]] && scheduledFolderId != nil) {
        
        NSString *scheduledFolderId = [PMStorageManager getScheduledFolderIdForAccount:[PMAPIManager shared].namespaceId.namespace_id];
       
            DLog(@" messageId %@\n scheduledFolderId = %@",_inboxMailModel.messageId, scheduledFolderId);
       
            if (scheduledFolderId && _inboxMailModel.messageId) {
            
                [[PMAPIManager shared] moveMailWithThreadId:_inboxMailModel.messageId account:[PMAPIManager shared].namespaceId toFolder:scheduledFolderId completion:^(id data, id error, BOOL success) {
               
                    if (error) {
                   
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You can't move   mail" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:self cancelButtonTitle:@"I got it." otherButtonTitles:nil, nil];
                       [alert show];

                }
            }];

        }
      
    }else {
        [self showAlert];
        return;
        
    }
    
    [self dismissVc];
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

#pragma mark - Alerts Stuff

-(void)showAlert {
    
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Do you want to create new folder with name 'Follow up' ?" message:nil delegate:self cancelButtonTitle:@"No, thanks." otherButtonTitles:@"Yes!", nil];
    [self.alertView show];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 1) {
        
        [[PMAPIManager shared] createFolderWithName:SCHEDULED account:[PMAPIManager shared].namespaceId comlpetion:^(id data, id error, BOOL success) {
            
            if (!error) {
                
                NSDictionary *dict = (NSDictionary*)data;
                DLog(@"dict = %@", dict);
                [PMStorageManager setScheduledFolderId:dict[@"id"] forAccount:[PMAPIManager shared].namespaceId.namespace_id];
                
            }else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You can't create folder" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:self cancelButtonTitle:@"I got it." otherButtonTitles:nil, nil];
                [alert show];

                DLog(@"error = %@", error);
                
            }
            
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
