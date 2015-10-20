//
//  PMAlertViewController.m
//  planckMailiOS
//
//  Created by nazar on 10/19/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMAlertViewController.h"
#import "PMAlertCollectionViewCell.h"
@interface PMAlertViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *iconsArray;
@property (nonatomic, strong) NSArray *titlesArray;
@end

@implementation PMAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.iconsArray = @[[UIImage imageNamed:@"snooze_1.png"], [UIImage imageNamed:@"snooze_2.png"], [UIImage imageNamed:@"snooze_3.png"], [UIImage imageNamed:@"snooze_4.png"], [UIImage imageNamed:@"snooze_5.png"], [UIImage imageNamed:@"snooze_6.png"], [UIImage imageNamed:@"snooze_7.png"], [UIImage new], [UIImage new]];
    
    self.titlesArray = @[@"Later Today", @"This Evening", @"Tomorrow", @"This Weekend", @"Next Week", @"In a Month", @"Someday", @"", @"Pick a Date"];
    
    [self confrigurCollectionView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configuring UI Elements

-(void)confrigurCollectionView {

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    UINib *nib = [UINib nibWithNibName:@"PMAlertCollectionViewCell" bundle:nil];
    [self.collectionView registerClass:[PMAlertCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"Cell"];

}

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

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    


    
    if ([self.delegate respondsToSelector:@selector(PMAlertViewControllerDissmis:)]) {
        [self.delegate PMAlertViewControllerDissmis:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    
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
