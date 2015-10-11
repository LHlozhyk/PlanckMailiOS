//
//  PMEventDetailsVC.h
//  planckMailiOS
//
//  Created by admin on 9/20/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMEventModel;
@interface PMEventDetailsVC : UIViewController
- (instancetype)initWithEvent:(PMEventModel *)eventModel;
@end
