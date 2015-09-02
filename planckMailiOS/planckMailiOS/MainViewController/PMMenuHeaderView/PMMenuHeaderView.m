//
//  PMMenuHeaderView.m
//  planckMailiOS
//
//  Created by admin on 8/31/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMenuHeaderView.h"

@interface PMMenuHeaderView () {
    IBOutlet UIButton *_itemBtn;
}
- (IBAction)headerBntPressed:(id)sender;
@end

@implementation PMMenuHeaderView

- (void)headerBntPressed:(id)sender {
    UIButton *lItemBtn = (UIButton*)sender;
    if (_delegate && [_delegate respondsToSelector:@selector(PMMenuHeaderView:selectedState:)]) {
        [_delegate PMMenuHeaderView:self selectedState:!lItemBtn.selected];
    }
    lItemBtn.selected = !lItemBtn.selected;
}

- (void)setTitleName:(NSString *)titleName {
    _titleName = titleName;
    [_itemBtn setTitle:titleName forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    _itemBtn.selected = selected;
}

@end
