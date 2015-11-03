//
//  PMFileListViewController.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/24/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PMFileViewCell.h"
#import "PMFileManager.h"
#import "PMFileItem.h"

@interface PMFileListViewController : UIViewController <UITableViewDelegate>

@property BOOL isSelecting;

@property (weak, nonatomic) IBOutlet UITableView *tblFileList;
- (void) setNavigationBar:(NSString*)title;
-(void) showLoadingProgressBar;
-(void) hideLoadingProgressBar;


@end
