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
#import "PMCalendarCell.h"

#import "LIYDateTimePickerViewController.h"
#import "LIYCalendarPickerViewController.h"
#import "PMAPIManager.h"

@interface PMCalendarVC () <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *_tableView;
}

@property (nonatomic, strong) NSMutableArray *eventsArray;

- (IBAction)menuBtnPressed:(id)sender;
- (IBAction)createEventBtnPressed:(id)sender;

@end

@implementation PMCalendarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"MMM. yyy"];
    [self setTitle:@"Calendar"];
    
    NSString *lStartTimestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSinceNow]];
    
    
    _eventsArray = [NSMutableArray new];
    
    __weak typeof(self)__self = self;
    [[PMAPIManager shared] getEventsWithAccount:[[PMAPIManager shared] namespaceId] eventParams:nil comlpetion:^(id data, id error, BOOL success) {
        __self.eventsArray = data;
        [_tableView reloadData];
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
    return [_eventsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMCalendarCell *lCell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
    
    [lCell setEvent:_eventsArray[indexPath.row]];
    
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
