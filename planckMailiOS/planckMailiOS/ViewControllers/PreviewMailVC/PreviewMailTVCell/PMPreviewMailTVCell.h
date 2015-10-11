//
//  PMPreviewMailTVCell.h
//  planckMailiOS
//
//  Created by admin on 6/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMPreviewContentView.h"

@interface PMPreviewMailTVCell : UITableViewCell

+ (instancetype)newCell;

- (void)updateCellWithInfo:(NSDictionary *)dataInfo;
- (NSInteger)height;

@end
