//
//  PMMainVC.m
//  planckMailiOS
//
//  Created by Admin on 5/10/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMainVC.h"
#import "PMLoginVC.h"

@interface PMMainVC () <UIGestureRecognizerDelegate, PMLoginVCDelegate>
@end

@implementation PMMainVC

#pragma mark - PMMainVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PMLoginVC *lLoginVC = [segue destinationViewController];
    [lLoginVC setDelegate:self];
}

#pragma mark - LoginVC delegate

- (void)PMLoginVCDelegate:(PMLoginVC *)loginVC didSuccessLogin:(BOOL)state additionalAccount:(BOOL)additionalAccount {
    if (state && !additionalAccount) {
        UITabBarController *lMainTabBar = [STORYBOARD instantiateViewControllerWithIdentifier:@"MainTabBar"];
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController pushViewController:lMainTabBar animated:YES];
    }
}

@end
