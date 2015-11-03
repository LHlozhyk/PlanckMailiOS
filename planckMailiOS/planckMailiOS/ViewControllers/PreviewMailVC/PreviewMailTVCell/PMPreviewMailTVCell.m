//
//  PMPreviewMailTVCell.m
//  planckMailiOS
//
//  Created by admin on 6/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMPreviewMailTVCell.h"
#import "PMAttachmentCell.h"

#define ATTACHMENT_ROW_HEIGHT 40

@interface PMPreviewMailTVCell () <UITableViewDataSource, UITableViewDelegate>{
    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet UILabel *_detailLabel;
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet PMPreviewContentView *_contentView;
    __weak IBOutlet UITableView *tblFileList;
    
    __weak NSArray *files;
}
@end

@implementation PMPreviewMailTVCell

+ (instancetype)newCell {
    NSArray *cellsXIB = [[NSBundle mainBundle] loadNibNamed:@"PMPreviewMailTVCell" owner:nil options:nil];
    PMPreviewMailTVCell *cell = [cellsXIB firstObject];
    
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    tblFileList.dataSource = self;
    tblFileList.delegate = self;
    
    //tblFileList.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    
    
    files = dataInfo[@"files"];
    _tblFileListHeightConstraint.constant = ATTACHMENT_ROW_HEIGHT * files.count;
    
    
}

- (NSInteger)height {
    return 80 + _tblFileListHeightConstraint.constant + [_contentView contentHeight];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ATTACHMENT_ROW_HEIGHT;
}
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMAttachmentCell *cell;
    // Load the top-level objects from the custom cell XIB.
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PMAttachmentCell" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    cell = [topLevelObjects objectAtIndex:0];
    
    NSDictionary *file = files[indexPath.row];
    [cell bindModel:file];
    return cell;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *file = files[indexPath.row];
    
    [_delegate didSelectAttachment:file];
}

@end
