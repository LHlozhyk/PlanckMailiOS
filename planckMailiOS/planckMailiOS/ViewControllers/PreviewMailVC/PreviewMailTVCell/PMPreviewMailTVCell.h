//
//  PMPreviewMailTVCell.h
//  planckMailiOS
//
//  Created by admin on 6/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMPreviewContentView.h"

@protocol PMAttachmentViewCellDelegate <NSObject>

- (void)didSelectAttachment:(NSDictionary *)file;

@end

@interface PMPreviewMailTVCell : UITableViewCell

@property(nonatomic, weak) id<PMAttachmentViewCellDelegate> delegate;

+ (instancetype)newCell;

- (void)updateCellWithInfo:(NSDictionary *)dataInfo;
- (NSInteger)height;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblFileListHeightConstraint;
@end
