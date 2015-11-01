//
//  PMAlertViewController.h
//  planckMailiOS
//
//  Created by nazar on 10/19/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMInboxMailModel.h"

@protocol PMAlertViewControllerDelegate;

@interface PMAlertViewController : UIViewController

@property (nonatomic, weak) id<PMAlertViewControllerDelegate> delegate;
@property(nonatomic, strong) PMInboxMailModel *inboxMailModel;

@end

@protocol PMAlertViewControllerDelegate <NSObject>

- (void)PMAlertViewControllerDissmis:(PMAlertViewController*)viewContorller;
- (void)didShoozedMeil:(PMInboxMailModel *)meil;

@end
