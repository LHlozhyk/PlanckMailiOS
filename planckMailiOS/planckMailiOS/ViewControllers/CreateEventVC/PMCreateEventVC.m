//
//  PMCreateEventTVC.m
//  planckMailiOS
//
//  Created by admin on 9/20/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMCreateEventVC.h"
#import "PickerCells.h"
#import "PMEventModel.h"
#import "PMAPIManager.h"

#import "PMTextFieldTVCell.h"
#import "PMSwitchTVCell.h"

#import "MBProgressHUD.h"

@interface PMCreateEventVC () <PickerCellsDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, PMSwitchTVCellDelegate, PMTextFieldTVCellDelegate> {
    NSArray *_itemArray;
    
    IBOutlet UITableView *_tableiew;
    IBOutlet NSLayoutConstraint *_tableViewTop;
    
    IBOutlet UISwitch *_allDaySwitch;
    IBOutlet UITextField *_titleTF;
    IBOutlet UITextField *_locationTF;
}
@property(nonatomic, strong) PickerCellsController *pickersController;
@property(nonatomic, strong) PMEventModel *eventModel;

- (IBAction)cancelBtnPressed:(id)sender;
- (IBAction)doneBtnPressed:(id)sender;
@end

@implementation PMCreateEventVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _eventModel = [PMEventModel new];
    
    _itemArray = @[
                       @"eventTitleCell",
                       @[@"eventAllDayCell", @"eventStartsCell", @"eventEndsCell"],
                       @"eventAlertCell",
                       @"eventCalendarCell",
                       @"eventLocationCell",
                       @"eventInviteesCell",
                       @"eventNotesCell"
                   ];
    [_tableiew setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    self.pickersController = [PickerCellsController new];
    [self.pickersController attachToTableView:_tableiew tableViewsPriorDelegate:self withDelegate:self];
    
    UIDatePicker *datePicker1 = [[UIDatePicker alloc] init];
    datePicker1.datePickerMode = UIDatePickerModeDate;
    datePicker1.date = [NSDate date];
    NSIndexPath *path1 = [NSIndexPath indexPathForRow:1 inSection:1];
    [self.pickersController addDatePicker:datePicker1 forIndexPath:path1];
    
    UIDatePicker *datePicker2 = [[UIDatePicker alloc] init];
    datePicker2.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker2.date = [NSDate dateWithTimeIntervalSinceNow:1];
    NSIndexPath *path2 = [NSIndexPath indexPathForRow:2 inSection:1];
    [self.pickersController addDatePicker:datePicker2 forIndexPath:path2];
    
    [datePicker1 addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventValueChanged];
    [datePicker2 addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)keyboardWillShow:(NSNotification*)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    _tableViewTop.constant = -keyboardSize.height + 45;
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.view setNeedsLayout];
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    _tableViewTop.constant = 0;
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.view setNeedsLayout];
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)createEvent {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //NSDictionary *lEventParams = [_eventModel getEventParams];
    [[PMAPIManager shared] createCalendarEventWithAccount:[[PMAPIManager shared] namespaceId] eventParams:nil comlpetion:^(id data, id error, BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

#pragma mark - IBAction selectors

- (void)cancelBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneBtnPressed:(id)sender {
   // [self createEvent];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger lCountRows = 1;
    id lItem = _itemArray[section];
    if ([lItem isKindOfClass:[NSArray class]]) {
        lCountRows = ((NSArray*)lItem).count;
    }
    return lCountRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _itemArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat lEstimateHeight = 40;
    
    if (_itemArray.count - 1 == indexPath.section) {
        lEstimateHeight = 90;
    }
    return lEstimateHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *lCellIdentifier = nil;
    id lItem = _itemArray[indexPath.section];
    if ([lItem isKindOfClass:[NSArray class]]) {
        lCellIdentifier = ((NSArray*)lItem)[indexPath.row];
    } else {
        lCellIdentifier = lItem;
    }
    
    UITableViewCell *lCell = [tableView dequeueReusableCellWithIdentifier:lCellIdentifier];
    
    id picker = [self.pickersController pickerForOwnerCellIndexPath:indexPath];
    if (picker) {
        if ([picker isKindOfClass:UIPickerView.class]) {
            
            UIPickerView *pickerView = (UIPickerView *)picker;
            NSInteger selectedRow = [pickerView selectedRowInComponent:0];
            NSString *title = [self pickerView:pickerView titleForRow:selectedRow forComponent:0];
            lCell.detailTextLabel.text = title;
            
        } else if ([picker isKindOfClass:UIDatePicker.class]) {
            
            UIDatePicker *datePicker = (UIDatePicker *)picker;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            if (datePicker.datePickerMode == UIDatePickerModeDate) {
                [dateFormatter setDateFormat:@"dd-MM-yyyy"];
            } else if (datePicker.datePickerMode == UIDatePickerModeDateAndTime) {
                [dateFormatter setDateFormat:@"dd MMM. yyyy HH:mm"];
            } else {
                [dateFormatter setDateFormat:@"HH-mm"];
            }
            lCell.detailTextLabel.text = [dateFormatter stringFromDate:[(UIDatePicker *)picker date]];
        }
    }
    
    if ([lCell.reuseIdentifier isEqualToString:@"eventTitleCell"] || [lCell.reuseIdentifier isEqualToString:@"eventLocationCell"]) {
        [((PMTextFieldTVCell*)lCell) setDelegate:self];
    }
    
    return lCell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIPickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 30;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *text = [NSString stringWithFormat:@"Row number %li", (long)row];
    return text;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSIndexPath *ip = [self.pickersController indexPathForPicker:pickerView];
    if (ip) {
        [_tableiew reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - PickerCells delegate

- (void)pickerCellsController:(PickerCellsController *)controller willExpandTableViewContent:(UITableView *)tableView forHeight:(CGFloat)expandHeight {
    NSLog(@"expand height = %.f", expandHeight);
}

- (void)pickerCellsController:(PickerCellsController *)controller willCollapseTableViewContent:(UITableView *)tableView forHeight:(CGFloat)expandHeight {
    NSLog(@"collapse height = %.f", expandHeight);
}

#pragma mark - Actions

- (void)dateSelected:(UIDatePicker *)sender {
    NSIndexPath *ip = [self.pickersController indexPathForPicker:sender];
    if (ip) {
        [_tableiew reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - PMTextFieldTVCell delegates

- (void)PMTextFieldTVCellDelegate:(PMTextFieldTVCell *)textFieldTVCell textDidChange:(NSString *)text {
    if ([textFieldTVCell.reuseIdentifier isEqualToString:@"eventTitleCell"]) {
        _eventModel.title = text;
    } else if ([textFieldTVCell.reuseIdentifier isEqualToString:@"eventLocationCell"]) {
        _eventModel.location = text;
    }
}

#pragma mark - PMSwitchTVCell delegates

- (void)PMSwitchTVCell:(PMSwitchTVCell *)switchTVCell stateDidChange:(BOOL)state {
    
}

@end
