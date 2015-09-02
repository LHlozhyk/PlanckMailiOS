//
//  PMTableViewTabBar.m
//  planckMailiOS
//
//  Created by admin on 9/1/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMTableViewTabBar.h"
#import "Config.h"

@interface PMTableViewTabBar ()

@end

@implementation PMTableViewTabBar

- (void)awakeFromNib {
    [super awakeFromNib];
    _importantMessagesBtn.tintColor = NAVIGATION_BAR_TIN_COLOR;
    _readLaterMessageBtn.tintColor = NAVIGATION_BAR_TIN_COLOR;
//    
//    _line = [[UIView alloc] initWithFrame:CGRectMake(_importantMessagesBtn.frame.origin.x, _importantMessagesBtn.frame.size.height - 4, <#CGFloat width#>, <#CGFloat height#>)]
    
}

- (void)selectMessages:(selectedMessages)messages {
    
    if (messages == ImportantMessagesSelected) {
        [_importantMessagesBtn setSelected:YES];
        [_readLaterMessageBtn setSelected:NO];
    } else {
        [_importantMessagesBtn setSelected:NO];
        [_readLaterMessageBtn setSelected:YES];
    }
    
    SEL selector = @selector(messagesDidSelect:);
    if (_delegate && [_delegate respondsToSelector:selector]) {
        [_delegate messagesDidSelect:messages];

    }
}


- (IBAction)importantBtnTaped:(id)sender {
    [self selectMessages:ImportantMessagesSelected];
}

- (IBAction)readLaterBtnTaped:(id)sender {
    [self selectMessages:ReadLaterMessagesSelected];
}
@end
