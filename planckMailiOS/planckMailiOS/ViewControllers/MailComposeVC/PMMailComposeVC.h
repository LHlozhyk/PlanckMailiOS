//
//  PMMailComposeVC.h
//  planckMailiOS
//
//  Created by admin on 6/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "UIViewController+PMStoryboard.h"
#import "PMDraftModel.h"

typedef enum {
    PMMailComposeResultCancelled,
    PMMailComposeResultSaved,
    PMMailComposeResultSent,
    PMMailComposeResultFailed
} PMMailComposeResult;

@class PMMailComposeVC;
@protocol PMMailComposeVCDelegate <NSObject>
- (void)PMMailComposeVCDelegate:(PMMailComposeVC *)controller didFinishWithResult:(PMMailComposeResult)result error:(NSError *)error;
@end

@interface PMMailComposeVC : UIViewController
@property(nonatomic, copy) NSString *messageId;
@property(nonatomic, copy) NSString *emails;
@property(nonatomic, retain) PMDraftModel *draft;
@property(nonatomic, weak) id<PMMailComposeVCDelegate> mailComposeDelegate;
@end
