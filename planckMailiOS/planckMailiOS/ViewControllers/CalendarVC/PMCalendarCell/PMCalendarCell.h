//
//  PMCalendarCell.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 9/22/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMEventModel;
@interface PMCalendarCell : UITableViewCell

- (void)setEvent:(PMEventModel *)event;

@end
