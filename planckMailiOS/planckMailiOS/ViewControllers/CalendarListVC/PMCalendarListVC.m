//
//  PMCalendarListVC.m
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 10/18/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMCalendarListVC.h"
#import "PMAPIManager.h"
#import "DBManager.h"

@interface PMCalendarListVC () <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *_tableView;
}
- (IBAction)closeBtnPressed:(id)sender;

@property(nonatomic, strong) NSArray *items;
@end

@implementation PMCalendarListVC

#pragma mark - PMCalendarListVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _items = [[DBManager instance] getCalendars];
    if (_items.count == 0) {
        __weak typeof(self)__self = self;
        [[PMAPIManager shared] getCalendarsWithAccount:[[PMAPIManager shared] namespaceId] comlpetion:^(id data, id error, BOOL success) {
            
            for (NSDictionary *item in data) {
                
                DBCalendar *lNewCalendar = [DBManager createNewCalendar];
                lNewCalendar.account_id = item[@"account_id"];
                lNewCalendar.name = item[@"name"];
                lNewCalendar.calendarId = item[@"id"];
                lNewCalendar.object = item[@"object"];
                lNewCalendar.readOnly = [item[@"read_only"] boolValue];
                lNewCalendar.accountId = [[PMAPIManager shared] namespaceId];
            }
            [[DBManager instance] save];
            __self.items = [[DBManager instance] getCalendars];
            [_tableView reloadData];
            DLog(@"getCalendarsWithAccount - %@", data);
        }];
    }
    
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction selectors

- (void)closeBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *lCell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (lCell == nil) {
        lCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    DBCalendar *lItemCell = _items[indexPath.row];
    lCell.textLabel.text = [NSString stringWithFormat:@"%@ read - %i", lItemCell.name , lItemCell.readOnly];
    return lCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

@end
