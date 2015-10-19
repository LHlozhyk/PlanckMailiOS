//
//  PMEventDetailsVC.h
//  planckMailiOS
//
//  Created by admin on 9/20/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMEventModel;
@class PMEventDetailsVC;

@protocol PMEventDetailsVCDelegate <NSObject>
- (PMEventModel *)PMEventDetailsVCDelegate:(PMEventDetailsVC *)eventDetailsVC eventByIndex:(NSUInteger)eventIndex;
- (NSUInteger)numberOfEventsInEventDetailsVC:(PMEventDetailsVC *)eventDetailsVC;
@end

@interface PMEventDetailsVC : UIViewController
- (instancetype)initWithEvent:(PMEventModel *)eventModel index:(NSUInteger)index;
@property(nonatomic, weak) id<PMEventDetailsVCDelegate> delegate;

@end
