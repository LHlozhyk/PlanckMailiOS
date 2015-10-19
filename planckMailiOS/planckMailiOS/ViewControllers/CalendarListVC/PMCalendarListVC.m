//
//  PMCalendarListVC.m
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 10/18/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMCalendarListVC.h"
#import "PMAPIManager.h"

@interface PMCalendarListVC () <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *_tableView;
}
- (IBAction)closeBtnPressed:(id)sender;

@property(nonatomic, strong) NSArray *items;
@end

@implementation PMCalendarListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _items = [NSArray array];
    
    __weak typeof(self)__self = self;
    [[PMAPIManager shared] getCalendarsWithAccount:[[PMAPIManager shared] namespaceId] comlpetion:^(id data, id error, BOOL success) {
        __self.items = data;
        [_tableView reloadData];
        NSLog(@"getCalendarsWithAccount - %@", data);
    }];
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
    
    NSDictionary *lItemCell = _items[indexPath.row];
    lCell.textLabel.text = lItemCell[@"name"];
    return lCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

@end
