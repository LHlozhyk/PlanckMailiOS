//
//  UIViewController+PMStoryboard.m
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "UIViewController+PMStoryboard.h"

#define MAIN_STORYBOARD [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]]

@implementation UIViewController (PMStoryboard)

- (instancetype)initWithStoryboard {
    self = [MAIN_STORYBOARD instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    if (self) {
        
    }
    return self;
}

@end
