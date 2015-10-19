//
//  MainViewController.m
//  LGSideMenuControllerDemo
//
//  Created by Grigory Lutkov on 25.04.15.
//  Copyright (c) 2015 Grigory Lutkov. All rights reserved.
//

#import "MainViewController.h"
#import "LeftViewController.h"
#import "AppDelegate.h"
#import "DBManager.h"
#import "Config.h"

@interface MainViewController ()

@property (strong, nonatomic) LeftViewController *leftViewController;


@end

@implementation MainViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
//    self.view.backgroundColor = [UIColor whiteColor];
    NSArray *lNamespacesArray = [[DBManager instance] getNamespaces];
    self.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
    if (lNamespacesArray.count > 0) {
        UITabBarController *lTabController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        [(UINavigationController *)self.rootViewController setNavigationBarHidden:YES];
        [(UINavigationController*)self.rootViewController pushViewController:lTabController animated:NO];
    }
    
    _leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftViewController"];

    [self setLeftViewEnabledWithWidth:230.0f
                    presentationStyle:LGSideMenuPresentationStyleScaleFromBig
                 alwaysVisibleOptions:0];
    self.leftViewBackgroundColor = NAVIGATION_BAR_TIN_COLOR;
    _leftViewController.tableView.backgroundColor = [UIColor clearColor];
     _leftViewController.view.backgroundColor = [UIColor clearColor];
    _leftViewController.tintColor = [UIColor whiteColor];
    [_leftViewController.tableView reloadData];
    [self.leftView addSubview:_leftViewController.view];
    self.rootViewLayerShadowRadius = 0;
    self.rootViewLayerShadowColor = [UIColor clearColor];
    self.rootViewLayerBorderColor = [UIColor clearColor];
    self.mainTitle.textColor = [UIColor whiteColor];
    self.mainTitle.text = @"PLANCK";
}

- (void)leftViewWillLayoutSubviewsWithSize:(CGSize)size {
    [super leftViewWillLayoutSubviewsWithSize:size];
    
    _leftViewController.view.frame = CGRectMake(0.f , 66.f, size.width, size.height);
}


@end
