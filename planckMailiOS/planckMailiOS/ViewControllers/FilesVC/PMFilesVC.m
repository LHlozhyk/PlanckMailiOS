//
//  PMFilesVC.m
//  planckMailiOS
//
//  Created by admin on 8/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMFilesVC.h"

@interface PMFilesVC () <UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UITableView *_tableView;
    
    NSArray *_itemsArray;
}
@end

@implementation PMFilesVC

- (void)viewDidLoad {
    [super viewDidLoad];

    _itemsArray = @[
                    @{@"icon" : @"dropboxIcon",
                      @"title" : @"Add Your Dropbox Account"},
                    @{@"icon" : @"boxIcon",
                      @"title" : @"Add Your Box Account"},
                    @{@"icon" : @"googleDriveIcon",
                      @"title" : @"Add Your Google Drive Account"},
                    @{@"icon" : @"oneDriveIcon",
                      @"title" : @"Add Your One Drive Account"},
                    ];
    
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

//TODO: don't remove this code
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//    if (localNotif == nil)
//        return;
//    localNotif.fireDate = [[NSDate date] dateByAddingTimeInterval:10];
//    localNotif.timeZone = [NSTimeZone defaultTimeZone];
//    
//    localNotif.alertBody = @"Just fired new local notification";
//    localNotif.alertAction = @"New notification";
//    localNotif.category = @"invite";
//    
//    localNotif.soundName = UILocalNotificationDefaultSoundName;
//    localNotif.applicationIconBadgeNumber = 1;
//    // NSDictionary *infoDict = [NSDictionary dictionaryWithObject:item.eventName forKey:ToDoItemKey];
//    NSDictionary *infoDict = @{@"start time": [NSDate date], @"shifted on seconds": @"10"};
//    localNotif.userInfo = infoDict;
//    
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
//    NSLog(@"scheduledLocalNotifications are %@", [[UIApplication sharedApplication] scheduledLocalNotifications]);
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *lCell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (lCell == nil) {
        lCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    NSDictionary *lData = _itemsArray[indexPath.row];
    
    lCell.imageView.image = [UIImage imageNamed:lData[@"icon"]];
    lCell.textLabel.text = lData[@"title"];
    [lCell.textLabel setMinimumScaleFactor:0.2f];
    
    return lCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
