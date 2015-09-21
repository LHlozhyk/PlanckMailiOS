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
#import "PMEventDetailsVC.h"

#import "LIYDateTimePickerViewController.h"
#import "LIYCalendarPickerViewController.h"
#import "PMAPIManager.h"

@interface PMCalendarVC () <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *_tableView;
}
- (IBAction)menuBtnPressed:(id)sender;
- (IBAction)createEventBtnPressed:(id)sender;
@end

@implementation PMCalendarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"MMM. yyy"];
    [self setTitle:@"Calendar"];
    
    [[PMAPIManager shared] getCalendarsWithAccount:[[PMAPIManager shared] namespaceId] comlpetion:^(id data, id error, BOOL success) {
        
    }];
    
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
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

#pragma mark - TableView data source 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *lCell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
    return lCell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PMEventDetailsVC *lDetailEventVC = [[PMEventDetailsVC alloc] initWithStoryboard];
    [self.navigationController pushViewController:lDetailEventVC animated:YES];
}

#pragma mark - IBAction selectors

- (IBAction)menuBtnPressed:(id)sender {
    
}

- (IBAction)createEventBtnPressed:(id)sender {
    PMCreateEventVC *lNewEventVC = [[PMCreateEventVC alloc] initWithStoryboard];
    UINavigationController *lNavContoller = [[UINavigationController alloc] initWithRootViewController:lNewEventVC];
    lNavContoller.navigationBarHidden = YES;
    [lNewEventVC setTitle:@"New Event"];
    [self.tabBarController presentViewController:lNavContoller animated:YES completion:nil];
}


@end
