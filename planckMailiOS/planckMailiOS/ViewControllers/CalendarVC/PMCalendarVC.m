//
//  PMCalendarVC.m
//  planckMailiOS
//
//  Created by admin on 7/18/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMCalendarVC.h"

#import "UIViewController+PMStoryboard.h"
#import "PMCreateEventVC.h"

#import "LIYDateTimePickerViewController.h"
#import "LIYCalendarPickerViewController.h"
#import "PMAPIManager.h"

@interface PMCalendarVC ()
- (IBAction)menuBtnPressed:(id)sender;
- (IBAction)createEventBtnPressed:(id)sender;
@end

@implementation PMCalendarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"MMM. yyy"];
    [self setTitle:[df stringFromDate:[NSDate date]]];
    
    [[PMAPIManager shared] getCalendarsWithAccount:[[PMAPIManager shared] namespaceId] comlpetion:^(id data, id error, BOOL success) {
        
    }];
    
//    LIYDateTimePickerViewController *vc = [LIYDateTimePickerViewController timePickerForDate:[NSDate date] delegate:nil];
//    vc.showCalendarPickerButton = YES;
//    vc.showEventTimes = YES;
//    vc.showDateInDayColumnHeader = NO;
//    vc.allowTimeSelection = NO;
//    [vc setVisibleCalendarsFromUserDefaults];
//    
//    [self addChildViewController:vc];
//    vc.view.frame = self.view.frame;
//    [self.view addSubview:vc.view];
//    [vc didMoveToParentViewController:self];
    
}

#pragma mark - IBAction selectors

- (IBAction)menuBtnPressed:(id)sender {
    
}

- (IBAction)createEventBtnPressed:(id)sender {
    PMCreateEventVC *lNewEventVC = [[PMCreateEventVC alloc] initWithStoryboard];
    [self.tabBarController presentViewController:lNewEventVC animated:YES completion:nil];
}


@end
