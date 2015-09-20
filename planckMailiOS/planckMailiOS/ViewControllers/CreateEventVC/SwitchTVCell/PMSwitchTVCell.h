//
//  PMSwitchTVCell.h
//  planckMailiOS
//
//  Created by admin on 9/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMSwitchTVCell;
@protocol PMSwitchTVCellDelegate <NSObject>
- (void)PMSwitchTVCell:(PMSwitchTVCell*)switchTVCell stateDidChange:(BOOL)state;
@end

@interface PMSwitchTVCell : UITableViewCell {
    IBOutlet UISwitch *allDaySwitch;
}
@property (nonatomic, weak) id<PMSwitchTVCellDelegate> delegate;
@end
