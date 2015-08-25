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
    
    LIYDateTimePickerViewController *vc = [LIYDateTimePickerViewController timePickerForDate:[NSDate date] delegate:nil];
    vc.showCalendarPickerButton = YES;
    vc.showEventTimes = YES;
    vc.showDateInDayColumnHeader = NO;
    vc.allowTimeSelection = NO;
    [vc setVisibleCalendarsFromUserDefaults];
    
    [self addChildViewController:vc];
    vc.view.frame = self.view.frame;
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
}

@end
