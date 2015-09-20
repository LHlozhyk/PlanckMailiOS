//
//  LeftViewController.h
//  LGSideMenuControllerDemo
//
//  Created by Grigory Lutkov on 18.02.15.
//  Copyright (c) 2015 Grigory Lutkov. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LeftViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIColor *tintColor;

@end
