//
//  PMAttachmentCell.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/31/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMAttachmentCell.h"
#import "PMFileManager.h"



@implementation PMAttachmentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)bindModel:(NSDictionary *)model
{
    NSString *filename = model[@"filename"];
    NSString *iconName = [PMFileManager IconFileByExt:[filename pathExtension]];
    UIImage *icon = [UIImage imageNamed:iconName];
    
    self.imgIcon.image = icon;
    self.lblFileName.text = filename;
    self.lblFileSize.text = [PMFileManager FileSizeAsString:[model[@"size"] longLongValue]];
}
@end
