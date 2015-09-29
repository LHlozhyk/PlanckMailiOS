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

//#import "LIYDateTimePickerViewController.h"
//#import "LIYCalendarPickerViewController.h"
#import "PMAPIManager.h"

#import <JTCalendar/JTCalendar.h>

@interface PMCalendarVC () <UITableViewDelegate, UITableViewDataSource, JTCalendarDelegate, UIGestureRecognizerDelegate> {
    IBOutlet UITableView *_tableView;
    
    NSMutableDictionary *_eventsByDate;
    
    NSDate *_todayDate;
    NSDate *_minDate;
    NSDate *_maxDate;
    
    NSDate *_dateSelected;
}

@property (nonatomic, strong) NSMutableArray *eventsArray;

@property (weak, nonatomic) IBOutlet JTHorizontalCalendarView *calendarContentView;
@property (strong, nonatomic) JTCalendarManager *calendarManager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarContentViewHeight;

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
    
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    _calendarManager.settings.weekModeEnabled = YES;
    
    UISwipeGestureRecognizer *swipeUpDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(extendedCalendarContentView)];
    [swipeUpDown setDirection:(UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown )];
    [swipeUpDown setDelegate:self];
    
    [_calendarContentView addGestureRecognizer:swipeUpDown];
    
    // Generate random events sort by date using a dateformatter for the demonstration
    [self createRandomEvents];
    
    // Create a min and max date for limit the calendar, optional
    [self createMinAndMaxDate];
    
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setDate:_todayDate];
    
    
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

- (void)extendedCalendarContentView {
    _calendarManager.settings.weekModeEnabled = !_calendarManager.settings.weekModeEnabled;
    [_calendarManager reload];
    
    CGFloat newHeight = 300;
    if(_calendarManager.settings.weekModeEnabled) {
        newHeight = 85.;
    }
    
    self.calendarContentViewHeight.constant = newHeight;
    [self.view layoutIfNeeded];
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

#pragma mark - Private methods

#pragma mark - CalendarManager delegate

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    // Today
    if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor blueColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor colorWithRed:90.0f/255.0f green:196.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor colorWithRed:90.0f/255.0f green:196.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor colorWithRed:90.0f/255.0f green:196.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    if([self haveEventForDay:dayView.date]){
        dayView.dotView.hidden = NO;
    }
    else{
        dayView.dotView.hidden = YES;
    }
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    _dateSelected = dayView.date;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:nil];
    
    
    // Load the previous or next page if touch a day from another month
    
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
}

#pragma mark - CalendarManager delegate - Page mangement

// Used to limit the date for the calendar, optional
- (BOOL)calendar:(JTCalendarManager *)calendar canDisplayPageWithDate:(NSDate *)date
{
    return [_calendarManager.dateHelper date:date isEqualOrAfter:_minDate andEqualOrBefore:_maxDate];
}

- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar
{
    //    NSLog(@"Next page loaded");
}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar
{
    //    NSLog(@"Previous page loaded");
}

#pragma mark - Fake data

- (void)createMinAndMaxDate
{
    _todayDate = [NSDate date];
    
    // Min date will be 2 month before today
    _minDate = [_calendarManager.dateHelper addToDate:_todayDate months:-2];
    
    // Max date will be 2 month after today
    _maxDate = [_calendarManager.dateHelper addToDate:_todayDate months:2];
}

// Used only to have a key for _eventsByDate
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

- (BOOL)haveEventForDay:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(_eventsByDate[key] && [_eventsByDate[key] count] > 0){
        return YES;
    }
    
    return NO;
    
}

- (void)createRandomEvents
{
    _eventsByDate = [NSMutableDictionary new];
    
    for(int i = 0; i < 30; ++i){
        // Generate 30 random dates between now and 60 days later
        NSDate *randomDate = [NSDate dateWithTimeInterval:(rand() % (3600 * 24 * 60)) sinceDate:[NSDate date]];
        
        // Use the date as key for eventsByDate
        NSString *key = [[self dateFormatter] stringFromDate:randomDate];
        
        if(!_eventsByDate[key]){
            _eventsByDate[key] = [NSMutableArray new];
        }
        
        [_eventsByDate[key] addObject:randomDate];
    }
}



@end
