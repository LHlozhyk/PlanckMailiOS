//
//  PMMainVC.m
//  planckMailiOS
//
//  Created by Admin on 5/10/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMainVC.h"


@interface PMMainVC ()
@end

@implementation PMMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

@end
