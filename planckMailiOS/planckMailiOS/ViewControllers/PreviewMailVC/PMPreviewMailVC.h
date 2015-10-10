//
//  PMPreviewMailVC.h
//  planckMailiOS
//
//  Created by admin on 6/9/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PMInboxMailModel.h"
#import "UIViewController+PMStoryboard.h"

typedef enum {
    PMPreviewMailVCTypeActionArchive,
    PMPreviewMailVCTypeActionDelete
} PMPreviewMailVCTypeAction;

@protocol PMPreviewMailVCDelegate <NSObject>
- (void)PMPreviewMailVCDelegateAction:(PMPreviewMailVCTypeAction)typeAction mail:(PMInboxMailModel*)model;
@end

@interface PMPreviewMailVC : UIViewController
@property(nonatomic, strong) PMInboxMailModel *inboxMailModel;
@property(nonatomic, strong) NSArray *messages;
@property(nonatomic, weak) id<PMPreviewMailVCDelegate> delegate;

@property(nonatomic, strong) NSArray *inboxMailArray;
@property(nonatomic, assign) NSInteger selectedMailIndex;
@end
