//
//  PMCalendarVC.m
//  planckMailiOS
//
//  Created by admin on 7/18/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMCalendarVC.h"
#import "LIYDateTimePickerViewController.h"
#import "LIYCalendarPickerViewController.h"

@interface PMCalendarVC ()

@end

@implementation PMCalendarVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    LIYDateTimePickerViewController *vc = [LIYDateTimePickerViewController timePickerForDate:[NSDate date] delegate:nil];
    vc.showCalendarPickerButton = YES;
    vc.showEventTimes = YES;
    vc.showDateInDayColumnHeader = NO;
    vc.allowTimeSelection = NO;
    [vc setVisibleCalendarsFromUserDefaults];
    [vc.navigationItem setHidesBackButton:YES];
    [self.navigationController pushViewController:vc animated:NO];
}

@end
