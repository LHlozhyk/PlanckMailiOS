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
    __weak IBOutlet UILabel *_timeLabel;
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
    
    NSTimeInterval interval = [dataInfo[@"date"] doubleValue];
    NSDate *online = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, YYYY 'at' hh:mm aaa"];
    _timeLabel.text = [dateFormatter stringFromDate:online];
    
    [_contentView showDetail:dataInfo[@"body"]];
    _titleLabel.text = dataInfo[@"from"][0][@"name"];
    
    NSString *lToName = dataInfo[@"to"][0][@"name"];
    if ([lToName isEqualToString:@""]) {
        lToName = dataInfo[@"to"][0][@"email"];
    }
    _detailLabel.text = [NSString stringWithFormat:@"To: %@", lToName];
}

- (NSInteger)height {
    return 80 + [_contentView contentHeight];
}

@end
