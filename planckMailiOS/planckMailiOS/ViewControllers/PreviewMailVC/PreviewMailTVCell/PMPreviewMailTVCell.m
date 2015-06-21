//
//  PMPreviewMailTVCell.m
//  planckMailiOS
//
//  Created by admin on 6/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMPreviewMailTVCell.h"



@interface PMPreviewMailTVCell () {
    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet UILabel *_detailLabel;
    __weak IBOutlet PMPreviewContentView *_contentView;
}
@end

@implementation PMPreviewMailTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)updateCellWithInfo:(NSDictionary *)dataInfo {
    [_contentView showDetail:dataInfo[@"body"]];
    _titleLabel.text = dataInfo[@"from"][0][@"name"];
    _detailLabel.text = [NSString stringWithFormat:@"to %@", dataInfo[@"to"][0][@"name"]];
}

- (NSInteger)height {
    return 80 + [_contentView contentHeight];
}

@end
