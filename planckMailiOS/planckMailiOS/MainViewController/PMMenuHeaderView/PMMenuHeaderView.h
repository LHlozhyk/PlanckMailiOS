//
//  PMMenuHeaderView.h
//  planckMailiOS
//
//  Created by admin on 8/31/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMMenuHeaderView;
@protocol PMMenuHeaderViewDelegate <NSObject>
- (void)PMMenuHeaderView:(PMMenuHeaderView *)menuHeaderView selectedState:(BOOL)selected;
@end

@interface PMMenuHeaderView : UIView
@property(nonatomic, copy) NSString *titleName;
@property(nonatomic) BOOL selected;
@property(nonatomic, weak) id<PMMenuHeaderViewDelegate> delegate;
@end
