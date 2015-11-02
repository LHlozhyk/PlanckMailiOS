//
//  PMMailTVCell.m
//  planckMailiOS
//
//  Created by admin on 5/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMailTVCell.h"
#import "NSDate+DateConverter.h"
#import "DBInboxMailModel.h"

@interface PMMailTVCell () {
    __weak IBOutlet UIImageView *_attachedFileImageView;
    __weak IBOutlet UIImageView *_replyImageView;
    __weak IBOutlet UILabel *_personNameLabel;
    __weak IBOutlet UILabel *_titleNameLabel;
    __weak IBOutlet UILabel *descriptionLabel;
    __weak IBOutlet UILabel *timeLabel;
}
@end

@implementation PMMailTVCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)updateWithDBMailInboxModel:(DBInboxMailModel*)model {

    _attachedFileImageView.hidden = YES;
    _replyImageView.hidden = !model.isUnread;
    
    //nsdate *lNewDate = [NSDate dateWithTimeIntervalSince1970:model.]
    
    timeLabel.hidden = YES;
    _personNameLabel.text = model.owner_name;
    _titleNameLabel.text = model.subject;
    descriptionLabel.text = model.snippet;
    
}

- (void)updateWithModel:(PMInboxMailModel *)model {
    _attachedFileImageView.hidden = YES;
    _replyImageView.hidden = !model.isUnread;
    
    //nsdate *lNewDate = [NSDate dateWithTimeIntervalSince1970:model.]
    
    timeLabel.hidden = YES;
    _personNameLabel.text = model.ownerName;
    _titleNameLabel.text = model.subject;
    descriptionLabel.text = model.snippet;
}

@end
