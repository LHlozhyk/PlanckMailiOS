//
//  PMAlertViewController.h
//  planckMailiOS
//
//  Created by nazar on 10/19/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PMAlertViewControllerDelegate;

@interface PMAlertViewController : UIViewController

@property (nonatomic, weak) id<PMAlertViewControllerDelegate> delegate;

@end

@protocol PMAlertViewControllerDelegate <NSObject>

-(void)PMAlertViewControllerDissmis:(PMAlertViewController*)viewContorller;

@end
