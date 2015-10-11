//
//  UITableView+BackgroundText.m
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 10/4/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "UITableView+BackgroundText.h"

@implementation UITableView (BackgroundText)

- (void)changeBackroundTextInSearcTVC:(BOOL)haveResults withMessage:(NSString *)message {
    UILabel *lLabelNoResult = nil;
    for (UIView *subview in self.subviews) {
        if ([subview class] == [UILabel class]) {
            UILabel *lLabelNoResult = (UILabel*)subview;
            if (haveResults == YES) {
                CGRect lLabelFrame = lLabelNoResult.frame;
                lLabelFrame.size.height += 20;
                
                lLabelNoResult.frame = lLabelFrame;
                lLabelNoResult.font = [UIFont systemFontOfSize:17.0f];
                lLabelNoResult.numberOfLines = 0;
                lLabelNoResult.text = message;
            } else if (haveResults == NO) {
                lLabelNoResult.text = @"";
            }
        }
    }
    if (lLabelNoResult == nil) {
        lLabelNoResult = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:lLabelNoResult];
        if (haveResults == YES) {
            lLabelNoResult.font = [UIFont systemFontOfSize:17.0f];
            lLabelNoResult.numberOfLines = 0;
            lLabelNoResult.textColor = [UIColor lightGrayColor];
            lLabelNoResult.textAlignment = NSTextAlignmentCenter;
            lLabelNoResult.text = message;
        } else if (haveResults == NO) {
            lLabelNoResult.text = @"";
        }
    }
}

@end
