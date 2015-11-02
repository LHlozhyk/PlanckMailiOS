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
#import "NSDate+DateConverter.h"

#import "PMCalendarListVC.h"

#import "PMEventModel.h"
#import "PMAPIManager.h"

#import <JTCalendar/JTCalendar.h>
#import "UITableView+BackgroundText.h"

@interface PMCalendarVC () <UITableViewDelegate, UITableViewDataSource, JTCalendarDelegate, UIGestureRecognizerDelegate, PMEventDetailsVCDelegate> {
    IBOutlet UITableView *_tableView;
    IBOutlet UILabel *_currentMonth;
    
    NSMutableDictionary *_eventsByDate;
    
    NSDate *_todayDate;
    NSDate *_minDate;
    NSDate *_maxDate;
    
    NSDate *_dateSelected;

    NSMutableArray *_dateItemsArray;
    NSMutableDictionary *_section;
    NSArray *_eventSections;
    
    NSInteger _offset;

}
@property (nonatomic, strong) UIButton *todayBtn;
@property (nonatomic, strong) NSMutableArray *eventsArray;

@property (weak, nonatomic) IBOutlet JTHorizontalCalendarView *calendarContentView;
@property (strong, nonatomic) JTCalendarManager *calendarManager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarContentViewHeight;

- (IBAction)menuBtnPressed:(id)sender;
- (IBAction)createEventBtnPressed:(id)sender;
- (IBAction)eventListBtnPressed:(id)sender;
@end

@implementation PMCalendarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _eventsArray = [NSMutableArray new];
    _eventsByDate = [NSMutableDictionary new];
    _section = [NSMutableDictionary new];
    
    [self customizeVC];
    _offset = 0;
    NSDictionary *eventParams = @{
                                  @"starts_after" : [NSString stringWithFormat:@"%f", [self timeStampWithDate:_minDate]],
                                  @"ends_before" : [NSString stringWithFormat:@"%f", [self timeStampWithDate:_maxDate]],
                                  @"expand_recurring" : @"true",
                                  @"limit" : @100,
                                  @"offset" : @(_offset)
                                  };
    __weak typeof(self)__self = self;
    
    [[PMAPIManager shared] getTheadWithAccount:[[PMAPIManager shared] namespaceId] completion:^(id error, BOOL success) {
        
    }];
    
    
    [[PMAPIManager shared] getEventsWithAccount:[[PMAPIManager shared] namespaceId] eventParams:eventParams comlpetion:^(id data, id error, BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __self.eventsArray = data;
            _offset = __self.eventsArray.count;
            // Generate random events sort by date using a dateformatter for the demonstration
            [__self createRandomEvents];
            if (__self.eventsArray.count == 0) {
                [_tableView changeBackroundTextInSearcTVC:YES withMessage:@"Problem with load Calendar events. Please check your internet connection and try again"];
            }
        });
    }];
    
    _todayBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 70, self.view.frame.size.height - 140, 42, 42)];
    [_todayBtn addTarget:self action:@selector(todayBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [_todayBtn setBackgroundImage:[UIImage imageNamed:@"arrowUpIcon"] forState:UIControlStateNormal];
    [_todayBtn setHidden:YES];
    [self.view addSubview:_todayBtn];
}

- (NSTimeInterval)timeStampWithDate:(NSDate*)date {
    return [date timeIntervalSince1970];
}

- (void)todayBtnPressed {
    NSString *key = [[self dateFormatter] stringFromDate:_todayDate];
    if ([_eventSections containsObject:key]) {
        NSUInteger section = [_eventSections indexOfObject:key];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                          atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    [_calendarManager setDate:_todayDate];
    _dateSelected = _todayDate;
    [_calendarManager reload];
    [_todayBtn setHidden:YES];
}

- (void)customizeVC {
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    _calendarManager.settings.weekModeEnabled = YES;
    
    UISwipeGestureRecognizer *swipeUpDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(extendedCalendarContentView)];
    [swipeUpDown setDirection:(UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown)];
    [swipeUpDown setDelegate:self];
    [self.calendarContentView addGestureRecognizer:swipeUpDown];
    
    
    [self createRandomEvents];
    
    // Create a min and max date for limit the calendar, optional
    [self createMinAndMaxDate];
    
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setDate:_todayDate];
}

- (void)extendedCalendarContentView {
    _calendarManager.settings.weekModeEnabled = !_calendarManager.settings.weekModeEnabled;
    [_calendarManager reload];
    
    CGFloat newHeight = 300;
    if(_calendarManager.settings.weekModeEnabled) {
        newHeight = 85.;
    }
    
    self.calendarContentViewHeight.constant = newHeight;
    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - UITapRecodnizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSIndexPath *firstVisibleIndexPath = [[_tableView indexPathsForVisibleRows] objectAtIndex:0];
    NSLog(@"first visible cell's section: %li, row: %li", (long)firstVisibleIndexPath.section, (long)firstVisibleIndexPath.row);
    
    NSDate *lSelectedDate = [[self dateFormatter] dateFromString:_eventSections[firstVisibleIndexPath.section]];
    if (![_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:lSelectedDate] ) {
        [_calendarManager setDate:lSelectedDate];
        _dateSelected = lSelectedDate;
        [_calendarManager reload];
    }
    [self.view bringSubviewToFront:_todayBtn];
    [_todayBtn setHidden:[_dateSelected isEqualToDate:_todayDate]];
    
    if ([_dateSelected compare:_todayDate] == NSOrderedDescending) {
        [_todayBtn setBackgroundImage:[UIImage imageNamed:@"arrowUpIcon"] forState:UIControlStateNormal];
    } else {
        [_todayBtn setBackgroundImage:[UIImage imageNamed:@"arrowDownIcon"] forState:UIControlStateNormal];
    }
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _eventSections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _eventSections[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = _section[_eventSections[section]];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMCalendarCell *lCell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
    
    NSArray *array = _section[_eventSections[indexPath.section]];
    
    [lCell setEvent:array[indexPath.row]];
    return lCell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *array = _section[_eventSections[indexPath.section]];
    PMEventDetailsVC *lDetailEventVC = [[PMEventDetailsVC alloc] initWithEvent:array[indexPath.row] index:indexPath.row];
    [lDetailEventVC setDelegate:self];
    [self.navigationController pushViewController:lDetailEventVC animated:YES];
}

#pragma mark - PMEventDetailsVC delegate 

- (PMEventModel *)PMEventDetailsVCDelegate:(PMEventDetailsVC *)eventDetailsVC eventByIndex:(NSUInteger)eventIndex {
    return _eventsArray[eventIndex];
}

- (NSUInteger)numberOfEventsInEventDetailsVC:(PMEventDetailsVC *)eventDetailsVC {
    return _eventsArray.count;
}

#pragma mark - IBAction selectors

- (IBAction)menuBtnPressed:(id)sender {
    PMCalendarListVC *lCalendarLisctVC = [[PMCalendarListVC alloc] initWithStoryboard];
    [self presentViewController:lCalendarLisctVC animated:YES completion:nil];
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
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView {
    
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"MMM yyy"]; // Date formater
    NSString *date = [dateformate stringFromDate:calendar.date];
    _currentMonth.text = date;
    
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

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView {
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
    
    if (_eventSections.count > 0) {
        NSString *key = [[self dateFormatter] stringFromDate:dayView.date];
        if ([_eventSections containsObject:key]) {
            NSUInteger section = [_eventSections indexOfObject:key];
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                              atScrollPosition:UITableViewScrollPositionTop animated:YES];
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

- (void)createMinAndMaxDate {
    _todayDate = [NSDate date];
    
    // Min date will be 2 month before today
    _minDate = [_calendarManager.dateHelper addToDate:_todayDate months:-3];
    
    // Max date will be 2 month after today
    _maxDate = [_calendarManager.dateHelper addToDate:_todayDate months:12];
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
    
    if(_section[key] && [_section[key] count] > 0){
        return YES;
    }
    
    return NO;
    
}

- (void)createRandomEvents {
    
    for(PMEventModel *event in _eventsArray){
        
        // Generate 30 random dates between now and 60 days later
        NSDate *date = [NSDate date];
        
        switch (event.eventDateType) {
            case EventDateTimeType: {
                date = [NSDate dateWithTimeIntervalSince1970:[event.startTime doubleValue]];
            }
                break;
                
            case EventDateTimespanType: {
                date = [NSDate dateWithTimeIntervalSince1970:[event.startTime doubleValue]];
            }
                
                break;
                
            case EventDateDateType: {
                date = [NSDate eventDateFromString:event.startTime];
            }
                break;
                
            case EventDateDatespanType: {
                date = [NSDate eventDateFromString:event.startTime];
            }
                break;
                
            default:
                break;
        }
        
        // Use the date as key for eventsByDate
        NSString *key = [[self dateFormatter] stringFromDate:date];
        
        if(!_section[key]){
            _section[key] = [NSMutableArray new];
        }
        
        [_section[key] addObject:event];
    }
    
    _eventSections = [_section.allKeys sortedArrayUsingComparator:
                                            ^(id obj1, id obj2) {
                                                NSDate *d1 = [[self dateFormatter] dateFromString:obj1];
                                                NSDate *d2 = [[self dateFormatter] dateFromString:obj2];
                                                
                                                return [d1 compare:d2];
                                            }];
    
    [_tableView reloadData];
    [_calendarManager reload];
    NSString *key = [[self dateFormatter] stringFromDate:_todayDate];
    if ([_eventSections containsObject:key]) {
        NSUInteger section = [_eventSections indexOfObject:key];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                          atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    NSLog(@"_eventsByDate - %@", _section);
}



@end
