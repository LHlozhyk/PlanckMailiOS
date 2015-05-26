//
//  PMMailTVCell.h
//  planckMailiOS
//
//  Created by admin on 5/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMInboxMailModel.h"
@interface PMMailTVCell : UITableViewCell
- (void)updateWithModel:(PMInboxMailModel*)model;
@end
